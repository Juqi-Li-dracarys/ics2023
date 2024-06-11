/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 22:03:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-11 11:06:00
 */


 `include "ysyx_23060136_DEFINES.sv"

 
// Main Decode unit
// Support ISA: RISCV64-IM
// ===========================================================================
module ysyx_23060136_IDU_DECODE (
    input              [  `ysyx_23060136_INST_W-1:0]         IDU_inst                   ,
    // ===========================================================================
    // reg addr
    output             [  `ysyx_23060136_GPR_W-1:0]          IDU_rd                     ,
    output             [  `ysyx_23060136_GPR_W-1:0]          IDU_rs1                    ,
    output             [  `ysyx_23060136_GPR_W-1:0]          IDU_rs2                    ,
    output             [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rs                 ,
    output             [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rd_1               ,
    output             [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rd_2               ,  
    // ===========================================================================
    // ALU calculating type define
    output                                                   ALU_word_t                 ,
    output                                                   ALU_add                    ,
    output                                                   ALU_sub                    ,
    // 带符号小于
    output                                                   ALU_slt                    ,
    // 无符号小于
    output                                                   ALU_sltu                   ,
    // 与或异或运算
    output                                                   ALU_or                     ,
    output                                                   ALU_and                    ,
    output                                                   ALU_xor                    ,
    // 移位运算
    output                                                   ALU_sll                    ,
    output                                                   ALU_srl                    ,
    output                                                   ALU_sra                    ,

    output                                                   ALU_mul                    ,
    output                                                   ALU_mul_hi                 ,
    output                                                   ALU_mul_u                  ,
    output                                                   ALU_mul_s                  ,
    output                                                   ALU_mul_su                 ,

    output                                                   ALU_div                    ,
    output                                                   ALU_div_u                  ,
    output                                                   ALU_div_s                  ,
    output                                                   ALU_rem                    ,
    output                                                   ALU_rem_u                  ,
    output                                                   ALU_rem_s                  ,

    // 直接输出
    output                                                   ALU_explicit               ,
    // ===========================================================================
    // ALU input 1, input 2 type
    output                                                   ALU_i1_rs1                 ,
    output                                                   ALU_i1_pc                  ,

    output                                                   ALU_i2_rs2                 ,
    output                                                   ALU_i2_imm                 ,
    output                                                   ALU_i2_4                   ,
    output                                                   ALU_i2_csr                 ,
    // ===========================================================================
    // jump
    output                                                   jump                       ,
    output                                                   rv64_branch                ,            
    output                                                   pc_plus_imm                ,
    output                                                   rs1_plus_imm               ,
    output                                                   csr_plus_imm               ,
    output                                                   cmp_eq                     ,
    output                                                   cmp_neq                    ,
    output                                                   cmp_ge                     ,
    output                                                   cmp_lt                     ,
    // ===========================================================================
    // write/read register
    output                                                   write_gpr                  ,
    output                                                   write_csr_1                ,
    output                                                   write_csr_2                ,
    output                                                   mem_to_reg                 ,
    // we will handle csr in the ALU
    output                                                   rv64_csrrs                 ,
    output                                                   rv64_csrrw                 ,
    output                                                   rv64_ecall                 ,
    // ===========================================================================
    // write/read memory
    output                                                   write_mem                  ,
    output                                                   mem_byte                   ,
    output                                                   mem_half                   ,
    output                                                   mem_word                   ,
    output                                                   mem_dword                  ,
    output                                                   mem_byte_u                 ,
    output                                                   mem_half_u                 ,
    output                                                   mem_word_u                 ,
    // ===========================================================================
    // halt
    output                                                   system_halt                ,
    output         [  `ysyx_23060136_BITS_W-1:0]             IDU_imm                                 

) ;


    // ===========================================================================
    wire  [6 : 0]  opcode      =   IDU_inst[6 : 0]  ;
    wire  [2 : 0]  func3       =   IDU_inst[14 : 12];
    wire  [6 : 0]  func7       =   IDU_inst[31 : 25];
    wire  [11 : 0] csr_id      =   IDU_inst[31 : 20];

    assign         IDU_rs1     =   IDU_inst[19 : 15];
    assign         IDU_rs2     =   IDU_inst[24 : 20];
    assign         IDU_rd      =   IDU_inst[11 : 7] ;

    wire  opcode_1_0_00  = (opcode[1 : 0] == 2'b00) ;
    wire  opcode_1_0_01  = (opcode[1 : 0] == 2'b01) ;
    wire  opcode_1_0_10  = (opcode[1 : 0] == 2'b10) ;
    wire  opcode_1_0_11  = (opcode[1 : 0] == 2'b11) ;

    wire  opcode_4_2_000 = (opcode[4 : 2] == 3'b000);
    wire  opcode_4_2_001 = (opcode[4 : 2] == 3'b001);
    wire  opcode_4_2_010 = (opcode[4 : 2] == 3'b010);
    wire  opcode_4_2_011 = (opcode[4 : 2] == 3'b011);
    wire  opcode_4_2_100 = (opcode[4 : 2] == 3'b100);
    wire  opcode_4_2_101 = (opcode[4 : 2] == 3'b101);
    wire  opcode_4_2_110 = (opcode[4 : 2] == 3'b110);
    wire  opcode_4_2_111 = (opcode[4 : 2] == 3'b111);
    
    wire  opcode_6_5_00  = (opcode[6 : 5] == 2'b00) ;
    wire  opcode_6_5_01  = (opcode[6 : 5] == 2'b01) ;
    wire  opcode_6_5_10  = (opcode[6 : 5] == 2'b10) ;
    wire  opcode_6_5_11  = (opcode[6 : 5] == 2'b11) ;
  
    wire  func3_000      = (func3 == 3'b000)        ;
    wire  func3_001      = (func3 == 3'b001)        ;
    wire  func3_010      = (func3 == 3'b010)        ;
    wire  func3_011      = (func3 == 3'b011)        ;
    wire  func3_100      = (func3 == 3'b100)        ;
    wire  func3_101      = (func3 == 3'b101)        ;
    wire  func3_110      = (func3 == 3'b110)        ;
    wire  func3_111      = (func3 == 3'b111)        ;

    wire  func7_0000000  = (func7 == 7'b0000000)    ;
    wire  func7_0100000  = (func7 == 7'b0100000)    ;
    wire  func7_0000001  = (func7 == 7'b0000001)    ;
    wire  func7_0000101  = (func7 == 7'b0000101)    ;
    wire  func7_0001001  = (func7 == 7'b0001001)    ;
    wire  func7_0001101  = (func7 == 7'b0001101)    ;
    wire  func7_0010101  = (func7 == 7'b0010101)    ;
    wire  func7_0100001  = (func7 == 7'b0100001)    ;
    wire  func7_0010001  = (func7 == 7'b0010001)    ;
    wire  func7_0101101  = (func7 == 7'b0101101)    ;
    wire  func7_1111111  = (func7 == 7'b1111111)    ;
    wire  func7_0000100  = (func7 == 7'b0000100)    ;
    wire  func7_0001000  = (func7 == 7'b0001000)    ;
    wire  func7_0001100  = (func7 == 7'b0001100)    ;
    wire  func7_0101100  = (func7 == 7'b0101100)    ;
    wire  func7_0010000  = (func7 == 7'b0010000)    ;
    wire  func7_0010100  = (func7 == 7'b0010100)    ;
    wire  func7_1100000  = (func7 == 7'b1100000)    ;
    wire  func7_1110000  = (func7 == 7'b1110000)    ;
    wire  func7_1010000  = (func7 == 7'b1010000)    ;
    wire  func7_1101000  = (func7 == 7'b1101000)    ;
    wire  func7_1111000  = (func7 == 7'b1111000)    ;
    wire  func7_1010001  = (func7 == 7'b1010001)    ;
    wire  func7_1110001  = (func7 == 7'b1110001)    ;
    wire  func7_1100001  = (func7 == 7'b1100001)    ;
    wire  func7_1101001  = (func7 == 7'b1101001)    ;


    // ===========================================================================
    // ALU IDU_Instructions are relative to imm(I type)
    wire  rv64_op_i     =  opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11;
    wire  rv64_addi     =  rv64_op_i  &  func3_000;
    wire  rv64_slti     =  rv64_op_i  &  func3_010;
    wire  rv64_sltiu    =  rv64_op_i  &  func3_011;
    wire  rv64_xori     =  rv64_op_i  &  func3_100;
    wire  rv64_ori      =  rv64_op_i  &  func3_110;
    wire  rv64_andi     =  rv64_op_i  &  func3_111;
    wire  rv64_slli     =  rv64_op_i  &  func3_001 & (IDU_inst[31 : 26] == 6'b000000);
    wire  rv64_srli     =  rv64_op_i  &  func3_101 & (IDU_inst[31 : 26] == 6'b000000);
    wire  rv64_srai     =  rv64_op_i  &  func3_101 & (IDU_inst[31 : 26] == 6'b010000);

    // RV64 only
    wire  rv64_op_i_32  =  opcode_6_5_00 & opcode_4_2_110 & opcode_1_0_11                ;
    wire  rv64_addiw    =  rv64_op_i_32  &  func3_000                                    ;
    wire  rv64_sraiw    =  rv64_op_i_32  &  func3_101 & (IDU_inst[31 : 26] == 6'b010000) ;
    wire  rv64_srliw    =  rv64_op_i_32  &  func3_101 & (IDU_inst[31 : 26] == 6'b000000) ;
    wire  rv64_slliw    =  rv64_op_i_32  &  func3_001 & (IDU_inst[31 : 26] == 6'b000000) ;


    // ===========================================================================
    // ALU IDU_Instructions are relative to register(R type)
    wire  rv64_op_r     =  opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11;
    wire  rv64_add      =  rv64_op_r  &  func3_000  &  func7_0000000;
    wire  rv64_sub      =  rv64_op_r  &  func3_000  &  func7_0100000;
    wire  rv64_sll      =  rv64_op_r  &  func3_001  &  func7_0000000;
    wire  rv64_slt      =  rv64_op_r  &  func3_010  &  func7_0000000;
    wire  rv64_sltu     =  rv64_op_r  &  func3_011  &  func7_0000000;
    wire  rv64_xor      =  rv64_op_r  &  func3_100  &  func7_0000000;
    wire  rv64_srl      =  rv64_op_r  &  func3_101  &  func7_0000000;
    wire  rv64_sra      =  rv64_op_r  &  func3_101  &  func7_0100000;
    wire  rv64_or       =  rv64_op_r  &  func3_110  &  func7_0000000;
    wire  rv64_and      =  rv64_op_r  &  func3_111  &  func7_0000000;

    wire  rv64_mul      =  rv64_op_r  &  func3_000  &  func7_0000001;
    wire  rv64_mulh     =  rv64_op_r  &  func3_001  &  func7_0000001;
    wire  rv64_mulhsu   =  rv64_op_r  &  func3_010  &  func7_0000001;
    wire  rv64_mulhu    =  rv64_op_r  &  func3_011  &  func7_0000001;
    wire  rv64_div      =  rv64_op_r  &  func3_100  &  func7_0000001;
    wire  rv64_divu     =  rv64_op_r  &  func3_101  &  func7_0000001;
    wire  rv64_rem      =  rv64_op_r  &  func3_110  &  func7_0000001;
    wire  rv64_remu     =  rv64_op_r  &  func3_111  &  func7_0000001;

    
    // RV64 only
    wire  rv64_op_r_32  =  opcode_6_5_01 & opcode_4_2_110 & opcode_1_0_11;
    wire  rv64_addw     =  rv64_op_r_32  &  func3_000  &  func7_0000000;
    wire  rv64_subw     =  rv64_op_r_32  &  func3_000  &  func7_0100000;
    wire  rv64_sllw     =  rv64_op_r_32  &  func3_001  &  func7_0000000;
    wire  rv64_srlw     =  rv64_op_r_32  &  func3_101  &  func7_0000000;
    wire  rv64_sraw     =  rv64_op_r_32  &  func3_101  &  func7_0100000;

    wire  rv64_mulw     =  rv64_op_r_32  &  func3_000  &  func7_0000001;
    wire  rv64_divw     =  rv64_op_r_32  &  func3_100  &  func7_0000001;
    wire  rv64_divuw    =  rv64_op_r_32  &  func3_101  &  func7_0000001;
    wire  rv64_remw     =  rv64_op_r_32  &  func3_110  &  func7_0000001;
    wire  rv64_remuw    =  rv64_op_r_32  &  func3_111  &  func7_0000001;


    // ===========================================================================
    // Load / Store IDU_Instructions
    wire  rv64_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11;
    wire  rv64_lb       = rv64_load   &  func3_000;
    wire  rv64_lh       = rv64_load   &  func3_001;
    wire  rv64_lw       = rv64_load   &  func3_010;
    wire  rv64_lbu      = rv64_load   &  func3_100;
    wire  rv64_lhu      = rv64_load   &  func3_101;
    wire  rv64_lwu      = rv64_load   &  func3_110;
    wire  rv64_ld       = rv64_load   &  func3_011;


    wire  rv64_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11;
    wire  rv64_sb       = rv64_store  &  func3_000;
    wire  rv64_sh       = rv64_store  &  func3_001;
    wire  rv64_sw       = rv64_store  &  func3_010;
    wire  rv64_sd       = rv64_store  &  func3_011;


    // ===========================================================================
    // Branch IDU_Instructions
    assign  rv64_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;
    wire  rv64_beq      = rv64_branch  &  func3_000;
    wire  rv64_bne      = rv64_branch  &  func3_001;
    wire  rv64_blt      = rv64_branch  &  func3_100;
    wire  rv64_bge      = rv64_branch  &  func3_101;
    wire  rv64_bltu     = rv64_branch  &  func3_110;
    wire  rv64_bgeu     = rv64_branch  &  func3_111;


    // ===========================================================================
    // System IDU_Instructions
    wire   rv64_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11;
    wire   rv64_ebreak   = rv64_system & func3_000 & (IDU_inst[31:20] == 12'b0000_0000_0001);
    wire   rv64_mret     = rv64_system & func3_000 & (IDU_inst[31:20] == 12'b0011_0000_0010);
    assign rv64_csrrw    = rv64_system & func3_001;
    assign rv64_csrrs    = rv64_system & func3_010;
    assign rv64_ecall    = rv64_system & func3_000 & (IDU_inst[31:20] == 12'b0000_0000_0000);


    // ===========================================================================
    // jump without condition
    wire  rv64_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11;
    wire  rv64_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;

    // U type IDU_inst
    wire  rv64_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11;
    wire  rv64_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11;


    // ===========================================================================
    // ALU calculating type

    assign ALU_word_t    =  rv64_op_i_32 | rv64_op_r_32;

    assign ALU_add       = rv64_add   | rv64_addi  | rv64_auipc | rv64_load | rv64_store | rv64_jal  | rv64_jalr | rv64_addiw | rv64_addw;
    assign ALU_sub       = rv64_sub   | rv64_subw;
    assign ALU_slt       = rv64_slt   | rv64_slti  | rv64_beq   | rv64_bne  | rv64_blt   | rv64_bge;
    assign ALU_sltu      = rv64_sltu  | rv64_sltiu | rv64_bltu  | rv64_bgeu;
    assign ALU_or        = rv64_or    | rv64_ori ;
    assign ALU_and       = rv64_and   | rv64_andi;
    assign ALU_xor       = rv64_xor   | rv64_xori;
    assign ALU_sll       = rv64_sll   | rv64_slli | rv64_sllw | rv64_slliw;
    assign ALU_srl       = rv64_srl   | rv64_srli | rv64_srlw | rv64_srliw;
    assign ALU_sra       = rv64_sra   | rv64_srai | rv64_sraw | rv64_sraiw;

    // Multiplier ctrl
    assign ALU_mul       = rv64_mul   | rv64_mulw   | rv64_mulh | rv64_mulhsu | rv64_mulhu ;
    assign ALU_mul_hi    = rv64_mulh  | rv64_mulhsu | rv64_mulhu;
    assign ALU_mul_u     = rv64_mulhu;
    assign ALU_mul_s     = rv64_mulh;
    assign ALU_mul_su    = rv64_mulhsu;

    // Divider ctrl
    assign ALU_div       = rv64_div  | rv64_divu  | rv64_divw | rv64_divuw;
    assign ALU_div_u     = rv64_divu | rv64_divuw ;
    assign ALU_div_s     = rv64_div  | rv64_divw;

    assign ALU_rem       = rv64_rem  | rv64_remu  | rv64_remw | rv64_remuw;
    assign ALU_rem_u     = rv64_remu | rv64_remuw;
    assign ALU_rem_s     = rv64_rem  | rv64_remw;
    
    assign ALU_explicit  = rv64_lui  | rv64_csrrw | rv64_csrrs;

    // ===========================================================================
    // ALU input
    assign ALU_i1_pc     = rv64_auipc | rv64_jalr | rv64_jal;
    assign ALU_i1_rs1    = ~ALU_i1_pc;

    assign ALU_i2_rs2    = rv64_op_r  | rv64_branch | rv64_op_r_32;
    assign ALU_i2_imm    = rv64_op_i  | rv64_auipc  | rv64_lui  | rv64_load | rv64_store | rv64_op_i_32;
    assign ALU_i2_4      = rv64_jal   | rv64_jalr;
    assign ALU_i2_csr    = rv64_csrrw | rv64_csrrs;


    // ===========================================================================
    // op type define
    wire  op_I_type     = rv64_op_i  | rv64_op_i_32 | rv64_load | rv64_jalr | rv64_csrrw | rv64_csrrs | rv64_ecall | rv64_ebreak;
    wire  op_R_type     = rv64_op_r  | rv64_op_r_32 | rv64_mret;
    wire  op_B_type     = rv64_branch;
    wire  op_J_type     = rv64_jal;
    wire  op_U_type     = rv64_auipc | rv64_lui;
    wire  op_S_type     = rv64_store;


    // ===========================================================================
    // jump signal
    assign jump          = rv64_jal  | rv64_jalr | op_B_type | rv64_ecall | rv64_mret;
    assign pc_plus_imm   = rv64_jal  | op_B_type;
    assign rs1_plus_imm  = rv64_jalr;
    assign csr_plus_imm  = rv64_mret | rv64_ecall;
    // for branch
    assign cmp_eq        = rv64_beq;
    assign cmp_neq       = rv64_bne;
    assign cmp_ge        = rv64_bge  | rv64_bgeu;
    assign cmp_lt        = rv64_blt  | rv64_bltu;


    // ===========================================================================
    // write register
    assign write_gpr    = ~(rv64_branch | rv64_store | rv64_mret | rv64_ecall | rv64_ebreak);
    assign write_csr_1  = rv64_ecall | rv64_csrrs | rv64_csrrw;
    assign write_csr_2  = rv64_ecall;
    assign mem_to_reg   = rv64_load;


    // ===========================================================================
    // write/read memory
    assign write_mem    = rv64_store;
    assign mem_byte     = rv64_lb | rv64_sb;
    assign mem_half     = rv64_lh | rv64_sh;
    assign mem_word     = rv64_lw | rv64_sw;
    assign mem_dword    = rv64_ld | rv64_sd;

    assign mem_byte_u   = rv64_lbu         ;
    assign mem_half_u   = rv64_lhu         ;
    assign mem_word_u   = rv64_lwu         ;


    // ===========================================================================
    // system halt
    assign system_halt  = rv64_ebreak;

    // ===========================================================================
    // imm generate

    assign IDU_imm      = ({`ysyx_23060136_BITS_W{op_I_type}} & {{52{IDU_inst[31]}}, IDU_inst[31 : 20]})                                        |
                          ({`ysyx_23060136_BITS_W{op_B_type}} & {{52{IDU_inst[31]}}, IDU_inst[7], IDU_inst[30 : 25], IDU_inst[11 : 8], 1'b0})   |
                          ({`ysyx_23060136_BITS_W{op_S_type}} & {{52{IDU_inst[31]}}, IDU_inst[31 : 25], IDU_inst[11 : 7]})                      |
                          ({`ysyx_23060136_BITS_W{op_U_type}} & {{32{IDU_inst[31]}}, IDU_inst[31 : 12], 12'b0})                                 |
                          ({`ysyx_23060136_BITS_W{op_J_type}} & {{44{IDU_inst[31]}}, IDU_inst[19 : 12], IDU_inst[20], IDU_inst[30 : 21], 1'b0}) |
                          ({`ysyx_23060136_BITS_W{op_R_type}} & `ysyx_23060136_BITS_W'b0)                                                       ;


    // ===========================================================================
    // CSR internal ctr
    wire     csr_ecall         = (csr_id     ==     12'd0  )   ;
    wire     csr_mret          = (csr_id     ==     12'd770)   ;
    wire     csr_mtvec         = (csr_id     ==     12'd773)   ;
    wire     csr_mstatus       = (csr_id     ==     12'd768)   ;
    wire     csr_mcause        = (csr_id     ==     12'd834)   ;
    wire     csr_mepc          = (csr_id     ==     12'd833)   ;

    wire     csr_mvendorid     = (csr_id     ==     12'd3857)  ;
    wire     csr_marchid       = (csr_id     ==     12'd3858)  ;

    
    assign   IDU_csr_rs        = ({`ysyx_23060136_CSR_W{csr_ecall}}     & `ysyx_23060136_mtvec)     | ({`ysyx_23060136_CSR_W{csr_mret}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mtvec}}     & `ysyx_23060136_mtvec)     | ({`ysyx_23060136_CSR_W{csr_mstatus}}    & `ysyx_23060136_mstatus) |
                                 ({`ysyx_23060136_CSR_W{csr_mcause}}    & `ysyx_23060136_mcause)    | ({`ysyx_23060136_CSR_W{csr_mepc}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mvendorid}} & `ysyx_23060136_mvendorid) | ({`ysyx_23060136_CSR_W{csr_marchid}}    & `ysyx_23060136_marchid) ;

    assign   IDU_csr_rd_1      = ({`ysyx_23060136_CSR_W{csr_ecall}}     & `ysyx_23060136_mepc)      | ({`ysyx_23060136_CSR_W{csr_mret}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mtvec}}     & `ysyx_23060136_mtvec)     | ({`ysyx_23060136_CSR_W{csr_mstatus}}    & `ysyx_23060136_mstatus) |
                                 ({`ysyx_23060136_CSR_W{csr_mcause}}    & `ysyx_23060136_mcause)    | ({`ysyx_23060136_CSR_W{csr_mepc}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mvendorid}} & `ysyx_23060136_mvendorid) | ({`ysyx_23060136_CSR_W{csr_marchid}}    & `ysyx_23060136_marchid) ;

    assign   IDU_csr_rd_2      = {`ysyx_23060136_CSR_W{csr_ecall}}      & `ysyx_23060136_mcause;



endmodule





