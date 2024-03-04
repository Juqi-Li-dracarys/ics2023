/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 17:15:10 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-02-24 17:15:10 
 */

 `include "DEFINES_ysyx23060136.sv"

 /* verilator lint_off UNUSED */

// interface for main memory

// ===========================================================================
module MEM_DATA_MEM_ysyx23060136 (
    input                               clk                        ,
    input                               rst                        ,
    input              [  31:0]         pc                         ,
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
    // 读写完成信号
    output                              MEM_rvalid                 ,
    output                              MEM_wready                  
);

    // ===========================================================================
    // read module signal
    wire                                      m_axi_arvalid  =  r_state_idle & new_raddr      ;
    wire         [31 : 0]                     m_axi_araddr   =  MEM_raddr                     ;
    wire                                      m_axi_aready                                    ;
    wire                                      m_axi_rready   =  r_state_busy                  ;
    wire         [31 : 0]                     m_axi_rdata                                     ;
    wire                                      m_axi_rvalid                                    ;
    // we do not need response in reading
    wire         [1 : 0]                      m_axi_rresp                                     ;


    // write module signal 
    wire         [  31:0]                     m_axi_awaddr   =  MEM_waddr                     ;
    wire                                      m_axi_awvalid  =  w_state_idle & new_waddr      ; 
    wire                                      m_axi_awready                                   ;
    wire         [  31:0]                     m_axi_wdata    =  MEM_wdata                     ;

    wire         [   3:0]                     m_axi_wstrb    =  ({4{MEM_mem_byte}}) & 4'b0001 |
                                                                ({4{MEM_mem_half}}) & 4'b0011 |
                                                                ({4{MEM_mem_word}}) & 4'b1111 ;

    wire                                      m_axi_wvalid   =  MEM_write_mem & w_state_busy  ;
    wire                                      m_axi_wready                                    ;
    // we do not need response in writing
    wire         [   1:0]                     m_axi_bresp                                     ;
    wire                                      m_axi_bready   =  w_state_done                  ;
    wire                                      m_axi_bvalid                                    ;

    // ===========================================================================

    // 当 raddr 有效且变化时，raddr_change 暂时拉高，下一个周期之后，raddr_change 会保存在 new_raddr 中
    // 当状态机处于 busy 时， new_raddr 会被自动清0

    logic                      new_raddr;
    logic                      new_waddr;

    // read mater state machine
    logic        [1 : 0]       r_state;
    // 当 AXI lite 发生握手，将转移到下一个状态
    wire         [1 : 0]       r_state_next   =  ({2{r_state_idle}} & ((m_axi_aready & m_axi_arvalid) ? `busy : `idle)) |
                                                 ({2{r_state_busy}} & ((m_axi_rvalid & m_axi_rready)  ? `idle : `busy)) ;

    wire                       new_raddr_next =  (r_state_idle      & ( new_raddr    ? new_raddr : MEM_i_raddr_change)) |
                                                 (r_state_busy      & `false                                          ) ;
    
    
    wire                       r_state_idle   =  (r_state == `idle);
    wire                       r_state_busy   =  (r_state == `busy);


    // write mater state machine
    logic        [1 : 0]       w_state;
    wire         [1 : 0]       w_state_next   = ({2{w_state_idle}} & ((m_axi_awready & m_axi_awvalid)  ?  `busy : `idle)) | 
                                                ({2{w_state_busy}} & ((m_axi_wready  & m_axi_wvalid)   ?  `done : `busy)) |
                                                ({2{w_state_done}} & ((m_axi_bready  & m_axi_bvalid)   ?  `idle : `done)) ;

    wire                       new_waddr_next =  (w_state_idle      & ( new_waddr    ? new_waddr : MEM_i_waddr_change)) |
                                                 (w_state_busy      & `false                                          ) ;
 
    

    wire                       w_state_idle   =  (w_state == `idle);
    wire                       w_state_busy   =  (w_state == `busy);
    wire                       w_state_done   =  (w_state == `done);

    // bit 提取和符号拓展
    wire   [31 : 0]     byte_rdata   =   (m_axi_rdata & 32'h0000_00FF);
    wire   [31 : 0]     half_rdata   =   (m_axi_rdata & 32'h0000_FFFF);
    wire   [31 : 0]     word_rdata   =    m_axi_rdata;

    assign  MEM_rdata   =   ({32{MEM_mem_byte_u}}) & byte_rdata                                        |
                            ({32{MEM_mem_half_u}}) & half_rdata                                        |
                            ({32{MEM_mem_word  }}) & word_rdata                                        |
                            ({32{MEM_mem_byte  }}) & (byte_rdata | {{24{byte_rdata[7]}},  {8{1'b0}}} ) |
                            ({32{MEM_mem_half  }}) & (half_rdata | {{16{half_rdata[15]}}, {16{1'b0}}}) ;

                            
    // this signal is used for next phase of CPU 
    assign  MEM_rvalid  =  r_state_idle & ~MEM_i_raddr_change & ~new_raddr;
    assign  MEM_wready  =  w_state_idle & ~MEM_i_waddr_change & ~new_waddr;

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

    // ===========================================================================
    PUBLIC_SRAM_ysyx23060136 MEM_SRAM_ysyx23060136_inst (
    .clk                               (clk                       ),
    .rst                               (rst                       ),
    .s_axi_arvalid                     (m_axi_arvalid             ),
    .s_axi_araddr                      (m_axi_araddr              ),
    .s_axi_aready                      (m_axi_aready              ),
    .s_axi_rready                      (m_axi_rready              ),
    .s_axi_rdata                       (m_axi_rdata               ),
    .s_axi_rvalid                      (m_axi_rvalid              ),
    .s_axi_rresp                       (m_axi_rresp               ),
    .s_axi_awaddr                      (m_axi_awaddr              ),
    .s_axi_awvalid                     (m_axi_awvalid             ),
    .s_axi_awready                     (m_axi_awready             ),
    .s_axi_wdata                       (m_axi_wdata               ),
    .s_axi_wstrb                       (m_axi_wstrb               ),
    .s_axi_wvalid                      (m_axi_wvalid              ),
    .s_axi_wready                      (m_axi_wready              ),
    .s_axi_bresp                       (m_axi_bresp               ),
    .s_axi_bready                      (m_axi_bready              ),
    .s_axi_bvalid                      (m_axi_bvalid              ) 
  );


endmodule



