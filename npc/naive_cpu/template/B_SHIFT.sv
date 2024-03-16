/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 22:21:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 23:23:06
 */

// 桶型移位器

module B_SHIFT #(
    parameter data_width = 6'd32, 
    parameter shamt_width = 3'd5
)
(
    input   [data_width-1 : 0]    din,    // The data designed to be shifted
    input   [shamt_width-1 : 0]   shamt,  // The bit of this shifting
    input                         LR,     // when LR=1, left_shift, else right_shift
    input                         AL,     // when AL=1, algorithm_shift, else logic_shift
    output reg [data_width-1 : 0] dout    // Output data
);

    // One interpretation of algorithm shift
    always_comb begin
        // logic shift
        if(AL == 1'b0 || (AL == 1'b1 && LR == 1'b1))
            dout = LR ? din << shamt : din >> shamt;
        // algorithm_shift(right)
        else begin
            dout = shamt[0] ? {din[data_width-1], din[data_width-1 : 1]} : din;
            dout = shamt[1] ? {{2{dout[data_width-1]}}, dout[data_width-1 : 2]} : dout;
            dout = shamt[2] ? {{4{dout[data_width-1]}}, dout[data_width-1 : 4]} : dout;
            dout = shamt[3] ? {{8{dout[data_width-1]}}, dout[data_width-1 : 8]} : dout;
            dout = shamt[4] ? {{16{dout[data_width-1]}}, dout[data_width-1 : 16]} : dout;
        end
    end

endmodule


