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

        output                                                   ALU_valid                    ,
        output                                                   EXU_ALU_Less                 ,
        output                                                   EXU_ALU_Zero                 ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_ALUout               ,

        
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
        input                                                    EXU_rv32_csrrs               ,
        input                                                    EXU_rv32_csrrw               ,
        input                                                    EXU_rv32_ecall               ,

        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_CSR_out             
    );

    wire  [  `ysyx_23060136_BITS_W-1:0]  ALU_da_word_t = EXU_i_ALU_word_t ? {32'b0, EXU_ALU_da[31 : 0]} : EXU_ALU_da;
    wire  [  `ysyx_23060136_BITS_W-1:0]  ALU_db_word_t = EXU_i_ALU_word_t ? {32'b0, EXU_ALU_da[31 : 0]} : EXU_ALU_da;

    // Control bus
    wire  sub_add = (EXU_i_ALU_sub) | (EXU_i_ALU_slt) | (EXU_i_ALU_sltu);  // sub_add = 1, subtract
    wire  US      = (EXU_i_ALU_sltu);                                      // US = 1, unsigned
    wire  LR      = (EXU_i_ALU_sll);                                       // LR = 1, left
    wire  AL      = (EXU_i_ALU_sra);                                       // AL = 1, algorithm shif

    
    // subtract db
    wire   [`ysyx_23060136_BITS_W-1 : 0]   sub_db = {32{sub_add}} ^ EXU_ALU_db;

    // adder
    wire              add_carry;
    wire              add_overflow;
    wire   [`ysyx_23060136_BITS_W-1 : 0]   add_result;

    assign {add_carry,add_result} = EXU_ALU_da + sub_db + {{`ysyx_23060136_BITS_W-1{1'b0}}, sub_add};
    assign add_overflow           = (EXU_ALU_da[`ysyx_23060136_BITS_W-1] == sub_db[`ysyx_23060136_BITS_W-1]) && (EXU_ALU_da[`ysyx_23060136_BITS_W-1] != add_result[`ysyx_23060136_BITS_W-1]);
    assign EXU_ALU_Zero           = (add_result == 32'b0);
    assign EXU_ALU_Less           = US ? add_carry ^ sub_add : add_overflow ^ add_result[`ysyx_23060136_BITS_W-1];

    
    // shifter
    wire    [`ysyx_23060136_BITS_W-1 : 0]   result_shifter;

    EXU_ALU_SHIFT_ysyx_23060136 shifter (
                                   .din(EXU_ALU_da),
                                   .shamt(EXU_ALU_db[4 : 0]),
                                   .LR(LR),
                                   .AL(AL),
                                   .dout(result_shifter)
                               );

                               
    // ALU output control
    assign EXU_ALU_ALUout =     ({32{EXU_ALU_add}}       & (add_result))                 |
                                ({32{EXU_ALU_sub}}       & (add_result))                 |

                                ({32{EXU_ALU_slt}}       & ({{`ysyx_23060136_BITS_W-1{1'b0}}, EXU_ALU_Less})) |
                                ({32{EXU_ALU_sltu}}      & ({{`ysyx_23060136_BITS_W-1{1'b0}}, EXU_ALU_Less})) |

                                ({32{EXU_ALU_or}}        & (EXU_ALU_da | EXU_ALU_db))    |
                                ({32{EXU_ALU_and}}       & (EXU_ALU_da & EXU_ALU_db))    |
                                ({32{EXU_ALU_xor}}       & (EXU_ALU_da ^ EXU_ALU_db))    |

                                ({32{EXU_ALU_sll}}       & (result_shifter))             |
                                ({32{EXU_ALU_srl}}       & (result_shifter))             |
                                ({32{EXU_ALU_sra}}       & (result_shifter))             |

                                ({32{EXU_ALU_explicit}}  & (EXU_ALU_db))                 ;


    assign EXU_ALU_CSR_out  =  ({32{EXU_rv32_csrrs}}  & (EXU_HAZARD_rs1_data | EXU_HAZARD_csr_rs_data))  |
                               ({32{EXU_rv32_csrrw}}  & (EXU_HAZARD_rs1_data))                           |
                               ({32{EXU_rv32_ecall}}  & (EXU_pc))                                        ;

endmodule



