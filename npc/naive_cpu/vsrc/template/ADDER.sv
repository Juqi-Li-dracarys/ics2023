/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 20:12:55 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 20:13:15
 */

module ADDER(
    input    [31 : 0]    a,
    input    [31 : 0]    b,
    input                cin,
    output   [31 : 0]    sum,
    output               cout
);

    assign {cout,sum} = a + b + cin;

endmodule


