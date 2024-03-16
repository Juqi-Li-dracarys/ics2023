/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-23 01:01:26 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-23 12:23:49
 */


 `include "DEFINES_ysyx23060136.sv"

 // module for dealing with csr 
// ===========================================================================
module EXU_ALU_CSR_ysyx23060136 (
    input              [  31:0]         EXU_pc                     ,
    input              [  31:0]         EXU_HAZARD_rs1_data        ,
    input              [  31:0]         EXU_HAZARD_csr_rs_data     ,
    input                               EXU_rv32_csrrs             ,
    input                               EXU_rv32_csrrw             ,
    input                               EXU_rv32_ecall             ,
    output             [  31:0]         EXU_ALU_CSR_out             
 );

    assign EXU_ALU_CSR_out  = ({32{EXU_rv32_csrrs}}  & (EXU_HAZARD_rs1_data | EXU_HAZARD_csr_rs_data))  |
                              ({32{EXU_rv32_csrrw}}  & (EXU_HAZARD_rs1_data))                           |
                              ({32{EXU_rv32_ecall}}  & (EXU_pc))                                        ;
     
endmodule


