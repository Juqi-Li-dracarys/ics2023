/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 17:16:35 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 17:19:51
 */


 `include "ysyx_23060136_DEFINES.sv"


 // CSR internal ctr
// ===========================================================================
 module ysyx_23060136_IDU_CSR_DECODE (
    input              [  11:0]                              IDU_csr_id                 ,
    output             [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rs                 ,
    output             [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rd_1               ,
    output             [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rd_2                 
 );
 
    // CSR internal ctr
    wire     csr_ecall         = (IDU_csr_id     ==     12'd0  )   ;
    wire     csr_mret          = (IDU_csr_id     ==     12'd770)   ;
    wire     csr_mtvec         = (IDU_csr_id     ==     12'd773)   ;
    wire     csr_mstatus       = (IDU_csr_id     ==     12'd768)   ;
    wire     csr_mcause        = (IDU_csr_id     ==     12'd834)   ;
    wire     csr_mepc          = (IDU_csr_id     ==     12'd833)   ;

    wire     csr_mvendorid     = (IDU_csr_id     ==     12'd3857)  ;
    wire     csr_marchid       = (IDU_csr_id     ==     12'd3858)  ;


   
    assign   IDU_csr_rs        = ({`ysyx_23060136_CSR_W{csr_ecall}}     & `ysyx_23060136_mtvec)     | ({`ysyx_23060136_CSR_W{csr_mret}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mtvec}}     & `ysyx_23060136_mtvec)     | ({`ysyx_23060136_CSR_W{csr_mstatus}}    & `ysyx_23060136_mstatus) |
                                 ({`ysyx_23060136_CSR_W{csr_mcause}}    & `ysyx_23060136_mcause)    | ({`ysyx_23060136_CSR_W{csr_mepc}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mvendorid}} & `ysyx_23060136_mvendorid) | ({`ysyx_23060136_CSR_W{csr_marchid}}    & `ysyx_23060136_marchid) ;

    assign   IDU_csr_rd_1      = ({`ysyx_23060136_CSR_W{csr_ecall}}     & `ysyx_23060136_mepc)      | ({`ysyx_23060136_CSR_W{csr_mret}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mtvec}}     & `ysyx_23060136_mtvec)     | ({`ysyx_23060136_CSR_W{csr_mstatus}}    & `ysyx_23060136_mstatus) |
                                 ({`ysyx_23060136_CSR_W{csr_mcause}}    & `ysyx_23060136_mcause)    | ({`ysyx_23060136_CSR_W{csr_mepc}}       & `ysyx_23060136_mepc)    |
                                 ({`ysyx_23060136_CSR_W{csr_mvendorid}} & `ysyx_23060136_mvendorid) | ({`ysyx_23060136_CSR_W{csr_marchid}}    & `ysyx_23060136_marchid) ;

    assign   IDU_csr_rd_2      = {`ysyx_23060136_CSR_W{csr_ecall}}      & `ysyx_23060136_mstatus;

    
endmodule


