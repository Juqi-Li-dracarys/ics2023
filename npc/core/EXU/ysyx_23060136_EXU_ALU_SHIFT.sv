/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 23:41:28 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 23:43:03
 */



 `include "ysyx_23060136_DEFINES.sv"


// 桶型移位器
// ===========================================================================
module ysyx_23060136_EXU_ALU_SHIFT #(
        parameter data_width  = `ysyx_23060136_BITS_W ,
        parameter shamt_width = `ysyx_23060136_BITS_S
    )
    (
        input        [data_width-1 : 0]    din   ,     // The data designed to be shifted
        input        [shamt_width-1 : 0]   shamt ,     // The bit of this shifting
        input                              LR    ,     // when LR=1, left_shift, else right_shift
        input                              AL    ,     // when AL=1, algorithm_shift, else logic_shift
        output logic [data_width-1 : 0]    dout        // Output data
    );

    // One interpretation of algorithm shift
    always_comb begin
        // logic shift
        if(AL == 1'b0 || (AL == 1'b1 && LR == 1'b1))
            dout = LR ? din << shamt : din >> shamt;
        // algorithm_shift(right)
        else begin
            dout = shamt[0] ? {din[data_width-1],        din[data_width-1 : 1]} :   din;
            dout = shamt[1] ? {{2{dout[data_width-1]}},  dout[data_width-1 : 2]} :  dout;
            dout = shamt[2] ? {{4{dout[data_width-1]}},  dout[data_width-1 : 4]} :  dout;
            dout = shamt[3] ? {{8{dout[data_width-1]}},  dout[data_width-1 : 8]} :  dout;
            dout = shamt[4] ? {{16{dout[data_width-1]}}, dout[data_width-1 : 16]} : dout;
        end
    end

endmodule


