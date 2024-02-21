/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-15 22:20:59 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-18 20:57:18
 */

`include "IFU_DEFINES_ysyx23060136.sv"

// instruction read-only memory
// ===========================================================================

module IFU_INST_MEM_ysyx23060136(
        input             clk,
        input             rst,
        input    [31 : 0] IFU_pc,
        output   [31 : 0] IFU_cur,
        output            inst_mem_valid
    );

    IFU_ROM_ysyx23060136 inst_rom(
                         .clk(clk),
                         .rst(rst),
                         .r_addr(IFU_pc),
                         .r_data(IFU_cur),
                         .data_valid(inst_mem_valid)
                     );

endmodule

