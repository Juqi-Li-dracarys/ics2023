/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 21:16:06 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-28 13:12:48
 */

 `include "DEFINES_ysyx23060136.sv"

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
        // general data form IDU
        input              [  31:0]         IDU_o_pc                   ,
        input              [  31:0]         IDU_o_inst                 ,
        input                               IDU_o_commit               ,
        input              [   4:0]         IDU_o_rd                   ,
        input              [   4:0]         IDU_o_rs1                  ,
        input              [   4:0]         IDU_o_rs2                  ,
        input              [  31:0]         IDU_o_imm                  ,
        input              [  31:0]         IDU_o_rs1_data             ,
        input              [  31:0]         IDU_o_rs2_data             ,
        input              [   2:0]         IDU_o_csr_rd               ,
        input              [   2:0]         IDU_o_csr_rs               ,
        input              [  31:0]         IDU_o_csr_rs_data          ,
        // ===========================================================================
        // data from forward unit to deal with third stage hazard
        input              [  31:0]         FORWARD_rs1_data_SEG       ,
        input              [  31:0]         FORWARD_rs2_data_SEG       ,
        input              [  31:0]         FORWARD_csr_rs_data_SEG    ,

        input                               FORWARD_rs1_hazard_SEG     ,
        input                               FORWARD_rs2_hazard_SEG     ,
        input                               FORWARD_csr_rs_hazard_SEG  ,      
        // ===========================================================================
        output    logic    [31 : 0]         EXU_i_pc                   ,
        output    logic    [31 : 0]         EXU_i_inst                 ,
        output    logic                     EXU_i_commit               ,
        output    logic    [4 : 0]          EXU_i_rd                   ,
        output    logic    [4 : 0]          EXU_i_rs1                  ,
        output    logic    [4 : 0]          EXU_i_rs2                  ,
        output    logic    [31 : 0]         EXU_i_imm                  ,
        output    logic    [31 : 0]         EXU_i_rs1_data             ,
        output    logic    [31 : 0]         EXU_i_rs2_data             ,
        output    logic    [2 : 0]          EXU_i_csr_rd               ,
        output    logic    [2 : 0]          EXU_i_csr_rs               ,
        output    logic    [31 : 0]         EXU_i_csr_rs_data          ,
        // ===========================================================================
        // ALU signal(IDU_internal)
        input                               IDU_o_ALU_add              ,
        input                               IDU_o_ALU_sub              ,
        input                               IDU_o_ALU_slt              ,
        input                               IDU_o_ALU_sltu             ,
        input                               IDU_o_ALU_or               ,
        input                               IDU_o_ALU_and              ,
        input                               IDU_o_ALU_xor              ,
        input                               IDU_o_ALU_sll              ,
        input                               IDU_o_ALU_srl              ,
        input                               IDU_o_ALU_sra              ,
        input                               IDU_o_ALU_explicit         ,
        input                               IDU_o_ALU_i1_rs1           ,
        input                               IDU_o_ALU_i1_pc            ,
        input                               IDU_o_ALU_i2_rs2           ,
        input                               IDU_o_ALU_i2_imm           ,
        input                               IDU_o_ALU_i2_4             ,
        input                               IDU_o_ALU_i2_csr           ,

        output    logic                     EXU_i_ALU_add              ,
        output    logic                     EXU_i_ALU_sub              ,
        output    logic                     EXU_i_ALU_slt              ,
        output    logic                     EXU_i_ALU_sltu             ,
        output    logic                     EXU_i_ALU_or               ,
        output    logic                     EXU_i_ALU_and              ,
        output    logic                     EXU_i_ALU_xor              ,
        output    logic                     EXU_i_ALU_sll              ,
        output    logic                     EXU_i_ALU_srl              ,
        output    logic                     EXU_i_ALU_sra              ,
        output    logic                     EXU_i_ALU_explicit         ,
        output    logic                     EXU_i_ALU_i1_rs1           ,
        output    logic                     EXU_i_ALU_i1_pc            ,
        output    logic                     EXU_i_ALU_i2_rs2           ,
        output    logic                     EXU_i_ALU_i2_imm           ,
        output    logic                     EXU_i_ALU_i2_4             ,
        output    logic                     EXU_i_ALU_i2_csr           ,
        // ===========================================================================
        // jump signal for BRANCH
        input                               IDU_o_jump                 ,
        input                               IDU_o_pc_plus_imm          ,
        input                               IDU_o_rs1_plus_imm         ,
        input                               IDU_o_csr_plus_imm         ,
        input                               IDU_o_cmp_eq               ,
        input                               IDU_o_cmp_neq              ,
        input                               IDU_o_cmp_ge               ,
        input                               IDU_o_cmp_lt               ,

        output    logic                     EXU_i_jump                 ,
        output    logic                     EXU_i_pc_plus_imm          ,
        output    logic                     EXU_i_rs1_plus_imm         ,
        output    logic                     EXU_i_csr_plus_imm         ,
        output    logic                     EXU_i_cmp_eq               ,
        output    logic                     EXU_i_cmp_neq              ,
        output    logic                     EXU_i_cmp_ge               ,
        output    logic                     EXU_i_cmp_lt               ,
        // ===========================================================================
        // write back
        input                               IDU_o_write_gpr              ,
        input                               IDU_o_write_csr              ,
        input                               IDU_o_mem_to_reg             ,
        input                               IDU_o_rv32_csrrs             ,
        input                               IDU_o_rv32_csrrw             ,
        input                               IDU_o_rv32_ecall             ,

        output    logic                     EXU_i_write_gpr              ,
        output    logic                     EXU_i_write_csr              ,
        output    logic                     EXU_i_mem_to_reg             ,
        output    logic                     EXU_i_rv32_csrrs             ,
        output    logic                     EXU_i_rv32_csrrw             ,
        output    logic                     EXU_i_rv32_ecall             ,
        // ===========================================================================
        // mem
        input                               IDU_o_write_mem              ,
        input                               IDU_o_mem_byte               ,
        input                               IDU_o_mem_half               ,
        input                               IDU_o_mem_word               ,
        input                               IDU_o_mem_byte_u             ,
        input                               IDU_o_mem_half_u             ,

        output    logic                     EXU_i_write_mem              ,
        output    logic                     EXU_i_mem_byte               ,
        output    logic                     EXU_i_mem_half               ,
        output    logic                     EXU_i_mem_word               ,
        output    logic                     EXU_i_mem_byte_u             ,
        output    logic                     EXU_i_mem_half_u             ,
        // ===========================================================================
        // system
        input                               IDU_o_system_halt            ,
        output    logic                     EXU_i_system_halt            
         
    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (BRANCH_flushID & ~FORWARD_stallEX)) begin
            // Reset all EXU outputs
            EXU_i_pc           <=  `PC_RST;
            EXU_i_inst         <=  `NOP;
            // after reste or flush, commit is equal to 1
            EXU_i_commit       <=  1'b0;
            EXU_i_rd           <=  5'b0;
            EXU_i_rs1          <=  5'b0;
            EXU_i_rs2          <=  5'b0;
            EXU_i_imm          <=  32'b0;
            EXU_i_rs1_data     <=  32'b0;
            EXU_i_rs2_data     <=  32'b0;
            EXU_i_csr_rd       <=  3'b0;
            EXU_i_csr_rs       <=  3'b0;
            EXU_i_csr_rs_data  <=  32'b0;

            EXU_i_ALU_add      <=  1'b0;
            EXU_i_ALU_sub      <=  1'b0;
            EXU_i_ALU_slt      <=  1'b0;
            EXU_i_ALU_sltu     <=  1'b0;
            EXU_i_ALU_or       <=  1'b0;
            EXU_i_ALU_and      <=  1'b0;
            EXU_i_ALU_xor      <=  1'b0;
            EXU_i_ALU_sll      <=  1'b0;
            EXU_i_ALU_srl      <=  1'b0;
            EXU_i_ALU_sra      <=  1'b0;
            EXU_i_ALU_explicit <=  1'b0;
            EXU_i_ALU_i1_rs1   <=  1'b0;
            EXU_i_ALU_i1_pc    <=  1'b0;
            EXU_i_ALU_i2_rs2   <=  1'b0;
            EXU_i_ALU_i2_imm   <=  1'b0;
            EXU_i_ALU_i2_4     <=  1'b0;
            EXU_i_ALU_i2_csr   <=  1'b0;

            // Reset jump signals
            EXU_i_jump         <=  1'b0;
            EXU_i_pc_plus_imm  <=  1'b0;
            EXU_i_rs1_plus_imm <=  1'b0;
            EXU_i_csr_plus_imm <=  1'b0;
            EXU_i_cmp_eq       <=  1'b0;
            EXU_i_cmp_neq      <=  1'b0;
            EXU_i_cmp_ge       <=  1'b0;
            EXU_i_cmp_lt       <=  1'b0;

            // Reset write back signals
            EXU_i_write_gpr    <=  1'b0;
            EXU_i_write_csr    <=  1'b0;
            EXU_i_mem_to_reg   <=  1'b0;
            EXU_i_rv32_csrrs   <=  1'b0;
            EXU_i_rv32_csrrw   <=  1'b0;
            EXU_i_rv32_ecall   <=  1'b0;

            // Reset mem signals
            EXU_i_write_mem    <=  1'b0;
            EXU_i_mem_byte     <=  1'b0;
            EXU_i_mem_half     <=  1'b0;
            EXU_i_mem_word     <=  1'b0;
            EXU_i_mem_byte_u   <=  1'b0;
            EXU_i_mem_half_u   <=  1'b0;

            // Reset system signals
            EXU_i_system_halt  <=  1'b0;
        end
        else if(~FORWARD_stallEX) begin
            EXU_i_pc           <=  IDU_o_pc  ;
            EXU_i_inst         <=  IDU_o_inst  ;
            EXU_i_commit       <=  IDU_o_commit  ;
            EXU_i_rd           <=  IDU_o_rd;    
            EXU_i_rs1          <=  IDU_o_rs1;  
            EXU_i_rs2          <=  IDU_o_rs2;
            EXU_i_imm          <=  IDU_o_imm;
            // 判断数据来源
            EXU_i_rs1_data     <=  FORWARD_rs1_hazard_SEG ? FORWARD_rs1_data_SEG : IDU_o_rs1_data;  
            EXU_i_rs2_data     <=  FORWARD_rs2_hazard_SEG ? FORWARD_rs2_data_SEG : IDU_o_rs2_data;  
            EXU_i_csr_rd       <=  IDU_o_csr_rd;
            EXU_i_csr_rs       <=  IDU_o_csr_rs; 
            EXU_i_csr_rs_data  <=  FORWARD_csr_rs_hazard_SEG ? FORWARD_csr_rs_data_SEG : IDU_o_csr_rs_data;

            EXU_i_ALU_add      <=  IDU_o_ALU_add;  
            EXU_i_ALU_sub      <=  IDU_o_ALU_sub; 
            EXU_i_ALU_slt      <=  IDU_o_ALU_slt;
            EXU_i_ALU_sltu     <=  IDU_o_ALU_sltu;  
            EXU_i_ALU_or       <=  IDU_o_ALU_or;
            EXU_i_ALU_and      <=  IDU_o_ALU_and;  
            EXU_i_ALU_xor      <=  IDU_o_ALU_xor;  
            EXU_i_ALU_sll      <=  IDU_o_ALU_sll;  
            EXU_i_ALU_srl      <=  IDU_o_ALU_srl;  
            EXU_i_ALU_sra      <=  IDU_o_ALU_sra; 
            EXU_i_ALU_explicit <=  IDU_o_ALU_explicit;  
            EXU_i_ALU_i1_rs1   <=  IDU_o_ALU_i1_rs1;  
            EXU_i_ALU_i1_pc    <=  IDU_o_ALU_i1_pc;  
            EXU_i_ALU_i2_rs2   <=  IDU_o_ALU_i2_rs2;  
            EXU_i_ALU_i2_imm   <=  IDU_o_ALU_i2_imm;  
            EXU_i_ALU_i2_4     <=  IDU_o_ALU_i2_4;   
            EXU_i_ALU_i2_csr   <=  IDU_o_ALU_i2_csr;

            EXU_i_jump         <=  IDU_o_jump;  
            EXU_i_pc_plus_imm  <=  IDU_o_pc_plus_imm;  
            EXU_i_rs1_plus_imm <=  IDU_o_rs1_plus_imm;  
            EXU_i_csr_plus_imm <=  IDU_o_csr_plus_imm; 
            EXU_i_cmp_eq       <=  IDU_o_cmp_eq;
            EXU_i_cmp_neq      <=  IDU_o_cmp_neq;
            EXU_i_cmp_ge       <=  IDU_o_cmp_ge;
            EXU_i_cmp_lt       <=  IDU_o_cmp_lt;
            
            EXU_i_write_gpr    <=  IDU_o_write_gpr;
            EXU_i_write_csr    <=  IDU_o_write_csr;  
            EXU_i_mem_to_reg   <=  IDU_o_mem_to_reg;  
            EXU_i_rv32_csrrs   <=  IDU_o_rv32_csrrs;  
            EXU_i_rv32_csrrw   <=  IDU_o_rv32_csrrw;   
            EXU_i_rv32_ecall   <=  IDU_o_rv32_ecall;  
            EXU_i_write_mem    <=  IDU_o_write_mem;  
            EXU_i_mem_byte     <=  IDU_o_mem_byte;  
            EXU_i_mem_half     <=  IDU_o_mem_half;  
            EXU_i_mem_word     <=  IDU_o_mem_word;  
            EXU_i_mem_byte_u   <=  IDU_o_mem_byte_u;  
            EXU_i_mem_half_u   <=  IDU_o_mem_half_u;

            EXU_i_system_halt  <=  IDU_o_system_halt;
        end
        
    end

endmodule



