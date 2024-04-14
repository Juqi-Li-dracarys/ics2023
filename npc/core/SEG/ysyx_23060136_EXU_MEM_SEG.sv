/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-09 20:46:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-09 21:44:29
 */


 `include "ysyx_23060136_DEFINES.sv"

 
/*
      EXU -> EXU_REG -> MEM
*/

// ===========================================================================
module  ysyx_23060136_EXU_MEM_SEG (
        input                                                   clk                       ,
        input                                                   rst                       ,
        // ===========================================================================
        // forward unit signal
        input                                                   FORWARD_flushEX           ,
        input                                                   FORWARD_stallME           ,
        // ===========================================================================
        // general data
        input                                                    EXU_o_commit             ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_o_pc                 ,
        input              [  `ysyx_23060136_INST_W-1:0]         EXU_o_inst               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_o_ALU_ALUout         ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_o_ALU_CSR_out        ,

        // mem
        input              [   `ysyx_23060136_GPR_W-1:0]         EXU_o_rd                 ,
    
        // mem
        input              [   `ysyx_23060136_CSR_W-1:0]         EXU_o_csr_rd_1           ,
        input              [   `ysyx_23060136_CSR_W-1:0]         EXU_o_csr_rd_2           ,
        // mem
        input                                                    EXU_o_write_gpr          ,
        input                                                    EXU_o_write_csr_1        ,
        input                                                    EXU_o_write_csr_2        ,
        input                                                    EXU_o_mem_to_reg         ,
        
        input                                                    EXU_o_system_halt        ,

        // ===========================================================================
        output   logic                                           MEM_i_commit                 ,
        output   logic    [`ysyx_23060136_BITS_W-1 : 0]          MEM_i_pc                     ,
        output   logic    [`ysyx_23060136_INST_W-1 : 0]          MEM_i_inst                   ,
        output   logic    [`ysyx_23060136_BITS_W-1 : 0]          MEM_i_ALU_ALUout             ,
        output   logic    [`ysyx_23060136_BITS_W-1 : 0]          MEM_i_ALU_CSR_out            ,

        output   logic    [`ysyx_23060136_GPR_W-1 : 0]           MEM_i_rd                     ,
        output   logic    [`ysyx_23060136_CSR_W-1 : 0]           MEM_i_csr_rd_1               ,
        output   logic    [`ysyx_23060136_CSR_W-1 : 0]           MEM_i_csr_rd_2               ,
        // mem
        output   logic                                           MEM_i_write_gpr              ,
        output   logic                                           MEM_i_write_csr_1            ,
        output   logic                                           MEM_i_write_csr_2            ,
        output   logic                                           MEM_i_mem_to_reg             ,
        // system
        output   logic                                           MEM_i_system_halt                       
    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (FORWARD_flushEX & ~FORWARD_stallME)) begin
            MEM_i_commit           <=   `ysyx_23060136_false;
            MEM_i_pc               <=  `ysyx_23060136_PC_RST;
            MEM_i_inst             <=  `ysyx_23060136_NOP;
            MEM_i_ALU_ALUout       <=  `ysyx_23060136_false;
            MEM_i_ALU_CSR_out      <=  `ysyx_23060136_false;
            MEM_i_rd               <=  `ysyx_23060136_false;            
            // mem
            MEM_i_csr_rd_1         <=  `ysyx_23060136_false;
            MEM_i_csr_rd_2         <=  `ysyx_23060136_false;                            
            // mem
            MEM_i_write_gpr        <=  `ysyx_23060136_false;                              
            MEM_i_write_csr_1      <=  `ysyx_23060136_false;
            MEM_i_write_csr_2      <=  `ysyx_23060136_false;                               
            MEM_i_mem_to_reg       <=  `ysyx_23060136_false;                               
                                
            MEM_i_system_halt      <=  `ysyx_23060136_false;                                                            
        end
        else if(~FORWARD_stallME) begin
            MEM_i_commit           <=  EXU_o_commit;
            MEM_i_pc               <=  EXU_o_pc;
            MEM_i_inst             <=  EXU_o_inst;
            MEM_i_ALU_ALUout       <=  EXU_o_ALU_ALUout;
            MEM_i_ALU_CSR_out      <=  EXU_o_ALU_CSR_out;
            MEM_i_rd               <=  EXU_o_rd;                     
            // mem
            MEM_i_csr_rd_1         <=  EXU_o_csr_rd_1;
            MEM_i_csr_rd_2         <=  EXU_o_csr_rd_2;                            
            // mem
            MEM_i_write_gpr        <=  EXU_o_write_gpr;                                
            MEM_i_write_csr_1      <=  EXU_o_write_csr_1;
            MEM_i_write_csr_2      <=  EXU_o_write_csr_2;                                  
            MEM_i_mem_to_reg       <=  EXU_o_mem_to_reg;                                 
                                    
            MEM_i_system_halt      <=  EXU_o_system_halt;                                    
        end
    end

endmodule


