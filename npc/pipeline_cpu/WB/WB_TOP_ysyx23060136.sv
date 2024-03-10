/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-27 16:42:25
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-03 21:35:51
 */

 `include "DEFINES_ysyx23060136.sv"

 
// Top module for write back
// ===========================================================================
module WB_TOP_ysyx23060136 (
        input                               WB_i_commit                  ,
        input              [  31:0]         WB_i_pc                      ,
        input              [  31:0]         WB_i_inst                    ,

        input              [  31:0]         WB_i_ALU_ALUout              ,
        input              [  31:0]         WB_i_ALU_CSR_out             ,
        input              [  31:0]         WB_i_rdata                   ,

        input              [   4:0]         WB_i_rd                      ,
        input              [   1:0]         WB_i_csr_rd                  ,

        input                               WB_i_write_gpr               ,
        input                               WB_i_write_csr               ,
        input                               WB_i_mem_to_reg              ,

        input                               WB_i_system_halt             ,
        input                               WB_i_op_valid                ,
        input                               WB_i_ALU_valid               ,
        // ===========================================================================
        // write back to IDU GPR register file and CSR register file
        output             [  31:0]         WB_o_rf_busW               ,
        output             [  31:0]         WB_o_csr_busW              ,
        output             [   4:0]         WB_o_rd                    ,
        output             [   1:0]         WB_o_csr_rd                ,
        output                              WB_o_RegWr                 ,
        output                              WB_o_CSRWr                 ,

        // write data for FORWARD
        output             [  31:0]         WB_o_rs1_data              ,
        output             [  31:0]         WB_o_rs2_data              ,
        output             [  31:0]         WB_o_csr_rs_data           ,

        // system
        output             [  31:0]         WB_o_pc                    ,
        output             [  31:0]         WB_o_inst                  ,
        output                              WB_o_commit                ,
        output                              WB_o_system_halt           ,
        output                              WB_o_op_valid              ,
        output                              WB_o_ALU_valid             

    );

    // write back bus for gpr
    assign  WB_o_rf_busW        =    WB_i_mem_to_reg ?  WB_i_rdata : WB_i_ALU_ALUout ;
    // write back bus for csr
    assign  WB_o_csr_busW       =    WB_i_ALU_CSR_out;
    assign  WB_o_rd             =    WB_i_rd;
    assign  WB_o_csr_rd         =    WB_i_csr_rd ;
    assign  WB_o_RegWr          =    WB_i_write_gpr;
    assign  WB_o_CSRWr          =    WB_i_write_csr;
    assign  WB_o_commit         =    WB_i_commit;
    assign  WB_o_system_halt    =    WB_i_system_halt;
    assign  WB_o_op_valid       =    WB_i_op_valid;
    assign  WB_o_ALU_valid      =    WB_i_ALU_valid;
    assign  WB_o_pc             =    WB_i_pc;
    assign  WB_o_inst           =    WB_i_inst;

    // signal for FORWARD
    assign  WB_o_rs1_data       =    WB_o_rf_busW ; 
    assign  WB_o_rs2_data       =    WB_o_rf_busW ;
    assign  WB_o_csr_rs_data    =    WB_o_csr_busW;

endmodule


