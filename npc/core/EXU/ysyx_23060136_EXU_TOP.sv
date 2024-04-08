/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 16:26:18 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-07 17:31:00
 */


 `include "ysyx_23060136_DEFINES.sv"


// Top module of EXU
// ===========================================================================
module ysyx_23060136_EXU_TOP (
        input                                                     clk                          ,
        input                                                     rst                          ,
        input                                                     FORWARD_stallEX1             ,

        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_pc                     ,
        input              [  `ysyx_23060136_INST_W-1 :0]         EXU_i_inst                   ,
        input                                                     EXU_i_commit                 ,
        input              [  `ysyx_23060136_GPR_W-1  :0]         EXU_i_rd                     ,
        input              [  `ysyx_23060136_GPR_W-1  :0]         EXU_i_rs1                    ,
        input              [  `ysyx_23060136_GPR_W-1  :0]         EXU_i_rs2                    ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_imm                    ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_rs1_data               ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_rs2_data               ,
        input              [  `ysyx_23060136_CSR_W-1:0  ]         EXU_i_csr_rd_1               ,
        input              [  `ysyx_23060136_CSR_W-1:0  ]         EXU_i_csr_rd_2               ,
        input              [  `ysyx_23060136_CSR_W-1:0  ]         EXU_i_csr_rs                 ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_csr_rs_data            ,

        // ===========================================================================
        // ALU
        input                                                     EXU_i_ALU_word_t             ,
        input                                                     EXU_i_ALU_add                ,
        input                                                     EXU_i_ALU_sub                ,
        input                                                     EXU_i_ALU_slt                ,
        input                                                     EXU_i_ALU_sltu               ,
        input                                                     EXU_i_ALU_or                 ,
        input                                                     EXU_i_ALU_and                ,
        input                                                     EXU_i_ALU_xor                ,
        input                                                     EXU_i_ALU_sll                ,
        input                                                     EXU_i_ALU_srl                ,
        input                                                     EXU_i_ALU_sra                ,
        input                                                     EXU_i_ALU_mul                ,
        input                                                     EXU_i_ALU_mul_hi             ,
        input                                                     EXU_i_ALU_mul_lo             ,
        input                                                     EXU_i_ALU_mul_u              ,
        input                                                     EXU_i_ALU_mul_s              ,
        input                                                     EXU_i_ALU_mul_su             ,
        input                                                     EXU_i_ALU_div                ,
        input                                                     EXU_i_ALU_div_u              ,
        input                                                     EXU_i_ALU_div_s              ,
        input                                                     EXU_i_ALU_rem                ,
        input                                                     EXU_i_ALU_rem_u              ,
        input                                                     EXU_i_ALU_rem_s              ,
        input                                                     EXU_i_ALU_explicit           ,
        
        input                                                     EXU_i_ALU_i1_rs1             ,
        input                                                     EXU_i_ALU_i1_pc              ,
        input                                                     EXU_i_ALU_i2_rs2             ,
        input                                                     EXU_i_ALU_i2_imm             ,
        input                                                     EXU_i_ALU_i2_4               ,
        input                                                     EXU_i_ALU_i2_csr             ,
        // ===========================================================================
        input                                                     EXU_i_jump                   ,
        input                                                     EXU_i_pc_plus_imm            ,
        input                                                     EXU_i_rs1_plus_imm           ,
        input                                                     EXU_i_csr_plus_imm           ,
        input                                                     EXU_i_cmp_eq                 ,
        input                                                     EXU_i_cmp_neq                ,
        input                                                     EXU_i_cmp_ge                 ,
        input                                                     EXU_i_cmp_lt                 ,

        input                                                     EXU_i_write_gpr              ,
        input                                                     EXU_i_write_csr_1            ,
        input                                                     EXU_i_write_csr_2            ,
        input                                                     EXU_i_mem_to_reg             ,
        input                                                     EXU_i_rv64_csrrs             ,
        input                                                     EXU_i_rv64_csrrw             ,
        input                                                     EXU_i_rv64_ecall             ,

        input                                                     EXU_i_write_mem              ,
        input                                                     EXU_i_mem_byte               ,
        input                                                     EXU_i_mem_half               ,
        input                                                     EXU_i_mem_word               ,
        input                                                     EXU_i_mem_dword              ,
        input                                                     EXU_i_mem_byte_u             ,
        input                                                     EXU_i_mem_half_u             ,
        input                                                     EXU_i_mem_word_u             ,

        input                                                     EXU_i_system_halt            ,

        // Forward to ALU input
        input              [  `ysyx_23060136_BITS_W-1 :0]         FORWARD_rs1_data_EXU_1       ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         FORWARD_rs2_data_EXU_1       ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         FORWARD_csr_rs_data_EXU_1    ,
        input                                                     FORWARD_rs1_hazard_EXU_1     ,
        input                                                     FORWARD_rs2_hazard_EXU_1     ,
        input                                                     FORWARD_csr_rs_hazard_EXU_1  ,
        
        // ===========================================================================
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_pc                   ,
        output             [  `ysyx_23060136_INST_W-1 :0]         EXU_o_inst                 ,
        // mem
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_ALU_ALUout           ,
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_ALU_CSR_out          ,
        output                                                    EXU_o_commit               ,
        // IFU
        output             [  `ysyx_23060136_BITS_W-1 :0]         BRANCH_branch_target       ,
        output                                                    BRANCH_PCSrc               ,
        output                                                    BRANCH_flushIF             ,
        output                                                    BRANCH_flushID             ,
        // ===========================================================================
        // origin signal pushed to the next stage
        // mem
        output             [   `ysyx_23060136_GPR_W-1:0]          EXU_o_rd                 ,
        // forward unit will use the rs
        output             [   `ysyx_23060136_GPR_W-1:0]          EXU_o_rs1                ,
        output             [   `ysyx_23060136_GPR_W-1:0]          EXU_o_rs2                ,
        // mem write data
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_HAZARD_rs2_data    ,
        output             [   `ysyx_23060136_CSR_W-1:0]          EXU_o_csr_rd_1           ,
        output             [   `ysyx_23060136_CSR_W-1:0]          EXU_o_csr_rd_2           ,
        // forward unit
        output             [   `ysyx_23060136_CSR_W-1:0]          EXU_o_csr_rs             ,
        // mem
        output                                                    EXU_o_write_gpr          ,
        output                                                    EXU_o_write_csr_1        ,
        output                                                    EXU_o_write_csr_2        ,
        output                                                    EXU_o_mem_to_reg         ,

        output                                                    EXU_o_write_mem          ,
        output                                                    EXU_o_mem_byte           ,
        output                                                    EXU_o_mem_half           ,
        output                                                    EXU_o_mem_word           ,
        output                                                    EXU_o_mem_dword          ,
        output                                                    EXU_o_mem_byte_u         ,
        output                                                    EXU_o_mem_half_u         ,
        output                                                    EXU_o_mem_word_u         ,

        output                                                    EXU_o_system_halt        

    );

    // internal signal
    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU_HAZARD_rs1_data;
    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU_HAZARD_csr_rs_data;

    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU_ALU_da;
    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU_ALU_db;

    wire                      EXU_ALU_Less;
    wire                      EXU_ALU_Zero;

    // transmit directly
    assign    EXU_o_commit       = EXU_i_commit;
    assign    EXU_o_pc           = EXU_i_pc;
    assign    EXU_o_inst         = EXU_i_inst;
    assign    EXU_o_rd           = EXU_i_rd;
    assign    EXU_o_rs1          = EXU_i_rs1;
    assign    EXU_o_rs2          = EXU_i_rs2;
    assign    EXU_o_csr_rd       = EXU_i_csr_rd;
    assign    EXU_o_csr_rs       = EXU_i_csr_rs;
    assign    EXU_o_write_gpr    = EXU_i_write_gpr;
    assign    EXU_o_write_csr    = EXU_i_write_csr;
    assign    EXU_o_mem_to_reg   = EXU_i_mem_to_reg;

    assign    EXU_o_write_mem    = EXU_i_write_mem;
    assign    EXU_o_mem_byte     = EXU_i_mem_byte;
    assign    EXU_o_mem_half     = EXU_i_mem_half;
    assign    EXU_o_mem_word     = EXU_i_mem_word;
    assign    EXU_o_mem_byte_u   = EXU_i_mem_byte_u;
    assign    EXU_o_mem_half_u   = EXU_i_mem_half_u;

    assign    EXU_o_system_halt  = EXU_i_system_halt;

    EXU_HAZARD_ysyx_23060136  EXU_HAZARD_ysyx_23060136_inst (
                                 .EXU_rs1_data                      (EXU_i_rs1_data            ),
                                 .EXU_rs2_data                      (EXU_i_rs2_data            ),
                                 .EXU_csr_rs_data                   (EXU_i_csr_rs_data         ),
                                 .EXU_pc                            (EXU_i_pc                  ),
                                 .EXU_imm                           (EXU_i_imm                 ),
                                 .FORWARD_rs1_data_EXU              (FORWARD_rs1_data_EXU      ),
                                 .FORWARD_rs2_data_EXU              (FORWARD_rs2_data_EXU      ),
                                 .FORWARD_csr_rs_data_EXU           (FORWARD_csr_rs_data_EXU   ),
                                 .FORWARD_rs1_hazard_EXU            (FORWARD_rs1_hazard_EXU    ),
                                 .FORWARD_rs2_hazard_EXU            (FORWARD_rs2_hazard_EXU    ),
                                 .FORWARD_csr_rs_hazard_EXU         (FORWARD_csr_rs_hazard_EXU ),
                                 .EXU_HAZARD_rs1_data               (EXU_HAZARD_rs1_data       ),
                                 .EXU_HAZARD_rs2_data               (EXU_o_HAZARD_rs2_data     ),
                                 .EXU_HAZARD_csr_rs_data            (EXU_HAZARD_csr_rs_data    ),
                                 .EXU_ALU_i1_rs1                    (EXU_i_ALU_i1_rs1          ),
                                 .EXU_ALU_i1_pc                     (EXU_i_ALU_i1_pc           ),
                                 .EXU_ALU_i2_rs2                    (EXU_i_ALU_i2_rs2          ),
                                 .EXU_ALU_i2_imm                    (EXU_i_ALU_i2_imm          ),
                                 .EXU_ALU_i2_4                      (EXU_i_ALU_i2_4            ),
                                 .EXU_ALU_i2_csr                    (EXU_i_ALU_i2_csr          ),
                                 .EXU_ALU_da                        (EXU_ALU_da                ),
                                 .EXU_ALU_db                        (EXU_ALU_db                )
                             );


    EXU_ALU_ysyx_23060136  EXU_ALU_ysyx_23060136_inst (
                              .EXU_ALU_da                        (EXU_ALU_da                ),
                              .EXU_ALU_db                        (EXU_ALU_db                ),
                              .EXU_ALU_add                       (EXU_i_ALU_add             ),
                              .EXU_ALU_sub                       (EXU_i_ALU_sub             ),
                              .EXU_ALU_slt                       (EXU_i_ALU_slt             ),
                              .EXU_ALU_sltu                      (EXU_i_ALU_sltu            ),
                              .EXU_ALU_or                        (EXU_i_ALU_or              ),
                              .EXU_ALU_and                       (EXU_i_ALU_and             ),
                              .EXU_ALU_xor                       (EXU_i_ALU_xor             ),
                              .EXU_ALU_sll                       (EXU_i_ALU_sll             ),
                              .EXU_ALU_srl                       (EXU_i_ALU_srl             ),
                              .EXU_ALU_sra                       (EXU_i_ALU_sra             ),
                              .EXU_ALU_explicit                  (EXU_i_ALU_explicit        ),
                              .EXU_ALU_Less                      (EXU_ALU_Less              ),
                              .EXU_ALU_Zero                      (EXU_ALU_Zero              ),
                              .EXU_ALU_ALUout                    (EXU_o_ALU_ALUout          ),
                              .EXU_pc                            (EXU_i_pc                  ),
                              .EXU_HAZARD_rs1_data               (EXU_HAZARD_rs1_data       ),
                              .EXU_HAZARD_csr_rs_data            (EXU_HAZARD_csr_rs_data    ),
                              .EXU_rv32_csrrs                    (EXU_i_rv32_csrrs          ),
                              .EXU_rv32_csrrw                    (EXU_i_rv32_csrrw          ),
                              .EXU_rv32_ecall                    (EXU_i_rv32_ecall          ),
                              .EXU_ALU_CSR_out                   (EXU_o_ALU_CSR_out         )
                          );



    EXU_BRANCH_ysyx_23060136  EXU_BRANCH_ysyx_23060136_inst (
                                 .EXU_pc                            (EXU_i_pc                  ),
                                 .EXU_HAZARD_rs1_data               (EXU_HAZARD_rs1_data       ),
                                 .EXU_HAZARD_csr_rs_data            (EXU_HAZARD_csr_rs_data    ),
                                 .EXU_imm                           (EXU_i_imm                 ),
                                 .EXU_ALU_Less                      (EXU_ALU_Less              ),
                                 .EXU_ALU_Zero                      (EXU_ALU_Zero              ),
                                 .EXU_jump                          (EXU_i_jump                ),
                                 .EXU_pc_plus_imm                   (EXU_i_pc_plus_imm         ),
                                 .EXU_rs1_plus_imm                  (EXU_i_rs1_plus_imm        ),
                                 .EXU_csr_plus_imm                  (EXU_i_csr_plus_imm        ),
                                 .EXU_cmp_eq                        (EXU_i_cmp_eq              ),
                                 .EXU_cmp_neq                       (EXU_i_cmp_neq             ),
                                 .EXU_cmp_ge                        (EXU_i_cmp_ge              ),
                                 .EXU_cmp_lt                        (EXU_i_cmp_lt              ),
                                 .branch_target                     (BRANCH_branch_target      ),
                                 .PCSrc                             (BRANCH_PCSrc              ),
                                 .BRANCH_flushIF                    (BRANCH_flushIF            ),
                                 .BRANCH_flushID                    (BRANCH_flushID            )
                             );


endmodule


