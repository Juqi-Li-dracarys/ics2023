/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-19 13:23:33 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 20:36:35
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
        // data
        output     [31 : 0]     IDU_pc_n,
        output     [4 : 0]      IDU_rd,
        output     [4 : 0]      IDU_rs1,
        output     [4 : 0]      IDU_rs2,
        output     [31 : 0]     IDU_imm,
        output     [31 : 0]     IDU_rs1_data,
        output     [31 : 0]     IDU_rs2_data,
        output     [1 : 0]      IDU_csr_rd,
        output     [31 : 0]     IDU_csr_rs_data,
        
        // ===========================================================================
        // ALU signal
        output                  ALU_add,
        output                  ALU_sub,
        output                  ALU_slt,
        output                  ALU_sltu,
        output                  ALU_or,
        output                  ALU_and,
        output                  ALU_xor,
        output                  ALU_sll,
        output                  ALU_srl,
        output                  ALU_sra,
        output                  ALU_explicit,
        output                  ALU_i1_rs1,
        output                  ALU_i1_pc,
        output                  ALU_i2_rs2,
        output                  ALU_i2_imm,
        output                  ALU_i2_4,
        output                  ALU_i2_csr,
        // ===========================================================================
        // jump signal
        output                  jump,
        output                  pc_plus_imm,
        output                  rs1_plus_imm,
        output                  csr_plus_imm,
        // ===========================================================================
        // write back
        output                  write_gpr,
        output                  write_csr,
        output                  mem_to_reg,
        // ===========================================================================
        // mem
        output                  write_mem,
        output                  mem_byte,
        output                  mem_half,
        output                  mem_word,
        output                  mem_byte_u,
        output                  mem_half_u,
        // ===========================================================================
        // system
        output                  system_halt,
        output                  op_valid
    );


       logic     [11 : 0]       IDU_csr_id;
       logic     [1 : 0]        IDU_csr_rs;
       logic                    op_R_type;
       logic                    op_I_type;
       logic                    op_B_type;
       logic                    op_J_type;
       logic                    op_U_type;
       logic                    op_S_type;


       assign                   IDU_valid    =       `true;
       assign                   IDU_ready    =       `true;
       assign                   IDU_pc_n     =        IDU_pc;


    IDU_DECODE_ysyx23060136  IDU_DECODE_ysyx23060136_inst (
                                 .IDU_inst(IDU_inst),
                                 .IDU_rd(IDU_rd),
                                 .IDU_rs1(IDU_rs1),
                                 .IDU_rs2(IDU_rs2),
                                 .IDU_csr_id(IDU_csr_id),
                                 .ALU_add(ALU_add),
                                 .ALU_sub(ALU_sub),
                                 .ALU_slt(ALU_slt),
                                 .ALU_sltu(ALU_sltu),
                                 .ALU_or(ALU_or),
                                 .ALU_and(ALU_and),
                                 .ALU_xor(ALU_xor),
                                 .ALU_sll(ALU_sll),
                                 .ALU_srl(ALU_srl),
                                 .ALU_sra(ALU_sra),
                                 .ALU_explicit(ALU_explicit),
                                 .ALU_i1_rs1(ALU_i1_rs1),
                                 .ALU_i1_pc(ALU_i1_pc),
                                 .ALU_i2_rs2(ALU_i2_rs2),
                                 .ALU_i2_imm(ALU_i2_imm),
                                 .ALU_i2_4(ALU_i2_4),
                                 .ALU_i2_csr(ALU_i2_csr),
                                 .op_R_type(op_R_type),
                                 .op_I_type(op_I_type),
                                 .op_B_type(op_B_type),
                                 .op_J_type(op_J_type),
                                 .op_U_type(op_U_type),
                                 .op_S_type(op_S_type),
                                 .jump(jump),
                                 .pc_plus_imm(pc_plus_imm),
                                 .rs1_plus_imm(rs1_plus_imm),
                                 .csr_plus_imm(csr_plus_imm),
                                 .write_gpr(write_gpr),
                                 .write_csr(write_csr),
                                 .mem_to_reg(mem_to_reg),
                                 .write_mem(write_mem),
                                 .mem_byte(mem_byte),
                                 .mem_half(mem_half),
                                 .mem_word(mem_word),
                                 .mem_byte_u(mem_byte_u),
                                 .mem_half_u(mem_half_u),
                                 .system_halt(system_halt)
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
                                   .op_valid(op_valid)
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



