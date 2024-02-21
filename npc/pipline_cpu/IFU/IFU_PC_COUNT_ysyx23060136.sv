/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-15 22:21:15 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-18 20:57:27
 */

 `include "IFU_DEFINES_ysyx23060136.sv"

// PC counter of CPU
// ===========================================================================

module IFU_PC_COUNT_ysyx23060136 (
    input                      clk,
    input                      rst,
    input                      PCSrc,
    input                      IFU_stall,
    input        [31 : 0]      branch_target,
    output logic [31 : 0]      IFU_pc
);

    logic [31 : 0]  pc_update;
    logic [31 : 0]  pc_next;

    assign pc_update = PCSrc ? branch_target : IFU_pc + 32'h4;
    assign pc_next = IFU_stall ? IFU_pc : pc_update;
    
    always_ff @(posedge clk) begin
        if(rst)
            IFU_pc <= `PC_RST;
        else begin
            IFU_pc <= pc_next;
        end
    end

endmodule


