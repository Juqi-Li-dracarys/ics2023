/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-23 01:05:22 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-23 12:20:59
 */


`include "EXU_DEFINES_ysyx23060136.sv"

 
// ALU of the CPU
// ===========================================================================
module EXU_ALU_ysyx23060136 (
        input       [31 : 0]    EXU_ALU_da,       // input signal A
        input       [31 : 0]    EXU_ALU_db,       // input signal B

        input                   EXU_ALU_add,
        input                   EXU_ALU_sub,
        input                   EXU_ALU_slt,
        input                   EXU_ALU_sltu,
        input                   EXU_ALU_or,
        input                   EXU_ALU_and,
        input                   EXU_ALU_xor,
        input                   EXU_ALU_sll,
        input                   EXU_ALU_srl,
        input                   EXU_ALU_sra,
        input                   EXU_ALU_explicit,

        output                  EXU_ALU_Less,
        output                  EXU_ALU_Zero,
        output     [31 : 0]     EXU_ALU_ALUout,   // output of the result
        output                  EXU_ALU_valid
    );


    // Control bus
    logic sub_add = (EXU_ALU_sub)|(EXU_ALU_slt)|(EXU_ALU_sltu); // sub_add = 1, subtract
    logic US      = (EXU_ALU_sltu);                             // US = 1, unsigned
    logic LR      = (EXU_ALU_sll);                              // LR = 1, left
    logic AL      = (EXU_ALU_sra);                              // AL = 1, algorithm shif

    
    // subtract db
    logic  [31 : 0]   sub_db = {32{sub_add}} ^ EXU_ALU_db;

    // adder
    logic             add_carry;
    logic             add_overflow;
    logic  [31 : 0]   add_result;

    assign {add_carry,add_result} = EXU_ALU_da + sub_db + {{31{1'b0}}, sub_add};
    assign add_overflow           = (EXU_ALU_da[31] == sub_db[31]) && (EXU_ALU_da[31] != add_result[31]);
    assign EXU_ALU_Zero           = (add_result == 32'b0);
    assign EXU_ALU_Less           = US ? add_carry ^ sub_add : add_overflow ^ add_result[31];

    
    // shifter
    logic   [31 : 0]   result_shifter;

    EXU_ALU_SHIFT_ysyx23060136 shifter (
                                   .din(EXU_ALU_da),
                                   .shamt(EXU_ALU_db[4 : 0]),
                                   .LR(LR),
                                   .AL(AL),
                                   .dout(result_shifter)
                               );

                               
    // ALU output control
    assign EXU_ALU_ALUout =     ({32{EXU_ALU_add}}       & (add_result))                 |
                                ({32{EXU_ALU_sub}}       & (add_result))                 |

                                ({32{EXU_ALU_slt}}       & ({{31{1'b0}}, EXU_ALU_Less})) |
                                ({32{EXU_ALU_sltu}}      & ({{31{1'b0}}, EXU_ALU_Less})) |

                                ({32{EXU_ALU_or}}        & (EXU_ALU_da | EXU_ALU_db))    |
                                ({32{EXU_ALU_and}}       & (EXU_ALU_da & EXU_ALU_db))    |
                                ({32{EXU_ALU_xor}}       & (EXU_ALU_da ^ EXU_ALU_db))    |

                                ({32{EXU_ALU_sll}}       & (result_shifter))             |
                                ({32{EXU_ALU_srl}}       & (result_shifter))             |
                                ({32{EXU_ALU_sra}}       & (result_shifter))             |

                                ({32{EXU_ALU_explicit}}  & (EXU_ALU_db))                 ;


    assign EXU_ALU_valid  =     (EXU_ALU_add      && !(EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_sub      && !(EXU_ALU_add || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_slt      && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_sltu     && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_or       && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_and      && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_xor      && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_sll      && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_srl || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_srl      && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_sra || EXU_ALU_explicit)) ||
                                (EXU_ALU_sra      && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_explicit)) ||
                                (EXU_ALU_explicit && !(EXU_ALU_add || EXU_ALU_sub || EXU_ALU_slt || EXU_ALU_sltu || EXU_ALU_or || EXU_ALU_and || EXU_ALU_xor || EXU_ALU_sll || EXU_ALU_srl || EXU_ALU_sra));    

endmodule



