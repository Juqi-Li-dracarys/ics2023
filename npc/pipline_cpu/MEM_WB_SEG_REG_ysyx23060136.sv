/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-28 23:55:05 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 00:20:23
 */


`include "TOP_DEFINES_ysyx23060136.sv"


// ===========================================================================
module MEM_WB_SEG_REG_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
        // forward signal
        input                               FORWARD_flushME            ,
        input                               FORWARD_stallWB            ,

        input                               MEM_commit_WB              ,
        input             [31 : 0]          MEM_pc_WB                  ,
        input             [31 : 0]          MEM_inst_WB                ,

        input             [31 : 0]          MEM_ALU_ALUout_WB          ,
        input             [31 : 0]          MEM_ALU_CSR_out_WB         ,
        input             [31 : 0]          MEM_rdata                  ,

        input             [4 : 0]           MEM_rd_WB                  ,
        input             [1 : 0]           MEM_csr_rd_WB              ,
        // system signal
        input                               MEM_system_halt_WB         ,
        input                               MEM_op_valid_WB            ,
        input                               MEM_ALU_valid_WB           ,

        // ===========================================================================
        output   logic                      WB_commit                  ,
        output   logic    [31 : 0]          WB_pc                      ,
        output   logic    [31 : 0]          WB_inst                    ,

        output   logic    [31 : 0]          WB_ALU_ALUout              ,
        output   logic    [31 : 0]          WB_ALU_CSR_out             ,
        output   logic    [31 : 0]          WB_rdata                   ,

        output   logic    [4 : 0]           WB_rd                      ,
        output   logic    [1 : 0]           WB_csr_rd                  ,

        output   logic                      WB_system_halt             ,
        output   logic                      WB_op_valid                ,
        output   logic                      WB_ALU_valid

    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushME & ~FORWARD_stallWB)) begin
            WB_commit         <=     1'b0;
            WB_pc             <=     32'b0;
            WB_inst           <=     32'b0;
            WB_ALU_ALUout     <=     32'b0;
            WB_ALU_CSR_out    <=     32'b0;
            WB_rdata          <=     32'b0;
            WB_rd             <=     5'b0;
            WB_csr_rd         <=     2'b0;
            WB_system_halt    <=     1'b0;
            WB_op_valid       <=     1'b0;
            WB_ALU_valid      <=     1'b0;
        end
        else if(~FORWARD_stallWB) begin
            WB_commit         <=     MEM_commit_WB;
            WB_pc             <=     MEM_pc_WB;
            WB_inst           <=     MEM_inst_WB;
            WB_ALU_ALUout     <=     MEM_ALU_ALUout_WB;
            WB_ALU_CSR_out    <=     MEM_ALU_CSR_out_WB;
            WB_rdata          <=     MEM_rdata;
            WB_rd             <=     MEM_rd_WB;
            WB_csr_rd         <=     MEM_csr_rd_WB;
            WB_system_halt    <=     MEM_system_halt_WB;
            WB_op_valid       <=     MEM_op_valid_WB;
            WB_ALU_valid      <=     MEM_ALU_valid_WB;
        end
    end

endmodule


