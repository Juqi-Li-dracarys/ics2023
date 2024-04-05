/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 17:30:02 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 17:40:26
 */


 `include "ysyx23060136_DEFINES.sv"


// IFU top module with internal mini pipeline

/*
   FORWARD -> `IFU` -> IFU_IDU_SEG_REG
*/

// ===========================================================================
module ysyx23060136_IFU_TOP(
        input                                               clk                        ,
        input                                               rst                        ,
        // FORWARD stall instruction
        input                                               FORWARD_stallIF            ,
        input                                               BRANCH_flushIF             ,
        // jump target
        input              [  `BITS_W_23060136-1:0]         BRANCH_branch_target       ,
        // jump signal from Branch
        input                                               BRANCH_PCSrc               ,
        // inst from memory
        output             [  `INST_W_23060136-1:0]         IFU_o_inst                 ,
        // pc from PC counter
        output             [  `BITS_W_23060136-1:0]         IFU_o_pc                   ,
        // output IFU_valid for FORWARD unit
        // 当该信号为 true
        output                                              IFU_o_valid                ,

        input              [  `BITS_W_23060136-1:0]         ARBITER_IFU_inst           ,
        input                                               ARBITER_IFU_inst_valid     ,
        input                                               ARBITER_IFU_pc_ready       ,
  
        output             [  `BITS_W_23060136-1:0]         ARBITER_IFU_pc             ,
        output                                              ARBITER_IFU_pc_valid       ,
        output                                              ARBITER_IFU_inst_ready     ,
        output                                              IFU_error_signal
    );

    // current inst/pc is valid
    wire           inst_valid                           ;
    assign         IFU_o_valid      =      inst_valid   ;

    
    IFU_INST_MEM_ysyx23060136  IFU_INST_MEM_ysyx23060136_inst (
                                   .clk                               (clk                       ),
                                   .rst                               (rst                       ),
                                   .IFU_o_pc                          (IFU_o_pc                  ),
                                   .IFU_o_inst                        (IFU_o_inst                ),
                                   .pc_change                         (pc_change                 ),
                                   .inst_valid                        (inst_valid                ),

                                   .ARBITER_IFU_inst                  (ARBITER_IFU_inst          ),
                                   .ARBITER_IFU_inst_valid            (ARBITER_IFU_inst_valid    ),
                                   .ARBITER_IFU_pc_ready              (ARBITER_IFU_pc_ready      ),

                                   .ARBITER_IFU_pc                    (ARBITER_IFU_pc            ),
                                   .ARBITER_IFU_pc_valid              (ARBITER_IFU_pc_valid      ),
                                   .ARBITER_IFU_inst_ready            (ARBITER_IFU_inst_ready    ),
                                   .IFU_error_signal                  (IFU_error_signal          ) 
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



