/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 01:41:27 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-24 01:48:14
 */

 `include "EXU_DEFINES_ysyx23060136.sv"


 // ===========================================================================
module EXU_TOP_ysyx23060136 (

        input              [  31:0]         EXU_pc                     ,
        input              [  31:0]         EXU_inst                   ,
        input                               EXU_commit                 ,
        input              [   4:0]         EXU_rd                     ,
        input              [   4:0]         EXU_rs1                    ,
        input              [   4:0]         EXU_rs2                    ,
        input              [  31:0]         EXU_imm                    ,
        input              [  31:0]         EXU_rs1_data               ,
        input              [  31:0]         EXU_rs2_data               ,
        input              [   1:0]         EXU_csr_rd                 ,
        input              [   1:0]         EXU_csr_rs                 ,
        input              [  31:0]         EXU_csr_rs_data            ,

        input                               EXU_ALU_add                ,
        input                               EXU_ALU_sub                ,
        input                               EXU_ALU_slt                ,
        input                               EXU_ALU_sltu               ,
        input                               EXU_ALU_or                 ,
        input                               EXU_ALU_and                ,
        input                               EXU_ALU_xor                ,
        input                               EXU_ALU_sll                ,
        input                               EXU_ALU_srl                ,
        input                               EXU_ALU_sra                ,
        input                               EXU_ALU_explicit           ,
        input                               EXU_ALU_i1_rs1             ,
        input                               EXU_ALU_i1_pc              ,
        input                               EXU_ALU_i2_rs2             ,
        input                               EXU_ALU_i2_imm             ,
        input                               EXU_ALU_i2_4               ,
        input                               EXU_ALU_i2_csr             ,

        input                               EXU_jump                   ,
        input                               EXU_pc_plus_imm            ,
        input                               EXU_rs1_plus_imm           ,
        input                               EXU_csr_plus_imm           ,
        input                               EXU_cmp_eq                 ,
        input                               EXU_cmp_neq                ,
        input                               EXU_cmp_ge                 ,
        input                               EXU_cmp_lt                 ,

        input                               EXU_write_gpr              ,
        input                               EXU_write_csr              ,
        input                               EXU_mem_to_reg             ,
        input                               EXU_rv32_csrrs             ,
        input                               EXU_rv32_csrrw             ,
        input                               EXU_rv32_ecall             ,

        input                               EXU_write_mem              ,
        input                               EXU_mem_byte               ,
        input                               EXU_mem_half               ,
        input                               EXU_mem_word               ,
        input                               EXU_mem_byte_u             ,
        input                               EXU_mem_half_u             ,

        input                               EXU_system_halt            ,
        input                               EXU_op_valid               ,


        input              [  31:0]         FORWARD_rs1_data           ,
        input              [  31:0]         FORWARD_rs2_data           ,
        input              [  31:0]         FORWARD_csr_rs_data        ,
        input                               FORWARD_rs1_hazard         ,
        input                               FORWARD_rs2_hazard         ,
        input                               FORWARD_csr_rs_hazard      ,

        // ===========================================================================
        output             [  31:0]         EXU_pc_MEM                 ,
        output             [  31:0]         EXU_inst_MEM               ,            
        // mem
        output             [  31:0]         EXU_ALU_ALUout             ,
        output             [  31:0]         EXU_ALU_CSR_out            ,
        output                              EXU_commit_MEM             ,
        // IFU
        output             [  31:0]         branch_target              ,
        output                              PCSrc                      ,
        output                              BRANCH_flushIF             ,
        output                              BRANCH_flushID             ,
        // system
        output                              EXU_ALU_valid              ,
        // ===========================================================================
        // origin signal pushed to the next stage
        // mem
        output             [   4:0]         EXU_rd_MEM                 ,
        // forward unit          
        output             [   4:0]         EXU_rs1_MEM                ,
        output             [   4:0]         EXU_rs2_MEM                ,
        output             [  31:0]         EXU_HAZARD_rs2_data        ,
        // mem
        output             [   1:0]         EXU_csr_rd_MEM             ,
        // forward unit
        output             [   1:0]         EXU_csr_rs_MEM             ,
        // mem
        output                              EXU_write_gpr_MEM          ,
        output                              EXU_write_csr_MEM          ,
        output                              EXU_mem_to_reg_MEM         ,

        output                              EXU_write_mem_MEM          ,
        output                              EXU_mem_byte_MEM           ,
        output                              EXU_mem_half_MEM           ,
        output                              EXU_mem_word_MEM           ,
        output                              EXU_mem_byte_u_MEM         ,
        output                              EXU_mem_half_u_MEM         ,

        output                              EXU_system_halt_MEM        ,
        output                              EXU_op_valid_MEM            

    );


    logic       [31 : 0]      EXU_HAZARD_rs1_data;
    logic       [31 : 0]      EXU_HAZARD_csr_rs_data;

    logic       [31 : 0]      EXU_ALU_da;
    logic       [31 : 0]      EXU_ALU_db;

    logic                     EXU_ALU_Less;
    logic                     EXU_ALU_Zero;

    // transmit directly
    assign    EXU_commit_MEM       = EXU_commit;
    assign    EXU_pc_MEM           = EXU_pc;
    assign    EXU_inst_MEM         = EXU_inst;
    assign    EXU_rd_MEM           = EXU_rd;
    assign    EXU_rs1_MEM          = EXU_rs1;
    assign    EXU_rs2_MEM          = EXU_rs2;
    assign    EXU_csr_rd_MEM       = EXU_csr_rd;
    assign    EXU_csr_rs_MEM       = EXU_csr_rs;
    assign    EXU_write_gpr_MEM    = EXU_write_gpr;
    assign    EXU_write_csr_MEM    = EXU_write_csr;
    assign    EXU_mem_to_reg_MEM   = EXU_mem_to_reg;

    assign    EXU_write_mem_MEM    = EXU_write_mem;
    assign    EXU_mem_byte_MEM     = EXU_mem_byte;
    assign    EXU_mem_half_MEM     = EXU_mem_half;
    assign    EXU_mem_word_MEM     = EXU_mem_word;
    assign    EXU_mem_byte_u_MEM   = EXU_mem_byte_u;
    assign    EXU_mem_half_u_MEM   = EXU_mem_half_u;

    assign    EXU_system_halt_MEM  = EXU_system_halt;
    assign    EXU_op_valid_MEM     = EXU_op_valid;


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


