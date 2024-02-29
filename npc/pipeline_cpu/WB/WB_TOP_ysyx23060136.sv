/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-27 16:42:25
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 08:42:05
 */


// ===========================================================================
module WB_TOP_ysyx23060136 (
        input                               WB_commit                  ,
        input              [  31:0]         WB_pc                      ,
        input              [  31:0]         WB_inst                    ,

        input              [  31:0]         WB_ALU_ALUout              ,
        input              [  31:0]         WB_ALU_CSR_out             ,
        input              [  31:0]         WB_rdata                   ,

        input              [   4:0]         WB_rd                      ,
        input              [   1:0]         WB_csr_rd                  ,

        input                               WB_write_gpr               ,
        input                               WB_write_csr               ,
        input                               WB_mem_to_reg              ,

        input                               WB_system_halt             ,
        input                               WB_op_valid                ,
        input                               WB_ALU_valid               ,
        // ===========================================================================
        // write back to IDU GPR register file and CSR register file
        output             [  31:0]         rf_busW                    ,
        output             [  31:0]         csr_busW                   ,
        output             [   4:0]         WBU_rd                     ,
        output             [   1:0]         WBU_csr_rd                 ,
        output                              RegWr                      ,
        output                              CSRWr                      ,

        output                              WBU_commit                 ,
        output                              WBU_system_halt            ,
        output                              WBU_op_valid               ,
        output                              WBU_ALU_valid              ,

        output             [  31:0]         WBU_pc                     ,
        output             [  31:0]         WBU_inst                    

    );

    assign  rf_busW         =  WB_mem_to_reg ?  WB_rdata : WB_ALU_ALUout ;
    assign  csr_busW        =  WB_ALU_CSR_out;
    assign  WBU_rd          =  WB_rd;
    assign  WBU_csr_rd      =  WB_csr_rd ;
    assign  RegWr           =  WB_write_gpr;
    assign  CSRWr           =  WB_write_csr;
    assign  WBU_commit      =  WB_commit;
    assign  WBU_system_halt =  WB_system_halt;
    assign  WBU_op_valid    =  WB_op_valid;
    assign  WBU_ALU_valid   =  WB_ALU_valid;
    assign  WBU_pc          =  WB_pc;
    assign  WBU_inst        =  WB_inst;

endmodule


