/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-05-02 16:02:22 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-05-02 16:07:21
 */


 `include "ysyx_23060136_DEFINES.sv"

 
// Booth partial product generator
// ===========================================================================
module ysyx_23060136_PP(
    // multiplier
    input       [   2:0]      b_in              ,
    // multiplicand
    input       [ 131:0]      A                 ,
    output      [ 131:0]      P                 ,
    output                    c                  
);

    // b+1, b, b-1
    wire                    b_add     =    b_in[2];
    wire                    b         =    b_in[1];
    wire                    b_sub     =    b_in[0];
    wire        [131:0]     double_A  =    A << 1 ;

    wire sel_negative, sel_double_negative, sel_positive, sel_double_positive;


    assign sel_negative         =  b_add & (b & ~b_sub | ~b & b_sub);
    assign sel_positive         = ~b_add & (b & ~b_sub | ~b & b_sub);
    assign sel_double_negative  =  b_add & ~b & ~b_sub              ;
    assign sel_double_positive  = ~b_add &  b &  b_sub              ;


    assign P = ~(~({132{sel_negative}} & ~A)  & ~({132{sel_double_negative}} & ~double_A) & 
                 ~({132{sel_positive}} & A )  & ~({132{sel_double_positive}} & double_A)) ;
          

    // 如果部分积的选择 是 ‑X 或者 ‑2X，则设置最后的末位进位 c 为 1
    // -X = ~X + 1 
    assign c = (sel_negative || sel_double_negative);


endmodule


