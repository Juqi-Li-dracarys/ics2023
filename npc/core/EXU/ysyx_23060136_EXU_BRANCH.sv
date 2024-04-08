/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 14:17:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-08 12:53:39
 */


 `include "ysyx_23060136_DEFINES.sv"
 

// Branch control
// ===========================================================================
module ysyx_23060136_EXU_BRANCH (
        // data
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_pc                     ,
        // data from hazard in EXU1
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_rs1_data        ,
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_csr_rs_data     ,
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_imm                    ,
        input                                                     EXU2_ALU_Less               ,
        input                                                     EXU2_ALU_Zero               ,

        // jump/branch types isn't equal to jump signal
        input                                                     EXU2_jump                   ,
        input                                                     EXU2_pc_plus_imm            ,
        input                                                     EXU2_rs1_plus_imm           ,
        input                                                     EXU2_csr_plus_imm           ,
        // signal is 0 means jump directly
        input                                                     EXU2_cmp_eq                 ,
        input                                                     EXU2_cmp_neq                ,
        input                                                     EXU2_cmp_ge                 ,
        input                                                     EXU2_cmp_lt                 ,

        // jump target for IFU
        output             [  `ysyx_23060136_BITS_W -1:0]         branch_target               ,
        // jump signal
        output                                                    PCSrc                       ,
        // 控制冒险
        output                                                    BRANCH_flushIF              ,
        output                                                    BRANCH_flushID              ,
        output                                                    BRANCH_flushEX1             
    );

    wire   [`ysyx_23060136_BITS_W -1 : 0]  adder_da  =  ({`ysyx_23060136_BITS_W {EXU2_pc_plus_imm}}  & EXU2_pc)                 |
                                                        ({`ysyx_23060136_BITS_W {EXU2_rs1_plus_imm}} & EXU2_HAZARD_rs1_data)    |
                                                        ({`ysyx_23060136_BITS_W {EXU2_csr_plus_imm}} & EXU2_HAZARD_csr_rs_data) ;

    assign   branch_target     =  adder_da + EXU2_imm;

    assign   PCSrc             =  EXU2_jump & ~((EXU2_cmp_eq & ~EXU2_ALU_Zero) | (EXU2_cmp_neq & EXU2_ALU_Zero)   |
                                               (EXU2_cmp_ge & EXU2_ALU_Less)   | (EXU2_cmp_lt  & ~EXU2_ALU_Less)) ;

    assign   BRANCH_flushID    =  PCSrc;
    assign   BRANCH_flushIF    =  PCSrc;
    assign   BRANCH_flushEX1   =  PCSrc;

endmodule


