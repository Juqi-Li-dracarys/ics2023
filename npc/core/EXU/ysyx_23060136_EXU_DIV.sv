/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-08 12:09:16 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 08:58:19
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
        output                                                      div_ready      ,  
        output                                                      div_out_valid  ,   
        output        [  `ysyx_23060136_BITS_W-1:0 ]                quotient       , 
        output        [  `ysyx_23060136_BITS_W-1:0 ]                remainder  
 );



`ifdef ysyx_23060136_DIV

/*
    // data amend before computing
 `  // convert from signed to unsigned

    被除数	除数	商	余数
    正	    正	   正	正
    正	    负	   负	正
    负	    正	   负	负
    负	    负	   正	负
*/

    wire [63 : 0]  dividend_amend  = divw ? ((div_signed && dividend[31]) ? {32'b0, -dividend[31:0]} : {32'b0, dividend[31:0]}) : 
                                            ((div_signed && dividend[63]) ? -dividend : dividend);

    wire [63 : 0]  divisor_amend   = divw ? ((div_signed && divisor[31])  ? {32'b0, -divisor[31:0]}  : {32'b0, divisor[31:0]}) : 
                                            ((div_signed && divisor[63])  ? -divisor  : divisor);

    // reverse and plus 1
    logic                                     quotient_signed_amend      ;
    logic                                     remainder_signed_amend     ;

    always_comb begin
        if(divw) begin
            quotient_signed_amend  = div_signed && (dividend[31] ^ divisor[31]) ? 1'b1 : 1'b0   ;
            remainder_signed_amend = div_signed &&  dividend[31] ? 1'b1 : 1'b0                  ;
        end
        else begin
            quotient_signed_amend  = div_signed && (dividend[63] ^ divisor[63]) ? 1'b1 : 1'b0   ;
            remainder_signed_amend = div_signed &&  dividend[63] ? 1'b1 : 1'b0                  ;
        end
    end

    // ===========================================================================
    // start calculate the quotient and remainder

    logic                 [ 63:0]          dividend_s                 ;
    logic                 [  127:0]        divisor_s                  ;
    logic                 [   8:0]         shift_times                ;
    logic                                  divider_working            ;
    logic                 [  63:0]         quotient_s                 ;

    
    always_ff @(posedge clk) begin
        if(rst || div_out_valid) begin
            dividend_s      <= 64'b0    ;
            divisor_s       <= 128'b0   ;
            shift_times     <= 9'b0     ;
            divider_working <= 1'b0     ;
            quotient_s      <= 64'b0    ;
        end
        else if(div_valid && div_ready) begin
            divisor_s       <= divw ? {33'b0, divisor_amend, 31'b0} : {1'b0, divisor_amend, 63'b0} ;
            dividend_s      <= dividend_amend            ;
            shift_times     <= 9'b0                      ;
            divider_working <= 1'b1                      ;
            quotient_s      <= 64'b0                     ;
        end
        else if(divider_working) begin
            // reamainder < 0
            if({64'b0, dividend_s} < divisor_s) begin
                divisor_s   <= {1'b0, divisor_s[127 : 1]};
                quotient_s  <= {quotient_s[62 : 0], 1'b0};
            end
            // reamainder >= 0
            else begin
                dividend_s  <= part_sub[63 : 0]          ;
                divisor_s   <= {1'b0, divisor_s[127 : 1]};
                quotient_s  <= {quotient_s[62:0], 1'b1}  ;
            end
            shift_times     <= shift_times + 1           ;
        end
    end


    wire  [  63:0]   part_sub    =  dividend_s - divisor_s[63 : 0]                                          ;


    assign div_ready              =  ~divider_working                                                       ;
    assign div_out_valid          =  divw      ? (shift_times == 9'd32) : (shift_times == 9'd64)            ;
    assign quotient               =  quotient_signed_amend  ? -quotient_s : quotient_s                      ;
    assign remainder              =  remainder_signed_amend ? -dividend_s : dividend_s                      ;

                      
    // ===========================================================================
    // signal cycle multiply sim
`else

    logic                             state;
    logic                             next_state;
    logic          [1 : 0]            cyc_counter;

    wire                              state_idle    =  (state == `ysyx_23060136_idle)   ;
    wire                              state_ready   =  (state == `ysyx_23060136_ready)  ;


    // ===========================================================================
    // function  interface
    wire         [`ysyx_23060136_BITS_W-1 : 0]     DIV_dword_u   =  $unsigned(dividend) / $unsigned(divisor);
    wire         [`ysyx_23060136_BITS_W-1 : 0]     DIV_dword_s   =  $signed(dividend)   / $signed(divisor);

    wire         [31 : 0]                          DIV_word_u    =  $unsigned(dividend[31 : 0]) / $unsigned(divisor[31 : 0]);    
    wire         [31 : 0]                          DIV_word_s    =  $signed(dividend[31 : 0])   / $signed(divisor[31 : 0]);

    wire         [`ysyx_23060136_BITS_W-1 : 0]     REM_dword_u   =  $unsigned(dividend) % $unsigned(divisor);
    wire         [`ysyx_23060136_BITS_W-1 : 0]     REM_dword_s   =  $signed(dividend)   % $signed(divisor);

    wire         [31 : 0]                          REM_word_u    =  $unsigned(dividend[31 : 0]) % $unsigned(divisor[31 : 0]);    
    wire         [31 : 0]                          REM_word_s    =  $signed(dividend[31 : 0])   % $signed(divisor[31 : 0]);
    
    
    assign                                         quotient      =  {64{!divw & !div_signed}}  &  DIV_dword_u   | 
                                                                    {64{!divw &  div_signed}}  &  DIV_dword_s   |
                                                                    {64{divw  &  !div_signed}} &  {{32{DIV_word_u[31]}}, DIV_word_u} |
                                                                    {64{divw  &  div_signed}}  &  {{32{DIV_word_s[31]}}, DIV_word_s};

    assign                                         remainder     =    {64{!divw & !div_signed}}  &  REM_dword_u   | 
                                                                    {64{!divw &  div_signed}}  &  REM_dword_s   |
                                                                    {64{divw  &  !div_signed}} &  {{32{REM_word_u[31]}}, REM_word_u} |
                                                                    {64{divw  &  div_signed}}  &  {{32{REM_word_s[31]}}, REM_word_s};   
    
    assign                                         div_ready     =    state_idle                                ;
    assign                                         div_out_valid =    &cyc_counter                              ;
                                                                        
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
            if(&cyc_counter) begin
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


`endif

endmodule


