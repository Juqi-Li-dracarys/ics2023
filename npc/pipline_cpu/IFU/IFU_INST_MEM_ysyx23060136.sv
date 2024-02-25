/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-26 00:41:18 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-02-26 00:41:18 
 */


`include "IFU_DEFINES_ysyx23060136.sv"

// interface for read only sram
// ===========================================================================

module IFU_INST_MEM_ysyx23060136(
        input             clk,
        input             rst,
        input    [31 : 0] IFU_pc,
        output   [31 : 0] IFU_cur,
        output            inst_mem_valid
    );

    IFU_SRAM_ysyx23060136  IFU_SRAM_ysyx23060136_inst (
    .clk(clk),
    .rst(rst),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_aready(s_axi_aready),
    .s_axi_rready(s_axi_rready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_bvalid(s_axi_bvalid)
  );


endmodule

