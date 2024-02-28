/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-27 16:42:25 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 00:22:13
 */


// ===========================================================================
module WB_TOP_ysyx23060136 (
    input                       WB_commit                  ,
    input     [31 : 0]          WB_pc                      ,
    input     [31 : 0]          WB_inst                    ,

    input     [31 : 0]          WB_ALU_ALUout              ,
    input     [31 : 0]          WB_ALU_CSR_out             ,
    input     [31 : 0]          WB_rdata                   ,

    input     [4 : 0]           WB_rd                      ,
    input     [1 : 0]           WB_csr_rd                  ,

    input                       WB_system_halt             ,
    input                       WB_op_valid                ,
    input                       WB_ALU_valid           
                 
);
    
endmodule


