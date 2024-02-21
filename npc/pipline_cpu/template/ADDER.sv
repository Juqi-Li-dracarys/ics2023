/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 20:12:55 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 16:40:23
 */

// naive way of building an adder

module ADDER #(parameter data_width = 6'd32) (
    input                      cin,      // carry input
    input  [data_width-1 : 0]  data_a,   // input signal A
    input  [data_width-1 : 0]  data_b,   // input signal B
    output                     cout,     // carry signal
    output                     zero,     // zero signal
    output                     overflow, // overflow sinal
    output [data_width-1 : 0]  addout    // output of the result
);

    assign {cout,addout} = data_a + data_b + {{31{1'b0}}, cin};
    assign overflow = (data_a[data_width-1] == data_b[data_width-1]) && (data_a[data_width-1] != addout[data_width-1]);
    assign zero = (addout == 32'b0);

endmodule


