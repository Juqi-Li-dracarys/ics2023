/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 01:40:32 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 00:11:09
 */


`include "DEFINES_ysyx23060136.sv"

/*
      EXU -> EXU_REG -> MEM
*/

// ===========================================================================
module EXU_MEM_SEG_REG_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
        // ===========================================================================
        // forward unit signal
        input                               FORWARD_flushEX            ,
        input                               FORWARD_stallME            ,
        // ===========================================================================
        // general data
        input                               EXU_o_commit             ,
        input              [  31:0]         EXU_o_pc                 ,
        input              [  31:0]         EXU_o_inst               ,
        input              [  31:0]         EXU_o_ALU_ALUout         ,
        input              [  31:0]         EXU_o_ALU_CSR_out        ,

        // mem
        input              [   4:0]         EXU_o_rd                 ,
        input              [  31:0]         EXU_o_HAZARD_rs2_data    ,
        // mem
        input              [   2:0]         EXU_o_csr_rd             ,
        // mem
        input                               EXU_o_write_gpr          ,
        input                               EXU_o_write_csr          ,
        input                               EXU_o_mem_to_reg         ,

        input                               EXU_o_write_mem          ,
        input                               EXU_o_mem_byte           ,
        input                               EXU_o_mem_half           ,
        input                               EXU_o_mem_word           ,
        input                               EXU_o_mem_byte_u         ,
        input                               EXU_o_mem_half_u         ,

        input                               EXU_o_system_halt        ,

        // ===========================================================================
        output   logic                      MEM_i_commit                 ,
        output   logic    [31 : 0]          MEM_i_pc                     ,
        output   logic    [31 : 0]          MEM_i_inst                   ,
        output   logic    [31 : 0]          MEM_i_ALU_ALUout             ,
        output   logic    [31 : 0]          MEM_i_ALU_CSR_out            ,

        output   logic    [4 : 0]           MEM_i_rd                     ,
        output   logic    [31 : 0]          MEM_i_rs2_data               ,
        // mem
        output   logic    [2 : 0]           MEM_i_csr_rd                 ,
        // mem
        output   logic                      MEM_i_write_gpr              ,
        output   logic                      MEM_i_write_csr              ,
        output   logic                      MEM_i_mem_to_reg             ,

        output   logic                      MEM_i_write_mem              ,
        output   logic                      MEM_i_mem_byte               ,
        output   logic                      MEM_i_mem_half               ,
        output   logic                      MEM_i_mem_word               ,
        output   logic                      MEM_i_mem_byte_u             ,
        output   logic                      MEM_i_mem_half_u             ,

        // system
        output   logic                      MEM_i_system_halt            ,

        // MEM addr valid signal, 与前面的 PC 更新逻辑类似
        // 当需要读/写MEM时，会给一个短脉冲
        output   logic                      MEM_i_raddr_change           ,  
        output   logic                      MEM_i_waddr_change                    
    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_i_commit           <=  1'b0;
            MEM_i_pc               <=  `PC_RST;
            MEM_i_inst             <=  `NOP;
            MEM_i_ALU_ALUout       <=  32'b0;
            MEM_i_ALU_CSR_out      <=  32'b0;
            MEM_i_rd               <=  5'b0; 
            MEM_i_rs2_data         <=  32'b0;                        
            // mem
            MEM_i_csr_rd           <=  3'b0;                             
            // mem
            MEM_i_write_gpr        <=  1'b0;                                
            MEM_i_write_csr        <=  1'b0;                                
            MEM_i_mem_to_reg       <=  1'b0;                                 
    
            MEM_i_write_mem        <=  1'b0;                                
            MEM_i_mem_byte         <=  1'b0;                               
            MEM_i_mem_half         <=  1'b0;                               
            MEM_i_mem_word         <=  1'b0;                               
            MEM_i_mem_byte_u       <=  1'b0;                                 
            MEM_i_mem_half_u       <=  1'b0;                                 
    
            MEM_i_system_halt      <=  1'b0;                                                              
        end
        else if(~FORWARD_stallME) begin
            MEM_i_commit           <=  EXU_o_commit;
            MEM_i_pc               <=  EXU_o_pc;
            MEM_i_inst             <=  EXU_o_inst;
            MEM_i_ALU_ALUout       <=  EXU_o_ALU_ALUout;
            MEM_i_ALU_CSR_out      <=  EXU_o_ALU_CSR_out;
            MEM_i_rd               <=  EXU_o_rd;
            MEM_i_rs2_data         <=  EXU_o_HAZARD_rs2_data;                       
            // mem
            MEM_i_csr_rd           <=  EXU_o_csr_rd;                             
            // mem
            MEM_i_write_gpr        <=  EXU_o_write_gpr;                                
            MEM_i_write_csr        <=  EXU_o_write_csr;                                
            MEM_i_mem_to_reg       <=  EXU_o_mem_to_reg;                                 
    
            MEM_i_write_mem        <=  EXU_o_write_mem;                                
            MEM_i_mem_byte         <=  EXU_o_mem_byte;                               
            MEM_i_mem_half         <=  EXU_o_mem_half;                               
            MEM_i_mem_word         <=  EXU_o_mem_word;                               
            MEM_i_mem_byte_u       <=  EXU_o_mem_byte_u;                                 
            MEM_i_mem_half_u       <=  EXU_o_mem_half_u;                                 
    
            MEM_i_system_halt      <=  EXU_o_system_halt;                                    
        end
    end

    always_ff @(posedge clk) begin : update_MEM_i_raddr_change
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_i_raddr_change <= `false;
        end
        else begin
            MEM_i_raddr_change <= (~FORWARD_stallME & EXU_o_mem_to_reg);
        end
    end

    always_ff @(posedge clk) begin : update_MEM_i_waddr_change
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_i_waddr_change <= `false;
        end
        else begin
            MEM_i_waddr_change <= (~FORWARD_stallME & EXU_o_write_mem);
        end
    end
    

endmodule


