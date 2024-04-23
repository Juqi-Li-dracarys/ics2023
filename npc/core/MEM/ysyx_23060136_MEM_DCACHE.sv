/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-09 21:33:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-18 22:06:19
 */


 `include "ysyx_23060136_DEFINES.sv"


// Interface for arbiter(AXI bus) and cache
// protocol: AXI and cache interface
// ===========================================================================
module ysyx_23060136_MEM_DCACHE (
    input                                                   clk                        ,
    input                                                   rst                        ,
    // for debug
    input              [  `ysyx_23060136_BITS_W-1:0]        pc                         ,
    // ===========================================================================
    // forward unit signal
    input                                                   FORWARD_flushEX            ,
    input                                                   FORWARD_stallME            ,

    // read/write addr
    input              [  `ysyx_23060136_BITS_W-1:0]        MEM_addr                   ,
    // write data
    input              [  `ysyx_23060136_BITS_W-1:0]        MEM_wdata                  ,
    output  logic      [  `ysyx_23060136_BITS_W-1:0]        MEM_o_rdata                ,

    // write/read mode
    input                                                   EXU_o_write_mem            , 
    input                                                   EXU_o_mem_to_reg           ,

    input                                                   EXU_o_mem_byte             , 
    input                                                   EXU_o_mem_half             , 
    input                                                   EXU_o_mem_word             , 
    input                                                   EXU_o_mem_dword            , 
    input                                                   EXU_o_mem_byte_u           , 
    input                                                   EXU_o_mem_half_u           , 
    input                                                   EXU_o_mem_word_u           , 
    // ===========================================================================
    // Interface for arbiter(AXI) 
    input                                                   ARBITER_MEM_arready        , 
    output    logic                                         ARBITER_MEM_arvalid        , 
    output    logic   [  31:0]                              ARBITER_MEM_araddr         , 
    output            [   3:0]                              ARBITER_MEM_arid           , 
    output            [   7:0]                              ARBITER_MEM_arlen          , 
    output    logic   [   2:0]                              ARBITER_MEM_arsize         , 
    output            [   1:0]                              ARBITER_MEM_arburst        , 
    output                                                  ARBITER_MEM_rready         , 
    input                                                   ARBITER_MEM_rvalid         , 
    input             [   1:0]                              ARBITER_MEM_rresp          , 
    input             [  63:0]                              ARBITER_MEM_rdata          , 
    input                                                   ARBITER_MEM_rlast          , 
    input             [   3:0]                              ARBITER_MEM_rid            ,
    // ===========================================================================
    // read interface for clint(AXI-lite)
    input                                                   CLINT_MEM_raddr_ready       ,
    output  logic      [  `ysyx_23060136_BITS_W-1:0]        CLINT_MEM_raddr             ,
    // 这里需要声明读取长度
    output  logic      [   2:0]                             CLINT_MEM_rsize             ,
    output  logic                                           CLINT_MEM_raddr_valid       ,

    input              [  `ysyx_23060136_BITS_W-1:0]        CLINT_MEM_rdata             ,
    input                                                   CLINT_MEM_rdata_valid       ,
    output                                                  CLINT_MEM_rdata_ready       ,
    // ===========================================================================
    // interface for AXI-full write BUS in SoC
    input                                                   io_master_awready            ,
    output  logic                                           io_master_awvalid            ,
    output  logic      [   31:0]                            io_master_awaddr             ,
    output             [   3:0]                             io_master_awid               ,
    output             [   7:0]                             io_master_awlen              ,
    output  logic      [   2:0]                             io_master_awsize             ,
    output             [   1:0]                             io_master_awburst            ,
    input                                                   io_master_wready             ,
    output  logic                                           io_master_wvalid             , 
    output  logic      [  63:0]                             io_master_wdata              ,
    output  logic      [   7:0]                             io_master_wstrb              ,
    output  logic                                           io_master_wlast              ,
    output                                                  io_master_bready             ,
    input                                                   io_master_bvalid             ,
    input              [   1:0]                             io_master_bresp              ,
    input              [   3:0]                             io_master_bid                ,
    // ===========================================================================
    // cache interface
    // To do: cache
    output             [   5:0]                             io_sram4_addr               ,   
    output                                                  io_sram4_cen                ,   
    output                                                  io_sram4_wen                ,   
    output             [ 127:0]                             io_sram4_wmask              ,   
    output             [ 127:0]                             io_sram4_wdata              ,   
    input              [ 127:0]                             io_sram4_rdata              ,
    output             [   5:0]                             io_sram5_addr               ,   
    output                                                  io_sram5_cen                ,   
    output                                                  io_sram5_wen                ,   
    output             [ 127:0]                             io_sram5_wmask              ,   
    output             [ 127:0]                             io_sram5_wdata              ,   
    input              [ 127:0]                             io_sram5_rdata              , 
    output             [   5:0]                             io_sram6_addr               ,
    output                                                  io_sram6_cen                ,   
    output                                                  io_sram6_wen                ,   
    output             [ 127:0]                             io_sram6_wmask              ,   
    output             [ 127:0]                             io_sram6_wdata              ,   
    input              [ 127:0]                             io_sram6_rdata              ,
                  
    output             [   5:0]                             io_sram7_addr               ,   
    output                                                  io_sram7_cen                ,   
    output                                                  io_sram7_wen                ,   
    output             [ 127:0]                             io_sram7_wmask              ,   
    output             [ 127:0]                             io_sram7_wdata              ,   
    input              [ 127:0]                             io_sram7_rdata              ,
    // ===========================================================================    
    // 读写完成信号和异常信号
    output    logic                                         MEM_rvalid                   ,
    output    logic                                         MEM_wdone                    ,
    output    logic                                         MEM_error_signal             
);

    // ===========================================================================
    // read module signal(arbiter)
    assign                              ARBITER_MEM_rready       =  r_state_wait & (is_mmio | is_sdram)  ;
    assign                              CLINT_MEM_rdata_ready    =  r_state_wait & is_clint              ; 

    // write module signal
    assign                              io_master_bready         =  w_state_wait                       ;
    assign                              io_master_awid           =  4'b0                               ;
    assign                              io_master_awlen          =  8'b0000_0000                       ;
    assign                              io_master_awburst        =  2'b00                              ;

    assign                              ARBITER_MEM_arid         =  'b0                                ;
    assign                              ARBITER_MEM_arlen        =  8'b0000_0000                       ;
    assign                              ARBITER_MEM_arburst      =  2'b00                              ;

    // ===========================================================================
    // pre calculate 1
    wire                                 from_clint               =     MEM_addr >= `ysyx_23060136_CLINT_BASE & MEM_addr < `ysyx_23060136_CLINT_END       ;
    wire                                 from_sdram               =     MEM_addr >= `ysyx_23060136_MBASE      & MEM_addr < `ysyx_23060136_MEND            ;
    wire                                 from_mmio                =     MEM_addr >= `ysyx_23060136_MMIOB      & MEM_addr < `ysyx_23060136_MMIOD           ;
     // record the lower 3 bits of addr
    wire [2 : 0]                         bit_start                =     MEM_addr[2 : 0]                                            ;

    wire [7 : 0]                         w_i_strb                 =     ({8{EXU_o_mem_byte}})  & (8'b0000_0001 << MEM_addr[2 : 0]) |
                                                                        ({8{EXU_o_mem_half}})  & (8'b0000_0011 << MEM_addr[2 : 0]) |
                                                                        ({8{EXU_o_mem_word}})  & (8'b0000_1111 << MEM_addr[2 : 0]) |
                                                                        ({8{EXU_o_mem_dword}}) & (8'b1111_1111)                    ;

    // write data after shift
    wire  [63 : 0]                       w_i_data                 =      MEM_wdata << ({MEM_addr[2 : 0], 3'b0});

    // expand to sram mask code
    wire  [63 : 0]                       w_i_strb_expand          =      {{8{w_i_strb[7]}}, {8{w_i_strb[6]}}, {8{w_i_strb[5]}}, {8{w_i_strb[4]}}, {8{w_i_strb[3]}},{8{w_i_strb[2]}},{8{w_i_strb[1]}},{8{w_i_strb[0]}}};

    // ===========================================================================
    // pre buffer 1

    // sdram guest
    logic                                                is_sdram                       ;
    logic                                                is_clint                       ;
    logic                                                is_mmio                        ;

    logic        [2 : 0]                                 bit_start_buffer               ;
    logic                                                MEM_byte_u_buffer              ;
    logic                                                MEM_half_u_buffer              ;
    logic                                                MEM_word_u_buffer              ;
    logic                                                MEM_byte_buffer                ;          
    logic                                                MEM_half_buffer                ;      
    logic                                                MEM_word_buffer                ;      
    logic                                                MEM_dword_buffer               ;
    // used in later
    logic        [  `ysyx_23060136_BITS_W-1:0]           MEM_addr_buffer                ;

    // shift data and mask buffer
    logic        [ `ysyx_23060136_BITS_W-1 : 0]          w_i_data_buffer                ;
    logic        [7 : 0]                                 w_i_strb_buffer                ;

    // ===========================================================================
    // TO DO cache
    // our policy is listed as below:
/*
    ### read cache

    1. 当 CPU 的流水线阻塞信号拉低时，首先判断读写类型，并在这个周期内判断 cache 是否判断是否命中
    2. 如果命中，则进入 hit 状态，短暂阻塞流水线，在一个周期后将 SRAM 的数据写入段寄存器；
    3. 如果未命中，且是需要替换的块是脏块，则立刻**同时**发起总线的读写请求，即执行 write back 
    并读入 SDRAM 的数据到 cache 和段寄存器中，如果不是脏块，则只需要读入 SDRAM 的数据到 cache 和段寄存器中
    
    ### write cache
    
    1. 当 CPU 的流水线阻塞信号拉低时，首先在此周期判断 cache 是否命中和读写类型
    2. 如果成功命中，则在这个周期写入 SDRAM，并不阻塞流水线，比 read cache 操作还少一个周期，dirty 置位
    3. 如果未命中且是要替换的块是脏块，则先暂存需要写入的信息到一个 buffer，进入 WB 状态，立即发起 write back 请求，
    将这个块写回 SDRAM，写回完成后进入 allocate 状态，此时再次发起数据写入请求，将需要写入内存的数据从 buffer 写入 SDRAM，并在同时写入 cache
    
*/

    // 注意，任何从内存加载到 cache 的行为都需要将 dirty 清空，
    // 任何单独写 cache 的行为都需要将 dirty 置位，对于非 SDRAM 的内存空间，cache 要始终判定为 miss

    // cache state machine(read)
    logic     [1 : 0]          cr_state                                                                            ;
    logic     [1 : 0]          cr_state_next                                                                       ;

    wire                       cr_state_idle            =  (cr_state == `ysyx_23060136_dcache_idle)                ;
    wire                       cr_state_hit             =  (cr_state == `ysyx_23060136_dcache_r_hit)               ;
    wire                       cr_state_dirty           =  (cr_state == `ysyx_23060136_dcache_r_dirty)             ;
    wire                       cr_state_miss            =  (cr_state == `ysyx_23060136_dcache_r_miss)              ;

    // cache state machine(write)
    logic    [2 : 0]           cw_state                                                                            ;
    logic    [2 : 0]           cw_state_next                                                                       ;

    wire                       cw_state_idle            =  (cw_state == `ysyx_23060136_dcache_idle)                ;
    wire                       cw_state_dirty           =  (cw_state == `ysyx_23060136_dcache_w_dirty)             ;
    wire                       cw_state_wb              =  (cw_state == `ysyx_23060136_dcache_w_wb)                ;
    wire                       cw_state_al              =  (cw_state == `ysyx_23060136_dcache_w_al)                ;
    wire                       cw_state_lo              =  (cw_state == `ysyx_23060136_dcache_w_lo)                ;


    always_comb begin : cr_state_update
        unique case(cr_state)
            `ysyx_23060136_dcache_idle: begin
                if(!FORWARD_stallME & EXU_o_mem_to_reg) begin
                    if(cr_hit) begin
                        cr_state_next = `ysyx_23060136_dcache_r_hit;
                    end
                    else if(cr_wb) begin
                        cr_state_next = `ysyx_23060136_dcache_r_dirty;
                    end
                    else if(cr_miss) begin
                        cr_state_next = `ysyx_23060136_dcache_r_miss;
                    end
                    else begin 
                        cr_state_next = `ysyx_23060136_dcache_idle; 
                    end
                end
                else begin
                    cr_state_next = `ysyx_23060136_dcache_idle; 
                end
            end

            `ysyx_23060136_dcache_r_hit: begin
                cr_state_next = `ysyx_23060136_dcache_idle;
            end

            `ysyx_23060136_dcache_r_dirty: begin
                cr_state_next = `ysyx_23060136_dcache_r_miss;
            end

            `ysyx_23060136_dcache_r_miss: begin
                // read finish and jump to idle
                // write back might not finish
                if(r_state_next == `ysyx_23060136_idle & r_state_wait)  begin
                    cr_state_next = `ysyx_23060136_dcache_idle;
                end
                else begin
                    cr_state_next = `ysyx_23060136_dcache_r_miss;
                end
            end
            default:cr_state_next = `ysyx_23060136_dcache_idle;
        endcase
    end

    always_ff @(posedge clk) begin : cr_state_machine
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            cr_state <=  `ysyx_23060136_dcache_idle;
        end
        else begin
            cr_state <=  cr_state_next;
        end
    end


    always_comb begin : cw_state_update
        unique case(cw_state)
            `ysyx_23060136_dcache_idle: begin
                if(!FORWARD_stallME & EXU_o_write_mem) begin
                    if(cw_hit) begin
                        cw_state_next = `ysyx_23060136_dcache_idle;
                    end
                    else if(cw_wb) begin
                        cw_state_next = `ysyx_23060136_dcache_w_dirty;
                    end
                    else if(cw_miss) begin
                        cw_state_next = `ysyx_23060136_dcache_w_al;
                    end
                    else begin
                        cw_state_next = `ysyx_23060136_dcache_idle;
                    end
                end
                else begin
                    cw_state_next = `ysyx_23060136_dcache_idle;
                end
            end

            `ysyx_23060136_dcache_w_dirty: begin
                cw_state_next = `ysyx_23060136_dcache_w_wb;
            end

            `ysyx_23060136_dcache_w_wb: begin
                if(w_state_wait & w_state_next == `ysyx_23060136_idle) begin
                    cw_state_next = `ysyx_23060136_dcache_w_al;
                end
                else begin
                    cw_state_next = `ysyx_23060136_dcache_w_wb;
                end
            end

            `ysyx_23060136_dcache_w_al: begin
                if(w_state_wait & w_state_next == `ysyx_23060136_idle) begin
                    if(is_sdram) begin
                        cw_state_next = `ysyx_23060136_dcache_w_lo;
                    end
                    else begin
                        cw_state_next = `ysyx_23060136_dcache_idle;   
                    end 
                end
                else begin
                    cw_state_next = `ysyx_23060136_dcache_w_al;
                end
            end

            `ysyx_23060136_dcache_w_lo: begin
                if(r_state_wait & r_state_next == `ysyx_23060136_idle) begin
                    cw_state_next = `ysyx_23060136_dcache_idle;
                end
                else begin
                    cw_state_next = `ysyx_23060136_dcache_w_lo;
                end
            end
            default: cw_state_next = `ysyx_23060136_dcache_idle;
        endcase
    end

    always_ff @(posedge clk) begin : cw_state_machine
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            cw_state <=  `ysyx_23060136_dcache_idle;
        end
        else begin
            cw_state <=  cw_state_next;
        end
    end



    // offset from AXI or MEM_addr
    // read or write cache      
    // wire    [`ysyx_23060136_cache_offset-1 : 0]       cache_offset   =  {3{cw_state_idle    & cr_state_idle & r_state_idle & w_state_idle}} & MEM_addr[2 : 0]  |
    //                                                                     {3{r_state_wait }}  & ARBITER_MEM_araddr[2 : 0]                                        |
    //                                                                     {3{w_state_ready}}  & io_master_awaddr[2 : 0]                                          ;
    // // group id from AXI or MEM_addr    
    // wire    [`ysyx_23060136_cache_index-1 : 0]        cache_index    =  {8{cw_state_idle    & (cr_state_idle & r_state_idle & w_state_idle)}} & MEM_addr[10 : 3] |
    //                                                                     {8{r_state_wait }}  & ARBITER_MEM_araddr[10 : 3]                                       |
    //                                                                     {8{w_state_ready}}  & io_master_awaddr[10 : 3]                                         ;
    // // tag from AXI or MEM_addr                    
    // wire    [`ysyx_23060136_cache_tag-1 : 0]          cache_tag      =  {21{cw_state_idle    & cr_state_idle & r_state_idle & w_state_idle}} & MEM_addr[31 : 11] |
    //                                                                     {21{r_state_wait }}  & ARBITER_MEM_araddr[31 : 11]                                      |
    //                                                                     {21{w_state_ready}}  & io_master_awaddr[31 : 11]                                        ;

    // ===========================================================================
    // pre calculate 2

    wire    [`ysyx_23060136_cache_offset-1 : 0]       cache_offset   =  MEM_addr[2 : 0]                         ;
    wire    [`ysyx_23060136_cache_index-1 : 0]        cache_index    =  MEM_addr[10 : 3]                        ;
    wire    [`ysyx_23060136_cache_tag-1 : 0]          cache_tag      =  MEM_addr[31 : 11]                       ;
    // start line index of the group
    wire    [8  : 0]                                  group_base     = {cache_index, 1'b0}                      ; 


    // cache read hit
    logic                                             cr_hit                                                    ;
    // read need write back
    logic                                             cr_wb                                                     ;
    logic                                             cr_miss                                                   ;

    // cache write hit
    logic                                             cw_hit                                                    ;
    // write need write back
    logic                                             cw_wb                                                     ;
    logic                                             cw_miss                                                   ;

    
    // every line has the tag
    logic   [`ysyx_23060136_cache_tag-1 : 0]          tag_array [`ysyx_23060136_cache_line-1 : 0]               ;  
    // valid bit
    logic                                             valid_bit [`ysyx_23060136_cache_line-1 : 0]               ;
    // dirty bit
    logic                                             dirty_bit [`ysyx_23060136_cache_line-1 : 0]               ;

    // line in group to thrash
    logic   [`ysyx_23060136_cache_group-1 : 0]        thrash                                                    ;
    wire    [8  : 0]                                  thrash_line =  group_base + {7'b0,thrash[cache_index]}    ;

    // hit cache line in one group(0/1)
    logic                                             hit_line_id                                               ;


    // write back addr(in idle)
    wire    [`ysyx_23060136_cache_index-1 : 0]        dirty_index =  cache_index                                ;
    wire    [  `ysyx_23060136_BITS_W-1:0]             dirty_addr  =  {32'b0, tag_array[thrash_line], dirty_index, 3'b0} ;



    // write back source(dirty state)
    wire    [  `ysyx_23060136_BITS_W-1:0]             dirty_data  =  {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b00)}}  & (thrash[cache_index_buf] ? (io_sram4_rdata[127 : 64]) : (io_sram4_rdata[63 : 0])) |
                                                                     {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b01)}}  & (thrash[cache_index_buf] ? (io_sram5_rdata[127 : 64]) : (io_sram5_rdata[63 : 0])) |
                                                                     {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b10)}}  & (thrash[cache_index_buf] ? (io_sram6_rdata[127 : 64]) : (io_sram6_rdata[63 : 0])) |
                                                                     {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b11)}}  & (thrash[cache_index_buf] ? (io_sram7_rdata[127 : 64]) : (io_sram7_rdata[63 : 0])) ;

    // MEM_output(read hit state)
    wire    [ `ysyx_23060136_BITS_W-1:0]              cache_o_data =  {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b00)}}  & (hit_line_id_buf        ? (io_sram4_rdata[127 : 64]) : (io_sram4_rdata[63 : 0])) |
                                                                      {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b01)}}  & (hit_line_id_buf        ? (io_sram5_rdata[127 : 64]) : (io_sram5_rdata[63 : 0])) |
                                                                      {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b10)}}  & (hit_line_id_buf        ? (io_sram6_rdata[127 : 64]) : (io_sram6_rdata[63 : 0])) |
                                                                      {`ysyx_23060136_BITS_W{(cache_index_buf[7 : 6] == 2'b11)}}  & (hit_line_id_buf        ? (io_sram7_rdata[127 : 64]) : (io_sram7_rdata[63 : 0])) ;


    always_comb begin : cache_pre_state_cal
        cr_hit      = `ysyx_23060136_false;
        cr_wb       = `ysyx_23060136_false;
        cr_miss     = `ysyx_23060136_false;

        cw_hit      = `ysyx_23060136_false;
        cw_wb       = `ysyx_23060136_false;
        cw_miss     = `ysyx_23060136_false;

        hit_line_id = `ysyx_23060136_false;
        
        if(from_sdram & !FORWARD_stallME & !FORWARD_flushEX) begin
            // hit0
            if(tag_array[group_base] == cache_tag & valid_bit[group_base]) begin
                if(EXU_o_mem_to_reg) begin
                    cr_hit       = `ysyx_23060136_true;
                    hit_line_id  =  'b0;
                end
                else if(EXU_o_write_mem) begin
                    cw_hit       = `ysyx_23060136_true;
                    hit_line_id  =  'b0;
                end
            end
            // hit1
            else if(tag_array[group_base + 1] == cache_tag & valid_bit[group_base + 1]) begin
                if(EXU_o_mem_to_reg) begin
                    cr_hit       = `ysyx_23060136_true;
                    hit_line_id  =  'b1;
                end
                else if(EXU_o_write_mem) begin
                    cw_hit       = `ysyx_23060136_true;
                    hit_line_id  =  'b1;
                end
            end
            // write back
            else if(dirty_bit[thrash_line] & valid_bit[thrash_line]) begin
                if(EXU_o_mem_to_reg) begin
                    cr_wb  = `ysyx_23060136_true;
                end
                else if(EXU_o_write_mem) begin
                    cw_wb  = `ysyx_23060136_true;
                end
            end
            // miss
            else begin
                if(EXU_o_mem_to_reg) begin
                    cr_miss  = `ysyx_23060136_true;
                end
                else if(EXU_o_write_mem) begin
                    cw_miss  = `ysyx_23060136_true;
                end
            end
        end
        // mmio
        else if((from_mmio | from_clint) & !FORWARD_stallME & !FORWARD_flushEX) begin
            if(EXU_o_mem_to_reg) begin
                cr_miss       = `ysyx_23060136_true;
            end
            else if(EXU_o_write_mem) begin
                cw_miss       = `ysyx_23060136_true;
            end
        end
    end
        
        
    // ===========================================================================
    // pre buffer 2
    logic        [`ysyx_23060136_cache_index-1 : 0]        cache_index_buf          ;
    logic        [`ysyx_23060136_cache_tag-1 : 0]          cache_tag_buf            ;
    logic        [8  : 0]                                  thrash_line_buf          ;
    logic        [ `ysyx_23060136_BITS_W-1 : 0]            dirty_addr_buffer        ;
    logic                                                  hit_line_id_buf          ;

    // pre_cal -> pre_buffer
    always_ff @(posedge clk) begin : update_buffer
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            is_mmio                     <=   `ysyx_23060136_false;
            is_sdram                    <=   `ysyx_23060136_false;
            is_clint                    <=   `ysyx_23060136_false;

            MEM_addr_buffer             <=   `ysyx_23060136_false;

            MEM_byte_u_buffer           <=   `ysyx_23060136_false; 
            MEM_half_u_buffer           <=   `ysyx_23060136_false; 
            MEM_word_u_buffer           <=   `ysyx_23060136_false; 
            MEM_byte_buffer             <=   `ysyx_23060136_false; 
            MEM_half_buffer             <=   `ysyx_23060136_false; 
            MEM_word_buffer             <=   `ysyx_23060136_false; 
            MEM_dword_buffer            <=   `ysyx_23060136_false;
            bit_start_buffer            <=   `ysyx_23060136_false;

            cache_index_buf             <=   `ysyx_23060136_false;
            hit_line_id_buf             <=   `ysyx_23060136_false;
            cache_tag_buf               <=   `ysyx_23060136_false;
            thrash_line_buf             <=   `ysyx_23060136_false;

            dirty_addr_buffer           <=  `ysyx_23060136_false ;
            w_i_data_buffer             <=  `ysyx_23060136_false ;
            w_i_strb_buffer             <=  `ysyx_23060136_false ;

        end
        else if(~FORWARD_stallME) begin
            is_mmio                   <=    from_mmio        ;
            is_sdram                  <=    from_sdram       ;
            is_clint                  <=    from_clint       ;

            MEM_addr_buffer           <=    MEM_addr         ;
            MEM_byte_u_buffer         <=    EXU_o_mem_byte_u ;   
            MEM_half_u_buffer         <=    EXU_o_mem_half_u ;        
            MEM_word_u_buffer         <=    EXU_o_mem_word_u ;  
            MEM_byte_buffer           <=    EXU_o_mem_byte   ; 
            MEM_half_buffer           <=    EXU_o_mem_half   ; 
            MEM_word_buffer           <=    EXU_o_mem_word   ; 
            MEM_dword_buffer          <=    EXU_o_mem_dword  ; 

            bit_start_buffer          <=   bit_start         ;
            cache_index_buf           <=   cache_index       ;
            cache_tag_buf             <=   cache_tag         ;
            thrash_line_buf           <=   thrash_line       ;
            hit_line_id_buf           <=   hit_line_id       ;
            dirty_addr_buffer         <=   dirty_addr        ;

            w_i_data_buffer           <=   w_i_data          ;
            w_i_strb_buffer           <=   w_i_strb          ;
        end
    end


    integer j;
    always_ff @(posedge clk) begin : updata_tag_array
        if(rst) begin
            for(j = 0; j < `ysyx_23060136_cache_line; j = j + 1) begin
                tag_array[j] <= `ysyx_23060136_false;
                valid_bit[j] <= `ysyx_23060136_false;
                dirty_bit[j] <= `ysyx_23060136_false;
            end
        end
        // miss or dirty
        else if(is_sdram && ((cr_state_miss & cr_state_next == `ysyx_23060136_dcache_idle) | (cw_state_lo & cr_state_next == `ysyx_23060136_dcache_idle))) begin
            valid_bit[thrash_line_buf] <= `ysyx_23060136_true;
            tag_array[thrash_line_buf] <=  cache_tag_buf;
            dirty_bit[thrash_line_buf] <= `ysyx_23060136_false;
        end
        // write hit
        else if(cw_hit) begin
            dirty_bit[group_base + {7'b0, hit_line_id}]  <= `ysyx_23060136_true;
        end
    end


    always_ff @(posedge clk) begin : update_thrash
        if(rst) begin
            for(j = 0; j < `ysyx_23060136_cache_group; j = j + 1) begin
                thrash[j] <= `ysyx_23060136_false;
            end
        end
        else if(is_sdram && ((cr_state_miss & cr_state_next ==  `ysyx_23060136_dcache_idle) || (cw_state_lo & cw_state_next ==  `ysyx_23060136_dcache_idle))) begin
            thrash[cache_index_buf] <= ~thrash[cache_index_buf];
        end
    end


    // ===========================================================================
    // cache interface
    // 128 bits -> group
    assign                     io_sram4_addr           =        (cr_state_idle & cw_state_idle) ? cache_index[5 : 0] : cache_index_buf[5 : 0];

    assign                     io_sram4_cen            =      ~ (((cache_index    [7 : 6] == 2'b00) & (cr_wb | cr_hit | cw_wb | cw_hit)) |
                                                                 ((cache_index_buf[7 : 6] == 2'b00) & ((cr_state_miss & r_state_wait & is_sdram) | (cw_state_lo & r_state_wait & is_sdram))));


    assign                     io_sram4_wen            =      ~(~io_sram4_cen & (cr_state_miss & r_state_wait  & r_state_next == `ysyx_23060136_idle) | 
                                                                                (cw_state_lo   & r_state_wait  & r_state_next == `ysyx_23060136_idle) |
                                                                                (cw_hit)) ;


    assign                     io_sram4_wmask          =       ({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b00}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     | 
                                                                {128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b00}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     |
                                                                {128{cw_hit        & cache_index[7 : 6] == 2'b00}}                          & ((hit_line_id             ? ({~w_i_strb_expand, 64'hFFFF_FFFF_FFFF_FFFF}): ({64'hFFFF_FFFF_FFFF_FFFF, ~w_i_strb_expand}))))      ;


    assign                     io_sram4_wdata          =      (({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b00}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   | 
                                                               ({128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b00}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   |
                                                               ({128{cw_hit & cache_index[7 : 6] == 2'b00}}                                 & (hit_line_id             ? ({w_i_data, 64'b0})           : ({64'b0, w_i_data}))))           ;                                                     
    



    assign                     io_sram5_addr           =        (cr_state_idle & cw_state_idle) ? cache_index[5 : 0] : cache_index_buf[5 : 0];

    assign                     io_sram5_cen            =      ~ (((cache_index    [7 : 6] == 2'b01) & (cr_wb | cr_hit | cw_wb | cw_hit)) |
                                                                 ((cache_index_buf[7 : 6] == 2'b01) & ((cr_state_miss & r_state_wait & is_sdram) | (cw_state_lo & r_state_wait & is_sdram))));


    assign                     io_sram5_wen            =      ~(~io_sram5_cen & (cr_state_miss & r_state_wait  & r_state_next == `ysyx_23060136_idle) | 
                                                                                (cw_state_lo   & r_state_wait  & r_state_next == `ysyx_23060136_idle) |
                                                                                (cw_hit)) ;


    assign                     io_sram5_wmask          =       ({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b01}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     | 
                                                                {128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b01}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     |
                                                                {128{cw_hit        & cache_index[7 : 6] == 2'b01}}                          & ((hit_line_id             ? ({~w_i_strb_expand, 64'hFFFF_FFFF_FFFF_FFFF}): ({64'hFFFF_FFFF_FFFF_FFFF, ~w_i_strb_expand}))))      ;


    assign                     io_sram5_wdata          =      (({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b01}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   | 
                                                               ({128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b01}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   |
                                                               ({128{cw_hit & cache_index[7 : 6] == 2'b01}}                                 & (hit_line_id             ? ({w_i_data, 64'b0})           : ({64'b0, w_i_data}))))           ;                                                     

    
    
    
    

    
    
    assign                     io_sram6_addr           =        (cr_state_idle & cw_state_idle) ? cache_index[5 : 0] : cache_index_buf[5 : 0];

    assign                     io_sram6_cen            =      ~ (((cache_index    [7 : 6] == 2'b10) & (cr_wb | cr_hit | cw_wb | cw_hit)) |
                                                                 ((cache_index_buf[7 : 6] == 2'b10) & ((cr_state_miss & r_state_wait & is_sdram) | (cw_state_lo & r_state_wait & is_sdram))));


    assign                     io_sram6_wen            =      ~(~io_sram6_cen & (cr_state_miss & r_state_wait  & r_state_next == `ysyx_23060136_idle) | 
                                                                                (cw_state_lo   & r_state_wait  & r_state_next == `ysyx_23060136_idle) |
                                                                                (cw_hit)) ;


    assign                     io_sram6_wmask          =       ({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b10}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     | 
                                                                {128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b10}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     |
                                                                {128{cw_hit        & cache_index[7 : 6] == 2'b10}}                          & ((hit_line_id             ? ({~w_i_strb_expand, 64'hFFFF_FFFF_FFFF_FFFF}): ({64'hFFFF_FFFF_FFFF_FFFF, ~w_i_strb_expand}))))      ;


    assign                     io_sram6_wdata          =      (({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b10}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   | 
                                                               ({128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b10}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   |
                                                               ({128{cw_hit & cache_index[7 : 6] == 2'b10}}                                 & (hit_line_id             ? ({w_i_data, 64'b0})           : ({64'b0, w_i_data}))))           ;                                                     
    
    
    
    

    assign                     io_sram7_addr           =        (cr_state_idle & cw_state_idle) ? cache_index[5 : 0] : cache_index_buf[5 : 0];

    assign                     io_sram7_cen            =      ~ (((cache_index    [7 : 6] == 2'b11) & (cr_wb | cr_hit | cw_wb | cw_hit)) |
                                                                 ((cache_index_buf[7 : 6] == 2'b11) & ((cr_state_miss & r_state_wait & is_sdram) | (cw_state_lo & r_state_wait & is_sdram))));


    assign                     io_sram7_wen            =      ~(~io_sram7_cen & (cr_state_miss & r_state_wait  & r_state_next == `ysyx_23060136_idle) | 
                                                                                (cw_state_lo   & r_state_wait  & r_state_next == `ysyx_23060136_idle) |
                                                                                (cw_hit)) ;


    assign                     io_sram7_wmask          =       ({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b11}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     | 
                                                                {128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b11}}      & (thrash[cache_index_buf]  ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF) : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000))     |
                                                                {128{cw_hit        & cache_index[7 : 6] == 2'b11}}                          & ((hit_line_id             ? ({~w_i_strb_expand, 64'hFFFF_FFFF_FFFF_FFFF}): ({64'hFFFF_FFFF_FFFF_FFFF, ~w_i_strb_expand}))))      ;


    assign                     io_sram7_wdata          =      (({128{cr_state_miss & r_state_wait  & cache_index_buf[7 : 6] == 2'b11}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   | 
                                                               ({128{cw_state_lo   & r_state_wait  & cache_index_buf[7 : 6] == 2'b11}}      & (thrash[cache_index_buf] ? ({ARBITER_MEM_rdata, 64'b0})  : ({64'b0, ARBITER_MEM_rdata})))   |
                                                               ({128{cw_hit & cache_index[7 : 6] == 2'b11}}                                 & (hit_line_id             ? ({w_i_data, 64'b0})           : ({64'b0, w_i_data}))))           ;                                                     


    // ===========================================================================
    // debug                                                                                                
    // wire                                        debug_valid_0  =  valid_bit[group_base];
    // wire                                        debug_valid_1  =  valid_bit[group_base + 1];
    // wire                                        debug_thrash_0 =  thrash   [cache_index];
    // wire                                        debug_thrash_1 =  thrash   [cache_index_buf];
    // wire                                        debug_dirty_0  =  dirty_bit[group_base];
    // wire                                        debug_dirty_1  =  dirty_bit[group_base+1];
    // wire   [`ysyx_23060136_cache_tag-1 : 0]     debug_tag_0    =  tag_array[group_base];
    // wire   [`ysyx_23060136_cache_tag-1 : 0]     debug_tag_1    =  tag_array[group_base+1];
    // wire   [`ysyx_23060136_cache_tag-1 : 0]     debug_tag_2    =  tag_array[group_base + {7'b0,thrash[cache_index]}];


    // always_ff @(posedge clk) begin : debug
    //     if(!FORWARD_stallME & !rst) begin
    //         if(MEM_addr == 64'h00000000800009a0 || cache_index == 'h34) begin
    //             if(EXU_o_write_mem) begin
    //                 $display("get @PC=0x%x, cache index=0x%x, addr=0x%x, write", pc, cache_index, MEM_addr);
    //                 if(cw_hit) begin
    //                     $display("hit the cache");
    //                 end
    //                 else if(cw_wb) begin
    //                     $display("miss and write back");
    //                 end
    //                 else begin
    //                     $display("miss the cache");
    //                 end
    //             end
    //             else if(EXU_o_mem_to_reg) begin
    //                 $display("get @PC=0x%x, cache index=0x%x, addr=0x%x, read", pc, cache_index, MEM_addr);
    //                 if(cr_hit) begin
    //                     $display("hit the cache");
    //                 end
    //                 else if(cr_wb) begin
    //                     $display("miss and write back");
    //                 end
    //                 else begin
    //                     $display("miss the cache");
    //                 end
    //             end
    //         end
    //     end
    // end

    
    // ===========================================================================
    // AXI
    // read mater state machine
    logic        [1 : 0]       r_state;
    logic        [1 : 0]       r_state_next;
    wire                       r_state_idle    =  (r_state == `ysyx_23060136_idle);
    wire                       r_state_ready   =  (r_state == `ysyx_23060136_ready);
    wire                       r_state_wait    =  (r_state == `ysyx_23060136_wait);
    

    always_comb begin : r_state_trans
        unique case(r_state)
            `ysyx_23060136_idle: begin
                // cache read miss, raise the read request immediately
                if((cr_miss) | (cr_state_dirty) | (cw_state_lo)) begin
                    r_state_next = `ysyx_23060136_ready;
                end
                else begin
                    r_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(is_mmio | is_sdram) begin
                    if(ARBITER_MEM_arready & ARBITER_MEM_arvalid) begin
                        r_state_next = `ysyx_23060136_wait;
                    end
                    else begin
                        r_state_next = `ysyx_23060136_ready;
                    end
                end
                else begin
                    if(CLINT_MEM_raddr_ready & CLINT_MEM_raddr_valid) begin
                        r_state_next = `ysyx_23060136_wait;
                    end
                    else begin
                        r_state_next = `ysyx_23060136_ready;
                    end
                end
            end
            `ysyx_23060136_wait: begin
                if(is_mmio | is_sdram) begin
                    if(ARBITER_MEM_rready & ARBITER_MEM_rvalid) begin
                        r_state_next = `ysyx_23060136_idle;
                    end
                    else begin
                        r_state_next = `ysyx_23060136_wait;
                    end
                end
                else begin
                    if(CLINT_MEM_rdata_ready & CLINT_MEM_rdata_valid) begin
                        r_state_next = `ysyx_23060136_idle;
                    end
                    else begin
                        r_state_next = `ysyx_23060136_wait;
                    end
                end
            end
            default: r_state_next = `ysyx_23060136_idle;
        endcase
    end

    
    always_ff @(posedge clk) begin : r_state_machine
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            r_state <=  `ysyx_23060136_idle;
        end
        else begin
            r_state <=  r_state_next;
        end
    end


    always_ff @(posedge clk) begin : update_source_read
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin            
            ARBITER_MEM_araddr <= `ysyx_23060136_false;
            ARBITER_MEM_arsize <= `ysyx_23060136_false;
            CLINT_MEM_raddr    <= `ysyx_23060136_PC_RST;                          
            CLINT_MEM_rsize    <= `ysyx_23060136_false; 
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_MEM_araddr <=    (cr_state_idle & cr_state_next == `ysyx_23060136_dcache_r_miss)  ? {MEM_addr[31 : 3], {3{1'b0}}} :  {MEM_addr_buffer[31 : 3], {3{1'b0}}} ;

            ARBITER_MEM_arsize <=    (cr_state_idle & cr_state_next == `ysyx_23060136_dcache_r_miss)  ? 
                                     (({3{EXU_o_mem_byte_u}}) & 3'b000         |   ({3{EXU_o_mem_byte  }}) & 3'b000           |
                                     ({3{EXU_o_mem_half_u}}) & 3'b001          |   ({3{EXU_o_mem_half  }}) & 3'b001           |
                                     ({3{EXU_o_mem_word  }}) & 3'b010          |   ({3{EXU_o_mem_word_u }}) & 3'b010          |
                                     ({3{EXU_o_mem_dword}})  & 3'b011) : 

                                     (({3{MEM_byte_u_buffer}}) & 3'b000        |   ({3{MEM_byte_buffer  }})   & 3'b000          |
                                      ({3{MEM_half_u_buffer}}) & 3'b001        |   ({3{MEM_half_buffer  }})   & 3'b001          |
                                      ({3{MEM_word_buffer  }}) & 3'b010        |   ({3{MEM_word_u_buffer }})  & 3'b010          |
                                      ({3{MEM_dword_buffer}})  & 3'b011);

            // clint read  only
            CLINT_MEM_raddr    <=    MEM_addr; 
            CLINT_MEM_rsize    <=    ({3{EXU_o_mem_byte_u}}) & 3'b000           |   ({3{EXU_o_mem_byte  }}) & 3'b000           |
                                     ({3{EXU_o_mem_half_u}}) & 3'b001           |   ({3{EXU_o_mem_half  }}) & 3'b001           |
                                     ({3{EXU_o_mem_word  }}) & 3'b010           |   ({3{EXU_o_mem_word_u }}) & 3'b010          |
                                     ({3{EXU_o_mem_dword}})  & 3'b011           ;
        end 
    end

    always_ff @(posedge clk) begin : A_raddr_valid
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            ARBITER_MEM_arvalid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            if(cr_miss) begin
                ARBITER_MEM_arvalid <=  (from_mmio | from_sdram) ? `ysyx_23060136_true : ARBITER_MEM_arvalid;
            end
            else begin
                ARBITER_MEM_arvalid <=  (is_mmio | is_sdram) ? `ysyx_23060136_true : ARBITER_MEM_arvalid;
            end
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            ARBITER_MEM_arvalid <= `ysyx_23060136_false;
        end
    end

    // cache read miss
    always_ff @(posedge clk) begin : C_raddr_valid
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            CLINT_MEM_raddr_valid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready & from_clint & cr_state_idle)) begin
            CLINT_MEM_raddr_valid <=  `ysyx_23060136_true;
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            CLINT_MEM_raddr_valid <= `ysyx_23060136_false;
        end
    end


    wire [`ysyx_23060136_BITS_W-1 : 0]  r_abstract   =  (is_clint ?  CLINT_MEM_rdata : ARBITER_MEM_rdata) >> ({bit_start_buffer, 3'b0});
    // cache read hit data
    wire [`ysyx_23060136_BITS_W-1 : 0]  c_abstract   =  cache_o_data >> ({bit_start_buffer, 3'b0});


    always_ff @(posedge clk) begin : rdata_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_o_rdata   <=  `ysyx_23060136_false;
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle & ARBITER_MEM_rlast)begin
            MEM_o_rdata   <=  ({`ysyx_23060136_BITS_W{MEM_byte_u_buffer}})   & r_abstract  & `ysyx_23060136_BITS_W'h0000_0000_0000_00FF   |
                              ({`ysyx_23060136_BITS_W{MEM_half_u_buffer}})   & r_abstract  & `ysyx_23060136_BITS_W'h0000_0000_0000_FFFF   |
                              ({`ysyx_23060136_BITS_W{MEM_word_u_buffer}})   & r_abstract  & `ysyx_23060136_BITS_W'h0000_0000_FFFF_FFFF   |
                              ({`ysyx_23060136_BITS_W{MEM_byte_buffer}})     & ((`ysyx_23060136_BITS_W'h0000_0000_0000_00FF & r_abstract) | {{56{r_abstract[7]}},  {8{1'b0}}})  |
                              ({`ysyx_23060136_BITS_W{MEM_half_buffer}})     & ((`ysyx_23060136_BITS_W'h0000_0000_0000_FFFF & r_abstract) | {{48{r_abstract[15]}}, {16{1'b0}}}) |
                              ({`ysyx_23060136_BITS_W{MEM_word_buffer}})     & ((`ysyx_23060136_BITS_W'h0000_0000_FFFF_FFFF & r_abstract) | {{32{r_abstract[31]}}, {32{1'b0}}}) |
                              ({`ysyx_23060136_BITS_W{MEM_dword_buffer}})    &  r_abstract ;
        end
        // read hit
        else if(cr_state_hit & cr_state_next == `ysyx_23060136_dcache_idle) begin
            MEM_o_rdata  <=  ({`ysyx_23060136_BITS_W{MEM_byte_u_buffer}})   & c_abstract  & `ysyx_23060136_BITS_W'h0000_0000_0000_00FF   |
                             ({`ysyx_23060136_BITS_W{MEM_half_u_buffer}})   & c_abstract  & `ysyx_23060136_BITS_W'h0000_0000_0000_FFFF   |
                             ({`ysyx_23060136_BITS_W{MEM_word_u_buffer}})   & c_abstract  & `ysyx_23060136_BITS_W'h0000_0000_FFFF_FFFF   |
                             ({`ysyx_23060136_BITS_W{MEM_byte_buffer}})     & ((`ysyx_23060136_BITS_W'h0000_0000_0000_00FF & c_abstract) | {{56{c_abstract[7]}},  {8{1'b0}}})  |
                             ({`ysyx_23060136_BITS_W{MEM_half_buffer}})     & ((`ysyx_23060136_BITS_W'h0000_0000_0000_FFFF & c_abstract) | {{48{c_abstract[15]}}, {16{1'b0}}}) |
                             ({`ysyx_23060136_BITS_W{MEM_word_buffer}})     & ((`ysyx_23060136_BITS_W'h0000_0000_FFFF_FFFF & c_abstract) | {{32{c_abstract[31]}}, {32{1'b0}}}) |
                             ({`ysyx_23060136_BITS_W{MEM_dword_buffer}})    &  c_abstract ;
        end 
    end
    
                                                  
    always_ff @(posedge clk) begin : rvalid_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_rvalid <= `ysyx_23060136_true;
        end
        else if((cr_state_idle & cr_state_next == `ysyx_23060136_dcache_r_hit)    || (cr_state_idle & cr_state_next == `ysyx_23060136_dcache_r_dirty) || (cr_state_idle & cr_state_next == `ysyx_23060136_dcache_r_miss) ||
                (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_dirty)  || (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_al)) begin
            MEM_rvalid <= `ysyx_23060136_false;
        end
        else if((cr_state_hit & cr_state_next == `ysyx_23060136_dcache_idle) || (cr_state_miss & cr_state_next == `ysyx_23060136_dcache_idle) || 
                (cw_state_lo  & cw_state_next == `ysyx_23060136_dcache_idle) || (cw_state_al  & cw_state_next == `ysyx_23060136_dcache_idle)) begin
            MEM_rvalid <= `ysyx_23060136_true;
        end
    end
    

    // ===========================================================================
    // write mater state machine in AXI
    /*
        • the master must not wait for the slave to assert AWREADY or WREADY before 
          asserting AWVALID or WVALID 
        • the slave can wait for AWVALID or WVALID, or both, before asserting AWREADY 
        • the slave can wait for AWVALID or WVALID, or both, before asserting WREADY
        • the slave must wait for both WVALID and WREADY to be asserted before asserting 
          BVALID.
    */

    logic        [1 : 0]       w_state;
    logic        [1 : 0]       w_state_next;
    
    wire                       w_state_idle    =  (w_state == `ysyx_23060136_idle);
    wire                       w_state_ready   =  (w_state == `ysyx_23060136_ready);
    wire                       w_state_wait    =  (w_state == `ysyx_23060136_wait);


    always_comb begin : w_state_trans
        // 当 AXI lite 发生握手，将转移到下一个状态
        unique case(w_state)
            `ysyx_23060136_idle: begin
                // 1. write miss not dirty
                // 2. read dirty
                // 3. write dirty and write data
                if((cw_miss) | (cr_state_dirty) | (cw_state_dirty) | (cw_state_al)) begin
                    w_state_next = `ysyx_23060136_ready;
                end
                else begin
                    w_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                    // hand shake over
                    if(!io_master_awvalid & !io_master_wvalid) begin
                        w_state_next = `ysyx_23060136_wait;
                    end
                    else begin
                        w_state_next = `ysyx_23060136_ready;
                    end
            end
            `ysyx_23060136_wait: begin
                if(io_master_bready  & io_master_bvalid) begin
                    w_state_next = `ysyx_23060136_idle;
                end
                else begin
                    w_state_next = `ysyx_23060136_wait;
                end
            end
            default: w_state_next = `ysyx_23060136_idle;
        endcase
    end


    always_ff @(posedge clk) begin : w_state_machine
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            w_state <=  `ysyx_23060136_idle;
        end
        else begin
            w_state <=  w_state_next;
        end
    end

    always_ff @(posedge clk) begin : wvalid_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            io_master_awvalid <= `ysyx_23060136_false;
            io_master_wvalid  <= `ysyx_23060136_false;
            io_master_wlast   <= `ysyx_23060136_false;          
        end
        else if((w_state_idle & w_state_next == `ysyx_23060136_ready)) begin
            io_master_awvalid <=  `ysyx_23060136_true;
            io_master_wvalid  <=  `ysyx_23060136_true;
            io_master_wlast   <=  `ysyx_23060136_true;
        end 
        else if(w_state_ready) begin
            if((io_master_awready)) begin
                io_master_awvalid <= `ysyx_23060136_false;
            end
             if((io_master_wready)) begin
                io_master_wvalid  <= `ysyx_23060136_false;
                io_master_wlast   <= `ysyx_23060136_false; 
            end  
        end
    end

    always_ff @(posedge clk) begin : waddr_config
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            io_master_awaddr  <= `ysyx_23060136_false;
            io_master_wdata   <= `ysyx_23060136_false; 
            io_master_awsize  <= `ysyx_23060136_false; 
            io_master_wstrb   <= `ysyx_23060136_false;
        end
        else if(w_state_idle & w_state_next == `ysyx_23060136_ready) begin
            // dirty addr is align to 64 bits
            io_master_awaddr  <=    (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_al) ? {MEM_addr[31 : 3], {3{1'b0}}} :   
                                    (cw_state_al) ? {MEM_addr_buffer[31 : 3],{3{1'b0}}}
                                    : {dirty_addr_buffer[31 : 3], {3{1'b0}}};
            // 注意字节对齐问题
            io_master_wdata   <=    (cw_state_idle  & cw_state_next == `ysyx_23060136_dcache_w_al) ? w_i_data : 
                                    (cw_state_al) ? w_i_data_buffer : dirty_data;

            io_master_awsize  <=    (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_al) ? 
                                    (({3{EXU_o_mem_byte}}) & 3'b000         |   ({3{EXU_o_mem_half}}) & 3'b001       |
                                    ({3{EXU_o_mem_word}})  & 3'b010         |   ({3{EXU_o_mem_dword}}) & 3'b011)     :  
                                    
                                    ((cw_state_al) ? 
                                    (({3{MEM_byte_buffer}}) & 3'b000         |   ({3{MEM_half_buffer}}) & 3'b001       |
                                    ({3{MEM_word_buffer}})  & 3'b010         |   ({3{MEM_dword_buffer}}) & 3'b011)     : 3'b011)         ;

            io_master_wstrb   <=    (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_al) ? 
                                    w_i_strb : (cw_state_al) ? w_i_strb_buffer : 8'hFF;             
        end
    end


    always_ff @(posedge clk) begin : wdone_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_wdone <= `ysyx_23060136_true;
        end
        else if((cr_state_idle & cr_state_next == `ysyx_23060136_dcache_r_dirty) || (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_dirty) || 
                (cw_state_idle & cw_state_next == `ysyx_23060136_dcache_w_al)) begin
            MEM_wdone <= `ysyx_23060136_false;
        end
        else if((cr_state_miss & cr_state_next == `ysyx_23060136_dcache_idle) || (cw_state_lo & cw_state_next == `ysyx_23060136_dcache_idle) || (cw_state_al  & cw_state_next == `ysyx_23060136_dcache_idle)) begin
            MEM_wdone <= `ysyx_23060136_true;
        end
    end

    always_ff @(posedge clk) begin : error_update
        if(rst) begin
            MEM_error_signal <= `ysyx_23060136_false;
        end
        else if((w_state_wait & w_state_next == `ysyx_23060136_idle)) begin
            MEM_error_signal <= (io_master_bresp != `ysyx_23060136_OKAY) || (io_master_bid != io_master_awid);
        end
        else if((r_state_wait & r_state_next == `ysyx_23060136_idle)) begin
            MEM_error_signal <= (ARBITER_MEM_rresp != `ysyx_23060136_OKAY) || (ARBITER_MEM_rid != ARBITER_MEM_arid);
        end
    end

endmodule



