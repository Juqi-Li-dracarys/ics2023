/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-09 21:33:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-11 16:51:29
 */


 `include "ysyx_23060136_DEFINES.sv"


// interface for DATA memory
// protocol: Easy AXI-lite and full-AXI

// ===========================================================================
module ysyx_23060136_MEM_DATA_MEM (
    input                                                   clk                        ,
    input                                                   rst                        ,
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
    // read interface for arbiter(AXI-lite) 
    input                                                   ARBITER_MEM_raddr_ready     ,
    output  logic      [  `ysyx_23060136_BITS_W-1:0]        ARBITER_MEM_raddr           ,
    // 这里需要声明读取长度
    output  logic      [   2:0]                             ARBITER_MEM_rsize           ,
    output  logic                                           ARBITER_MEM_raddr_valid     ,

    input              [  `ysyx_23060136_BITS_W-1:0]        ARBITER_MEM_rdata           ,
    input                                                   ARBITER_MEM_rdata_valid     ,
    output                                                  ARBITER_MEM_rdata_ready     ,
    // ===========================================================================
    // read interface for clint(AXI-lite)
    input                                                   CLINT_MEM_raddr_ready       ,
    output  logic           [  `ysyx_23060136_BITS_W-1:0]   CLINT_MEM_raddr             ,
    // 这里需要声明读取长度
    output  logic      [   2:0]                             CLINT_MEM_rsize             ,
    output  logic                                           CLINT_MEM_raddr_valid       ,

    input              [  `ysyx_23060136_BITS_W-1:0]        CLINT_MEM_rdata             ,
    input                                                   CLINT_MEM_rdata_valid       ,
    output                                                  CLINT_MEM_rdata_ready       ,

    // ===========================================================================
    // interface for AXI-full write BUS in SoC
    input                                                    io_master_awready            ,
    output  logic                                            io_master_awvalid            ,
    output  logic      [   31:0]                             io_master_awaddr             ,
    output             [   3:0]                              io_master_awid               ,
    output             [   7:0]                              io_master_awlen              ,
    output  logic      [   2:0]                              io_master_awsize             ,
    output             [   1:0]                              io_master_awburst            ,
    input                                                    io_master_wready             ,
    output  logic                                            io_master_wvalid             , 
    output  logic      [  63:0]                              io_master_wdata              ,
    output  logic      [   7:0]                              io_master_wstrb              ,
    output  logic                                            io_master_wlast              ,
    output                                                   io_master_bready             ,
    input                                                    io_master_bvalid             ,
    input              [   1:0]                              io_master_bresp              ,
    input              [   3:0]                              io_master_bid                ,
    // ===========================================================================
    // 读写完成信号和异常信号
    output    logic                                          MEM_rvalid                   ,
    output    logic                                          MEM_wdone                    ,
    output    logic                                          MEM_error_signal             
);

    // ===========================================================================
    // read module signal(arbiter)
    assign                              ARBITER_MEM_rdata_ready  =  r_state_wait & is_mem              ;
    assign                              CLINT_MEM_rdata_ready    =  r_state_wait & !is_mem             ; 

    // write module signal
    assign                              io_master_bready         =  w_state_wait                       ;
    assign                              io_master_awid           =  4'b0                               ;
    assign                              io_master_awlen          =  8'b0000_0000                       ;
    assign                              io_master_awburst        =  2'b00                              ;

    // ===========================================================================
    wire                       cache_hit      =  `ysyx_23060136_false;
    // ===========================================================================


    // read mater state machine
    logic        [1 : 0]       r_state;
    logic        [1 : 0]       r_state_next;
    wire                       r_state_idle    =  (r_state == `ysyx_23060136_idle);
    wire                       r_state_ready   =  (r_state == `ysyx_23060136_ready);
    wire                       r_state_wait    =  (r_state == `ysyx_23060136_wait);

    // read state
    wire                       from_mem        =  `ysyx_23060136_true;
    logic                      is_mem           ;
    logic                      MEM_mem_byte_u   ;
    logic                      MEM_mem_half_u   ;
    logic                      MEM_mem_word_u   ;
    logic                      MEM_mem_byte     ;          
    logic                      MEM_mem_half     ;      
    logic                      MEM_mem_word     ;      
    logic                      MEM_mem_dword    ;                  


    always_comb begin : r_state_trans
        // 当 AXI lite 发生握手，将转移到下一个状态
        unique case(r_state)
            `ysyx_23060136_idle: begin
                if(!FORWARD_stallME & !cache_hit & EXU_o_mem_to_reg) begin
                    r_state_next = `ysyx_23060136_ready;
                end
                else begin
                    r_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(is_mem) begin
                    if(ARBITER_MEM_raddr_ready & ARBITER_MEM_raddr_valid) begin
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
                if(is_mem) begin
                    if(ARBITER_MEM_rdata_ready & ARBITER_MEM_rdata_valid) begin
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
            is_mem         <=   `ysyx_23060136_false;
            MEM_mem_byte_u <=   `ysyx_23060136_false; 
            MEM_mem_half_u <=   `ysyx_23060136_false; 
            MEM_mem_word_u <=   `ysyx_23060136_false; 
            MEM_mem_byte   <=   `ysyx_23060136_false; 
            MEM_mem_half   <=   `ysyx_23060136_false; 
            MEM_mem_word   <=   `ysyx_23060136_false; 
            MEM_mem_dword  <=   `ysyx_23060136_false;  
            
            ARBITER_MEM_raddr <= `ysyx_23060136_PC_RST;
            ARBITER_MEM_rsize <= `ysyx_23060136_false;
            CLINT_MEM_raddr   <= `ysyx_23060136_PC_RST;                          
            CLINT_MEM_rsize   <= `ysyx_23060136_false; 
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            is_mem         <=    from_mem;
            MEM_mem_byte_u <=    EXU_o_mem_byte_u ;   
            MEM_mem_half_u <=    EXU_o_mem_half_u ;        
            MEM_mem_word_u <=    EXU_o_mem_word_u ;  
            MEM_mem_byte   <=    EXU_o_mem_byte   ; 
            MEM_mem_half   <=    EXU_o_mem_half   ; 
            MEM_mem_word   <=    EXU_o_mem_word   ; 
            MEM_mem_dword  <=    EXU_o_mem_dword  ; 
            ARBITER_MEM_raddr <=  MEM_addr;
            ARBITER_MEM_rsize <=    ({3{MEM_mem_byte_u}}) & 3'b000           |   ({3{MEM_mem_byte  }}) & 3'b000           |
                                    ({3{MEM_mem_half_u}}) & 3'b001           |   ({3{MEM_mem_half  }}) & 3'b001           |
                                    ({3{MEM_mem_word  }}) & 3'b010           |   ({3{MEM_mem_word_u }}) & 3'b010          |
                                    ({3{MEM_mem_dword}})  & 3'b011           ;
            CLINT_MEM_raddr   <=  MEM_addr; 
            CLINT_MEM_rsize   <=    ({3{MEM_mem_byte_u}}) & 3'b000           |   ({3{MEM_mem_byte  }}) & 3'b000           |
                                    ({3{MEM_mem_half_u}}) & 3'b001           |   ({3{MEM_mem_half  }}) & 3'b001           |
                                    ({3{MEM_mem_word  }}) & 3'b010           |   ({3{MEM_mem_word_u }}) & 3'b010          |
                                    ({3{MEM_mem_dword}})  & 3'b011           ; 
        end 
    end

    always_ff @(posedge clk) begin : A_raddr_valid
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            ARBITER_MEM_raddr_valid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready & from_mem)) begin
            ARBITER_MEM_raddr_valid <=  `ysyx_23060136_true;
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            ARBITER_MEM_raddr_valid <= `ysyx_23060136_false;
        end
    end

    always_ff @(posedge clk) begin : C_raddr_valid
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            CLINT_MEM_raddr_valid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready & !from_mem)) begin
            CLINT_MEM_raddr_valid <=  `ysyx_23060136_true;
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            CLINT_MEM_raddr_valid <= `ysyx_23060136_false;
        end
    end

    wire [`ysyx_23060136_BITS_W-1 : 0]  r_abstract  =  (is_mem ? ARBITER_MEM_rdata : CLINT_MEM_rdata) >> ({ARBITER_MEM_raddr[2 : 0], 3'b0});

    always_ff @(posedge clk) begin : rdata_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_o_rdata   <=  `ysyx_23060136_false;
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle)begin
            MEM_o_rdata   <=  ({`ysyx_23060136_BITS_W{MEM_mem_byte_u}}) & r_abstract  & `ysyx_23060136_BITS_W'h0000_0000_0000_00FF   |
                              ({`ysyx_23060136_BITS_W{MEM_mem_half_u}})   & r_abstract  & `ysyx_23060136_BITS_W'h0000_0000_0000_FFFF   |
                              ({`ysyx_23060136_BITS_W{MEM_mem_word_u}})   & r_abstract  & `ysyx_23060136_BITS_W'h0000_0000_FFFF_FFFF   |
                              ({`ysyx_23060136_BITS_W{MEM_mem_byte  }})   & ((`ysyx_23060136_BITS_W'h0000_0000_0000_00FF & r_abstract) | {{56{r_abstract[7]}},  {8{1'b0}}})  |
                              ({`ysyx_23060136_BITS_W{MEM_mem_half  }})   & ((`ysyx_23060136_BITS_W'h0000_0000_0000_FFFF & r_abstract) | {{48{r_abstract[15]}}, {16{1'b0}}}) |
                              ({`ysyx_23060136_BITS_W{MEM_mem_word}})     & ((`ysyx_23060136_BITS_W'h0000_0000_FFFF_FFFF & r_abstract) | {{32{r_abstract[31]}}, {32{1'b0}}}) |
                              ({`ysyx_23060136_BITS_W{MEM_mem_dword}})    &  r_abstract ;
        end 
    end
    
                                                
    always_ff @(posedge clk) begin : rvalid_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_rvalid <= `ysyx_23060136_true;
        end
        else if(r_state_idle & r_state_next == `ysyx_23060136_ready) begin
            MEM_rvalid <= `ysyx_23060136_false;
        end
        else if(r_state_wait & r_state_next == `ysyx_23060136_idle)begin
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
                if(!FORWARD_stallME & !cache_hit & EXU_o_write_mem) begin
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
            if((io_master_awready))begin
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
            io_master_awaddr  <=    {MEM_addr[31 : 3], {3{1'b0}}};
            // 注意字节对齐问题
            io_master_wdata   <=    MEM_wdata << ({MEM_addr[2 : 0], 3'b0});

            io_master_awsize  <=    ({3{EXU_o_mem_byte}}) & 3'b000         |   ({3{EXU_o_mem_half}}) & 3'b001             |
                                    ({3{EXU_o_mem_word}}) & 3'b010         |   ({3{EXU_o_mem_dword}}) & 3'b011            ;

            io_master_wstrb   <=    ({8{EXU_o_mem_byte}}) & (8'b0000_0001 << MEM_addr[2 : 0]) |
                                    ({8{EXU_o_mem_half}}) & (8'b0000_0011 << MEM_addr[2 : 0]) |
                                    ({8{EXU_o_mem_word}}) & (8'b0000_1111 << MEM_addr[2 : 0]) |
                                    ({8{EXU_o_mem_dword}}) & (8'b1111_1111)                    ;
        end
    end


    always_ff @(posedge clk) begin : error_update
        if(rst) begin
            MEM_error_signal <= `ysyx_23060136_false;
        end
        else if(w_state_wait & w_state_next == `ysyx_23060136_idle) begin
            MEM_error_signal <= (io_master_bresp != `ysyx_23060136_OKAY) || (io_master_bid != io_master_awid);
        end
    end

    always_ff @(posedge clk) begin : wdone_update
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_wdone <= `ysyx_23060136_true;
        end
        else if(w_state_idle & w_state_next == `ysyx_23060136_ready) begin
            MEM_wdone <= `ysyx_23060136_false;
        end
        else if(w_state_wait & w_state_next == `ysyx_23060136_idle)begin
            MEM_wdone <= `ysyx_23060136_true;
        end
    end

endmodule



