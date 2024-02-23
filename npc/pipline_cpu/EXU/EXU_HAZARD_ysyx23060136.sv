/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-22 20:47:51 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-23 01:02:26
 */


// module for handling hazard in EXU
`include "EXU_DEFINES_ysyx23060136.sv"


// module for handling hazard in EXU
// ===========================================================================
module EXU_HAZARD_ysyx23060136(
        input       [31 : 0]     EXU_rs1_data,
        input       [31 : 0]     EXU_rs2_data,
        input       [31 : 0]     EXU_csr_rs_data,
        input       [31 : 0]     EXU_pc,
        input       [31 : 0]     EXU_imm,

        input       [31 : 0]     FORWARD_rs1_data,
        input       [31 : 0]     FORWARD_rs2_data,
        input       [31 : 0]     FORWARD_csr_rs_data,

        input                    FORWARD_rs1_hazard,
        input                    FORWARD_rs2_hazard,
        input                    FORWARD_csr_rs_hazard,

        output      [31 : 0]     EXU_HAZARD_rs1_data,
        output      [31 : 0]     EXU_HAZARD_rs2_data,
        output      [31 : 0]     EXU_HAZARD_csr_rs_data,

        // ALU
        input                    EXU_ALU_i1_rs1,
        input                    EXU_ALU_i1_pc,
        input                    EXU_ALU_i2_rs2,
        input                    EXU_ALU_i2_imm,
        input                    EXU_ALU_i2_4,
        input                    EXU_ALU_i2_csr,

        output      [31 : 0]     EXU_ALU_da,
        output      [31 : 0]     EXU_ALU_db
    );

    assign EXU_HAZARD_rs1_data    = FORWARD_rs1_hazard    ? FORWARD_rs1_data    :    EXU_rs1_data;
    assign EXU_HAZARD_rs2_data    = FORWARD_rs2_hazard    ? FORWARD_rs2_data    :    EXU_rs2_data;
    assign EXU_HAZARD_csr_rs_data = FORWARD_csr_rs_hazard ? FORWARD_csr_rs_data :    EXU_csr_rs_data;
    assign EXU_ALU_da             = ({32{EXU_ALU_i1_rs1}} & (EXU_HAZARD_rs1_data))    |
                                    ({32{EXU_ALU_i1_pc}}  & (EXU_pc))                 ;
    assign EXU_ALU_db             = ({32{EXU_ALU_i2_rs2}} & (EXU_HAZARD_rs2_data))    |
                                    ({32{EXU_ALU_i2_imm}} & (EXU_imm))                |
                                    ({32{EXU_ALU_i2_4}}   & (32'h4))                  |
                                    ({32{EXU_ALU_i2_csr}} & (EXU_csr_rs_data))        ;

endmodule


