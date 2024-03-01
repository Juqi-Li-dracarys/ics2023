/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-21 17:23:48
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 20:28:24
 */


 `include "DEFINES_ysyx23060136.sv"


 // CSR internal ctr
// ===========================================================================
 module IDU_CSR_DECODE_ysyx_23060136 (
    input              [  11:0]         IDU_csr_id                 ,
    output             [   1:0]         IDU_csr_rs                 ,
    output             [   1:0]         IDU_csr_rd                  
 );
    // CSR internal ctr
    logic    csr_ecall    = (IDU_csr_id     ==     12'd0);
    logic    csr_mret     = (IDU_csr_id     ==     12'd770);
    logic    csr_mtvec    = (IDU_csr_id     ==     12'd773);
    logic    csr_mstatus  = (IDU_csr_id     ==     12'd768);
    logic    csr_mcause   = (IDU_csr_id     ==     12'd834);
    logic    csr_mepc     = (IDU_csr_id     ==     12'd833);


    assign   IDU_csr_rs   = ({2{csr_ecall}}  & `mtvec)  | ({2{csr_mret}}    & `mepc)    |
                            ({2{csr_mtvec}}  & `mtvec)  | ({2{csr_mstatus}} & `mstatus) |
                            ({2{csr_mcause}} & `mcause) | ({2{csr_mepc}}    & `mepc);

    assign   IDU_csr_rd   = ({2{csr_ecall}}  & `mepc)   | ({2{csr_mret}}    & `mepc)    |
                            ({2{csr_mtvec}}  & `mtvec)  | ({2{csr_mstatus}} & `mstatus) |
                            ({2{csr_mcause}} & `mcause) | ({2{csr_mepc}}    & `mepc);

 endmodule


