/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-23 12:21:23 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-24 01:46:02
 */
 
 `include "DEFINES_ysyx23060136.sv"

// Branch control
// ===========================================================================
module EXU_BRANCH_ysyx23060136 (
        // data
        input              [  31:0]         EXU_pc                     ,
        input              [  31:0]         EXU_HAZARD_rs1_data        ,
        input              [  31:0]         EXU_HAZARD_csr_rs_data     ,
        input              [  31:0]         EXU_imm                    ,
        input                               EXU_ALU_Less               ,
        input                               EXU_ALU_Zero               ,

        // jump/branch types isn't equal to jump signal
        input                               EXU_jump                   ,
        input                               EXU_pc_plus_imm            ,
        input                               EXU_rs1_plus_imm           ,
        input                               EXU_csr_plus_imm           ,
        // signal is 0 means jump directly
        input                               EXU_cmp_eq                 ,
        input                               EXU_cmp_neq                ,
        input                               EXU_cmp_ge                 ,
        input                               EXU_cmp_lt                 ,

        // jump target
        output             [  31:0]         branch_target              ,
        // jump signal
        output                              PCSrc                      ,
        // 控制冒险
        output                              BRANCH_flushIF             ,
        output                              BRANCH_flushID              
    );

    wire   [31 : 0]  adder_da  = ({32{EXU_pc_plus_imm}}  & EXU_pc)                 |
                                 ({32{EXU_rs1_plus_imm}} & EXU_HAZARD_rs1_data)    |
                                 ({32{EXU_csr_plus_imm}} & EXU_HAZARD_csr_rs_data) ;

    assign   branch_target     =  adder_da + EXU_imm;

    assign   PCSrc             =  EXU_jump & ~((EXU_cmp_eq & ~EXU_ALU_Zero) | (EXU_cmp_neq & EXU_ALU_Zero)   |
                                               (EXU_cmp_ge & EXU_ALU_Less)  | (EXU_cmp_lt  & ~EXU_ALU_Less)) ;

    assign   BRANCH_flushID    =  PCSrc;

    assign   BRANCH_flushIF    =  PCSrc;

endmodule


