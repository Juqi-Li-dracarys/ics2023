/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-08 12:09:16 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-08 12:53:34
 */


 `include "ysyx_23060136_DEFINES.sv"
 

// 64-Bit Divider
// ===========================================================================
module ysyx_23060136_EXU_DIV(
        input                                                  clk	          ,   
        input                                                  rst 	          ,    
        input         [  `ysyx_23060136_BITS_W-1:0 ]           dividend       ,    
        input         [  `ysyx_23060136_BITS_W-1:0 ]           divisor	      ,              
        input                                                  div_valid      ,      
        input                                                  divw	          ,      
        input                                                  div_signed     ,   
        input                                                  flush	      , 
        output                                                 div_ready      ,  
        output                                                 div_out_valid  ,   
        output        [  `ysyx_23060136_BITS_W-1:0 ]           quotient       , 
        output        [  `ysyx_23060136_BITS_W-1:0 ]           remainder  
 );
        


    
endmodule


