/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 14:07:48 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-08 12:52:48
 */


 `include "ysyx_23060136_DEFINES.sv"


// ALU of the CPU
// ===========================================================================
module ysyx_23060136_EXU_ALU (
        input                                                    clk                          ,
        input                                                    rst                          ,

        input                                                    BRANCH_flushEX1              ,
        input                                                    FORWARD_stallEX2             ,

        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_da                   ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_db                   ,
        
        input                                                    EXU_i_ALU_word_t             ,
        input                                                    EXU_i_ALU_add                ,
        input                                                    EXU_i_ALU_sub                ,
        input                                                    EXU_i_ALU_slt                ,
        input                                                    EXU_i_ALU_sltu               ,
        input                                                    EXU_i_ALU_or                 ,
        input                                                    EXU_i_ALU_and                ,
        input                                                    EXU_i_ALU_xor                ,
        input                                                    EXU_i_ALU_sll                ,
        input                                                    EXU_i_ALU_srl                ,
        input                                                    EXU_i_ALU_sra                ,

        input                                                    EXU_i_ALU_mul                ,
        input                                                    EXU_i_ALU_mul_hi             ,
        input                                                    EXU_i_ALU_mul_lo             ,
        input                                                    EXU_i_ALU_mul_u              ,
        input                                                    EXU_i_ALU_mul_s              ,
        input                                                    EXU_i_ALU_mul_su             ,
        input                                                    EXU_i_ALU_div                ,
        input                                                    EXU_i_ALU_div_u              ,
        input                                                    EXU_i_ALU_div_s              ,
        input                                                    EXU_i_ALU_rem                ,
        input                                                    EXU_i_ALU_rem_u              ,
        input                                                    EXU_i_ALU_rem_s              ,

        input                                                    EXU_i_ALU_explicit           ,

        output     logic                                         ALU_valid                    ,
        output     logic                                         EXU_ALU_Less                 ,
        output     logic                                         EXU_ALU_Zero                 ,
        output     logic    [  `ysyx_23060136_BITS_W-1:0]        EXU_ALU_ALUout               ,

        
        // interface for MUL/DIV
        // ===========================================================================

        output     logic                                        mul_valid	                 ,   
        output     logic                                        mulw	                     ,  
        output     logic   [1 : 0]                              mul_signed	                 ,  
        output     logic   [  `ysyx_23060136_BITS_W-1:0 ]       multiplicand                 ,  
        output     logic   [  `ysyx_23060136_BITS_W-1:0 ]       multiplier	                 ,  
        input                                                   mul_ready	                 ,  
        input                                                   mul_out_valid	             ,  
        input              [  `ysyx_23060136_BITS_W-1:0 ]       result_hi	                 ,  
        input              [  `ysyx_23060136_BITS_W-1:0 ]       result_lo	                 ,

        output     logic                                        div_valid                    ,
        output     logic   [  `ysyx_23060136_BITS_W-1:0 ]       dividend                     ,                                                                         
        output     logic   [  `ysyx_23060136_BITS_W-1:0 ]       divisor	                     ,                                                                                                                                                                                                                   
        output     logic                                        divw	                     ,                                                                              
        output     logic                                        div_signed                   ,                                                                                                                                                                                          
        input                                                   div_ready                    ,                                                                                                                                              
        input                                                   div_out_valid                ,                                                                         
        input              [  `ysyx_23060136_BITS_W-1:0 ]       quotient                     ,                                                                             
        input              [  `ysyx_23060136_BITS_W-1:0 ]       remainder                    ,                              

        // CSR handler
        // ===========================================================================
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_pc                       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_rs1_data          ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_csr_rs_data       ,
        input                                                    EXU_rv64_csrrs               ,
        input                                                    EXU_rv64_csrrw               ,
        input                                                    EXU_rv64_ecall               ,

        output    logic    [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_CSR_out             
    );

    // word_t cut off
    wire  [  `ysyx_23060136_BITS_W-1:0]  ALU_da_word_t = EXU_i_ALU_word_t ? {32'b0, EXU_ALU_da[31 : 0]} : EXU_ALU_da;
    wire  [  `ysyx_23060136_BITS_W-1:0]  ALU_db_word_t = EXU_i_ALU_word_t ? {32'b0, EXU_ALU_db[31 : 0]} : EXU_ALU_db;

    // Control bus
    wire                                 sub_add       = (EXU_i_ALU_sub) | (EXU_i_ALU_slt) | (EXU_i_ALU_sltu);  // sub_add = 1, subtract
    wire                                 US            = (EXU_i_ALU_sltu);                                      // US = 1, unsigned
    wire                                 LR            = (EXU_i_ALU_sll);                                       // LR = 1, left
    wire                                 AL            = (EXU_i_ALU_sra);                                       // AL = 1, algorithm shift

    
    // subtract db
    wire   [`ysyx_23060136_BITS_W-1 : 0]   sub_db                 = {`ysyx_23060136_BITS_W{sub_add}} ^ ALU_db_word_t;
    wire                                   add_carry;
    wire   [`ysyx_23060136_BITS_W-1 : 0]   add_result;
    assign                                 {add_carry,add_result} =  ALU_da_word_t + sub_db + {{`ysyx_23060136_BITS_W-1{1'b0}}, sub_add};      

    wire                                   add_overflow           =  ( ALU_da_word_t[`ysyx_23060136_BITS_W-1] == sub_db[`ysyx_23060136_BITS_W-1]) && ( ALU_da_word_t[`ysyx_23060136_BITS_W-1] != add_result[`ysyx_23060136_BITS_W-1]);
    wire                                   EXU_ALU_Zero_COMB      =  (add_result == `ysyx_23060136_BITS_W'b0);
    wire                                   EXU_ALU_Less_COMB      =  US ? add_carry ^ sub_add : add_overflow ^ add_result[`ysyx_23060136_BITS_W-1];

    
    // shifter
    wire    [`ysyx_23060136_BITS_W-1 : 0]  result_shifter;

    ysyx_23060136_EXU_SHIFT  shifter (
        .din                               (ALU_da_word_t             ),
        .shamt                             (ALU_db_word_t[`ysyx_23060136_BITS_S-1 : 0]),
        .LR                                (LR                        ),
        .AL                                (AL                        ),
        .dout                              (result_shifter            ) 
    );

                               
    // ALU result that does not require MUL OR DIV
    wire [`ysyx_23060136_BITS_W-1 : 0]  EXU_ALU_COMB     =      ({`ysyx_23060136_BITS_W{EXU_i_ALU_add}}       & (add_result))                 |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sub}}       & (add_result))                 |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_slt}}       & ({{`ysyx_23060136_BITS_W-1{1'b0}}, EXU_ALU_Less_COMB})) |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sltu}}      & ({{`ysyx_23060136_BITS_W-1{1'b0}}, EXU_ALU_Less_COMB})) |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_or}}        & ( ALU_da_word_t | ALU_db_word_t))    |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_and}}       & ( ALU_da_word_t & ALU_db_word_t))    |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_xor}}       & ( ALU_da_word_t ^ ALU_db_word_t))    |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sll}}       & (result_shifter))             |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_srl}}       & (result_shifter))             |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sra}}       & (result_shifter))             |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_explicit}}  & (ALU_db_word_t))              ;


    wire [`ysyx_23060136_BITS_W-1 : 0]  EXU_ALU_CSR_COMB   =    ({`ysyx_23060136_BITS_W{EXU_rv64_csrrs}}  & (EXU_HAZARD_rs1_data | EXU_HAZARD_csr_rs_data))  |
                                                                ({`ysyx_23060136_BITS_W{EXU_rv64_csrrw}}  & (EXU_HAZARD_rs1_data))                           |
                                                                ({`ysyx_23060136_BITS_W{EXU_rv64_ecall}}  & (EXU_pc))                                        ;





    // state machine of ALU
    logic    [2 : 0]        state;
    logic    [2 : 0]        next_state;

    wire                    state_idle             =  (state == `ysyx_23060136_idle)                         ;
    wire                    state_ready_mul        =  (state == `ysyx_23060136_ready_mul)                    ;
    wire                    state_ready_div        =  (state == `ysyx_23060136_ready_div)                    ;
    wire                    state_ready_wait_mul   =  (state == `ysyx_23060136_wait_mul)                     ;
    wire                    state_ready_wait_div   =  (state == `ysyx_23060136_wait_div)                     ;


    always_ff @(posedge clk) begin : state_update
        if(rst || (BRANCH_flushEX1 & ~FORWARD_stallEX2)) begin
            state <=  `ysyx_23060136_idle;
        end
        else begin
            state <=   next_state;
        end
    end

    // state trans
    always_comb begin
        unique case(state)
            `ysyx_23060136_idle: begin
                // raise the request of div or mul
                if(EXU_i_ALU_mul & !FORWARD_stallEX2) begin
                    next_state = `ysyx_23060136_ready_mul;
                end
                else if(EXU_i_ALU_div & !FORWARD_stallEX2) begin
                    next_state = `ysyx_23060136_ready_div;
                end
                else begin
                    next_state = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready_mul: begin
                if(mul_valid & mul_ready) begin
                    next_state = `ysyx_23060136_wait_mul;
                end
                else begin
                    next_state = `ysyx_23060136_ready_mul;
                end
            end
            `ysyx_23060136_ready_div: begin
                if(div_valid & div_ready) begin
                    next_state = `ysyx_23060136_wait_div;
                end
                else begin
                    next_state = `ysyx_23060136_ready_div;
                end
            end
            `ysyx_23060136_wait_mul: begin
                if(mul_out_valid) begin
                    next_state = `ysyx_23060136_idle;
                end
                else begin
                    next_state = `ysyx_23060136_wait_mul;
                end
            end
            `ysyx_23060136_wait_div: begin
                if(div_out_valid) begin
                    next_state = `ysyx_23060136_idle;
                end
                else begin
                    next_state = `ysyx_23060136_wait_div;
                end
            end
            default: next_state = `ysyx_23060136_idle;
        endcase
    end

    always_ff @(posedge clk) begin : seg_update
        if(rst || (BRANCH_flushEX1 & ~FORWARD_stallEX2)) begin
            EXU_ALU_Less    <=  `ysyx_23060136_false;
            EXU_ALU_Zero    <=  `ysyx_23060136_false;
            EXU_ALU_CSR_out <=  `ysyx_23060136_false;

            mulw            <=  `ysyx_23060136_false;
            mul_signed      <=  `ysyx_23060136_false;
            multiplicand    <=  `ysyx_23060136_false;
            multiplier      <=  `ysyx_23060136_false;

            dividend        <=  `ysyx_23060136_false;                                     
            divisor	        <=  `ysyx_23060136_false;                                     
            divw	        <=  `ysyx_23060136_false;                                     
            div_signed      <=  `ysyx_23060136_false;                                     
        end
        else if(~FORWARD_stallEX2) begin  
            EXU_ALU_Less    <=   EXU_ALU_Less_COMB;
            EXU_ALU_Zero    <=   EXU_ALU_Zero_COMB;
            EXU_ALU_CSR_out <=   EXU_ALU_CSR_COMB;

            mulw            <=   EXU_i_ALU_word_t;
            mul_signed      <=   (2'b00 & {2{EXU_i_ALU_mul}}) | (2'b10 & {2{EXU_i_ALU_mul_su}}) | (2'b11 & {2{EXU_i_ALU_mul_s}});
            multiplicand    <=   ALU_da_word_t;
            multiplier      <=   ALU_db_word_t;

            dividend        <=   ALU_da_word_t;
            divisor	        <=   ALU_db_word_t;    
            divw	        <=   EXU_i_ALU_word_t;                    
            div_signed      <=   (EXU_i_ALU_div_s | EXU_i_ALU_rem_s) & (!EXU_i_ALU_div_u | !EXU_i_ALU_rem_u);                  
        end
    end

    always_ff @(posedge clk) begin : mul_valid_update
        if(rst || (BRANCH_flushEX1 & ~FORWARD_stallEX2)) begin
            mul_valid <= `ysyx_23060136_false;
        end
        else if(state_idle & next_state == `ysyx_23060136_ready_mul) begin
            mul_valid <= `ysyx_23060136_true;
        end
        else if((next_state == `ysyx_23060136_wait_mul) & state_ready_mul) begin
            mul_valid <= `ysyx_23060136_false;
        end
    end

    always_ff @(posedge clk) begin : div_valid_update
        if(rst || (BRANCH_flushEX1 & ~FORWARD_stallEX2)) begin
            div_valid <= `ysyx_23060136_false;
        end
        else if(state_idle & next_state == `ysyx_23060136_ready_div) begin
            div_valid <= `ysyx_23060136_true;
        end
        else if((next_state == `ysyx_23060136_wait_div) & state_ready_div) begin
            div_valid <= `ysyx_23060136_false;
        end
    end

    
endmodule



