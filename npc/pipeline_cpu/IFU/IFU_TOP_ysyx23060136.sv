/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-13 14:39:12
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 15:57:14
 */

 `include "DEFINES_ysyx23060136.sv"

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
        input              [  31:0]         BRANCH_branch_target       ,
        // jump signal from Branch
        input                               BRANCH_PCSrc               ,
        // inst from memory
        output             [  31:0]         IFU_o_inst                 ,
        // pc from PC counter
        output             [  31:0]         IFU_o_pc                   ,
        // output IFU_valid for FORWARD unit
        // 当该信号为 true
        output                              IFU_o_valid
    );

    // current inst/pc is valid
    wire           pc_change                  ;
    wire           inst_valid                ;
    assign         IFU_o_valid = inst_valid  ;

    
    IFU_INST_MEM_ysyx23060136  IFU_INST_MEM_ysyx23060136_inst (
                                   .clk                               (clk                       ),
                                   .rst                               (rst                       ),
                                   .IFU_o_pc                          (IFU_o_pc                  ),
                                   .IFU_o_inst                        (IFU_o_inst                ),
                                   .pc_change                         (pc_change                 ),
                                   .inst_valid                        (inst_valid                )
                               );


    IFU_PC_COUNT_ysyx23060136  PC_COUNT_ysyx23060136_inst (
                                   .clk                               (clk                       ),
                                   .rst                               (rst                       ),
                                   .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
                                   .FORWARD_stallIF                   (FORWARD_stallIF           ),
                                   .BRANCH_branch_target              (BRANCH_branch_target      ),
                                   .IFU_o_pc                          (IFU_o_pc                  ),
                                   .pc_change                         (pc_change                 )
                               );

endmodule



