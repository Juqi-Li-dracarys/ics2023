/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-26 00:41:18 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-02-26 00:41:18 
 */


`include "IFU_DEFINES_ysyx23060136.sv"

// interface for read-only sram
// protocol: AXI-LITE
// ===========================================================================
module IFU_INST_MEM_ysyx23060136(
      input                               clk                        ,
      input                               rst                        ,
      input              [  31:0]         IFU_pc                     ,
      output             [  31:0]         IFU_inst                   ,
      output                              inst_valid             
    );


    //  sarm instance 
    // 当 pc 的值发生变化时，我们才考虑读取下一条指令
    logic                                     m_axi_arvalid  =  r_state_idle & pc_change;
    logic        [31 : 0]                     m_axi_araddr   =  IFU_pc                      ;
    logic                                     m_axi_aready                                  ;
    logic                                     m_axi_rready   =  r_state_busy                ;
    logic        [31 : 0]                     m_axi_rdata                                   ;
    logic                                     m_axi_rvalid                                  ;
    // we do not need response
    logic        [1 : 0]                      m_axi_rresp                                   ;

    // we do not need to write data from AXI
    logic                                     m_axi_awready              ;
    logic                                     m_axi_wready               ;
    logic        [1 : 0]                      m_axi_bresp                ;
    logic                                     m_axi_bvalid               ;

    // 暂存当前 PC 值，当 PC 变化时，我们将新值视为有效值
    logic        [31 : 0]      temp_pc;
    logic                      pc_change = (temp_pc != IFU_pc);

    assign  IFU_inst        =  m_axi_rdata;
    // this signal is used for next phase of CPU 
    assign  inst_valid      =  r_state_idle & ~pc_change;

    logic          r_state_idle     =  (r_state == `idle);
    logic          r_state_busy     =  (r_state == `busy);

    // read mater state machine
    logic        [1 : 0]       r_state;
    // 当 AXI lite 发生握手，将转移到下一个状态
    logic        [1 : 0]       r_state_next   =  ({2{r_state_idle}} & ((m_axi_aready & m_axi_arvalid) ? `busy : `idle)) |
                                                 ({2{r_state_busy}} & ((m_axi_rvalid & m_axi_rready)  ? `idle : `busy)) ;

    always_ff @(posedge clk) begin : state_machine
      if(rst) begin
          r_state <=  `idle;
      end
      else begin
          r_state <=  r_state_next;
      end
    end

    always_ff @(posedge clk) begin : temp_pc_update
        if(rst) begin
            temp_pc <= `PC_RST;
        end
        else if(pc_change) begin
            temp_pc <= IFU_pc;
        end
    end
  

    IFU_SRAM_ysyx23060136  IFU_SRAM_ysyx23060136_inst (
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


