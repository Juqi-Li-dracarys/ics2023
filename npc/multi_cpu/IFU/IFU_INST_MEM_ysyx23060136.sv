/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-15 22:20:59 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-16 14:06:37
 */

`include "IFU_DEFINES_ysyx23060136.sv"

// instruction read-only memory
//////////////////////////////////////////////////

module IFU_INST_MEM_ysyx23060136(
        input                 clk,
        input                 rst,
        input  logic [31 : 0] pc_cur,
        output logic [31 : 0] inst_cur,
        output                inst_mem_valid
    );

    IFU_ROM_ysyx23060136 inst_rom(
                         .clk(clk),
                         .rst(rst),
                         .r_addr(pc_cur),
                         .r_data(inst_cur),
                         .data_valid(inst_mem_valid)
                     );

endmodule

