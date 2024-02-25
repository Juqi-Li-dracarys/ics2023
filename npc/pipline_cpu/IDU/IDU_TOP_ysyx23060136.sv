/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-19 13:23:33 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-24 00:24:39
 */


`include "IDU_DEFINES_ysyx23060136.sv"


// top module of IDU
// ===========================================================================
module IDU_TOP_ysyx23060136 (
        input                   clk,
        input                   rst,
        input      [31 : 0]     IDU_pc,
        input      [31 : 0]     IDU_inst,
        // ===========================================================================
        // WBU write back
        input      [4 : 0]      WBU_rd,
        input                   RegWr,
        input      [31 : 0]     rf_busW,
        input      [1 : 0]      WBU_csr_rd,
        input                   CSRWr,
        input      [31 : 0]     csr_busW,
        // ===========================================================================
        // hand shake
        output                  IDU_ready,
        output                  IDU_valid,
        // ===========================================================================
        // general data
        output     [31 : 0]     IDU_pc_EXU, // push singnal to the next stage
        output     [4 : 0]      IDU_rd,
        output     [4 : 0]      IDU_rs1,
        output     [4 : 0]      IDU_rs2,
        output     [31 : 0]     IDU_imm,
        output     [31 : 0]     IDU_rs1_data,
        output     [31 : 0]     IDU_rs2_data,
        output     [1 : 0]      IDU_csr_rd,
        output     [1 : 0]      IDU_csr_rs,
        output     [31 : 0]     IDU_csr_rs_data,
        // ===========================================================================
        // ALU signal
        output                  IDU_ALU_add,
        output                  IDU_ALU_sub,
        output                  IDU_ALU_slt,
        output                  IDU_ALU_sltu,
        output                  IDU_ALU_or,
        output                  IDU_ALU_and,
        output                  IDU_ALU_xor,
        output                  IDU_ALU_sll,
        output                  IDU_ALU_srl,
        output                  IDU_ALU_sra,
        output                  IDU_ALU_explicit,
        output                  IDU_ALU_i1_rs1,
        output                  IDU_ALU_i1_pc,
        output                  IDU_ALU_i2_rs2,
        output                  IDU_ALU_i2_imm,
        output                  IDU_ALU_i2_4,
        output                  IDU_ALU_i2_csr,
        // ===========================================================================
        // jump signal
        output                  IDU_jump,
        output                  IDU_pc_plus_imm,
        output                  IDU_rs1_plus_imm,
        output                  IDU_csr_plus_imm,
        output                  IDU_cmp_eq,
        output                  IDU_cmp_neq,
        output                  IDU_cmp_ge,
        output                  IDU_cmp_lt,
        // ===========================================================================
        // write back
        output                  IDU_write_gpr,
        output                  IDU_write_csr,
        output                  IDU_mem_to_reg,
        output                  IDU_rv32_csrrs,
        output                  IDU_rv32_csrrw,
        output                  IDU_rv32_ecall,
        // ===========================================================================
        // mem
        output                  IDU_write_mem,
        output                  IDU_mem_byte,
        output                  IDU_mem_half,
        output                  IDU_mem_word,
        output                  IDU_mem_byte_u,
        output                  IDU_mem_half_u,
        // ===========================================================================
        // system
        output                  IDU_system_halt,
        output                  IDU_op_valid
    );


    logic     [11 : 0]       IDU_csr_id;
    logic                    op_R_type;
    logic                    op_I_type;
    logic                    op_B_type;
    logic                    op_J_type;
    logic                    op_U_type;
    logic                    op_S_type;


    assign                   IDU_valid    =       `true;
    assign                   IDU_ready    =       `true;
    assign                   IDU_pc_EXU   =        IDU_pc;


    IDU_DECODE_ysyx23060136  IDU_DECODE_ysyx23060136_inst (
                                 .IDU_inst(IDU_inst),
                                 .IDU_rd(IDU_rd),
                                 .IDU_rs1(IDU_rs1),
                                 .IDU_rs2(IDU_rs2),
                                 .IDU_csr_id(IDU_csr_id),
                                 .ALU_add(IDU_ALU_add),
                                 .ALU_sub(IDU_ALU_sub),
                                 .ALU_slt(IDU_ALU_slt),
                                 .ALU_sltu(IDU_ALU_sltu),
                                 .ALU_or(IDU_ALU_or),
                                 .ALU_and(IDU_ALU_and),
                                 .ALU_xor(IDU_ALU_xor),
                                 .ALU_sll(IDU_ALU_sll),
                                 .ALU_srl(IDU_ALU_srl),
                                 .ALU_sra(IDU_ALU_sra),
                                 .ALU_explicit(IDU_ALU_explicit),
                                 .ALU_i1_rs1(IDU_ALU_i1_rs1),
                                 .ALU_i1_pc(IDU_ALU_i1_pc),
                                 .ALU_i2_rs2(IDU_ALU_i2_rs2),
                                 .ALU_i2_imm(IDU_ALU_i2_imm),
                                 .ALU_i2_4(IDU_ALU_i2_4),
                                 .ALU_i2_csr(IDU_ALU_i2_csr),
                                 .op_R_type(op_R_type),
                                 .op_I_type(op_I_type),
                                 .op_B_type(op_B_type),
                                 .op_J_type(op_J_type),
                                 .op_U_type(op_U_type),
                                 .op_S_type(op_S_type),
                                 .jump(IDU_jump),
                                 .pc_plus_imm(IDU_pc_plus_imm),
                                 .rs1_plus_imm(IDU_rs1_plus_imm),
                                 .csr_plus_imm(IDU_csr_plus_imm),

                                 .cmp_eq(IDU_cmp_eq),
                                 .cmp_neq(IDU_cmp_neq),
                                 .cmp_ge(IDU_cmp_ge),
                                 .cmp_lt(IDU_cmp_lt),

                                 .write_gpr(IDU_write_gpr),
                                 .write_csr(IDU_write_csr),
                                 .mem_to_reg(IDU_mem_to_reg),
                                 .rv32_csrrs(IDU_rv32_csrrs),
                                 .rv32_csrrw(IDU_rv32_csrrw),
                                 .rv32_ecall(IDU_rv32_ecall),
                                 .write_mem(IDU_write_mem),
                                 .mem_byte(IDU_mem_byte),
                                 .mem_half(IDU_mem_half),
                                 .mem_word(IDU_mem_word),
                                 .mem_byte_u(IDU_mem_byte_u),
                                 .mem_half_u(IDU_mem_half_u),
                                 .system_halt(IDU_system_halt)
                             );

    IDU_IMM_GEN_ysyx_23060136  IDU_IMM_GEN_ysyx_23060136_inst (
                                   .IDU_inst(IDU_inst),
                                   .op_R_type(op_R_type),
                                   .op_I_type(op_I_type),
                                   .op_B_type(op_B_type),
                                   .op_J_type(op_J_type),
                                   .op_U_type(op_U_type),
                                   .op_S_type(op_S_type),
                                   .IDU_imm(IDU_imm),
                                   .op_valid(IDU_op_valid)
                               );

    IDU_GPR_FILE_ysyx_23060136  IDU_GPR_FILE_ysyx_23060136_inst (
                                    .clk(clk),
                                    .rst(rst),
                                    .IDU_rs1(IDU_rs1),
                                    .IDU_rs2(IDU_rs2),
                                    .WBU_rd(WBU_rd),
                                    .RegWr(RegWr),
                                    .rf_busW(rf_busW),
                                    .IDU_rs1_data(IDU_rs1_data),
                                    .IDU_rs2_data(IDU_rs2_data)
                                );

    IDU_CSR_FILE_ysyx_23060136  IDU_CSR_FILE_ysyx_23060136_inst (
                                    .clk(clk),
                                    .rst(rst),
                                    .IDU_csr_rs(IDU_csr_rs),
                                    .WBU_csr_rd(WBU_csr_rd),
                                    .CSRWr(CSRWr),
                                    .csr_busW(csr_busW),
                                    .IDU_csr_rs_data(IDU_csr_rs_data)
                                );

    IDU_CSR_DECODE_ysyx_23060136  IDU_CSR_DECODE_ysyx_23060136_inst (
                                      .IDU_csr_id(IDU_csr_id),
                                      .IDU_csr_rs(IDU_csr_rs),
                                      .IDU_csr_rd(IDU_csr_rd)
                                  );

endmodule



