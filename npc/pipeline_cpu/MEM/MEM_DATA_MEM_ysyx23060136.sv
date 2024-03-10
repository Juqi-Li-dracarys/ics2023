/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 17:15:10 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-04 21:55:37
 */

 `include "DEFINES_ysyx23060136.sv"

 /* verilator lint_off UNUSED */

// interface for main memory
// protocol: AXI-lite
// ===========================================================================
module MEM_DATA_MEM_ysyx23060136 (
    input                               clk                        ,
    input                               rst                        ,
    // 每次地址更新时，会有一个短脉冲
    input                               MEM_i_raddr_change         ,  
    input                               MEM_i_waddr_change         ,
    // read
    input              [  31:0]         MEM_raddr                  ,
    output             [  31:0]         MEM_rdata                  ,
    // write
    input              [  31:0]         MEM_waddr                  ,
    input              [  31:0]         MEM_wdata                  ,
    input                               MEM_write_mem              ,
    // write mode
    input                               MEM_mem_byte               ,
    input                               MEM_mem_half               ,
    input                               MEM_mem_word               ,
    input                               MEM_mem_byte_u             ,
    input                               MEM_mem_half_u             ,
    // ===========================================================================
    // interface for arbiter(read)
    input                               ARBITER_MEM_raddr_ready     ,
    output             [  31:0]         ARBITER_MEM_raddr           ,
    output                              ARBITER_MEM_raddr_valid     ,

    input              [  31:0]         ARBITER_MEM_rdata           ,
    input                               ARBITER_MEM_rdata_valid     ,
    output                              ARBITER_MEM_rdata_ready     ,
    // ===========================================================================
    // interface for xbar(write)
    input                               XBAR_MEM_waddr_ready        ,
    output             [  31:0]         XBAR_MEM_waddr              ,
    output             [   3:0]         XBAR_MEM_wstrb              ,
    output                              XBAR_MEM_waddr_valid        ,

    input                               XBAR_MEM_wdata_ready        ,
    output             [  31:0]         XBAR_MEM_wdata              ,
    output                              XBAR_MEM_wdata_valid        ,
    
    input              [   1:0]         XBAR_MEM_bresp              ,
    input                               XBAR_MEM_bvalid             ,
    output                              XBAR_MEM_bready             ,
    // ===========================================================================
    // 读写完成信号
    output                              MEM_rvalid                  ,
    output                              MEM_wready                  
);

    // ===========================================================================
    // read module signal
    assign                              ARBITER_MEM_raddr_valid  =  r_state_idle & new_raddr      ;
    assign                              ARBITER_MEM_raddr        =  MEM_raddr                     ;
    assign                              ARBITER_MEM_rdata_ready  =  r_state_busy                  ;

    // write module signal 
    assign                              XBAR_MEM_waddr_valid     =  w_state_idle & new_waddr      ;
    assign                              XBAR_MEM_wdata_valid     =  MEM_write_mem & w_state_busy  ;
    assign                              XBAR_MEM_waddr           =  MEM_waddr                     ;
    assign                              XBAR_MEM_wdata           =  MEM_wdata                     ;
    assign                              XBAR_MEM_wstrb           =  ({4{MEM_mem_byte}}) & 4'b0001 |
                                                                    ({4{MEM_mem_half}}) & 4'b0011 |
                                                                    ({4{MEM_mem_word}}) & 4'b1111 ;

    // response signal
    assign                              XBAR_MEM_bready          =  w_state_done                  ;



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

    
    // write mater state machine
    logic        [1 : 0]       w_state;
    wire                       w_state_idle   =  (w_state == `idle);
    wire                       w_state_busy   =  (w_state == `busy);
    wire                       w_state_done   =  (w_state == `done);
     // 当 AXI lite 发生握手，将转移到下一个状态
    wire         [1 : 0]       w_state_next   = ({2{w_state_idle}} & ((XBAR_MEM_waddr_ready & XBAR_MEM_waddr_valid)  ?  `busy : `idle)) | 
                                                ({2{w_state_busy}} & ((XBAR_MEM_wdata_ready & XBAR_MEM_wdata_valid)  ?  `done : `busy)) |
                                                ({2{w_state_done}} & ((XBAR_MEM_bready      & XBAR_MEM_bvalid)       ?  `idle : `done)) ;
 
    

    // bit 提取和符号拓展
    wire         [31 : 0]     byte_rdata      =   (ARBITER_MEM_rdata & 32'h0000_00FF)                                        ;
    wire         [31 : 0]     half_rdata      =   (ARBITER_MEM_rdata & 32'h0000_FFFF)                                        ;
    wire         [31 : 0]     word_rdata      =    ARBITER_MEM_rdata                                                         ;

    assign                    MEM_rdata       =   ({32{MEM_mem_byte_u}}) & byte_rdata                                        |
                                                  ({32{MEM_mem_half_u}}) & half_rdata                                        |
                                                  ({32{MEM_mem_word  }}) & word_rdata                                        |
                                                  ({32{MEM_mem_byte  }}) & (byte_rdata | {{24{byte_rdata[7]}},  {8{1'b0}}})  |
                                                  ({32{MEM_mem_half  }}) & (half_rdata | {{16{half_rdata[15]}}, {16{1'b0}}}) ;

                            
    // this signal is used for next phase of CPU 
    assign                   MEM_rvalid       =   r_state_idle & ~MEM_i_raddr_change & ~new_raddr;
    assign                   MEM_wready       =   w_state_idle & ~MEM_i_waddr_change & ~new_waddr;

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
            new_raddr <= new_raddr_next;
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

endmodule



