/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-06-10 10:17:13 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-06-10 10:17:13 
 */



`include "ysyx_23060136_DEFINES.sv"


// I-cache module with AXI ctr and sram interface
// protocol: AXI / sarm interface
// ===========================================================================
module ysyx_23060136_IFU_ICACHE (
      // data from pc counter
      input                                             clk                        ,
      input                                             rst                        ,
      
      input              [  `ysyx_23060136_BITS_W-1:0]  IFU1_pc                    ,

      input                                             BRANCH_flushIF             ,
      input                                             BHT_flushIF                ,   
      input                                             FORWARD_stallIF            ,
      // ===========================================================================
      // Arbiter AXI interface 
      input                                             ARBITER_IFU_arready        , 
      output    logic                                   ARBITER_IFU_arvalid        , 
      output    logic   [  31:0]                        ARBITER_IFU_araddr         , 
      output            [   3:0]                        ARBITER_IFU_arid           , 
      output            [   7:0]                        ARBITER_IFU_arlen          , 
      output    logic   [   2:0]                        ARBITER_IFU_arsize         , 
      output            [   1:0]                        ARBITER_IFU_arburst        , 
      output                                            ARBITER_IFU_rready         , 
      input                                             ARBITER_IFU_rvalid         , 
      input             [   1:0]                        ARBITER_IFU_rresp          , 
      input             [  63:0]                        ARBITER_IFU_rdata          , 
      input                                             ARBITER_IFU_rlast          , 
      input             [   3:0]                        ARBITER_IFU_rid            ,

      // ===========================================================================
      // cache interface
      // To do: cache
      output             [   5:0]                       io_sram0_addr              ,             
      output                                            io_sram0_cen               ,             
      output                                            io_sram0_wen               ,             
      output             [ 127:0]                       io_sram0_wmask             ,             
      output             [ 127:0]                       io_sram0_wdata             ,             
      input              [ 127:0]                       io_sram0_rdata             ,

      output             [   5:0]                       io_sram1_addr              ,             
      output                                            io_sram1_cen               ,             
      output                                            io_sram1_wen               ,             
      output             [ 127:0]                       io_sram1_wmask             ,             
      output             [ 127:0]                       io_sram1_wdata             ,             
      input              [ 127:0]                       io_sram1_rdata             ,

      output             [   5:0]                       io_sram2_addr              ,             
      output                                            io_sram2_cen               ,             
      output                                            io_sram2_wen               ,             
      output             [ 127:0]                       io_sram2_wmask             ,             
      output             [ 127:0]                       io_sram2_wdata             ,             
      input              [ 127:0]                       io_sram2_rdata             ,

      output             [   5:0]                       io_sram3_addr              ,             
      output                                            io_sram3_cen               ,             
      output                                            io_sram3_wen               ,             
      output             [ 127:0]                       io_sram3_wmask             ,             
      output             [ 127:0]                       io_sram3_wdata             ,             
      input              [ 127:0]                       io_sram3_rdata             ,
      // ===========================================================================
      // output for the next stage
      output   logic     [  `ysyx_23060136_INST_W-1:0]  IFU_o_inst                 ,
      output   logic                                    inst_valid                 ,
      output   logic                                    IFU_error_signal                                                 
);
    


    // PC值非法检测(only for debug)
    wire                         pc_legal               =  (IFU1_pc >= `ysyx_23060136_MBASE && IFU1_pc < `ysyx_23060136_MEND)  ;

    // 传输地址完成后，我们直接准备接受数据
    assign                       ARBITER_IFU_rready     =  r_state_wait                                            ;
    assign                       ARBITER_IFU_arid       =  'b0                                                     ;
    assign                       ARBITER_IFU_arlen      =  8'b0000_0000                                            ;
    assign                       ARBITER_IFU_arburst    =  2'b00                                                   ;
    
    wire                         r_state_idle           =  (r_state == `ysyx_23060136_idle)                        ;
    wire                         r_state_ready          =  (r_state == `ysyx_23060136_ready)                       ;
    wire                         r_state_wait           =  (r_state == `ysyx_23060136_wait)                        ;
    // state machine
    logic       [1 : 0]          r_state                                                                           ;
    logic       [1 : 0]          r_state_next                                                                      ;

    // AXI higher 32 bits or lower 
    logic                        arbiter_inst_hi                                                                   ;


    // ===========================================================================
    // Two-way set associative I-cache
    // Total cache size: 4KB
    // Block size: 8B(64bits)
    // Group size: 16B
    // Group number: 256
    // Line number: 512
    // ===========================================================================

    // cache state machine
    logic                  c_state                                                                           ;
    logic                  c_state_next                                                                      ;
    wire                   c_state_idle           =  (c_state == `ysyx_23060136_icache_idle)                 ;
    wire                   c_state_hit            =  (c_state == `ysyx_23060136_icache_r_hit)                ;


    // offset in block
    wire    [`ysyx_23060136_cache_offset-1 : 0]       cache_offset   =  r_state_idle ? IFU1_pc[2 : 0]   : ARBITER_IFU_araddr[2 : 0]     ;
    // group id
    wire    [`ysyx_23060136_cache_index-1 : 0]        cache_index    =  r_state_idle ? IFU1_pc[10 : 3]  : ARBITER_IFU_araddr[10 : 3]    ;
    logic   [`ysyx_23060136_cache_index-1 : 0]        cache_index_buf                                                                   ;             
    // tag                    
    wire    [`ysyx_23060136_cache_tag-1 : 0]          cache_tag      =  r_state_idle ? IFU1_pc[31 : 11] : ARBITER_IFU_araddr[31 : 11]   ;

    
    // 2 way associate
    logic   [`ysyx_23060136_cache_tag-1 : 0]          tag_array_1 [`ysyx_23060136_cache_group-1 : 0]                  ;  
    // valid bit
    logic                                             valid_bit_1 [`ysyx_23060136_cache_group-1 : 0]                  ;

    logic   [`ysyx_23060136_cache_tag-1 : 0]          tag_array_2 [`ysyx_23060136_cache_group-1 : 0]                  ;  
    // valid bit
    logic                                             valid_bit_2 [`ysyx_23060136_cache_group-1 : 0]                  ;

    
    // line(block) in group to thrash
    logic   [`ysyx_23060136_cache_group-1 : 0]        thrash                                                        ;                              
    // hit cache line in one group(0/1)
    logic                                             hit_line_id                                                   ;
    logic                                             hit_line_id_buf                                               ;

    // whether the hit occures
    logic                                             cache_hit                                                     ;
    // higher bits or lower in cache(higher 32 bits or lower)
    logic                                             cache_inst_hi                                                 ;

    // MUX for sram output data
    wire [  `ysyx_23060136_INST_W-1:0]                cache_o_inst = {`ysyx_23060136_INST_W{(cache_index_buf[7 : 6] == 2'b00)}}  & (hit_line_id_buf == 1'b1 ? (cache_inst_hi ? io_sram0_rdata[127 : 96] : io_sram0_rdata[95 : 64]) : (cache_inst_hi ? io_sram0_rdata[63 : 32] : io_sram0_rdata[31 : 0])) |
                                                                     {`ysyx_23060136_INST_W{(cache_index_buf[7 : 6] == 2'b01)}}  & (hit_line_id_buf == 1'b1 ? (cache_inst_hi ? io_sram1_rdata[127 : 96] : io_sram1_rdata[95 : 64]) : (cache_inst_hi ? io_sram1_rdata[63 : 32] : io_sram1_rdata[31 : 0])) |
                                                                     {`ysyx_23060136_INST_W{(cache_index_buf[7 : 6] == 2'b10)}}  & (hit_line_id_buf == 1'b1 ? (cache_inst_hi ? io_sram2_rdata[127 : 96] : io_sram2_rdata[95 : 64]) : (cache_inst_hi ? io_sram2_rdata[63 : 32] : io_sram2_rdata[31 : 0])) |
                                                                     {`ysyx_23060136_INST_W{(cache_index_buf[7 : 6] == 2'b11)}}  & (hit_line_id_buf == 1'b1 ? (cache_inst_hi ? io_sram3_rdata[127 : 96] : io_sram3_rdata[95 : 64]) : (cache_inst_hi ? io_sram3_rdata[63 : 32] : io_sram3_rdata[31 : 0])) ;
    

    // ===========================================================================
    // cache interface     
    // addr = group id
    // group 128bits, sram 128bits                                                         
                                                                     
    assign                      io_sram0_addr           =  cache_index[5 : 0]                                                    ;
    assign                      io_sram0_cen            =  ~((cache_index[7 : 6] == 2'b00) & (r_state_idle & c_state_next == `ysyx_23060136_icache_r_hit | r_state_wait))     ;
    assign                      io_sram0_wen            =  ~(r_state_wait & ~io_sram0_cen & r_state_next == `ysyx_23060136_idle) ;
    assign                      io_sram0_wmask          =  {128{(cache_index[7 : 6] == 2'b00)}} & (thrash[cache_index] ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)  : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000)) ;
    assign                      io_sram0_wdata          =  {128{(cache_index[7 : 6] == 2'b00)}} & (thrash[cache_index] ? ({ARBITER_IFU_rdata, 64'b0})  : ({64'b0, ARBITER_IFU_rdata})) ;



    assign                      io_sram1_addr           =  cache_index[5 : 0]                                                     ;
    assign                      io_sram1_cen            =   ~((cache_index[7 : 6] == 2'b01) & (r_state_idle & c_state_next == `ysyx_23060136_icache_r_hit  | r_state_wait))      ;
    assign                      io_sram1_wen            =   ~(r_state_wait & ~io_sram1_cen & r_state_next == `ysyx_23060136_idle)  ;
    assign                      io_sram1_wmask          =  {128{(cache_index[7 : 6] == 2'b01)}} & (thrash[cache_index] ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)  : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000)) ;
    assign                      io_sram1_wdata          =  {128{(cache_index[7 : 6] == 2'b01)}} & (thrash[cache_index] ? ({ARBITER_IFU_rdata, 64'b0})  : ({64'b0, ARBITER_IFU_rdata})) ;



    assign                      io_sram2_addr           =  cache_index[5 : 0]                                                     ;
    assign                      io_sram2_cen            =  ~((cache_index[7 : 6] == 2'b10) & (r_state_idle & c_state_next == `ysyx_23060136_icache_r_hit | r_state_wait))       ;
    assign                      io_sram2_wen            =  ~(r_state_wait & ~io_sram2_cen & r_state_next == `ysyx_23060136_idle)   ;
    assign                      io_sram2_wmask          =  {128{(cache_index[7 : 6] == 2'b10)}} & (thrash[cache_index] ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)  : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000)) ;
    assign                      io_sram2_wdata          =  {128{(cache_index[7 : 6] == 2'b10)}} & (thrash[cache_index] ? ({ARBITER_IFU_rdata, 64'b0})  : ({64'b0, ARBITER_IFU_rdata})) ;



    assign                      io_sram3_addr           =  cache_index[5 : 0]                                                    ;
    assign                      io_sram3_cen            =  ~((cache_index[7 : 6] == 2'b11) & (r_state_idle & c_state_next == `ysyx_23060136_icache_r_hit | r_state_wait))      ;
    assign                      io_sram3_wen            =  ~(r_state_wait & ~io_sram3_cen & r_state_next == `ysyx_23060136_idle) ;
    assign                      io_sram3_wmask          =  {128{(cache_index[7 : 6] == 2'b11)}} & (thrash[cache_index] ? (128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF)  : (128'hFFFF_FFFF_FFFF_FFFF_0000_0000_0000_0000)) ;
    assign                      io_sram3_wdata          =  {128{(cache_index[7 : 6] == 2'b11)}} & (thrash[cache_index] ? ({ARBITER_IFU_rdata, 64'b0})  : ({64'b0, ARBITER_IFU_rdata})) ;


    always_comb begin : c_state_update
        case(c_state)
            `ysyx_23060136_icache_idle: begin
                if(!FORWARD_stallIF & cache_hit & r_state_idle) begin
                    c_state_next = `ysyx_23060136_icache_r_hit;
                end
                else begin
                    c_state_next = `ysyx_23060136_icache_idle;
                end
            end
            `ysyx_23060136_icache_r_hit: begin
                c_state_next = `ysyx_23060136_icache_idle;
            end
            default: c_state_next = `ysyx_23060136_icache_idle;
        endcase
    end

    always_ff @(posedge clk) begin : c_state_machine
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & !FORWARD_stallIF)) begin
            c_state <=  `ysyx_23060136_icache_idle;
        end
        else begin
            c_state <=  c_state_next;
        end
    end

    // logic for juedging hit
    always_comb begin : cache_hit_judge
        cache_hit   = `ysyx_23060136_false;
        hit_line_id = `ysyx_23060136_false;
        if(tag_array_1[cache_index] == cache_tag & valid_bit_1[cache_index] & r_state_idle) begin
            cache_hit    = `ysyx_23060136_true;
            hit_line_id  =  'b0;
        end
        else if(tag_array_2[cache_index] == cache_tag & valid_bit_2[cache_index] & r_state_idle) begin
            cache_hit    = `ysyx_23060136_true;
            hit_line_id  =  'b1;
        end
    end

    // miss and update logic
    integer j;
    always_ff @(posedge clk) begin : updata_tag_array
        if(rst) begin
            for(j = 0; j < `ysyx_23060136_cache_group; j = j + 1) begin
                tag_array_1[j] <= `ysyx_23060136_false;
                valid_bit_1[j] <= `ysyx_23060136_false;
                tag_array_2[j] <= `ysyx_23060136_false;
                valid_bit_2[j] <= `ysyx_23060136_false;
            end
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle) begin
            if(!thrash[cache_index]) begin
                valid_bit_1[cache_index] <= `ysyx_23060136_true;
                tag_array_1[cache_index] <=  cache_tag;
            end
            else begin
                valid_bit_2[cache_index] <= `ysyx_23060136_true;
                tag_array_2[cache_index] <=  cache_tag;
            end
            // $display("thrash index = %d, group: %d", cache_index, thrash[cache_index]);
        end
    end


    always_ff @(posedge clk) begin : cache_valid_update
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & !FORWARD_stallIF)) begin
            cache_inst_hi   <= `ysyx_23060136_false;
            cache_index_buf <= `ysyx_23060136_false;
            hit_line_id_buf <= `ysyx_23060136_false;
        end
        else if(c_state_idle & c_state_next == `ysyx_23060136_icache_r_hit) begin
            cache_inst_hi   <= cache_offset[2];
            cache_index_buf <= cache_index;
            hit_line_id_buf <= hit_line_id;
        end
    end


    always_ff @(posedge clk) begin : update_thrash
        if(rst) begin
            for(j = 0; j < `ysyx_23060136_cache_group; j = j + 1) begin
                thrash[j] <= `ysyx_23060136_false;
            end
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle) begin
             thrash[cache_index] <= ~thrash[cache_index];
        end
    end


    // ===========================================================================
    // AXI process

    always_comb begin : r_state_trans
        // pipeline flow and cache miss
        unique case(r_state)
            `ysyx_23060136_idle: begin
                // raise the read request on AXI 
                if(!FORWARD_stallIF & !cache_hit) begin
                    r_state_next = `ysyx_23060136_ready;
                end
                else begin
                    r_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(ARBITER_IFU_arready & ARBITER_IFU_arvalid) begin
                    r_state_next = `ysyx_23060136_wait;
                end
                else begin
                    r_state_next = `ysyx_23060136_ready;
                end
            end
            `ysyx_23060136_wait: begin
                if(ARBITER_IFU_rvalid & ARBITER_IFU_rready & ARBITER_IFU_rlast) begin
                    r_state_next = `ysyx_23060136_idle;
                end
                else begin
                    r_state_next = `ysyx_23060136_wait;
                end
            end
            default: r_state_next = `ysyx_23060136_idle;
        endcase
    end
    

    always_ff @(posedge clk) begin : state_machine
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & !FORWARD_stallIF)) begin
            r_state <=  `ysyx_23060136_idle;
        end
        else begin
            r_state <=  r_state_next;
        end
    end


    always_ff @(posedge clk) begin : pc_valid
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & !FORWARD_stallIF)) begin
            ARBITER_IFU_arvalid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_IFU_arvalid <=  `ysyx_23060136_true;
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            ARBITER_IFU_arvalid <= `ysyx_23060136_false;  
        end
    end

    always_ff @(posedge clk) begin : addr_update
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & ~FORWARD_stallIF)) begin
            ARBITER_IFU_araddr <= `ysyx_23060136_false;
            ARBITER_IFU_arsize <= `ysyx_23060136_false;
            arbiter_inst_hi    <= `ysyx_23060136_false;
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_IFU_araddr <=  {IFU1_pc[31 : 3], {3{1'b0}}};
            ARBITER_IFU_arsize <=  3'b010;
            arbiter_inst_hi    <=  IFU1_pc[2];
        end
    end

    always_ff @(posedge clk) begin : inst_valid_trans
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & ~FORWARD_stallIF)) begin
            inst_valid <= `ysyx_23060136_true;
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready) || (c_state_idle & c_state_next == `ysyx_23060136_icache_r_hit) ) begin
            inst_valid <=  `ysyx_23060136_false;
        end
        else if(((r_state_next == `ysyx_23060136_idle & r_state_wait) || (c_state_hit & c_state_next == `ysyx_23060136_icache_idle))) begin
            inst_valid <= `ysyx_23060136_true;
        end
    end

    always_ff @(posedge clk) begin : inst_update
        if(rst || ((BRANCH_flushIF | BHT_flushIF) & ~FORWARD_stallIF)) begin
            IFU_o_inst <= `ysyx_23060136_NOP;
        end
        else if((r_state_next == `ysyx_23060136_idle & r_state_wait))begin
            IFU_o_inst <=  arbiter_inst_hi   ?  ARBITER_IFU_rdata[63 : 32] : ARBITER_IFU_rdata[31 : 0] ;
        end
        else if(c_state_hit & c_state_next == `ysyx_23060136_icache_idle) begin
            IFU_o_inst <= cache_o_inst;
        end
    end

    always_ff @(posedge clk) begin : update_respond
        if(rst) begin
            IFU_error_signal  <=  `ysyx_23060136_false;
        end
        else if(ARBITER_IFU_arvalid & !pc_legal) begin
            IFU_error_signal  <=  `ysyx_23060136_true;
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle & !IFU_error_signal) begin
            IFU_error_signal  <=  (ARBITER_IFU_rresp != `ysyx_23060136_OKAY) || (ARBITER_IFU_rid !=  ARBITER_IFU_arid);
        end
    end


`ifdef bench_counter

        logic     [`ysyx_23060136_BITS_W-1 : 0]       icache_miss_counter;
        logic     [`ysyx_23060136_BITS_W-1 : 0]       icache_hit_counter;
        
        // DIP-C in verilog
        import "DPI-C" function void set_icache_miss_counter(input logic [`ysyx_23060136_BITS_W-1 : 0] a []);
        import "DPI-C" function void set_icache_hit_counter(input logic [`ysyx_23060136_BITS_W-1 : 0] a []);

        // set the ptr to register
        initial begin
            set_icache_miss_counter(icache_miss_counter);
            set_icache_hit_counter(icache_hit_counter);
        end

        always_ff @(posedge clk) begin : icache_counter_update
            if(rst) begin
                icache_hit_counter <=  `ysyx_23060136_false;
                icache_miss_counter <=  `ysyx_23060136_false;
            end
            else if(!FORWARD_stallIF & cache_hit & r_state_idle & c_state_idle) begin
                icache_hit_counter  <=  icache_hit_counter + 'h1;
            end
            else if(!FORWARD_stallIF & !cache_hit & r_state_idle & c_state_idle) begin
                icache_miss_counter  <=  icache_miss_counter + 'h1;
            end
        end   
                                                      
`endif

endmodule


