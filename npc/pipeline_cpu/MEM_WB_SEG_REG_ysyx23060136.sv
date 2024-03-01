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

        input                               MEM_o_commit               ,
        input             [31 : 0]          MEM_o_pc                   ,
        input             [31 : 0]          MEM_o_inst                 ,

        input             [31 : 0]          MEM_o_ALU_ALUout           ,
        input             [31 : 0]          MEM_o_ALU_CSR_out          ,
        input             [31 : 0]          MEM_o_rdata                ,

        input                               MEM_o_write_gpr            ,
        input                               MEM_o_write_csr            ,
        input                               MEM_o_mem_to_reg           ,

        input             [4 : 0]           MEM_o_rd                   ,
        input             [1 : 0]           MEM_o_csr_rd               ,
        // system signal
        input                               MEM_o_system_halt          ,
        input                               MEM_o_op_valid             ,
        input                               MEM_o_ALU_valid            ,

        // ===========================================================================
        output   logic                      WB_i_commit                  ,
        output   logic    [31 : 0]          WB_i_pc                      ,
        output   logic    [31 : 0]          WB_i_inst                    ,

        output   logic    [31 : 0]          WB_i_ALU_ALUout              ,
        output   logic    [31 : 0]          WB_i_ALU_CSR_out             ,
        output   logic    [31 : 0]          WB_i_rdata                   ,

        output   logic                      WB_i_write_gpr               ,
        output   logic                      WB_i_write_csr               ,
        output   logic                      WB_i_mem_to_reg              ,

        output   logic    [4 : 0]           WB_i_rd                      ,
        output   logic    [1 : 0]           WB_i_csr_rd                  ,

        output   logic                      WB_i_system_halt             ,
        output   logic                      WB_i_op_valid                ,
        output   logic                      WB_i_ALU_valid

    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushME & ~FORWARD_stallWB)) begin
            WB_i_commit         <=     1'b0;
            WB_i_pc             <=     `PC_RST;
            WB_i_inst           <=     `NOP;
            WB_i_ALU_ALUout     <=     32'b0;
            WB_i_ALU_CSR_out    <=     32'b0;
            WB_i_rdata          <=     32'b0;

            WB_i_write_gpr      <=     1'b0;
            WB_i_write_csr      <=     1'b0;
            WB_i_mem_to_reg     <=     1'b0;

            WB_i_rd             <=     5'b0;
            WB_i_csr_rd         <=     2'b0;
            WB_i_system_halt    <=     1'b0;
            WB_i_op_valid       <=     1'b0;
            WB_i_ALU_valid      <=     1'b0;
        end
        else if(~FORWARD_stallWB) begin
            WB_i_commit         <=     MEM_o_commit;
            WB_i_pc             <=     MEM_o_pc;
            WB_i_inst           <=     MEM_o_inst;
            WB_i_ALU_ALUout     <=     MEM_o_ALU_ALUout;
            WB_i_ALU_CSR_out    <=     MEM_o_ALU_CSR_out;
            WB_i_rdata          <=     MEM_o_rdata;

            WB_i_write_gpr      <=     MEM_o_write_gpr;
            WB_i_write_csr      <=     MEM_o_write_csr;
            WB_i_mem_to_reg     <=     MEM_o_mem_to_reg;

            WB_i_rd             <=     MEM_o_rd;
            WB_i_csr_rd         <=     MEM_o_csr_rd;
            WB_i_system_halt    <=     MEM_o_system_halt;
            WB_i_op_valid       <=     MEM_o_op_valid;
            WB_i_ALU_valid      <=     MEM_o_ALU_valid;
        end
    end

endmodule


