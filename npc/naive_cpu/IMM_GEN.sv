/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 21:54:35 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 09:16:56
 */

 /* verilator lint_off UNUSED */
 /* verilator lint_off UNUSEDSIGNAL */

// 指令立即数提取
`define   I_type   3'b000
`define   S_type   3'b010
`define   B_type   3'b011
`define   U_type   3'b001
`define   J_type   3'b100

module IMM_GEN (
    input       [31 : 0]   inst,
    input       [2 : 0]    ExtOp,   // 指令类型
    output reg  [31 : 0]   imm
);

    always_comb  begin
         unique case(ExtOp)
            `I_type:                                                                          // I type
                imm = {{20{inst[31]}}, inst[31 : 20]};
            `S_type:                                                                          // S type
                imm = {{20{inst[31]}}, inst[31 : 25], inst[11 : 7]};
            `B_type:                                                                          // B type
                imm = {{20{inst[31]}}, inst[7], inst[30 : 25], inst[11 : 8], 1'b0};
            `U_type:                                                                          // U type
                imm = {inst[31 : 12], 12'b0};
            `J_type:                                                                          // J type
                imm = {{12{inst[31]}}, inst[19 : 12], inst[20], inst[30 : 21], 1'b0};
            default:
                imm = 32'b0;                                                                  // R-type
        endcase
    end

endmodule

