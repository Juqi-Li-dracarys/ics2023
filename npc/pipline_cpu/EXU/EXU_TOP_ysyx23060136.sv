/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 01:41:27 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-24 01:48:14
 */

module EXU_TOP_ysyx23060136 (



    );
    EXU_HAZARD_ysyx23060136  EXU_HAZARD_ysyx23060136_inst (
                                 .EXU_rs1_data(EXU_rs1_data),
                                 .EXU_rs2_data(EXU_rs2_data),
                                 .EXU_csr_rs_data(EXU_csr_rs_data),
                                 .EXU_pc(EXU_pc),
                                 .EXU_imm(EXU_imm),
                                 .FORWARD_rs1_data(FORWARD_rs1_data),
                                 .FORWARD_rs2_data(FORWARD_rs2_data),
                                 .FORWARD_csr_rs_data(FORWARD_csr_rs_data),
                                 .FORWARD_rs1_hazard(FORWARD_rs1_hazard),
                                 .FORWARD_rs2_hazard(FORWARD_rs2_hazard),
                                 .FORWARD_csr_rs_hazard(FORWARD_csr_rs_hazard),
                                 .EXU_HAZARD_rs1_data(EXU_HAZARD_rs1_data),
                                 .EXU_HAZARD_rs2_data(EXU_HAZARD_rs2_data),
                                 .EXU_HAZARD_csr_rs_data(EXU_HAZARD_csr_rs_data),
                                 .EXU_ALU_i1_rs1(EXU_ALU_i1_rs1),
                                 .EXU_ALU_i1_pc(EXU_ALU_i1_pc),
                                 .EXU_ALU_i2_rs2(EXU_ALU_i2_rs2),
                                 .EXU_ALU_i2_imm(EXU_ALU_i2_imm),
                                 .EXU_ALU_i2_4(EXU_ALU_i2_4),
                                 .EXU_ALU_i2_csr(EXU_ALU_i2_csr),
                                 .EXU_ALU_da(EXU_ALU_da),
                                 .EXU_ALU_db(EXU_ALU_db)
                             );

    EXU_ALU_ysyx23060136  EXU_ALU_ysyx23060136_inst (
                              .EXU_ALU_da(EXU_ALU_da),
                              .EXU_ALU_db(EXU_ALU_db),
                              .EXU_ALU_add(EXU_ALU_add),
                              .EXU_ALU_sub(EXU_ALU_sub),
                              .EXU_ALU_slt(EXU_ALU_slt),
                              .EXU_ALU_sltu(EXU_ALU_sltu),
                              .EXU_ALU_or(EXU_ALU_or),
                              .EXU_ALU_and(EXU_ALU_and),
                              .EXU_ALU_xor(EXU_ALU_xor),
                              .EXU_ALU_sll(EXU_ALU_sll),
                              .EXU_ALU_srl(EXU_ALU_srl),
                              .EXU_ALU_sra(EXU_ALU_sra),
                              .EXU_ALU_explicit(EXU_ALU_explicit),
                              .EXU_ALU_Less(EXU_ALU_Less),
                              .EXU_ALU_Zero(EXU_ALU_Zero),
                              .EXU_ALU_ALUout(EXU_ALU_ALUout),
                              .EXU_ALU_valid(EXU_ALU_valid)
                          );

    EXU_ALU_CSR_ysyx23060136  EXU_ALU_CSR_ysyx23060136_inst (
                                  .EXU_pc(EXU_pc),
                                  .EXU_HAZARD_rs1_data(EXU_HAZARD_rs1_data),
                                  .EXU_HAZARD_csr_rs_data(EXU_HAZARD_csr_rs_data),
                                  .EXU_rv32_csrrs(EXU_rv32_csrrs),
                                  .EXU_rv32_csrrw(EXU_rv32_csrrw),
                                  .EXU_rv32_ecall(EXU_rv32_ecall),
                                  .EXU_ALU_CSR_out(EXU_ALU_CSR_out)
                              );

    EXU_BRANCH_ysyx23060136  EXU_BRANCH_ysyx23060136_inst (
                                 .EXU_pc(EXU_pc),
                                 .EXU_HAZARD_rs1_data(EXU_HAZARD_rs1_data),
                                 .EXU_HAZARD_csr_rs_data(EXU_HAZARD_csr_rs_data),
                                 .EXU_imm(EXU_imm),
                                 .EXU_ALU_Less(EXU_ALU_Less),
                                 .EXU_ALU_Zero(EXU_ALU_Zero),
                                 .EXU_jump(EXU_jump),
                                 .EXU_pc_plus_imm(EXU_pc_plus_imm),
                                 .EXU_rs1_plus_imm(EXU_rs1_plus_imm),
                                 .EXU_csr_plus_imm(EXU_csr_plus_imm),
                                 .EXU_cmp_eq(EXU_cmp_eq),
                                 .EXU_cmp_neq(EXU_cmp_neq),
                                 .EXU_cmp_ge(EXU_cmp_ge),
                                 .EXU_cmp_lt(EXU_cmp_lt),
                                 .branch_target(branch_target),
                                 .PCSrc(PCSrc),
                                 .BRANCH_flushIF(BRANCH_flushIF),
                                 .BRANCH_flushID(BRANCH_flushID)
                             );


endmodule


