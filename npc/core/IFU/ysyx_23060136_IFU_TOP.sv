/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-06-10 10:17:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 23:33:17
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

        input              [  `ysyx_23060136_BITS_W -1:0]   BHT_pc                     ,
        // correct predict
        input                                               BHT_pre_true               ,
        // wrong predict
        input                                               BHT_pre_false              ,

        // inst from memory
        output             [  `ysyx_23060136_INST_W-1:0]    IFU_o_inst                 ,
        // pc from PC counter
        output             [  `ysyx_23060136_BITS_W-1:0]    IFU_o_pc                   ,
        // output IFU_valid for FORWARD unit
        // 当该信号为 true
        output                                              IFU_o_valid                ,
        output                                              IFU_o_commit               ,
        output                                              BHT_pre_take               ,
        // ===========================================================================
        input                                               ARBITER_IFU_arready        , 
        output                                              ARBITER_IFU_arvalid        , 
        output            [  31:0]                          ARBITER_IFU_araddr         , 
        output            [   3:0]                          ARBITER_IFU_arid           , 
        output            [   7:0]                          ARBITER_IFU_arlen          , 
        output            [   2:0]                          ARBITER_IFU_arsize         , 
        output            [   1:0]                          ARBITER_IFU_arburst        , 
        output                                              ARBITER_IFU_rready         , 
        input                                               ARBITER_IFU_rvalid         , 
        input             [   1:0]                          ARBITER_IFU_rresp          , 
        input             [  63:0]                          ARBITER_IFU_rdata          , 
        input                                               ARBITER_IFU_rlast          , 
        input             [   3:0]                          ARBITER_IFU_rid            ,
        output                                              IFU_error_signal           ,
        // ===========================================================================
        output            [   5:0]                          io_sram0_addr               ,
        output                                              io_sram0_cen                ,
        output                                              io_sram0_wen                ,
        output            [ 127:0]                          io_sram0_wmask              ,
        output            [ 127:0]                          io_sram0_wdata              ,
        input             [ 127:0]                          io_sram0_rdata              ,
        output            [   5:0]                          io_sram1_addr               ,
        output                                              io_sram1_cen                ,
        output                                              io_sram1_wen                ,
        output            [ 127:0]                          io_sram1_wmask              ,
        output            [ 127:0]                          io_sram1_wdata              ,
        input             [ 127:0]                          io_sram1_rdata              ,
        output            [   5:0]                          io_sram2_addr               ,
        output                                              io_sram2_cen                ,
        output                                              io_sram2_wen                ,
        output            [ 127:0]                          io_sram2_wmask              ,
        output            [ 127:0]                          io_sram2_wdata              ,
        input             [ 127:0]                          io_sram2_rdata              ,
        output            [   5:0]                          io_sram3_addr               ,
        output                                              io_sram3_cen                ,
        output                                              io_sram3_wen                ,
        output            [ 127:0]                          io_sram3_wmask              ,
        output            [ 127:0]                          io_sram3_wdata              ,
        input             [ 127:0]                          io_sram3_rdata              
    );

    // current inst/pc is valid
    wire                                   inst_valid                           ;
    wire                                   IFU2_commit                          ;
    wire     [  `ysyx_23060136_BITS_W-1:0] IFU1_pc                              ;
    wire     [  `ysyx_23060136_BITS_W-1:0] IFU2_pc                              ;

    assign                                 IFU_o_valid      =      inst_valid   ;
    assign                                 IFU_o_pc         =      IFU2_pc      ;
    assign                                 IFU_o_commit     =      IFU2_commit  ;



    wire   [  `ysyx_23060136_BITS_W-1:0]     BHT_branch_target  ;
    wire                                     BHT_flushIF        ;
    wire                                     BHT_PCSrc          ;

     ysyx_23060136_IFU_BHT  ysyx_23060136_IFU_BHT_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .IFU_o_inst                        (IFU_o_inst                ),
        .IFU_o_pc                          (IFU_o_pc                  ),
        .BHT_pc                            (BHT_pc                    ),
        .BHT_pre_true                      (BHT_pre_true              ),
        .BHT_pre_false                     (BHT_pre_false             ),
        .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
        .BHT_pre_take                      (BHT_pre_take              ),
        .BHT_flushIF                       (BHT_flushIF               ),
        .BHT_PCSrc                         (BHT_PCSrc                 ),
        .BHT_branch_target                 (BHT_branch_target         ) 
  );

     
    ysyx_23060136_IFU_ICACHE  ysyx_23060136_IFU_ICACHE_inst (
            .clk                               (clk                       ),
            .rst                               (rst                       ),
            .IFU1_pc                           (IFU1_pc                   ),
            .BRANCH_flushIF                    (BRANCH_flushIF            ),
            .FORWARD_stallIF                   (FORWARD_stallIF           ),
            .ARBITER_IFU_arready               (ARBITER_IFU_arready       ),
            .ARBITER_IFU_arvalid               (ARBITER_IFU_arvalid       ),
            .ARBITER_IFU_araddr                (ARBITER_IFU_araddr        ),
            .ARBITER_IFU_arid                  (ARBITER_IFU_arid          ),
            .ARBITER_IFU_arlen                 (ARBITER_IFU_arlen         ),
            .ARBITER_IFU_arsize                (ARBITER_IFU_arsize        ),
            .ARBITER_IFU_arburst               (ARBITER_IFU_arburst       ),
            .ARBITER_IFU_rready                (ARBITER_IFU_rready        ),
            .ARBITER_IFU_rvalid                (ARBITER_IFU_rvalid        ),
            .ARBITER_IFU_rresp                 (ARBITER_IFU_rresp         ),
            .ARBITER_IFU_rdata                 (ARBITER_IFU_rdata         ),
            .ARBITER_IFU_rlast                 (ARBITER_IFU_rlast         ),
            .ARBITER_IFU_rid                   (ARBITER_IFU_rid           ),
            .io_sram0_addr                     (io_sram0_addr             ),
            .io_sram0_cen                      (io_sram0_cen              ),
            .io_sram0_wen                      (io_sram0_wen              ),
            .io_sram0_wmask                    (io_sram0_wmask            ),
            .io_sram0_wdata                    (io_sram0_wdata            ),
            .io_sram0_rdata                    (io_sram0_rdata            ),
            .io_sram1_addr                     (io_sram1_addr             ),
            .io_sram1_cen                      (io_sram1_cen              ),
            .io_sram1_wen                      (io_sram1_wen              ),
            .io_sram1_wmask                    (io_sram1_wmask            ),
            .io_sram1_wdata                    (io_sram1_wdata            ),
            .io_sram1_rdata                    (io_sram1_rdata            ),
            .io_sram2_addr                     (io_sram2_addr             ),
            .io_sram2_cen                      (io_sram2_cen              ),
            .io_sram2_wen                      (io_sram2_wen              ),
            .io_sram2_wmask                    (io_sram2_wmask            ),
            .io_sram2_wdata                    (io_sram2_wdata            ),
            .io_sram2_rdata                    (io_sram2_rdata            ),
            .io_sram3_addr                     (io_sram3_addr             ),
            .io_sram3_cen                      (io_sram3_cen              ),
            .io_sram3_wen                      (io_sram3_wen              ),
            .io_sram3_wmask                    (io_sram3_wmask            ),
            .io_sram3_wdata                    (io_sram3_wdata            ),
            .io_sram3_rdata                    (io_sram3_rdata            ),
            .IFU_o_inst                        (IFU_o_inst                ),
            .inst_valid                        (inst_valid                ),
            .IFU_error_signal                  (IFU_error_signal          ) 
    );

    ysyx_23060136_IFU_PC  ysyx_23060136_IFU_PC_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
        .BRANCH_branch_target              (BRANCH_branch_target      ),
        .BHT_PCSrc                         (BHT_PCSrc                 ),
        .BHT_branch_target                 (BHT_branch_target         ),
        .IFU1_pc                           (IFU1_pc                   ) 
    );


    ysyx_23060136_IFU_SEG  ysyx_23060136_IFU_SEG_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .BRANCH_flushIF                    (BRANCH_flushIF            ),
        .BHT_flushIF                       (BHT_flushIF               ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .IFU1_pc                           (IFU1_pc                   ),
        .IFU2_pc                           (IFU2_pc                   ),
        .IFU2_commit                       (IFU2_commit               ) 
      );

endmodule



