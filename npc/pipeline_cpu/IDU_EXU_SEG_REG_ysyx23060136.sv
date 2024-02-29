/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 21:16:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-28 13:12:48
 */

 `include "TOP_DEFINES_ysyx23060136.sv"

/*
      IDU -> IDU_EXU_REG -> EXU
*/

// ===========================================================================
module IDU_EXU_SEG_REG_ysyx23060136(
        input                               clk                        ,
        input                               rst                        ,
        // ===========================================================================
        // forward unit signal
        input                               BRANCH_flushID             ,
        input                               FORWARD_stallEX            ,
        // general data
        input              [  31:0]         IDU_pc_EXU                 ,
        input              [  31:0]         IDU_inst_EXU               ,
        input                               IDU_commit_EXU             ,
        input              [   4:0]         IDU_rd                     ,
        input              [   4:0]         IDU_rs1                    ,
        input              [   4:0]         IDU_rs2                    ,
        input              [  31:0]         IDU_imm                    ,
        input              [  31:0]         IDU_rs1_data               ,
        input              [  31:0]         IDU_rs2_data               ,
        input              [   1:0]         IDU_csr_rd                 ,
        input              [   1:0]         IDU_csr_rs                 ,
        input              [  31:0]         IDU_csr_rs_data            ,

        input              [  31:0]         FORWARD_rs1_data_SEG       ,
        input              [  31:0]         FORWARD_rs2_data_SEG       ,
        input              [  31:0]         FORWARD_csr_rs_data_SEG    ,

        input                               FORWARD_rs1_hazard_SEG     ,
        input                               FORWARD_rs2_hazard_SEG     ,
        input                               FORWARD_csr_rs_hazard_SEG  ,      

        // ===========================================================================
        output    logic    [31 : 0]         EXU_pc                     ,
        output    logic    [31 : 0]         EXU_inst                   ,
        output    logic                     EXU_commit                 ,
        output    logic    [4 : 0]          EXU_rd                     ,
        output    logic    [4 : 0]          EXU_rs1                    ,
        output    logic    [4 : 0]          EXU_rs2                    ,
        output    logic    [31 : 0]         EXU_imm                    ,
        output    logic    [31 : 0]         EXU_rs1_data               ,
        output    logic    [31 : 0]         EXU_rs2_data               ,
        output    logic    [1 : 0]          EXU_csr_rd                 ,
        output    logic    [1 : 0]          EXU_csr_rs                 ,
        output    logic    [31 : 0]         EXU_csr_rs_data            ,
        // ===========================================================================
        // ALU signal
        input                               IDU_ALU_add                ,
        input                               IDU_ALU_sub                ,
        input                               IDU_ALU_slt                ,
        input                               IDU_ALU_sltu               ,
        input                               IDU_ALU_or                 ,
        input                               IDU_ALU_and                ,
        input                               IDU_ALU_xor                ,
        input                               IDU_ALU_sll                ,
        input                               IDU_ALU_srl                ,
        input                               IDU_ALU_sra                ,
        input                               IDU_ALU_explicit           ,
        input                               IDU_ALU_i1_rs1             ,
        input                               IDU_ALU_i1_pc              ,
        input                               IDU_ALU_i2_rs2             ,
        input                               IDU_ALU_i2_imm             ,
        input                               IDU_ALU_i2_4               ,
        input                               IDU_ALU_i2_csr             ,

        output    logic                     EXU_ALU_add                ,
        output    logic                     EXU_ALU_sub                ,
        output    logic                     EXU_ALU_slt                ,
        output    logic                     EXU_ALU_sltu               ,
        output    logic                     EXU_ALU_or                 ,
        output    logic                     EXU_ALU_and                ,
        output    logic                     EXU_ALU_xor                ,
        output    logic                     EXU_ALU_sll                ,
        output    logic                     EXU_ALU_srl                ,
        output    logic                     EXU_ALU_sra                ,
        output    logic                     EXU_ALU_explicit           ,
        output    logic                     EXU_ALU_i1_rs1             ,
        output    logic                     EXU_ALU_i1_pc              ,
        output    logic                     EXU_ALU_i2_rs2             ,
        output    logic                     EXU_ALU_i2_imm             ,
        output    logic                     EXU_ALU_i2_4               ,
        output    logic                     EXU_ALU_i2_csr             ,
        // ===========================================================================
        // jump signal
        input                               IDU_jump                   ,
        input                               IDU_pc_plus_imm            ,
        input                               IDU_rs1_plus_imm           ,
        input                               IDU_csr_plus_imm           ,
        input                               IDU_cmp_eq                 ,
        input                               IDU_cmp_neq                ,
        input                               IDU_cmp_ge                 ,
        input                               IDU_cmp_lt                 ,

        output    logic                     EXU_jump,
        output    logic                     EXU_pc_plus_imm,
        output    logic                     EXU_rs1_plus_imm,
        output    logic                     EXU_csr_plus_imm,
        output    logic                     EXU_cmp_eq,
        output    logic                     EXU_cmp_neq,
        output    logic                     EXU_cmp_ge,
        output    logic                     EXU_cmp_lt,
        // ===========================================================================
        // write back
        input                               IDU_write_gpr              ,
        input                               IDU_write_csr              ,
        input                               IDU_mem_to_reg             ,
        input                               IDU_rv32_csrrs             ,
        input                               IDU_rv32_csrrw             ,
        input                               IDU_rv32_ecall             ,

        output    logic                     EXU_write_gpr,
        output    logic                     EXU_write_csr,
        output    logic                     EXU_mem_to_reg,
        output    logic                     EXU_rv32_csrrs,
        output    logic                     EXU_rv32_csrrw,
        output    logic                     EXU_rv32_ecall,
        // ===========================================================================
        // mem
        input                               IDU_write_mem              ,
        input                               IDU_mem_byte               ,
        input                               IDU_mem_half               ,
        input                               IDU_mem_word               ,
        input                               IDU_mem_byte_u             ,
        input                               IDU_mem_half_u             ,

        output    logic                     EXU_write_mem,
        output    logic                     EXU_mem_byte,
        output    logic                     EXU_mem_half,
        output    logic                     EXU_mem_word,
        output    logic                     EXU_mem_byte_u,
        output    logic                     EXU_mem_half_u,
        // ===========================================================================
        // system
        input                               IDU_system_halt            ,
        input                               IDU_op_valid               ,

        output    logic                     EXU_system_halt            ,
        output    logic                     EXU_op_valid 
         
    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (BRANCH_flushID & ~FORWARD_stallEX)) begin
            // Reset all EXU outputs
            EXU_pc           <=  `PC_RST;
            EXU_inst         <=  `NOP;
            EXU_commit       <=  1'b0;
            EXU_rd           <=  5'b0;
            EXU_rs1          <=  5'b0;
            EXU_rs2          <=  5'b0;
            EXU_imm          <=  32'b0;
            EXU_rs1_data     <=  32'b0;
            EXU_rs2_data     <=  32'b0;
            EXU_csr_rd       <=  2'b0;
            EXU_csr_rs       <=  2'b0;
            EXU_csr_rs_data  <=  32'b0;

            EXU_ALU_add      <=  1'b0;
            EXU_ALU_sub      <=  1'b0;
            EXU_ALU_slt      <=  1'b0;
            EXU_ALU_sltu     <=  1'b0;
            EXU_ALU_or       <=  1'b0;
            EXU_ALU_and      <=  1'b0;
            EXU_ALU_xor      <=  1'b0;
            EXU_ALU_sll      <=  1'b0;
            EXU_ALU_srl      <=  1'b0;
            EXU_ALU_sra      <=  1'b0;
            EXU_ALU_explicit <=  1'b0;
            EXU_ALU_i1_rs1   <=  1'b0;
            EXU_ALU_i1_pc    <=  1'b0;
            EXU_ALU_i2_rs2   <=  1'b0;
            EXU_ALU_i2_imm   <=  1'b0;
            EXU_ALU_i2_4     <=  1'b0;
            EXU_ALU_i2_csr   <=  1'b0;

            // Reset jump signals
            EXU_jump         <=  1'b0;
            EXU_pc_plus_imm  <=  1'b0;
            EXU_rs1_plus_imm <=  1'b0;
            EXU_csr_plus_imm <=  1'b0;
            EXU_cmp_eq       <=  1'b0;
            EXU_cmp_neq      <=  1'b0;
            EXU_cmp_ge       <=  1'b0;
            EXU_cmp_lt       <=  1'b0;

            // Reset write back signals
            EXU_write_gpr    <=  1'b0;
            EXU_write_csr    <=  1'b0;
            EXU_mem_to_reg   <=  1'b0;
            EXU_rv32_csrrs   <=  1'b0;
            EXU_rv32_csrrw   <=  1'b0;
            EXU_rv32_ecall   <=  1'b0;

            // Reset mem signals
            EXU_write_mem    <=  1'b0;
            EXU_mem_byte     <=  1'b0;
            EXU_mem_half     <=  1'b0;
            EXU_mem_word     <=  1'b0;
            EXU_mem_byte_u   <=  1'b0;
            EXU_mem_half_u   <=  1'b0;

            // Reset system signals
            EXU_system_halt  <=  1'b0;
            EXU_op_valid     <=  1'b1;
        end
        else if(~FORWARD_stallEX) begin
            EXU_pc           <=  IDU_pc_EXU;
            EXU_inst         <=  IDU_inst_EXU;
            EXU_commit       <=  IDU_commit_EXU;
            EXU_rd           <=  IDU_rd;    
            EXU_rs1          <=  IDU_rs1;  
            EXU_rs2          <=  IDU_rs2;
            EXU_imm          <=  IDU_imm;
            EXU_rs1_data     <=  FORWARD_rs1_hazard_SEG ? FORWARD_rs1_data_SEG : IDU_rs1_data;  
            EXU_rs2_data     <=  FORWARD_rs2_hazard_SEG ? FORWARD_rs2_data_SEG : IDU_rs2_data;  
            EXU_csr_rd       <=  IDU_csr_rd;
            EXU_csr_rs       <=  IDU_csr_rs; 
            EXU_csr_rs_data  <=  FORWARD_csr_rs_hazard_SEG ? FORWARD_csr_rs_data_SEG : IDU_csr_rs_data;

            EXU_ALU_add      <=  IDU_ALU_add;  
            EXU_ALU_sub      <=  IDU_ALU_sub; 
            EXU_ALU_slt      <=  IDU_ALU_slt;
            EXU_ALU_sltu     <=  IDU_ALU_sltu;  
            EXU_ALU_or       <=  IDU_ALU_or;
            EXU_ALU_and      <=  IDU_ALU_and;  
            EXU_ALU_xor      <=  IDU_ALU_xor;  
            EXU_ALU_sll      <=  IDU_ALU_sll;  
            EXU_ALU_srl      <=  IDU_ALU_srl;  
            EXU_ALU_sra      <=  IDU_ALU_sra; 
            EXU_ALU_explicit <=  IDU_ALU_explicit;  
            EXU_ALU_i1_rs1   <=  IDU_ALU_i1_rs1;  
            EXU_ALU_i1_pc    <=  IDU_ALU_i1_pc;  
            EXU_ALU_i2_rs2   <=  IDU_ALU_i2_rs2;  
            EXU_ALU_i2_imm   <=  IDU_ALU_i2_imm;  
            EXU_ALU_i2_4     <=  IDU_ALU_i2_4;   
            EXU_ALU_i2_csr   <=  IDU_ALU_i2_csr;

            EXU_jump         <=  IDU_jump;  
            EXU_pc_plus_imm  <=  IDU_pc_plus_imm;  
            EXU_rs1_plus_imm <=  IDU_rs1_plus_imm;  
            EXU_csr_plus_imm <=  IDU_csr_plus_imm; 
            EXU_cmp_eq       <=  IDU_cmp_eq;
            EXU_cmp_neq      <=  IDU_cmp_neq;
            EXU_cmp_ge       <=  IDU_cmp_ge;
            EXU_cmp_lt       <=  IDU_cmp_lt;
            
            EXU_write_gpr    <=  IDU_write_gpr;
            EXU_write_csr    <=  IDU_write_csr;  
            EXU_mem_to_reg   <=  IDU_mem_to_reg;  
            EXU_rv32_csrrs   <=  IDU_rv32_csrrs;  
            EXU_rv32_csrrw   <=  IDU_rv32_csrrw;   
            EXU_rv32_ecall   <=  IDU_rv32_ecall;  
            EXU_write_mem    <=  IDU_write_mem;  
            EXU_mem_byte     <=  IDU_mem_byte;  
            EXU_mem_half     <=  IDU_mem_half;  
            EXU_mem_word     <=  IDU_mem_word;  
            EXU_mem_byte_u   <=  IDU_mem_byte_u;  
            EXU_mem_half_u   <=  IDU_mem_half_u;

            EXU_system_halt  <=  IDU_system_halt;
            EXU_op_valid     <=  IDU_op_valid;
        end
        
    end

endmodule



