/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-26 00:41:18 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-02-26 00:41:18 
 */


`include "DEFINES_ysyx23060136.sv"

/* verilator lint_off UNUSED */

// interface for read-only sram
// protocol: AXI-LITE
// ===========================================================================
module IFU_INST_MEM_ysyx23060136(
      input                               clk                        ,
      input                               rst                        ,
      input              [  31:0]         IFU_o_pc                   ,
      input                               pc_change                  ,
      output             [  31:0]         IFU_o_inst                 ,
      output                              inst_valid             
    );


    //  sarm instance 
    // 当 pc 的值发生变化时，我们才考虑读取下一条指令
    wire                                      m_axi_arvalid  =  r_state_idle & new_pc       ;
    wire         [31 : 0]                     m_axi_araddr   =  IFU_o_pc                    ;
    wire                                      m_axi_aready                                  ;
    wire                                      m_axi_rready   =  r_state_busy                ;
    wire         [31 : 0]                     m_axi_rdata                                   ;
    wire                                      m_axi_rvalid                                  ;
    
    // we do not need response
    wire         [1 : 0]                      m_axi_rresp                                   ;
    // we do not need to write data from AXI
    wire                                      m_axi_awready              ;
    wire                                      m_axi_wready               ;
    wire         [1 : 0]                      m_axi_bresp                ;
    wire                                      m_axi_bvalid               ;

    // 当 PC 变化时，pc_change 暂时拉高，下一个周期之后，pc_change 会保存在 new_pc 中
    // 当状态机处于 busy 时， new_pc 会被自动清0
    logic   new_pc ;  

    assign  IFU_o_inst        =  m_axi_rdata;
    // this signal is used for next phase of CPU 
    assign  inst_valid        =  r_state_idle & ~pc_change & ~new_pc;

    wire          r_state_idle     =  (r_state == `idle);
    wire          r_state_busy     =  (r_state == `busy);

    // read mater state machine
    logic        [1 : 0]       r_state;
    // 当 AXI lite 发生握手，将转移到下一个状态
    wire         [1 : 0]       r_state_next   =  ({2{r_state_idle}} & ((m_axi_aready & m_axi_arvalid) ? `busy : `idle)) |
                                                 ({2{r_state_busy}} & ((m_axi_rvalid & m_axi_rready)  ? `idle : `busy)) ;

    // new pc 在被拉高后，会阻塞在第一阶段，直到握手完成
    // 第二阶段清0
    wire                       new_pc_next    =  (r_state_idle &  (new_pc ? new_pc : pc_change)) | 
                                                 (r_state_busy &  `false                       ) ;


    always_ff @(posedge clk) begin : state_machine
      if(rst) begin
          r_state <=  `idle;
      end
      else begin
          r_state <=  r_state_next;
      end
    end

    always_ff @(posedge clk) begin : new_pc_update
        if(rst) begin
            new_pc  <= `false;
        end
        else begin
            new_pc  <=  new_pc_next;
        end
    end
  

    PUBLIC_SRAM_ysyx23060136  IFU_SRAM_ysyx23060136_inst (
                               .clk           (clk           ),
                               .rst           (rst           ),
                               .s_axi_arvalid (m_axi_arvalid ),
                               .s_axi_araddr  (m_axi_araddr  ),
                               .s_axi_aready  (m_axi_aready  ),
                               .s_axi_rready  (m_axi_rready  ),
                               .s_axi_rdata   (m_axi_rdata   ),
                               .s_axi_rvalid  (m_axi_rvalid  ),
                               .s_axi_rresp   (m_axi_rresp   ),

                               // we do not need to write data from AXI
                               .s_axi_awaddr  (`false        ),
                               .s_axi_awvalid (`false        ),
                               .s_axi_awready (m_axi_awready ),
                               .s_axi_wdata   (`false        ),
                               .s_axi_wstrb   (`false        ),
                               .s_axi_wvalid  (`false        ),
                               .s_axi_wready  (m_axi_wready  ),
                               .s_axi_bresp   (m_axi_bresp   ),
                               .s_axi_bready  (`false        ),
                               .s_axi_bvalid  (m_axi_bvalid  )
                           );


endmodule


