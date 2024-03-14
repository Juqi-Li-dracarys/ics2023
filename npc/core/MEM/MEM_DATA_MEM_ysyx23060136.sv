/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 17:15:10 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-08 17:12:18
 */

 `include "DEFINES_ysyx23060136.sv"


// interface for main memory
// protocol: Easy AXI-lite and full-AXI

// 注意 64 位数据对齐的问题， bug 在 2023.3.11 修复

// ===========================================================================
module MEM_DATA_MEM_ysyx23060136 (
    input                               clk                        ,
    input                               rst                        ,
    // 每次地址更新时，段寄存器会有一个短脉冲，这会作为读写请求的标志
    input                               MEM_i_raddr_change         ,  
    input                               MEM_i_waddr_change         ,
    // read interface for cpu
    input              [  31:0]         MEM_raddr                  ,
    output             [  31:0]         MEM_rdata                  ,
    // write interface for cpu
    input              [  31:0]         MEM_waddr                  ,
    input              [  31:0]         MEM_wdata                  ,
    // write/read mode
    input                               MEM_mem_byte               ,
    input                               MEM_mem_half               ,
    input                               MEM_mem_word               ,
    input                               MEM_mem_byte_u             ,
    input                               MEM_mem_half_u             ,
    // ===========================================================================
    // read interface for arbiter(AXI-lite) 
    input                               ARBITER_MEM_raddr_ready     ,
    output             [  31:0]         ARBITER_MEM_raddr           ,
    // 这里需要声明读取长度
    output             [   2:0]         ARBITER_MEM_rsize           ,
    output                              ARBITER_MEM_raddr_valid     ,

    input              [  63:0]         ARBITER_MEM_rdata           ,
    input                               ARBITER_MEM_rdata_valid     ,
    output                              ARBITER_MEM_rdata_ready     ,
    // ===========================================================================
    // interface for AXI-full write BUS in SoC
    input                               io_master_awready            ,
    output                              io_master_awvalid            ,
    output             [  31:0]         io_master_awaddr             ,
    output             [   3:0]         io_master_awid               ,
    output             [   7:0]         io_master_awlen              ,
    output             [   2:0]         io_master_awsize             ,
    output             [   1:0]         io_master_awburst            ,
    input                               io_master_wready             ,
    output                              io_master_wvalid             , 
    output             [  63:0]         io_master_wdata              ,
    output             [   7:0]         io_master_wstrb              ,
    output                              io_master_wlast              ,
    output                              io_master_bready             ,
    input                               io_master_bvalid             ,
    input              [   1:0]         io_master_bresp              ,
    input              [   3:0]         io_master_bid                ,
    // ===========================================================================
    // 读写完成信号和异常信号
    output                              MEM_rvalid                   ,
    output                              MEM_wready                   ,
    output    logic                     MEM_error_signal             
);

    // ===========================================================================
    // read module signal
    assign                              ARBITER_MEM_raddr_valid  =  r_state_idle & new_raddr           ;
    assign                              ARBITER_MEM_raddr        =  MEM_raddr                          ;
    assign                              ARBITER_MEM_rdata_ready  =  r_state_busy                       ;
    assign                              ARBITER_MEM_rsize        =  ({3{MEM_mem_byte_u}}) & 3'b000     |
                                                                    ({3{MEM_mem_half_u}}) & 3'b001     |
                                                                    ({3{MEM_mem_word  }}) & 3'b010     |
                                                                    ({3{MEM_mem_byte  }}) & 3'b000     |
                                                                    ({3{MEM_mem_half  }}) & 3'b001     ;

    // write module signal
    assign                              io_master_awvalid        =  w_state_idle & new_waddr           ;
    assign                              io_master_wvalid         =  w_state_idle & new_waddr           ;
    assign                              io_master_wlast          =  io_master_wvalid                   ;

    assign                              io_master_awaddr         =  MEM_waddr                          ;
    assign                              io_master_wdata          =  w_abstract                         ;

    assign                              io_master_awsize         =  ({3{MEM_mem_byte}}) & 3'b000       |
                                                                    ({3{MEM_mem_half}}) & 3'b001       |
                                                                    ({3{MEM_mem_word}}) & 3'b010       ;


    // 注意字节对齐问题
    assign                              io_master_wstrb          =  ({8{MEM_mem_byte}}) & (8'b0000_0001 << io_master_awaddr[2 : 0]) |
                                                                    ({8{MEM_mem_half}}) & (8'b0000_0011 << io_master_awaddr[2 : 0]) |
                                                                    ({8{MEM_mem_word}}) & (8'b0000_1111 << io_master_awaddr[2 : 0]) ;
                                                                    
    assign                              io_master_bready         =  w_state_busy                       ;

    // write configure
    assign                              io_master_awid           =  4'b0                               ;
    assign                              io_master_awlen          =  8'b0000_0000                       ;
    assign                              io_master_awburst        =  2'b00                              ;



    // ===========================================================================
    // 当 raddr 有效且变化时，raddr_change 暂时拉高，下一个周期之后，raddr_change 会保存在 new_raddr 中
    // 当状态机处于 busy 时， new_raddr 会被自动清0

    logic                      new_raddr;
    wire                       new_raddr_next =  (r_state_idle      & ( new_raddr    ? new_raddr : MEM_i_raddr_change)) |
                                                 (r_state_busy      & `false                                          ) ;

    logic                      new_waddr;
    wire                       new_waddr_next =  (w_state_idle      & ( new_waddr    ? new_waddr : MEM_i_waddr_change)) |
                                                 (w_state_busy      & `false                                          ) ;


    // read mater state machine
    logic        [1 : 0]       r_state;
    wire                       r_state_idle   =  (r_state == `idle);
    wire                       r_state_busy   =  (r_state == `busy);
    // 当 AXI lite 发生握手，将转移到下一个状态
    wire         [1 : 0]       r_state_next   =  ({2{r_state_idle}} & ((ARBITER_MEM_raddr_ready & ARBITER_MEM_raddr_valid) ? `busy : `idle)) |
                                                 ({2{r_state_busy}} & ((ARBITER_MEM_rdata_ready & ARBITER_MEM_rdata_valid) ? `idle : `busy)) ;

    // ===========================================================================
    // write mater state machine
    logic        [1 : 0]       w_state;
    wire                       w_state_idle   =  (w_state == `idle);
    wire                       w_state_busy   =  (w_state == `busy);
     // 当 AXI 发生同时握手，将转移到下一个状态
    wire         [1 : 0]       w_state_next   =  ({2{w_state_idle}} & ((io_master_awready & io_master_awvalid & io_master_wready & io_master_wvalid) ?  `busy : `idle)) | 
                                                 ({2{w_state_busy}} & ((io_master_bready  & io_master_bvalid)                                        ?  `idle : `busy)) ;
    
   
    // 32 位 64 位互转（write / read）
    wire     [63 : 0]          w_abstract     =  {32'b0, MEM_wdata} << ({io_master_awaddr[2 : 0], 3'b0})                                                           ;
    wire     [63 : 0]          r_abstract     =  ARBITER_MEM_rdata >> ({ARBITER_MEM_raddr[2 : 0], 3'b0})                                                           ;


    // 处理 AXI 64 位的对齐问题
    assign                     MEM_rdata      = ({32{MEM_mem_byte_u}}) & r_abstract[31 : 0]                    & 32'h0000_00FF                                     |
                                                ({32{MEM_mem_half_u}}) & r_abstract[31 : 0]                    & 32'h0000_FFFF                                     |
                                                ({32{MEM_mem_word}})   & r_abstract[31 : 0]                    & 32'hFFFF_FFFF                                     |
                                                ({32{MEM_mem_byte  }}) & ((32'h0000_00FF & r_abstract[31 : 0]) | {{24{r_abstract[7]}},  {8{1'b0}}})                |
                                                ({32{MEM_mem_half  }}) & ((32'h0000_FFFF & r_abstract[31 : 0]) | {{16{r_abstract[15]}}, {16{1'b0}}})               ;

                            
    // this signal is used for next phase of CPU 
    assign                     MEM_rvalid     =   r_state_idle & ~MEM_i_raddr_change & ~new_raddr;
    assign                     MEM_wready     =   w_state_idle & ~MEM_i_waddr_change & ~new_waddr;

    // ===========================================================================
    // read module
    always_ff @(posedge clk) begin : r_state_machine
        if(rst) begin
            r_state <=  `idle;
        end
        else begin
            r_state <=  r_state_next;
        end
    end

    always_ff @(posedge clk) begin : new_raddr_update
        if(rst) begin
            new_raddr <= `false;
        end
        else begin
            new_raddr <=  new_raddr_next;
        end
    end

    // ===========================================================================
    // write moduel
    always_ff @(posedge clk) begin : w_state_machine
        if(rst) begin
            w_state <=  `idle;
        end
        else begin
            w_state <=  w_state_next;
        end
    end

    always_ff @(posedge clk) begin : new_waddr_update
        if(rst) begin
            new_waddr <= `false;
        end
        else begin
            new_waddr <= new_waddr_next;
        end
    end

    always_ff @(posedge clk) begin : blockName
        if(rst) begin
            MEM_error_signal <= `false;
        end
        else if(io_master_bready & io_master_bvalid) begin
            MEM_error_signal <= (io_master_bresp != `OKAY) || (io_master_bid != io_master_awid);
        end
    end

endmodule



