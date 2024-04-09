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
        input                                                       clk	           ,   
        input                                                       rst 	       ,    
        input         [  `ysyx_23060136_BITS_W-1:0 ]                dividend       ,    
        input         [  `ysyx_23060136_BITS_W-1:0 ]                divisor	       ,              
        input                                                       div_valid      ,      
        input                                                       divw	       ,      
        input                                                       div_signed     ,   
        output  logic                                               div_ready      ,  
        output  logic                                               div_out_valid  ,   
        output  logic  [  `ysyx_23060136_BITS_W-1:0 ]               quotient       , 
        output  logic  [  `ysyx_23060136_BITS_W-1:0 ]               remainder  
 );



 logic                             state;
 logic                             next_state;
 logic          [1 : 0]            cyc_counter;

 wire                              state_idle    =  (state == `ysyx_23060136_idle)   ;
 wire                              state_ready   =  (state == `ysyx_23060136_ready)  ;


// ===========================================================================
// function  interface
 wire            [`ysyx_23060136_BITS_W-1 : 0]     DIV_dword_u   =  $unsigned(dividend) / $unsigned(divisor);
 wire            [`ysyx_23060136_BITS_W-1 : 0]     DIV_dword_s   =  $signed(dividend)   / $signed(divisor);

 wire            [31 : 0]                          DIV_word_u    =  $unsigned(dividend[31 : 0]) / $unsigned(divisor[31 : 0]);    
 wire            [31 : 0]                          DIV_word_s    =  $signed(dividend[31 : 0])   / $signed(divisor[31 : 0]);

 wire            [`ysyx_23060136_BITS_W-1 : 0]     REM_dword_u   =  $unsigned(dividend) % $unsigned(divisor);
 wire            [`ysyx_23060136_BITS_W-1 : 0]     REM_dword_s   =  $signed(dividend)   % $signed(divisor);

 wire            [31 : 0]                          REM_word_u    =  $unsigned(dividend[31 : 0]) % $unsigned(divisor[31 : 0]);    
 wire            [31 : 0]                          REM_word_s    =  $signed(dividend[31 : 0])   % $signed(divisor[31 : 0]);
 
 
 wire            [  `ysyx_23060136_BITS_W-1:0 ] MUL_result_quotient  =  {64{!divw & !div_signed}}  &  DIV_dword_u   | 
                                                                        {64{!divw &  div_signed}}  &  DIV_dword_s   |
                                                                        {64{divw  &  !div_signed}} &  {{32{DIV_word_u[31]}}, DIV_word_u} |
                                                                        {64{divw  &  div_signed}}  &  {{32{DIV_word_s[31]}}, DIV_word_s};


 wire            [  `ysyx_23060136_BITS_W-1:0 ] MUL_result_remainder =  {64{!divw & !div_signed}}  &  REM_dword_u   | 
                                                                        {64{!divw &  div_signed}}  &  REM_dword_s   |
                                                                        {64{divw  &  !div_signed}} &  {{32{REM_word_u[31]}}, REM_word_u} |
                                                                        {64{divw  &  div_signed}}  &  {{32{REM_word_s[31]}}, REM_word_s};                                                            
// ===========================================================================

 always_comb begin : next_state_update
     unique case(state)
     `ysyx_23060136_idle: begin
         if(div_valid & div_ready) begin
             next_state = `ysyx_23060136_ready;
         end
         else begin
             next_state = `ysyx_23060136_idle;
         end
     end
     `ysyx_23060136_ready: begin
         if(cyc_counter == 2'd3) begin
             next_state = `ysyx_23060136_idle;
         end
         else begin
             next_state = `ysyx_23060136_ready;
         end
     end
     default: next_state = `ysyx_23060136_idle;
     endcase
 end

 always_ff @(posedge clk) begin : state_update
     if(rst) begin
         state <=  `ysyx_23060136_idle;
     end
     else begin
         state <=   next_state;
     end
 end

 always_ff @(posedge clk) begin : counter_update
     if(rst || (state_idle & next_state == `ysyx_23060136_ready)) begin
         cyc_counter <= `ysyx_23060136_false;
     end
     else if(state_ready)begin
         cyc_counter <= cyc_counter + 1;
     end
 end

 always_ff @(posedge clk) begin : div_ready_update
     if(rst) begin
         div_ready     <= `ysyx_23060136_true;
         div_out_valid <= `ysyx_23060136_false;
     end
     else if((state_idle & next_state == `ysyx_23060136_ready)) begin
         div_ready     <= `ysyx_23060136_false;
         div_out_valid <= `ysyx_23060136_false;
     end
     else if(cyc_counter == 2'd3) begin
         div_ready     <= `ysyx_23060136_true;
         div_out_valid <= `ysyx_23060136_true;
     end
 end

 always_ff @(posedge clk) begin : div_result_update
     if(rst) begin
        quotient   <= `ysyx_23060136_false;
        remainder  <= `ysyx_23060136_false;
     end
     else if(cyc_counter == 2'd3)begin
        quotient   <=  MUL_result_quotient;
        remainder  <=  MUL_result_remainder;
     end
 end

endmodule


