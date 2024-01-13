/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 20:18:07 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 20:44:45
 */

module MULT(
    input    [31 : 0]    a,
    input    [31 : 0]    b,
    output   [63 : 0]    result
);

    assign result = a * b;

endmodule


