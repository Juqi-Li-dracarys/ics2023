/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 17:30:02 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 21:49:41
 */


 `include "ysyx_23060136_DEFINES.sv"


// IFU top module with internal mini pipeline

/*
   FORWARD -> IFU -> IFU_IDU_SEG_REG
*/

// ===========================================================================
module ysyx_23060136_IFU_TOP(
        input                                               clk                        ,
        input                                               rst                        ,
        // FORWARD stall instruction
        input                                               FORWARD_stallIF            ,
        input                                               BRANCH_flushIF             ,
        // jump target
        input              [  `ysyx_23060136_BITS_W-1:0]    BRANCH_branch_target       ,
        // jump signal from Branch
        input                                               BRANCH_PCSrc               ,
        // inst from memory
        output             [  `ysyx_23060136_INST_W-1:0]    IFU_o_inst                 ,
        // pc from PC counter
        output             [  `ysyx_23060136_BITS_W-1:0]    IFU_o_pc                   ,
        // output IFU_valid for FORWARD unit
        // 当该信号为 true
        output                                              IFU_o_valid                ,

        input              [  `ysyx_23060136_BITS_W-1:0]    ARBITER_IFU_inst           ,
        input                                               ARBITER_IFU_inst_valid     ,
        input                                               ARBITER_IFU_pc_ready       ,
  
        output             [  `ysyx_23060136_BITS_W-1:0]    ARBITER_IFU_pc             ,
        output                                              ARBITER_IFU_pc_valid       ,
        output                                              ARBITER_IFU_inst_ready     ,
        output                                              IFU_error_signal
    );

    // current inst/pc is valid
    wire                                   inst_valid                           ;
    wire     [  `ysyx_23060136_BITS_W-1:0] IFU1_pc                              ;
    wire     [  `ysyx_23060136_BITS_W-1:0] IFU2_pc                              ;

    assign                                 IFU_o_valid      =      inst_valid   ;
    assign                                 IFU_o_pc         =      IFU2_pc      ;

    ysyx_23060136_IFU_PC_COUNT  ysyx_23060136_IFU_PC_COUNT_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .BRANCH_branch_target              (BRANCH_branch_target      ),
        .IFU1_pc                           (IFU1_pc                   ) 
     );

     
     ysyx_23060136_IFU_INST_MEM  ysyx_23060136_IFU_INST_MEM_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .IFU1_pc                           (IFU1_pc                   ),
        .BRANCH_flushIF                    (BRANCH_flushIF            ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .ARBITER_IFU_pc_ready              (ARBITER_IFU_pc_ready      ),
        .ARBITER_IFU_pc                    (ARBITER_IFU_pc            ),
        .ARBITER_IFU_pc_valid              (ARBITER_IFU_pc_valid      ),
        .ARBITER_IFU_inst                  (ARBITER_IFU_inst          ),
        .ARBITER_IFU_inst_valid            (ARBITER_IFU_inst_valid    ),
        .ARBITER_IFU_inst_ready            (ARBITER_IFU_inst_ready    ),
        .IFU_o_inst                        (IFU_o_inst                ),
        .inst_valid                        (inst_valid                ),
        .IFU_error_signal                  (IFU_error_signal          ) 
  );


  ysyx_23060136_IFU_SEG  ysyx_23060136_IFU_SEG_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .BRANCH_flushIF                    (BRANCH_flushIF            ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .IFU1_pc                           (IFU1_pc                   ),
        .IFU2_pc                           (IFU2_pc                   ) 
  );

endmodule



