/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-28 13:07:41 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-28 23:59:44
 */

`include "MEM_DEFINES_ysyx23060136.sv"


// ===========================================================================
module MEM_TOP_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
        // ===========================================================================
        // forward signal
        input                               IFU_valid                  ,

        input             [4 : 0]           IDU_rs1                    ,
        input             [4 : 0]           IDU_rs2                    ,
        input             [1 : 0]           IDU_csr_rs                 ,

        input             [4 : 0]           EXU_rs1_MEM                ,
        input             [4 : 0]           EXU_rs2_MEM                ,
        input             [1 : 0]           EXU_csr_rs_MEM             ,

        input             [4 : 0]           WB_rd                      ,
        input             [1 : 0]           WB_csr_rd                  ,
        input                               WB_write_gpr               ,
        input                               WB_write_csr               ,
        input             [31 : 0]          WB_rs1_data_EXU            ,
        input             [31 : 0]          WB_rs2_data_EXU            ,
        input             [31 : 0]          WB_csr_rs_data_EXU         ,
        // ===========================================================================
        // general signal
        input                               MEM_commit                 ,
        input             [31 : 0]          MEM_pc                     ,
        input             [31 : 0]          MEM_inst                   ,
        input             [31 : 0]          MEM_ALU_ALUout             ,
        input             [31 : 0]          MEM_ALU_CSR_out            ,

        input             [4 : 0]           MEM_rd                     ,
        input             [31 : 0]          MEM_rs2_data               ,
        // mem
        input             [1 : 0]           MEM_csr_rd                 ,
        // mem
        input                               MEM_write_gpr              ,
        input                               MEM_write_csr              ,
        input                               MEM_mem_to_reg             ,

        input                               MEM_write_mem              ,
        input                               MEM_mem_byte               ,
        input                               MEM_mem_half               ,
        input                               MEM_mem_word               ,
        input                               MEM_mem_byte_u             ,
        input                               MEM_mem_half_u             ,

        // system
        input                               MEM_system_halt            ,
        input                               MEM_op_valid               ,
        input                               MEM_ALU_valid              ,

        // ===========================================================================

        output                              MEM_commit_WB              ,
        output            [31 : 0]          MEM_pc_WB                  ,
        output            [31 : 0]          MEM_inst_WB                ,

        output            [31 : 0]          MEM_ALU_ALUout_WB          ,
        output            [31 : 0]          MEM_ALU_CSR_out_WB         ,
        output            [31 : 0]          MEM_rdata                  ,

        output            [4 : 0]           MEM_rd_WB                  ,
        output            [1 : 0]           MEM_csr_rd_WB              ,

        output                              MEM_system_halt_WB         ,
        output                              MEM_op_valid_WB            ,
        output                              MEM_ALU_valid_WB           ,
        
        output                              FORWARD_stallIF            ,
        output                              FORWARD_stallID            ,
        output                              FORWARD_stallME            ,
        output                              FORWARD_flushWB            ,
        output            [31 : 0]          FORWARD_rs1_data_EXU       ,
        output            [31 : 0]          FORWARD_rs2_data_EXU       ,
        output            [31 : 0]          FORWARD_csr_rs_data_EXU    ,
        output                              FORWARD_rs1_hazard_EXU     ,
        output                              FORWARD_rs2_hazard_EXU     ,
        output                              FORWARD_csr_rs_hazard_EXU  ,
        output            [31 : 0]          FORWARD_rs1_data_SEG       ,
        output            [31 : 0]          FORWARD_rs2_data_SEG       ,
        output            [31 : 0]          FORWARD_csr_rs_data_SEG    ,
        output                              FORWARD_rs1_hazard_SEG     ,
        output                              FORWARD_rs2_hazard_SEG     ,
        output                              FORWARD_csr_rs_hazard_SEG  

    );



    logic      [  31:0]            MEM_raddr          =  MEM_ALU_ALUout;
    logic                          MEM_re             =  MEM_mem_to_reg;
    logic      [  31:0]            MEM_waddr          =  MEM_ALU_ALUout;
    logic      [  31:0]            MEM_wdata          =  MEM_rs2_data;
    logic                          MEM_rvalid;
    logic                          MEM_wready;

    assign                         MEM_commit_WB      =   MEM_commit ;
    assign                         MEM_pc_WB          =   MEM_pc     ;
    assign                         MEM_inst_WB        =   MEM_inst   ;
    assign                         MEM_ALU_ALUout_WB  =   MEM_ALU_ALUout;
    assign                         MEM_ALU_CSR_out_WB =   MEM_ALU_CSR_out;
    assign                         MEM_rd_WB          =   MEM_rd;
    assign                         MEM_csr_rd_WB      =   MEM_csr_rd;
    assign                         MEM_system_halt_WB =   MEM_system_halt;
    assign                         MEM_op_valid_WB    =   MEM_op_valid;
    assign                         MEM_ALU_valid_WB   =   MEM_ALU_valid;
    


    MEM_DATA_MEM_ysyx23060136  MEM_DATA_MEM_ysyx23060136_inst (
                                   .clk                               (clk                       ),
                                   .rst                               (rst                       ),
                                   .MEM_raddr                         (MEM_raddr                 ),
                                   .MEM_re                            (MEM_re                    ),
                                   .MEM_rdata                         (MEM_rdata                 ),
                                   .MEM_waddr                         (MEM_waddr                 ),
                                   .MEM_wdata                         (MEM_wdata                 ),
                                   .MEM_write_mem                     (MEM_write_mem             ),
                                   .MEM_mem_byte                      (MEM_mem_byte              ),
                                   .MEM_mem_half                      (MEM_mem_half              ),
                                   .MEM_mem_word                      (MEM_mem_word              ),
                                   .MEM_mem_byte_u                    (MEM_mem_byte_u            ),
                                   .MEM_mem_half_u                    (MEM_mem_half_u            ),
                                   .MEM_rvalid                        (MEM_rvalid                ),
                                   .MEM_wready                        (MEM_wready                )
                               );

    MEM_FORWARD_ysyx23060136  MEM_FORWARD_ysyx23060136_inst (
                                  .IFU_valid                         (IFU_valid                 ),
                                  .MEM_rvalid                        (MEM_rvalid                ),
                                  .MEM_wready                        (MEM_wready                ),
                                  .IDU_rs1                           (IDU_rs1                   ),
                                  .IDU_rs2                           (IDU_rs2                   ),
                                  .IDU_csr_rs                        (IDU_csr_rs                ),
                                  .EXU_rs1_MEM                       (EXU_rs1_MEM               ),
                                  .EXU_rs2_MEM                       (EXU_rs2_MEM               ),
                                  .EXU_csr_rs_MEM                    (EXU_csr_rs_MEM            ),
                                  .MEM_mem_to_reg                    (MEM_mem_to_reg            ),
                                  .MEM_rd                            (MEM_rd                    ),
                                  .MEM_csr_rd                        (MEM_csr_rd                ),
                                  .MEM_write_gpr                     (MEM_write_gpr             ),
                                  .MEM_write_csr                     (MEM_write_csr             ),
                                  .MEM_rdata                         (MEM_rdata                 ),
                                  .MEM_ALU_ALUout                    (MEM_ALU_ALUout            ),
                                  .MEM_ALU_CSR_out                   (MEM_ALU_CSR_out           ),
                                  .WB_rd                             (WB_rd                     ),
                                  .WB_csr_rd                         (WB_csr_rd                 ),
                                  .WB_write_gpr                      (WB_write_gpr              ),
                                  .WB_write_csr                      (WB_write_csr              ),
                                  .WB_rs1_data_EXU                   (WB_rs1_data_EXU           ),
                                  .WB_rs2_data_EXU                   (WB_rs2_data_EXU           ),
                                  .WB_csr_rs_data_EXU                (WB_csr_rs_data_EXU        ),
                                  .FORWARD_stallIF                   (FORWARD_stallIF           ),
                                  .FORWARD_stallID                   (FORWARD_stallID           ),
                                  .FORWARD_stallME                   (FORWARD_stallME           ),
                                  .FORWARD_flushWB                   (FORWARD_flushWB           ),
                                  .FORWARD_rs1_data_EXU              (FORWARD_rs1_data_EXU      ),
                                  .FORWARD_rs2_data_EXU              (FORWARD_rs2_data_EXU      ),
                                  .FORWARD_csr_rs_data_EXU           (FORWARD_csr_rs_data_EXU   ),
                                  .FORWARD_rs1_hazard_EXU            (FORWARD_rs1_hazard_EXU    ),
                                  .FORWARD_rs2_hazard_EXU            (FORWARD_rs2_hazard_EXU    ),
                                  .FORWARD_csr_rs_hazard_EXU         (FORWARD_csr_rs_hazard_EXU ),
                                  .FORWARD_rs1_data_SEG              (FORWARD_rs1_data_SEG      ),
                                  .FORWARD_rs2_data_SEG              (FORWARD_rs2_data_SEG      ),
                                  .FORWARD_csr_rs_data_SEG           (FORWARD_csr_rs_data_SEG   ),
                                  .FORWARD_rs1_hazard_SEG            (FORWARD_rs1_hazard_SEG    ),
                                  .FORWARD_rs2_hazard_SEG            (FORWARD_rs2_hazard_SEG    ),
                                  .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG )
                              );

endmodule

