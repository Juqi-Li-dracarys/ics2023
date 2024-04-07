/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-28 23:55:05 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 21:53:26
 */


`include "DEFINES_ysyx_23060136.sv"


// ===========================================================================
module MEM_WB_SEG_REG_ysyx_23060136 (
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
        input             [2 : 0]           MEM_o_csr_rd               ,
        // system signal
        input                               MEM_o_system_halt          ,
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
        output   logic    [2 : 0]           WB_i_csr_rd                  ,

        output   logic                      WB_i_system_halt             

    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushME & ~FORWARD_stallWB)) begin
            WB_i_commit         <=     `false;
            WB_i_pc             <=     `PC_RST;
            WB_i_inst           <=     `NOP;
            WB_i_ALU_ALUout     <=     32'b0;
            WB_i_ALU_CSR_out    <=     32'b0;
            WB_i_rdata          <=     32'b0;

            WB_i_write_gpr      <=     1'b0;
            WB_i_write_csr      <=     1'b0;
            WB_i_mem_to_reg     <=     1'b0;

            WB_i_rd             <=     5'b0;
            WB_i_csr_rd         <=     3'b0;
            WB_i_system_halt    <=     1'b0;
        end
        else begin
            WB_i_commit         <=     FORWARD_stallWB  ? `false              : MEM_o_commit;
            WB_i_pc             <=     FORWARD_stallWB  ?  WB_i_pc            : MEM_o_pc;
            WB_i_inst           <=     FORWARD_stallWB  ?  WB_i_inst          : MEM_o_inst;
            WB_i_ALU_ALUout     <=     FORWARD_stallWB  ?  WB_i_ALU_ALUout    : MEM_o_ALU_ALUout;
            WB_i_ALU_CSR_out    <=     FORWARD_stallWB  ?  WB_i_ALU_CSR_out   : MEM_o_ALU_CSR_out;
            WB_i_rdata          <=     FORWARD_stallWB  ?  WB_i_rdata         : MEM_o_rdata;

            WB_i_write_gpr      <=     FORWARD_stallWB  ?  WB_i_write_gpr     : MEM_o_write_gpr;
            WB_i_write_csr      <=     FORWARD_stallWB  ?  WB_i_write_csr     : MEM_o_write_csr;
            WB_i_mem_to_reg     <=     FORWARD_stallWB  ?  WB_i_mem_to_reg    : MEM_o_mem_to_reg;

            WB_i_rd             <=     FORWARD_stallWB  ?  WB_i_rd            : MEM_o_rd;
            WB_i_csr_rd         <=     FORWARD_stallWB  ?  WB_i_csr_rd        : MEM_o_csr_rd;
            WB_i_system_halt    <=     FORWARD_stallWB  ?  WB_i_system_halt   : MEM_o_system_halt;
        end
    end

endmodule


