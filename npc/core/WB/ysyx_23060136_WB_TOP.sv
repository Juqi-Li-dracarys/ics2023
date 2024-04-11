/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-10 15:24:02 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-10 15:26:43
 */


 `include "ysyx_23060136_DEFINES.sv"

 
// Top module for write back
// ===========================================================================
module ysyx_23060136_WB_TOP (
        input                                              WB_i_commit         ,
        input        [`ysyx_23060136_BITS_W-1 : 0]         WB_i_pc             ,
        input        [`ysyx_23060136_INST_W-1 : 0]         WB_i_inst           ,

        input        [`ysyx_23060136_BITS_W-1 : 0]         WB_i_ALU_ALUout     ,
        input        [`ysyx_23060136_BITS_W-1 : 0]         WB_i_ALU_CSR_out    ,
        input        [`ysyx_23060136_BITS_W-1 : 0]         WB_i_rdata          ,

        input                                              WB_i_write_gpr      ,
        input                                              WB_i_write_csr_1    ,
        input                                              WB_i_write_csr_2    ,
        input                                              WB_i_mem_to_reg     ,

        input        [`ysyx_23060136_GPR_W-1 : 0]          WB_i_rd             ,
        input        [`ysyx_23060136_CSR_W-1 : 0]          WB_i_csr_rd_1       ,
        input        [`ysyx_23060136_CSR_W-1 : 0]          WB_i_csr_rd_2       ,
        // system signal
        input                                              WB_i_system_halt    ,              

        // ===========================================================================
        // write back to IDU GPR register file and CSR register file
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_rf_busW               ,
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_csr_busW_1            ,
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_csr_busW_2            ,

        output             [  `ysyx_23060136_GPR_W-1:0]           WB_o_rd                    ,
        output             [  `ysyx_23060136_CSR_W-1:0]           WB_o_csr_rd_1              ,
        output             [  `ysyx_23060136_CSR_W-1:0]           WB_o_csr_rd_2              ,

        output                                                    WB_o_RegWr                 ,
        output                                                    WB_o_CSRWr_1               ,
        output                                                    WB_o_CSRWr_2               ,

        // write data for FORWARD
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_rs1_data              ,
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_rs2_data              ,
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_csr_rs_data_1         ,
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_csr_rs_data_2         ,

        // system
        output             [  `ysyx_23060136_BITS_W-1:0]          WB_o_pc                    ,
        output             [  `ysyx_23060136_INST_W-1:0]          WB_o_inst                  ,
        output                                                    WB_o_commit                ,
        output                                                    WB_o_system_halt           

    );

    // write back bus for gpr
    assign  WB_o_rf_busW        =    WB_i_mem_to_reg ?  WB_i_rdata : WB_i_ALU_ALUout ;
    // write back bus for csr
    assign  WB_o_csr_busW_1     =    WB_i_ALU_CSR_out;
    assign  WB_o_csr_busW_2     =    `ysyx_23060136_ecall_v;
    assign  WB_o_rd             =    WB_i_rd;
    assign  WB_o_csr_rd_1       =    WB_i_csr_rd_1 ;
    assign  WB_o_csr_rd_2       =    WB_i_csr_rd_2 ;
    assign  WB_o_RegWr          =    WB_i_write_gpr;
    assign  WB_o_CSRWr_1        =    WB_i_write_csr_1;
    assign  WB_o_CSRWr_2        =    WB_i_write_csr_2;
    assign  WB_o_commit         =    WB_i_commit;
    assign  WB_o_system_halt    =    WB_i_system_halt;
    assign  WB_o_pc             =    WB_i_pc;
    assign  WB_o_inst           =    WB_i_inst;

    // signal for FORWARD
    assign  WB_o_rs1_data       =    WB_o_rf_busW ; 
    assign  WB_o_rs2_data       =    WB_o_rf_busW ;
    assign  WB_o_csr_rs_data_1  =    WB_o_csr_busW_1;
    assign  WB_o_csr_rs_data_2  =    WB_o_csr_busW_2;

endmodule


