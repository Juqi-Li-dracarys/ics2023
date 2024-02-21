/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 21:16:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-22 00:38:40
 */



module IDU_EXU_SEG_REG_ysyx23060136(
        input                  clk,
        input                  rst,
        // ===========================================================================
        // hand shake
        output                  IDU_ready,
        output                  IDU_valid,
        // forward unit signal
        input                  FORWARD_flushIF,
        input                  FORWARD_stallID,
        // general data
        input     [31 : 0]     IDU_pc_EXU,
        input     [4 : 0]      IDU_rd,
        input     [4 : 0]      IDU_rs1,
        input     [4 : 0]      IDU_rs2,
        input     [31 : 0]     IDU_imm,
        input     [31 : 0]     IDU_rs1_data,
        input     [31 : 0]     IDU_rs2_data,
        input     [1 : 0]      IDU_csr_rd,
        input     [31 : 0]     IDU_csr_rs_data,
        // ===========================================================================
        // ALU signal
        input                  ALU_add,
        input                  ALU_sub,
        input                  ALU_slt,
        input                  ALU_sltu,
        input                  ALU_or,
        input                  ALU_and,
        input                  ALU_xor,
        input                  ALU_sll,
        input                  ALU_srl,
        input                  ALU_sra,
        input                  ALU_explicit,
        input                  ALU_i1_rs1,
        input                  ALU_i1_pc,
        input                  ALU_i2_rs2,
        input                  ALU_i2_imm,
        input                  ALU_i2_4,
        input                  ALU_i2_csr,
        // ===========================================================================
        // jump signal
        input                  jump,
        input                  pc_plus_imm,
        input                  rs1_plus_imm,
        input                  csr_plus_imm,
        // ===========================================================================
        // write back
        input                  write_gpr,
        input                  write_csr,
        input                  mem_to_reg,
        input                  rv32_csrrs,
        input                  rv32_csrrw,
        input                  rv32_ecall,
        // ===========================================================================
        // mem
        input                  write_mem,
        input                  mem_byte,
        input                  mem_half,
        input                  mem_word,
        input                  mem_byte_u,
        input                  mem_half_u,
        // ===========================================================================
        // system
        input                  system_halt,
        input                  op_valid
        
    );

    


endmodule



