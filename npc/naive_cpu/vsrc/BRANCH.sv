/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 17:28:53 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 10:20:08
 */

// Branch control

/*
    000 非跳转指令
    001 无条件跳转 PC 目标
    010 无条件跳转寄存器目标
    100 条件分支，等于
    101 条件分支，不等于
    110 条件分支，小于
    111 条件分支，大于等于
    011 ecall 跳转
*/

module BRANCH (
        input       [2 : 0]    Branch,
        input                  Zero, 
        input                  Less,
        output reg             PCAsrc,
        output reg  [1 : 0]    PCBsrc
);

    always_comb begin
        unique case(Branch)
            3'b000: begin
                PCAsrc = 1'b0; PCBsrc = 2'b0;
            end
            3'b001: begin
                PCAsrc = 1'b1; PCBsrc = 2'b0;
            end
            3'b010: begin
                PCAsrc = 1'b1; PCBsrc = 2'b1;
            end                       
            3'b100: begin
                PCAsrc = Zero; PCBsrc = 2'b0;
            end
            3'b101: begin
                PCAsrc = ~Zero; PCBsrc = 2'b0;
            end
            3'b110: begin
                PCAsrc = Less; PCBsrc = 2'b0;
            end
            3'b111: begin
                PCAsrc = ~Less; PCBsrc = 2'b0;
            end
            // ecall and mret
            3'b011: begin
                PCAsrc = 1'b1; PCBsrc = 2'h2;
            end
            default: begin
                PCAsrc = 1'b0; PCBsrc = 2'b0;
            end
        endcase
    end

endmodule


