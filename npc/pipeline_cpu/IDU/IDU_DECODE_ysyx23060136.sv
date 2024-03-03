/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-18 20:50:42
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-24 00:28:27
 */

 `include "DEFINES_ysyx23060136.sv"

// basic decode unit
// first stage decoder of CPU
// Support ISA: riscv32-e

/* verilator lint_off UNUSED */

// ===========================================================================
module IDU_DECODE_ysyx23060136(
    input              [  31:0]         IDU_inst                   ,
    // ===========================================================================
    // REG addr
    output             [   4:0]         IDU_rd                     ,
    output             [   4:0]         IDU_rs1                    ,
    output             [   4:0]         IDU_rs2                    ,
    output             [  11:0]         IDU_csr_id                 ,
    // ===========================================================================
    // ALU calculating type define
    output                              ALU_add                    ,
    output                              ALU_sub                    ,
    // 带符号小于
    output                              ALU_slt                    ,
    // 无符号小于
    output                              ALU_sltu                   ,
    // 与或异或运算
    output                              ALU_or                     ,
    output                              ALU_and                    ,
    output                              ALU_xor                    ,
    // 移位运算
    output                              ALU_sll                    ,
    output                              ALU_srl                    ,
    output                              ALU_sra                    ,
    // 直接输出
    output                              ALU_explicit               ,
    // ===========================================================================
    // ALU input 1, input 2 type
    output                              ALU_i1_rs1                 ,
    output                              ALU_i1_pc                  ,

    output                              ALU_i2_rs2                 ,
    output                              ALU_i2_imm                 ,
    output                              ALU_i2_4                   ,
    output                              ALU_i2_csr                 ,
    // ===========================================================================
    // OP type
    output                              op_R_type                  ,
    output                              op_I_type                  ,
    output                              op_B_type                  ,
    output                              op_J_type                  ,
    output                              op_U_type                  ,
    output                              op_S_type                  ,
    // ===========================================================================
    // jump
    output                              jump                       ,
    output                              pc_plus_imm                ,
    output                              rs1_plus_imm               ,
    output                              csr_plus_imm               ,
    output                              cmp_eq                     ,
    output                              cmp_neq                    ,
    output                              cmp_ge                     ,
    output                              cmp_lt                     ,
    // ===========================================================================
    // write/read register
    output                              write_gpr                  ,
    output                              write_csr                  ,
    output                              mem_to_reg                 ,
    // we wiil handle csr write date in the next stage
    output                              rv32_csrrs                 ,
    output                              rv32_csrrw                 ,
    output                              rv32_ecall                 ,
    // ===========================================================================
    // write/read memory
    output                              write_mem                  ,
    output                              mem_byte                   ,
    output                              mem_half                   ,
    output                              mem_word                   ,
    output                              mem_byte_u                 ,
    output                              mem_half_u                 ,
    // ===========================================================================
    // halt
    output                              system_halt                 

) ;


    // ===========================================================================
    wire  [6 : 0]  opcode      =   IDU_inst[6 : 0];
    assign         IDU_rd      =   IDU_inst[11 : 7];
    wire  [2 : 0]  func3       =   IDU_inst[14 : 12];
    assign         IDU_rs1     =   IDU_inst[19 : 15];
    assign         IDU_rs2     =   IDU_inst[24 : 20];
    wire  [6 : 0]  func7       =   IDU_inst[31 : 25];
    assign         IDU_csr_id  =   IDU_inst[31 : 20];

    wire  opcode_1_0_00  = (opcode[1 : 0] == 2'b00);
    wire  opcode_1_0_01  = (opcode[1 : 0] == 2'b01);
    wire  opcode_1_0_10  = (opcode[1 : 0] == 2'b10);
    wire  opcode_1_0_11  = (opcode[1 : 0] == 2'b11);

    wire  opcode_4_2_000 = (opcode[4 : 2] == 3'b000);
    wire  opcode_4_2_001 = (opcode[4 : 2] == 3'b001);
    wire  opcode_4_2_010 = (opcode[4 : 2] == 3'b010);
    wire  opcode_4_2_011 = (opcode[4 : 2] == 3'b011);
    wire  opcode_4_2_100 = (opcode[4 : 2] == 3'b100);
    wire  opcode_4_2_101 = (opcode[4 : 2] == 3'b101);
    wire  opcode_4_2_110 = (opcode[4 : 2] == 3'b110);
    wire  opcode_4_2_111 = (opcode[4 : 2] == 3'b111);
    
    wire  opcode_6_5_00  = (opcode[6 : 5] == 2'b00);
    wire  opcode_6_5_01  = (opcode[6 : 5] == 2'b01);
    wire  opcode_6_5_10  = (opcode[6 : 5] == 2'b10);
    wire  opcode_6_5_11  = (opcode[6 : 5] == 2'b11);
  
    wire  func3_000 = (func3 == 3'b000);
    wire  func3_001 = (func3 == 3'b001);
    wire  func3_010 = (func3 == 3'b010);
    wire  func3_011 = (func3 == 3'b011);
    wire  func3_100 = (func3 == 3'b100);
    wire  func3_101 = (func3 == 3'b101);
    wire  func3_110 = (func3 == 3'b110);
    wire  func3_111 = (func3 == 3'b111);

    wire  func7_0000000 = (func7 == 7'b0000000);
    wire  func7_0100000 = (func7 == 7'b0100000);

    wire  func7_0000001 = (func7 == 7'b0000001);
    wire  func7_0000101 = (func7 == 7'b0000101);
    wire  func7_0001001 = (func7 == 7'b0001001);
    wire  func7_0001101 = (func7 == 7'b0001101);
    wire  func7_0010101 = (func7 == 7'b0010101);
    wire  func7_0100001 = (func7 == 7'b0100001);
    wire  func7_0010001 = (func7 == 7'b0010001);
    wire  func7_0101101 = (func7 == 7'b0101101);
    wire  func7_1111111 = (func7 == 7'b1111111);
    wire  func7_0000100 = (func7 == 7'b0000100);
    wire  func7_0001000 = (func7 == 7'b0001000);
    wire  func7_0001100 = (func7 == 7'b0001100);
    wire  func7_0101100 = (func7 == 7'b0101100);
    wire  func7_0010000 = (func7 == 7'b0010000);
    wire  func7_0010100 = (func7 == 7'b0010100);
    wire  func7_1100000 = (func7 == 7'b1100000);
    wire  func7_1110000 = (func7 == 7'b1110000);
    wire  func7_1010000 = (func7 == 7'b1010000);
    wire  func7_1101000 = (func7 == 7'b1101000);
    wire  func7_1111000 = (func7 == 7'b1111000);
    wire  func7_1010001 = (func7 == 7'b1010001);
    wire  func7_1110001 = (func7 == 7'b1110001);
    wire  func7_1100001 = (func7 == 7'b1100001);
    wire  func7_1101001 = (func7 == 7'b1101001);




    // ===========================================================================
    // ALU IDU_Instructions are relative to imm(I type)
    wire  rv32_op_i   = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;
    wire  rv32_addi     =  rv32_op_i  &  func3_000;
    wire  rv32_slti     =  rv32_op_i  &  func3_010;
    wire  rv32_sltiu    =  rv32_op_i  &  func3_011;
    wire  rv32_xori     =  rv32_op_i  &  func3_100;
    wire  rv32_ori      =  rv32_op_i  &  func3_110;
    wire  rv32_andi     =  rv32_op_i  &  func3_111;
    wire  rv32_slli     =  rv32_op_i  &  func3_001 & (IDU_inst[31 : 26] == 6'b000000);
    wire  rv32_srli     =  rv32_op_i  &  func3_101 & (IDU_inst[31 : 26] == 6'b000000);
    wire  rv32_srai     =  rv32_op_i  &  func3_101 & (IDU_inst[31 : 26] == 6'b010000);

    
    // ===========================================================================
    // ALU IDU_Instructions are relative to register(R type)
    wire  rv32_op_r     =  opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;
    wire  rv32_add      =  rv32_op_r  &  func3_000  &  func7_0000000;
    wire  rv32_sub      =  rv32_op_r  &  func3_000  &  func7_0100000;
    wire  rv32_sll      =  rv32_op_r  &  func3_001  &  func7_0000000;
    wire  rv32_slt      =  rv32_op_r  &  func3_010  &  func7_0000000;
    wire  rv32_sltu     =  rv32_op_r  &  func3_011  &  func7_0000000;
    wire  rv32_xor      =  rv32_op_r  &  func3_100  &  func7_0000000;
    wire  rv32_srl      =  rv32_op_r  &  func3_101  &  func7_0000000;
    wire  rv32_sra      =  rv32_op_r  &  func3_101  &  func7_0100000;
    wire  rv32_or       =  rv32_op_r  &  func3_110  &  func7_0000000;
    wire  rv32_and      =  rv32_op_r  &  func3_111  &  func7_0000000;
    

    // ===========================================================================
    // Load / Store IDU_Instructions
    wire  rv32_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11;
    wire  rv32_lb       = rv32_load   &  func3_000;
    wire  rv32_lh       = rv32_load   &  func3_001;
    wire  rv32_lw       = rv32_load   &  func3_010;
    wire  rv32_lbu      = rv32_load   &  func3_100;
    wire  rv32_lhu      = rv32_load   &  func3_101;

    wire  rv32_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11;
    wire  rv32_sb       = rv32_store  &  func3_000;
    wire  rv32_sh       = rv32_store  &  func3_001;
    wire  rv32_sw       = rv32_store  &  func3_010;
    

    // ===========================================================================
    // Branch IDU_Instructions
    wire  rv32_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;
    wire  rv32_beq      = rv32_branch  &  func3_000;
    wire  rv32_bne      = rv32_branch  &  func3_001;
    wire  rv32_blt      = rv32_branch  &  func3_100;
    wire  rv32_bge      = rv32_branch  &  func3_101;
    wire  rv32_bltu     = rv32_branch  &  func3_110;
    wire  rv32_bgeu     = rv32_branch  &  func3_111;


    // ===========================================================================
    // System IDU_Instructions
    wire   rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;
    assign rv32_ecall    = rv32_system & func3_000 & (IDU_inst[31:20] == 12'b0000_0000_0000);
    wire   rv32_ebreak   = rv32_system & func3_000 & (IDU_inst[31:20] == 12'b0000_0000_0001);
    wire   rv32_mret     = rv32_system & func3_000 & (IDU_inst[31:20] == 12'b0011_0000_0010);
    assign rv32_csrrw    = rv32_system & func3_001;
    assign rv32_csrrs    = rv32_system & func3_010;


    // ===========================================================================
    // jump without condition
    wire  rv32_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;
    wire  rv32_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;

    // U type IDU_inst
    wire  rv32_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11;
    wire  rv32_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;


    // ===========================================================================
    // ALU calculating type
    assign ALU_add       = rv32_add  | rv32_addi  | rv32_auipc | rv32_load | rv32_store | rv32_jal  | rv32_jalr;
    assign ALU_sub       = rv32_sub;
    assign ALU_slt       = rv32_slt  | rv32_slti  | rv32_beq   | rv32_bne  | rv32_blt   | rv32_bge;
    assign ALU_sltu      = rv32_sltu | rv32_sltiu | rv32_bltu  | rv32_bgeu;
    assign ALU_xor       = rv32_xor  | rv32_xori;
    assign ALU_sll       = rv32_sll  | rv32_slli;
    assign ALU_srl       = rv32_srl  | rv32_srli;
    assign ALU_sra       = rv32_sra  | rv32_srai;
    assign ALU_or        = rv32_or   | rv32_ori;
    assign ALU_and       = rv32_and  | rv32_andi;
    assign ALU_explicit  = rv32_lui  | rv32_csrrw | rv32_csrrs;

    // ===========================================================================
    // ALU input
    assign ALU_i1_pc     = rv32_auipc | rv32_jalr | rv32_jal;
    assign ALU_i1_rs1    = ~ALU_i1_pc;

    assign ALU_i2_rs2    = rv32_op_r  | rv32_branch;
    assign ALU_i2_imm    = rv32_op_i  | rv32_auipc  | rv32_lui  | rv32_load | rv32_store;
    assign ALU_i2_4      = rv32_jal   | rv32_jalr;
    assign ALU_i2_csr    = rv32_csrrw | rv32_csrrs;

    // ===========================================================================
    // op type define
    assign op_I_type     = rv32_op_i  | rv32_load | rv32_jalr | rv32_csrrw | rv32_csrrs | rv32_ecall | rv32_ebreak;
    assign op_R_type     = rv32_op_r  | rv32_mret;
    assign op_B_type     = rv32_branch;
    assign op_J_type     = rv32_jal;
    assign op_U_type     = rv32_auipc | rv32_lui;
    assign op_S_type     = rv32_store;

    // ===========================================================================
    // jump signal
    assign jump          = rv32_jal  | rv32_jalr | op_B_type | rv32_ecall | rv32_mret;
    assign pc_plus_imm   = rv32_jal  | op_B_type;
    assign rs1_plus_imm  = rv32_jalr;
    assign csr_plus_imm  = rv32_mret | rv32_ecall;
    // for branch
    assign cmp_eq        = rv32_beq;
    assign cmp_neq       = rv32_bne;
    assign cmp_ge        = rv32_bge  | rv32_bgeu;
    assign cmp_lt        = rv32_blt  | rv32_bltu;


    // ===========================================================================
    // write register
    assign write_gpr    = ~(rv32_branch | rv32_store | rv32_mret | rv32_ecall | rv32_ebreak);
    assign write_csr    = rv32_ecall | rv32_csrrs | rv32_csrrw;
    assign mem_to_reg   = rv32_load;

    // ===========================================================================
    // write/read memory
    assign write_mem    = rv32_store;
    assign mem_byte     = rv32_lb | rv32_sb;
    assign mem_half     = rv32_lh | rv32_sh;
    assign mem_word     = rv32_lw | rv32_sw;
    assign mem_byte_u   = rv32_lbu;
    assign mem_half_u   = rv32_lhu;

    // ===========================================================================
    // system halt
    assign system_halt  = rv32_ebreak;

endmodule





