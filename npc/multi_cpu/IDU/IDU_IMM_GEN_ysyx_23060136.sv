/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-19 13:19:56 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-19 20:25:07
 */

 `include "IDU_DEFINES_ysyx23060136.sv"

// ===========================================================================

module IDU_IMM_GEN_ysyx_23060136(
        input   [31 : 0]   inst,
        input              op_R_type,
        input              op_I_type,
        input              op_B_type,
        input              op_J_type,
        input              op_U_type,
        input              op_S_type,
        output  [31 : 0]   imm,
        output             op_valid
    );


    assign imm =  ({32{op_I_type}} & {{20{inst[31]}}, inst[31 : 20]})                                |
                  ({32{op_B_type}} & {{20{inst[31]}}, inst[7], inst[30 : 25], inst[11 : 8], 1'b0})   |
                  ({32{op_S_type}} & {{20{inst[31]}}, inst[31 : 25], inst[11 : 7]})                  |
                  ({32{op_U_type}} & {inst[31 : 12], 12'b0})                                         |
                  ({32{op_J_type}} & {{12{inst[31]}}, inst[19 : 12], inst[20], inst[30 : 21], 1'b0}) | 
                  ({32{op_R_type}} & 32'b0);

    assign op_valid = (op_R_type ^ op_I_type ^ op_B_type ^ op_J_type ^ op_U_type ^ op_S_type) 
                   & ~((op_R_type & op_I_type) | (op_R_type & op_B_type) | (op_R_type & op_J_type) 
                    | (op_R_type & op_U_type) | (op_R_type & op_S_type) | (op_I_type & op_B_type) 
                    | (op_I_type & op_J_type) | (op_I_type & op_U_type) | (op_I_type & op_S_type) 
                    | (op_B_type & op_J_type) | (op_B_type & op_U_type) | (op_B_type & op_S_type) 
                    | (op_J_type & op_U_type) | (op_J_type & op_S_type) | (op_U_type & op_S_type));

endmodule




