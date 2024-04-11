/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-09 20:45:57 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-09 20:48:48
 */


 `include "ysyx_23060136_DEFINES.sv"

/*
      MEM -> MEM_WB_REG -> WB
*/

// ===========================================================================
module ysyx_23060136_MEM_WB_SEG_REG (
        input                                                    clk                        ,
        input                                                    rst                        ,
        // forward signal
        input                                                    FORWARD_flushME            ,
        input                                                    FORWARD_stallWB            ,

        input                                                    MEM_o_commit               ,
        input             [`ysyx_23060136_BITS_W-1 : 0]          MEM_o_pc                   ,
        input             [`ysyx_23060136_INST_W-1 : 0]          MEM_o_inst                 ,

        input             [`ysyx_23060136_BITS_W-1 : 0]          MEM_o_ALU_ALUout           ,
        input             [`ysyx_23060136_BITS_W-1 : 0]          MEM_o_ALU_CSR_out          ,
        input             [`ysyx_23060136_BITS_W-1 : 0]          MEM_o_rdata                ,

        input                                                    MEM_o_write_gpr            ,
        input                                                    MEM_o_write_csr_1          ,
        input                                                    MEM_o_write_csr_2          ,
        input                                                    MEM_o_mem_to_reg           ,

        input             [`ysyx_23060136_GPR_W-1 : 0]           MEM_o_rd                   ,
        input             [`ysyx_23060136_CSR_W-1 : 0]           MEM_o_csr_rd_1             ,
        input             [`ysyx_23060136_CSR_W-1 : 0]           MEM_o_csr_rd_2             ,
        // system signal
        input                                                    MEM_o_system_halt          ,

        // ===========================================================================
        output    logic                                          WB_i_commit               ,
        output    logic   [`ysyx_23060136_BITS_W-1 : 0]          WB_i_pc                   ,
        output    logic   [`ysyx_23060136_INST_W-1 : 0]          WB_i_inst                 ,

        output    logic   [`ysyx_23060136_BITS_W-1 : 0]          WB_i_ALU_ALUout           ,
        output    logic   [`ysyx_23060136_BITS_W-1 : 0]          WB_i_ALU_CSR_out          ,
        output    logic   [`ysyx_23060136_BITS_W-1 : 0]          WB_i_rdata                ,

        output    logic                                          WB_i_write_gpr            ,
        output    logic                                          WB_i_write_csr_1          ,
        output    logic                                          WB_i_write_csr_2          ,
        output    logic                                          WB_i_mem_to_reg           ,

        output    logic   [`ysyx_23060136_GPR_W-1 : 0]           WB_i_rd                   ,
        output    logic   [`ysyx_23060136_CSR_W-1 : 0]           WB_i_csr_rd_1             ,
        output    logic   [`ysyx_23060136_CSR_W-1 : 0]           WB_i_csr_rd_2             ,
        // system signal
        output    logic                                          WB_i_system_halt              

    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushME & ~FORWARD_stallWB)) begin
            WB_i_commit         <=     `ysyx_23060136_false;
            WB_i_pc             <=     `ysyx_23060136_PC_RST;
            WB_i_inst           <=     `ysyx_23060136_NOP;
            WB_i_ALU_ALUout     <=     `ysyx_23060136_false;
            WB_i_ALU_CSR_out    <=     `ysyx_23060136_false;
            WB_i_rdata          <=     `ysyx_23060136_false;

            WB_i_write_gpr      <=     `ysyx_23060136_false;
            WB_i_write_csr_1    <=     `ysyx_23060136_false;
            WB_i_write_csr_2    <=     `ysyx_23060136_false;
            WB_i_mem_to_reg     <=     `ysyx_23060136_false;

            WB_i_rd             <=     `ysyx_23060136_false;
            WB_i_csr_rd_1       <=     `ysyx_23060136_false;
            WB_i_csr_rd_2       <=     `ysyx_23060136_false;
            WB_i_system_halt    <=     `ysyx_23060136_false;
        end
        else if(~FORWARD_stallWB)begin
            WB_i_commit         <=     MEM_o_commit;
            WB_i_pc             <=     MEM_o_pc;
            WB_i_inst           <=     MEM_o_inst;
            WB_i_ALU_ALUout     <=     MEM_o_ALU_ALUout;
            WB_i_ALU_CSR_out    <=     MEM_o_ALU_CSR_out;
            WB_i_rdata          <=     MEM_o_rdata;

            WB_i_write_gpr      <=     MEM_o_write_gpr;
            WB_i_write_csr_1    <=     MEM_o_write_csr_1;
            WB_i_write_csr_2    <=     MEM_o_write_csr_2;
            WB_i_mem_to_reg     <=     MEM_o_mem_to_reg;

            WB_i_rd             <=     MEM_o_rd;
            WB_i_csr_rd_1       <=     MEM_o_csr_rd_1;
            WB_i_csr_rd_2       <=     MEM_o_csr_rd_2;
            WB_i_system_halt    <=     MEM_o_system_halt;
        end
    end

endmodule


