/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-13 14:39:12 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-16 14:06:21
 */

 `include "IFU_DEFINES_ysyx23060136.sv"

// IFU 在 CPU 中只会充当 master
// 与其他模块稍有区别
////////////////////////////////////////////////////

module IFU_TOP_ysyx23060136(
        input                      clk,
        input                      rst,
        // WBU module is ready
        input                      WBU_ready,
        // pc branch(junp inst)
        input  logic [31 : 0]      branch_target,
        // jump or not
        input                      PCSrc,
        // output inst
        output logic [31 : 0]      inst,
        // output pc
        output logic [31 : 0]      pc,
        // output IFU_valid
        output                     IFU_valid
    );

    //pc from PC counter(internal)
    logic [31 : 0] pc_cur;

    // inst from memory(internal)
    logic [31 : 0] inst_cur;

    // current inst is valid(from mem)
    logic          inst_mem_valid;

    // pc halt signal
    logic          IFU_stall;

    assign IFU_stall = ~(WBU_ready | IFU_valid);


    IFU_INST_MEM_ysyx23060136  INST_MEM_ysyx23060136_inst (
                               .clk(clk),
                               .rst(rst),
                               .pc_cur(pc_cur),
                               .inst_cur(inst_cur),
                               .inst_mem_valid(inst_mem_valid)
                           );


    IFU_MACHINE_ysyx23060136  IFU_MACHINE_ysyx23060136_inst (
                                .clk(clk),
                                .rst(rst),
                                .inst_mem_valid(inst_mem_valid),
                                .pc_cur(pc_cur),
                                .inst_cur(inst_cur),
                                .WBU_ready(WBU_ready),
                                .IFU_valid(IFU_valid),
                                .pc(pc),
                                .inst(inst)
                            );


    IFU_PC_COUNT_ysyx23060136  PC_COUNT_ysyx23060136_inst (
                               .clk(clk),
                               .rst(rst),
                               .PCSrc(PCSrc),
                               .IFU_stall(IFU_stall),
                               .branch_target(branch_target),
                               .pc_cur(pc_cur)
                           );

endmodule



