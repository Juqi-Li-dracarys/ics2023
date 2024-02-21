/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 20:18:07 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 10:28:41
 */

/*
    M 指令：
    01 000 乘法取低 32 位
    01 001 乘法取高 32 位，带符号
    01 011 乘法取高 32 位，无符号
*/

// naive way of building a mult

module MULT #(parameter data_width = 6'd32)(
    input       [data_width-1 : 0]    data_a,
    input       [data_width-1 : 0]    data_b,
    input       [1 : 0]               mul_op,
    output reg  [data_width-1 : 0]    result
);

    reg    [data_width*2-1 : 0]    mul;

    always_comb begin
        unique case(mul_op)
            2'b00: begin
                mul = data_a * data_b;
                result = mul[data_width-1 : 0];
            end 
            2'b01: begin
                mul = $signed(data_a) * $signed(data_b);
                result = mul[data_width*2-1 : data_width];
            end
            2'b11: begin
                mul = data_a * data_b;
                result = mul[data_width*2-1 : data_width];
            end 
            default: 
                result = 32'b0;
        endcase
    end

endmodule


