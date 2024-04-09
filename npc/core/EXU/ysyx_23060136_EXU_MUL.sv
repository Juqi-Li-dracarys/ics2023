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
    input                                                 clk           ,          
    input                                                 rst	        ,          
    input                                                 mul_valid	    ,                           
    input                                                 mulw	        ,                   
    input            [1 : 0]                              mul_signed    ,          
    input            [  `ysyx_23060136_BITS_W-1:0 ]       multiplicand  ,                
    input            [  `ysyx_23060136_BITS_W-1:0 ]       multiplier	, 

    output    logic                                       mul_ready	    ,                                                                    
    output    logic                                       mul_out_valid ,                                                          
    output    logic  [  `ysyx_23060136_BITS_W-1:0 ]       result_hi	    ,                                                             
    output    logic  [  `ysyx_23060136_BITS_W-1:0 ]       result_lo	                                                                                                                                   
);

    logic                             state;
    logic                             next_state;
    logic          [1 : 0]            cyc_counter;

    wire                              state_idle    =  (state == `ysyx_23060136_idle)   ;
    wire                              state_ready   =  (state == `ysyx_23060136_ready)  ;


// ===========================================================================
// function  interface
    wire            [127 : 0]         MUL_dword_u   =  $unsigned(multiplicand) * $unsigned(multiplier);
    wire            [127 : 0]         MUL_dword_s   =  $signed(multiplicand)   * $signed(multiplier);
    wire            [127 : 0]         MUL_dword_su  =  $signed(multiplicand)   * $unsigned(multiplier);
    // 
    wire            [31 : 0]          MUL_word      =  {$unsigned(multiplicand[31 : 0]) * $unsigned(multiplier[31 : 0])};    


    wire            [  `ysyx_23060136_BITS_W-1:0 ] MUL_result_hi =  {64{mul_signed == 2'b00}} &  MUL_dword_u[127 : 64]   | 
                                                                    {64{mul_signed == 2'b10}} &  MUL_dword_su[127 : 64]  |
                                                                    {64{mul_signed == 2'b11}} &  MUL_dword_s[127 : 64]   ;

    wire            [  `ysyx_23060136_BITS_W-1:0 ] MUL_result_lo =  (({64{mulw}})  & ({{32{MUL_word[31]}}, MUL_word}))   |
                                                                    ({64{!mulw}}   &
                                                                    ({64{mul_signed == 2'b00}} &  MUL_dword_u [63 : 0]    | 
                                                                     {64{mul_signed == 2'b10}} &  MUL_dword_su[63 : 0]    |
                                                                     {64{mul_signed == 2'b11}} &  MUL_dword_s [63 : 0]))  ;

// ===========================================================================

    always_comb begin : next_state_update
        unique case(state)
        `ysyx_23060136_idle: begin
            if(mul_valid & mul_ready) begin
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

    always_ff @(posedge clk) begin : mul_ready_update
        if(rst) begin
            mul_ready     <= `ysyx_23060136_true;
            mul_out_valid <= `ysyx_23060136_false;
        end
        else if((state_idle & next_state == `ysyx_23060136_ready)) begin
            mul_ready     <= `ysyx_23060136_false;
            mul_out_valid <= `ysyx_23060136_false;
        end
        else if(cyc_counter == 2'd3) begin
            mul_ready     <= `ysyx_23060136_true;
            mul_out_valid <= `ysyx_23060136_true;
        end
    end

    always_ff @(posedge clk) begin : mul_result_update
        if(rst) begin
            result_hi  <= `ysyx_23060136_false;
            result_lo  <= `ysyx_23060136_false;
        end
        else if(cyc_counter == 2'd3)begin
            result_hi  <= MUL_result_hi;
            result_lo  <= MUL_result_lo;
        end
    end


endmodule

