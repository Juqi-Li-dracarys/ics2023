/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-19 13:19:56
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-23 12:19:22
 */

 `include "DEFINES_ysyx23060136.sv"

 /* verilator lint_off UNUSED */

// imm and op module
// ===========================================================================
module IDU_IMM_GEN_ysyx_23060136(
        input              [  31:0]         IDU_inst                   ,
        input                               op_R_type                  ,
        input                               op_I_type                  ,
        input                               op_B_type                  ,
        input                               op_J_type                  ,
        input                               op_U_type                  ,
        input                               op_S_type                  ,
        output             [  31:0]         IDU_imm                    ,
        output                              op_valid
    );


    assign IDU_imm =   ({32{op_I_type}} & {{20{IDU_inst[31]}}, IDU_inst[31 : 20]})                                        |
                       ({32{op_B_type}} & {{20{IDU_inst[31]}}, IDU_inst[7], IDU_inst[30 : 25], IDU_inst[11 : 8], 1'b0})   |
                       ({32{op_S_type}} & {{20{IDU_inst[31]}}, IDU_inst[31 : 25], IDU_inst[11 : 7]})                      |
                       ({32{op_U_type}} & {IDU_inst[31 : 12], 12'b0})                                                     |
                       ({32{op_J_type}} & {{12{IDU_inst[31]}}, IDU_inst[19 : 12], IDU_inst[20], IDU_inst[30 : 21], 1'b0}) |
                       ({32{op_R_type}} & 32'b0);


    assign  op_valid =  (op_R_type & !(op_I_type | op_B_type | op_J_type | op_U_type | op_S_type)) |
                        (op_I_type & !(op_R_type | op_B_type | op_J_type | op_U_type | op_S_type)) |
                        (op_B_type & !(op_R_type | op_I_type | op_J_type | op_U_type | op_S_type)) |
                        (op_J_type & !(op_R_type | op_I_type | op_B_type | op_U_type | op_S_type)) |
                        (op_U_type & !(op_R_type | op_I_type | op_B_type | op_J_type | op_S_type)) |
                        (op_S_type & !(op_R_type | op_I_type | op_B_type | op_J_type | op_U_type));


endmodule




