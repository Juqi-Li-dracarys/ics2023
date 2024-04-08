/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-08 12:09:07 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-08 12:53:28
 */


 `include "ysyx_23060136_DEFINES.sv"


// 64-Bit multiply
// ===========================================================================
module ysyx_23060136_EXU_MUL (
    input                                            clk           ,          
    input                                            rst	       ,          
    input                                            mul_valid	   ,          
    input                                            flush	       ,                    
    input                                            mulw	       ,                   
    input       [1 : 0]                              mul_signed	   ,          
    input       [  `ysyx_23060136_BITS_W-1:0 ]       multiplicand  ,                
    input       [  `ysyx_23060136_BITS_W-1:0 ]       multiplier	   ,          
    output                                           mul_ready	   ,                                                                    
    output                                           mul_out_valid ,                                                          
    output      [  `ysyx_23060136_BITS_W-1:0 ]       result_hi	   ,                                                             
    output      [  `ysyx_23060136_BITS_W-1:0 ]       result_lo	                                                                                                                                   
);
    
endmodule

