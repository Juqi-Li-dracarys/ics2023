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
        output                                                   EXU_ALU_Less                 ,
        output                                                   EXU_ALU_Zero                 ,
        output     logic        [  `ysyx_23060136_BITS_W-1:0]    EXU_ALU_ALUout               ,

        
        // interface for MUL/DIV
        output                                                  flush	                     , 

        output                                                  mul_valid	                 ,   
        output                                                  mulw	                     ,  
        output             [1 : 0]                              mul_signed	                 ,  
        output             [  `ysyx_23060136_BITS_W-1:0 ]       multiplicand                 ,  
        output             [  `ysyx_23060136_BITS_W-1:0 ]       multiplier	                 ,  
        input                                                   mul_ready	                 ,  
        input                                                   mul_out_valid	             ,  
        input              [  `ysyx_23060136_BITS_W-1:0 ]       result_hi	                 ,  
        input              [  `ysyx_23060136_BITS_W-1:0 ]       result_lo	                 ,

        output             [  `ysyx_23060136_BITS_W-1:0 ]       dividend                     ,                                                                         
        output             [  `ysyx_23060136_BITS_W-1:0 ]       divisor	                     ,                                                                                                                                    
        output                                                  div_valid                    ,                                                                                   
        output                                                  divw	                     ,                                                                              
        output                                                  div_signed                   ,                                                                                                                                                                                          
        input                                                   div_ready                    ,                                                                                                                                              
        input                                                   div_out_valid                ,                                                                         
        input              [  `ysyx_23060136_BITS_W-1:0 ]       quotient                     ,                                                                             
        input              [  `ysyx_23060136_BITS_W-1:0 ]       remainder                    ,                              


        // ===========================================================================
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_pc                       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_rs1_data          ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_csr_rs_data       ,
        input                                                    EXU_rv64_csrrs               ,
        input                                                    EXU_rv64_csrrw               ,
        input                                                    EXU_rv64_ecall               ,

        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_CSR_out             
    );

    // word_t cut off
    wire  [  `ysyx_23060136_BITS_W-1:0]  ALU_da_word_t = EXU_i_ALU_word_t ? {32'b0, EXU_ALU_da[31 : 0]} :  EXU_ALU_da;
    wire  [  `ysyx_23060136_BITS_W-1:0]  ALU_db_word_t = EXU_i_ALU_word_t ? {32'b0, EXU_ALU_db[31 : 0]} : EXU_ALU_db;

    // Control bus
    wire  sub_add = (EXU_i_ALU_sub) | (EXU_i_ALU_slt) | (EXU_i_ALU_sltu);  // sub_add = 1, subtract
    wire  US      = (EXU_i_ALU_sltu);                                      // US = 1, unsigned
    wire  LR      = (EXU_i_ALU_sll);                                       // LR = 1, left
    wire  AL      = (EXU_i_ALU_sra);                                       // AL = 1, algorithm shif

    
    // subtract db
    wire   [`ysyx_23060136_BITS_W-1 : 0]   sub_db = {`ysyx_23060136_BITS_W{sub_add}} ^ ALU_db_word_t;

    // adder
    wire                                   add_carry;
    wire                                   add_overflow;
    wire   [`ysyx_23060136_BITS_W-1 : 0]   add_result;

    assign                                 {add_carry,add_result} =  ALU_da_word_t + sub_db + {{`ysyx_23060136_BITS_W-1{1'b0}}, sub_add};
    assign                                 add_overflow           = ( ALU_da_word_t[`ysyx_23060136_BITS_W-1] == sub_db[`ysyx_23060136_BITS_W-1]) && ( ALU_da_word_t[`ysyx_23060136_BITS_W-1] != add_result[`ysyx_23060136_BITS_W-1]);
    assign                                 EXU_ALU_Zero           = (add_result == `ysyx_23060136_BITS_W'b0);
    assign                                 EXU_ALU_Less           = US ? add_carry ^ sub_add : add_overflow ^ add_result[`ysyx_23060136_BITS_W-1];

    
    // shifter
    wire    [`ysyx_23060136_BITS_W-1 : 0]   result_shifter;

    ysyx_23060136_EXU_SHIFT  shifter (
                                   .din(ALU_da_word_t),
                                   .shamt(ALU_db_word_t[5 : 0]),
                                   .LR(LR),
                                   .AL(AL),
                                   .dout(result_shifter)
                               );

                               
    // ALU result that does not require MUL OR DIV
    wire [`ysyx_23060136_BITS_W-1 : 0]  EXU_ALU_FAST_CAL =      ({`ysyx_23060136_BITS_W{EXU_i_ALU_add}}       & (add_result))                 |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sub}}       & (add_result))                 |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_slt}}       & ({{`ysyx_23060136_BITS_W-1{1'b0}}, EXU_ALU_Less})) |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sltu}}      & ({{`ysyx_23060136_BITS_W-1{1'b0}}, EXU_ALU_Less})) |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_or}}        & ( ALU_da_word_t | ALU_db_word_t))    |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_and}}       & ( ALU_da_word_t & ALU_db_word_t))    |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_xor}}       & ( ALU_da_word_t ^ ALU_db_word_t))    |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sll}}       & (result_shifter))             |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_srl}}       & (result_shifter))             |
                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_sra}}       & (result_shifter))             |

                                                                ({`ysyx_23060136_BITS_W{EXU_i_ALU_explicit}}  & (ALU_db_word_t))                 ;


    assign EXU_ALU_CSR_out                               =      ({`ysyx_23060136_BITS_W{EXU_rv64_csrrs}}  & (EXU_HAZARD_rs1_data | EXU_HAZARD_csr_rs_data))  |
                                                                ({`ysyx_23060136_BITS_W{EXU_rv64_csrrw}}  & (EXU_HAZARD_rs1_data))                           |
                                                                ({`ysyx_23060136_BITS_W{EXU_rv64_ecall}}  & (EXU_pc))                                        ;


    // state machine of ALU
    logic           state;
    logic           next_state;

    always_ff @(posedge clk) begin : blockName
        if(rst) begin
            state <=  `ysyx_23060136_idle;
        end
        else begin
            state <=  next_state;
        end
    end

    always_comb begin : next_state_cal
        unique case(state)
        `ysyx_23060136_idle: begin
            // raise the request of div or mul
            if(EXU_i_ALU_mul || EXU_i_ALU_div) begin
                next_state = `ysyx_23060136_busy;
            end
            else begin
                next_state = `ysyx_23060136_idle;
            end
        end 
        endcase
    end

endmodule



