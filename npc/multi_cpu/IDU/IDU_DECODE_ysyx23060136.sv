/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-17 11:40:44 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-18 17:40:54
 */

// basic decode unit

module IDU_DECODE_ysyx23060136(
    input    [31 : 0]    inst,
    // ===========================================================================
    output   [6 : 0]     opcode,
    output   [4 : 0]     rd,
    output   [2 : 0]     func3,
    output   [4 : 0]     rs1,
    output   [4 : 0]     rs2,
    output   [6 : 0]     func7,
    // ===========================================================================
    // ALU type define
    output               ALU_add,
    output               ALU_sub,
    // 带符号小于
    output               ALU_slt,
    // 无符号小于
    output               ALU_sltu,
    // 与或异或运算
    output               ALU_or,   
    output               ALU_and,
    output               ALU_xor,
    // 移位运算
    output               ALU_sll,  
    output               ALU_srl,
    output               ALU_sra,
    // 直接输出
    output               ALU_explicit,
    // ===========================================================================
    // OP type
    output               is_R_type,
    output               is_I_type
    
) ; 

    // ===========================================================================
    assign  opcode  =   inst [6 : 0];
    assign  rd      =   inst [11 : 7];
    assign  func3   =   inst [14 : 12];
    assign  rs1     =   inst [19 : 15];
    assign  rs2     =   inst [24 : 20];
    assign  func7   =   inst [31 : 25];

    logic opcode_1_0_00  = (opcode[1 : 0] == 2'b00);
    logic opcode_1_0_01  = (opcode[1 : 0] == 2'b01);
    logic opcode_1_0_10  = (opcode[1 : 0] == 2'b10);
    logic opcode_1_0_11  = (opcode[1 : 0] == 2'b11);

    logic opcode_4_2_000 = (opcode[4 : 2] == 3'b000);
    logic opcode_4_2_001 = (opcode[4 : 2] == 3'b001);
    logic opcode_4_2_010 = (opcode[4 : 2] == 3'b010);
    logic opcode_4_2_011 = (opcode[4 : 2] == 3'b011);
    logic opcode_4_2_100 = (opcode[4 : 2] == 3'b100);
    logic opcode_4_2_101 = (opcode[4 : 2] == 3'b101);
    logic opcode_4_2_110 = (opcode[4 : 2] == 3'b110);
    logic opcode_4_2_111 = (opcode[4 : 2] == 3'b111);
    
    logic opcode_6_5_00  = (opcode[6 : 5] == 2'b00);
    logic opcode_6_5_01  = (opcode[6 : 5] == 2'b01);
    logic opcode_6_5_10  = (opcode[6 : 5] == 2'b10);
    logic opcode_6_5_11  = (opcode[6 : 5] == 2'b11);
  
    logic func3_000 = (func3 == 3'b000);
    logic func3_001 = (func3 == 3'b001);
    logic func3_010 = (func3 == 3'b010);
    logic func3_011 = (func3 == 3'b011);
    logic func3_100 = (func3 == 3'b100);
    logic func3_101 = (func3 == 3'b101);
    logic func3_110 = (func3 == 3'b110);
    logic func3_111 = (func3 == 3'b111);

    logic func7_0000000 = (func7 == 7'b0000000);
    logic func7_0100000 = (func7 == 7'b0100000);
    logic func7_0000001 = (func7 == 7'b0000001);
    logic func7_0000101 = (func7 == 7'b0000101);
    logic func7_0001001 = (func7 == 7'b0001001);
    logic func7_0001101 = (func7 == 7'b0001101);
    logic func7_0010101 = (func7 == 7'b0010101);
    logic func7_0100001 = (func7 == 7'b0100001);
    logic func7_0010001 = (func7 == 7'b0010001);
    logic func7_0101101 = (func7 == 7'b0101101);
    logic func7_1111111 = (func7 == 7'b1111111);
    logic func7_0000100 = (func7 == 7'b0000100); 
    logic func7_0001000 = (func7 == 7'b0001000); 
    logic func7_0001100 = (func7 == 7'b0001100); 
    logic func7_0101100 = (func7 == 7'b0101100); 
    logic func7_0010000 = (func7 == 7'b0010000); 
    logic func7_0010100 = (func7 == 7'b0010100); 
    logic func7_1100000 = (func7 == 7'b1100000); 
    logic func7_1110000 = (func7 == 7'b1110000); 
    logic func7_1010000 = (func7 == 7'b1010000); 
    logic func7_1101000 = (func7 == 7'b1101000); 
    logic func7_1111000 = (func7 == 7'b1111000); 
    logic func7_1010001 = (func7 == 7'b1010001);  
    logic func7_1110001 = (func7 == 7'b1110001);  
    logic func7_1100001 = (func7 == 7'b1100001);  
    logic func7_1101001 = (func7 == 7'b1101001);  


    
    // ===========================================================================
    // ALU Instructions are relative to imm(I type)
    // ExtOp = `I_type;
    // RegWr = 1'b1;
    // CSRWr = 1'b0;
    // ALUAsrc = 2'b0;
    // ALUBsrc = 2'b01;
    // ALUctr = (func3 == 3'b101 && func7[5]) ? {2'b10, func3} : {2'b00, func3};
    // Branch = 3'b000;
    // MemtoReg = 1'b0;
    // MemWr = 1'b0;
    // MemOp = 3'b000;
    // inst_signal = 2'b00;


    logic rv32_op_i   = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;
    logic rv32_addi     =  rv32_op_i  &  func3_000;
    logic rv32_slti     =  rv32_op_i  &  func3_010;
    logic rv32_sltiu    =  rv32_op_i  &  func3_011;
    logic rv32_xori     =  rv32_op_i  &  func3_100;
    logic rv32_ori      =  rv32_op_i  &  func3_110;
    logic rv32_andi     =  rv32_op_i  &  func3_111;
    logic rv32_slli     =  rv32_op_i  &  func3_001 & (inst[31 : 26] == 6'b000000);
    logic rv32_srli     =  rv32_op_i  &  func3_101 & (inst[31 : 26] == 6'b000000);
    logic rv32_srai     =  rv32_op_i  &  func3_101 & (inst[31 : 26] == 6'b010000);

    
    // ===========================================================================
    // ALU Instructions are relative to register(R type)
    logic rv32_op_r     =  opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;
    logic rv32_add      =  rv32_op_r  &  func3_000  &  func7_0000000;
    logic rv32_sub      =  rv32_op_r  &  func3_000  &  func7_0100000;
    logic rv32_sll      =  rv32_op_r  &  func3_001  &  func7_0000000;
    logic rv32_slt      =  rv32_op_r  &  func3_010  &  func7_0000000;
    logic rv32_sltu     =  rv32_op_r  &  func3_011  &  func7_0000000;
    logic rv32_xor      =  rv32_op_r  &  func3_100  &  func7_0000000;
    logic rv32_srl      =  rv32_op_r  &  func3_101  &  func7_0000000;
    logic rv32_sra      =  rv32_op_r  &  func3_101  &  func7_0100000;
    logic rv32_or       =  rv32_op_r  &  func3_110  &  func7_0000000;
    logic rv32_and      =  rv32_op_r  &  func3_111  &  func7_0000000;
    

    // ===========================================================================
    // Load / Store Instructions
    logic rv32_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11;
    logic rv32_lb       = rv32_load   &  func3_000;
    logic rv32_lh       = rv32_load   &  func3_001;
    logic rv32_lw       = rv32_load   &  func3_010;
    logic rv32_lbu      = rv32_load   &  func3_100;
    logic rv32_lhu      = rv32_load   &  func3_101;

    logic rv32_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11;
    logic rv32_sb       = rv32_store  &  func3_000;
    logic rv32_sh       = rv32_store  &  func3_001;
    logic rv32_sw       = rv32_store  &  func3_010;
    

    // ===========================================================================
    // Branch Instructions
    logic rv32_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;
    logic rv32_beq      = rv32_branch  &  func3_000;
    logic rv32_bne      = rv32_branch  &  func3_001;
    logic rv32_blt      = rv32_branch  &  func3_100;
    logic rv32_bge      = rv32_branch  &  func3_101;
    logic rv32_bltu     = rv32_branch  &  func3_110;
    logic rv32_bgeu     = rv32_branch  &  func3_111;


    // ===========================================================================
    // System Instructions
    logic rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;
    logic rv32_ecall    = rv32_system & func3_000 & (inst[31:20] == 12'b0000_0000_0000);
    logic rv32_ebreak   = rv32_system & func3_000 & (inst[31:20] == 12'b0000_0000_0001);
    logic rv32_mret     = rv32_system & func3_000 & (inst[31:20] == 12'b0011_0000_0010);
    logic rv32_csrrw    = rv32_system & func3_001; 
    logic rv32_csrrs    = rv32_system & func3_010; 


    // ===========================================================================
    // Special Instructions
    logic rv32_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;
    logic rv32_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;
    logic rv32_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11; 
    logic rv32_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;


    // ===========================================================================
    // ALU type
    assign ALU_add       = rv32_add  | rv32_addi  | rv32_auipc;
    assign ALU_sub       = rv32_sub;
    assign ALU_slt       = rv32_slt  | rv32_slti  | rv32_beq  | rv32_bne | rv32_blt | rv32_bge;
    assign ALU_sltu      = rv32_sltu | rv32_sltiu | rv32_bltu | rv32_bgeu;
    assign ALU_xor       = rv32_xor  | rv32_xori;
    assign ALU_sll       = rv32_sll  | rv32_slli;
    assign ALU_srl       = rv32_srl  | rv32_srli;
    assign ALU_sra       = rv32_sra  | rv32_srai;
    assign ALU_or        = rv32_or   | rv32_ori;
    assign ALU_and       = rv32_and  | rv32_andi;
    assign ALU_explicit  = rv32_lui;


    // ===========================================================================
    // type define
    assign is_I_type     = rv32_op_i | rv32_load | rv32_jalr | rv32_csrrw | rv32_csrrs; 
    assign is_R_type     = rv32_op_r | rv32_mret;




endmodule





