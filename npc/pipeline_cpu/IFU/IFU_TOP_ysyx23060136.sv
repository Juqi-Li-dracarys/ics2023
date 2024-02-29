/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-13 14:39:12
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 15:57:14
 */

`include "IFU_DEFINES_ysyx23060136.sv"

// IFU top module
/*
   FORWARD -> `IFU` -> IFU_IDU_SEG_REG
*/

// ===========================================================================
module IFU_TOP_ysyx23060136(
        input                               clk                        ,
        input                               rst                        ,
        // FORWARD stall instruction
        input                               FORWARD_stallIF            ,
        // jump target
        input              [  31:0]         branch_target              ,
        // jump signal from Branch
        input                               PCSrc                      ,
        // inst from memory(internal)
        output             [  31:0]         IFU_inst                   ,
        // pc from PC counter(internal)
        output             [  31:0]         IFU_pc                     ,
        // output IFU_valid for FORWARD unit
        output                              IFU_valid
    );

    // current inst is valid(from mem)
    logic          inst_valid;

    // pc halt signal from FORWARD unit
    logic          IFU_stall = FORWARD_stallIF;


    IFU_INST_MEM_ysyx23060136  IFU_INST_MEM_ysyx23060136_inst (
                                   .clk                               (clk                       ),
                                   .rst                               (rst                       ),
                                   .IFU_pc                            (IFU_pc                    ),
                                   .IFU_inst                          (IFU_inst                  ),
                                   .inst_valid                        (inst_valid                )
                               );


    IFU_PC_COUNT_ysyx23060136  PC_COUNT_ysyx23060136_inst (
                                   .clk                               (clk                       ),
                                   .rst                               (rst                       ),
                                   .PCSrc                             (PCSrc                     ),
                                   .IFU_stall                         (IFU_stall                 ),
                                   .branch_target                     (branch_target             ),
                                   .IFU_pc                            (IFU_pc                    )
                               );

    assign IFU_valid = inst_valid;

endmodule



