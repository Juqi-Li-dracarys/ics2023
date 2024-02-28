/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-24 01:40:32 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 00:11:09
 */


`include "TOP_DEFINES_ysyx23060136.sv"

/*
      EXU -> EXU_MEM_REG -> MEM
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
        input                               EXU_commit_MEM             ,
        input              [  31:0]         EXU_pc_MEM                 ,
        input              [  31:0]         EXU_inst_MEM               ,
        input              [  31:0]         EXU_ALU_ALUout             ,
        input              [  31:0]         EXU_ALU_CSR_out            ,

        // mem
        input              [   4:0]         EXU_rd_MEM                 ,
        input              [  31:0]         EXU_HAZARD_rs2_data        ,
        // mem
        input              [   1:0]         EXU_csr_rd_MEM             ,
        // mem
        input                               EXU_write_gpr_MEM          ,
        input                               EXU_write_csr_MEM          ,
        input                               EXU_mem_to_reg_MEM         ,

        input                               EXU_write_mem_MEM          ,
        input                               EXU_mem_byte_MEM           ,
        input                               EXU_mem_half_MEM           ,
        input                               EXU_mem_word_MEM           ,
        input                               EXU_mem_byte_u_MEM         ,
        input                               EXU_mem_half_u_MEM         ,

        input                               EXU_system_halt_MEM        ,
        input                               EXU_op_valid_MEM           ,
        input                               EXU_ALU_valid              ,
        // ===========================================================================
        output   logic                      MEM_commit                 ,
        output   logic    [31 : 0]          MEM_pc                     ,
        output   logic    [31 : 0]          MEM_inst                   ,
        output   logic    [31 : 0]          MEM_ALU_ALUout             ,
        output   logic    [31 : 0]          MEM_ALU_CSR_out            ,

        output   logic    [4 : 0]           MEM_rd                     ,
        output   logic    [31 : 0]          MEM_rs2_data               ,
        // mem
        output   logic    [1 : 0]           MEM_csr_rd                 ,
        // mem
        output   logic                      MEM_write_gpr              ,
        output   logic                      MEM_write_csr              ,
        output   logic                      MEM_mem_to_reg             ,

        output   logic                      MEM_write_mem              ,
        output   logic                      MEM_mem_byte               ,
        output   logic                      MEM_mem_half               ,
        output   logic                      MEM_mem_word               ,
        output   logic                      MEM_mem_byte_u             ,
        output   logic                      MEM_mem_half_u             ,

        // system
        output   logic                      MEM_system_halt            ,
        output   logic                      MEM_op_valid               ,
        output   logic                      MEM_ALU_valid 

    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_commit           <=  1'b0;
            MEM_pc               <=  32'b0;
            MEM_inst             <=  32'b0;
            MEM_ALU_ALUout       <=  32'b0;
            MEM_ALU_CSR_out      <=  32'b0;
            MEM_rd               <=  5'b0; 
            MEM_rs2_data         <=  32'b0;                        
            // mem
            MEM_csr_rd           <=  2'b0;                             
            // mem
            MEM_write_gpr        <=  1'b0;                                
            MEM_write_csr        <=  1'b0;                                
            MEM_mem_to_reg       <=  1'b0;                                 
    
            MEM_write_mem        <=  1'b0;                                
            MEM_mem_byte         <=  1'b0;                               
            MEM_mem_half         <=  1'b0;                               
            MEM_mem_word         <=  1'b0;                               
            MEM_mem_byte_u       <=  1'b0;                                 
            MEM_mem_half_u       <=  1'b0;                                 
    
            MEM_system_halt      <=  1'b0;                                  
            MEM_op_valid         <=  1'b0;                               
            MEM_ALU_valid        <=  1'b0;                                
        end
        else if(~FORWARD_stallME) begin
            MEM_commit           <=  EXU_commit_MEM;
            MEM_pc               <=  EXU_pc_MEM;
            MEM_inst             <=  EXU_inst_MEM;
            MEM_ALU_ALUout       <=  EXU_ALU_ALUout;
            MEM_ALU_CSR_out      <=  EXU_ALU_CSR_out;
            MEM_rd               <=  EXU_rd_MEM;
            MEM_rs2_data         <=  EXU_HAZARD_rs2_data;                       
            // mem
            MEM_csr_rd           <=  EXU_csr_rd_MEM;                             
            // mem
            MEM_write_gpr        <=  EXU_write_gpr_MEM;                                
            MEM_write_csr        <=  EXU_write_csr_MEM;                                
            MEM_mem_to_reg       <=  EXU_mem_to_reg_MEM;                                 
    
            MEM_write_mem        <=  EXU_write_mem_MEM;                                
            MEM_mem_byte         <=  EXU_mem_byte_MEM;                               
            MEM_mem_half         <=  EXU_mem_half_MEM;                               
            MEM_mem_word         <=  EXU_mem_word_MEM;                               
            MEM_mem_byte_u       <=  EXU_mem_byte_u_MEM;                                 
            MEM_mem_half_u       <=  EXU_mem_half_u_MEM;                                 
    
            MEM_system_halt      <=  EXU_system_halt_MEM;                                  
            MEM_op_valid         <=  EXU_op_valid_MEM;                               
            MEM_ALU_valid        <=  EXU_ALU_valid;   
        end
    end
    

endmodule


