/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-05-02 10:57:31 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-11 11:09:46
 */

 
 `include "ysyx_23060136_DEFINES.sv"

 
// Three bits full adder
// ===========================================================================
module ysyx_23060136_CSA(
    input     [   2:0]       in             ,
    output                   cout           ,
    output                   s               
);

    wire          a,b,cin                   ;
    
    assign        a     =       in[2]       ;
    assign        b     =       in[1]       ;
    assign        cin   =       in[0]       ;
    assign        s     =       a ^ b ^ cin ;
    assign        cout  =       a & b       | 
                                b & cin     | 
                                a & cin     ;

endmodule


