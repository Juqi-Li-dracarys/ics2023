/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 21:52:40 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-11 11:09:21
 */


 `include "ysyx_23060136_DEFINES.sv"

/*
      IDU -> IDU_EXU_REG -> EXU
*/

// ===========================================================================
module ysyx_23060136_IDU_EXU_SEG (
        input                                                    clk                        ,
        input                                                    rst                        ,
        // ===========================================================================
        // forward unit signal
        input                                                    BRANCH_flushID             ,
        input                                                    FORWARD_stallEX            ,
        // general data form IDU
        input              [  `ysyx_23060136_BITS_W-1:0]         IDU_o_pc                   ,
        input              [  `ysyx_23060136_INST_W-1:0]         IDU_o_inst                 ,
        input                                                    IDU_o_commit               ,
        input                                                    IDU_o_pre_take             ,
        input              [   `ysyx_23060136_GPR_W-1:0]         IDU_o_rd                   ,
        input              [   `ysyx_23060136_GPR_W-1:0]         IDU_o_rs1                  ,
        input              [   `ysyx_23060136_GPR_W-1:0]         IDU_o_rs2                  ,
        input              [  `ysyx_23060136_BITS_W-1:0]         IDU_o_imm                  ,
        input              [  `ysyx_23060136_BITS_W-1:0]         IDU_o_rs1_data             ,
        input              [  `ysyx_23060136_BITS_W-1:0]         IDU_o_rs2_data             ,
        input              [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rd_1             ,
        input              [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rd_2             ,
        input              [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rs               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         IDU_o_csr_rs_data          ,
        // ===========================================================================
        // data from forward unit to deal with third stage hazard
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_SEG       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_SEG       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_SEG    ,

        input                                                    FORWARD_rs1_hazard_SEG     ,
        input                                                    FORWARD_rs2_hazard_SEG     ,
        input                                                    FORWARD_csr_rs_hazard_SEG  ,
        
        input                                                    FORWARD_rs1_hazard_SEG_f     ,
        input                                                    FORWARD_rs2_hazard_SEG_f     ,
        input                                                    FORWARD_csr_rs_hazard_SEG_f  , 
        // ===========================================================================
        output    logic    [`ysyx_23060136_BITS_W-1 : 0]         EXU_i_pc                   ,
        output    logic    [`ysyx_23060136_INST_W-1 : 0]         EXU_i_inst                 ,
        output    logic                                          EXU_i_commit               ,
        output    logic                                          EXU_i_pre_take             ,
        output    logic    [`ysyx_23060136_GPR_W-1 : 0]          EXU_i_rd                   ,
        output    logic    [`ysyx_23060136_GPR_W-1 : 0]          EXU_i_rs1                  ,
        output    logic    [`ysyx_23060136_GPR_W-1 : 0]          EXU_i_rs2                  ,
        output    logic    [`ysyx_23060136_BITS_W-1 : 0]         EXU_i_imm                  ,
        output    logic    [`ysyx_23060136_BITS_W-1 : 0]         EXU_i_rs1_data             ,
        output    logic    [`ysyx_23060136_BITS_W-1 : 0]         EXU_i_rs2_data             ,
        output    logic    [`ysyx_23060136_CSR_W-1 : 0]          EXU_i_csr_rd_1             ,
        output    logic    [`ysyx_23060136_CSR_W-1 : 0]          EXU_i_csr_rd_2             ,
        output    logic    [`ysyx_23060136_CSR_W-1 : 0]          EXU_i_csr_rs               ,
        output    logic    [`ysyx_23060136_BITS_W-1 : 0]         EXU_i_csr_rs_data          ,
        // ===========================================================================
        // ALU signal(IDU_internal)
        input                                                    IDU_o_ALU_word_t           ,
        input                                                    IDU_o_ALU_add              ,
        input                                                    IDU_o_ALU_sub              ,
        // 带符号小于
        input                                                    IDU_o_ALU_slt              ,
        // 无符号小于
        input                                                    IDU_o_ALU_sltu             ,
        // 与或异或运算
        input                                                    IDU_o_ALU_or               ,
        input                                                    IDU_o_ALU_and              ,
        input                                                    IDU_o_ALU_xor              ,
        // 移位运算
        input                                                    IDU_o_ALU_sll              ,
        input                                                    IDU_o_ALU_srl              ,
        input                                                    IDU_o_ALU_sra              ,
    
        input                                                    IDU_o_ALU_mul              ,
        input                                                    IDU_o_ALU_mul_hi           ,
        input                                                    IDU_o_ALU_mul_u            ,
        input                                                    IDU_o_ALU_mul_s            ,
        input                                                    IDU_o_ALU_mul_su           ,
    
        input                                                    IDU_o_ALU_div              ,
        input                                                    IDU_o_ALU_div_u            ,
        input                                                    IDU_o_ALU_div_s            ,
        input                                                    IDU_o_ALU_rem              ,
        input                                                    IDU_o_ALU_rem_u            ,
        input                                                    IDU_o_ALU_rem_s            ,
        // 直接输出
        input                                                    IDU_o_ALU_explicit         ,

        input                                                    IDU_o_ALU_i1_rs1           ,
        input                                                    IDU_o_ALU_i1_pc            ,
        input                                                    IDU_o_ALU_i2_rs2           ,
        input                                                    IDU_o_ALU_i2_imm           ,
        input                                                    IDU_o_ALU_i2_4             ,
        input                                                    IDU_o_ALU_i2_csr           ,

        // ALU signal(IDU_internal)
        output   logic                                           EXU_i_ALU_word_t           ,
        output   logic                                           EXU_i_ALU_add              ,
        output   logic                                           EXU_i_ALU_sub              ,
        // 带符号小于
        output   logic                                           EXU_i_ALU_slt              ,
        // 无符号小于
        output   logic                                           EXU_i_ALU_sltu             ,
        // 与或异或运算
        output   logic                                           EXU_i_ALU_or               ,
        output   logic                                           EXU_i_ALU_and              ,
        output   logic                                           EXU_i_ALU_xor              ,
        // 移位运算
        output   logic                                           EXU_i_ALU_sll              ,
        output   logic                                           EXU_i_ALU_srl              ,
        output   logic                                           EXU_i_ALU_sra              ,
    
        output   logic                                           EXU_i_ALU_mul              ,
        output   logic                                           EXU_i_ALU_mul_hi           ,
        output   logic                                           EXU_i_ALU_mul_u            ,
        output   logic                                           EXU_i_ALU_mul_s            ,
        output   logic                                           EXU_i_ALU_mul_su           ,
    
        output   logic                                           EXU_i_ALU_div              ,
        output   logic                                           EXU_i_ALU_div_u            ,
        output   logic                                           EXU_i_ALU_div_s            ,
        output   logic                                           EXU_i_ALU_rem              ,
        output   logic                                           EXU_i_ALU_rem_u            ,
        output   logic                                           EXU_i_ALU_rem_s            ,
        // 直接输出
        output   logic                                           EXU_i_ALU_explicit         ,

        output   logic                                           EXU_i_ALU_i1_rs1           ,
        output   logic                                           EXU_i_ALU_i1_pc            ,
        output   logic                                           EXU_i_ALU_i2_rs2           ,
        output   logic                                           EXU_i_ALU_i2_imm           ,
        output   logic                                           EXU_i_ALU_i2_4             ,
        output   logic                                           EXU_i_ALU_i2_csr           ,
        // ===========================================================================
        // jump signal for BRANCH
        input                                                    IDU_o_jump                 ,
        input                                                    IDU_o_Btype                ,
        input                                                    IDU_o_pc_plus_imm          ,
        input                                                    IDU_o_rs1_plus_imm         ,
        input                                                    IDU_o_csr_plus_imm         ,
        input                                                    IDU_o_cmp_eq               ,
        input                                                    IDU_o_cmp_neq              ,
        input                                                    IDU_o_cmp_ge               ,
        input                                                    IDU_o_cmp_lt               ,

        output    logic                                          EXU_i_jump                 ,
        output    logic                                          EXU_i_Btype                ,
        output    logic                                          EXU_i_pc_plus_imm          ,
        output    logic                                          EXU_i_rs1_plus_imm         ,
        output    logic                                          EXU_i_csr_plus_imm         ,
        output    logic                                          EXU_i_cmp_eq               ,
        output    logic                                          EXU_i_cmp_neq              ,
        output    logic                                          EXU_i_cmp_ge               ,
        output    logic                                          EXU_i_cmp_lt               ,
        // ===========================================================================
        // write back
        input                                                    IDU_o_write_gpr              ,
        input                                                    IDU_o_write_csr_1            ,
        input                                                    IDU_o_write_csr_2            ,
        input                                                    IDU_o_mem_to_reg             ,
        input                                                    IDU_o_rv64_csrrs             ,
        input                                                    IDU_o_rv64_csrrw             ,
        input                                                    IDU_o_rv64_ecall             ,

        output    logic                                          EXU_i_write_gpr              ,
        output    logic                                          EXU_i_write_csr_1            ,
        output    logic                                          EXU_i_write_csr_2            ,
        output    logic                                          EXU_i_mem_to_reg             ,
        output    logic                                          EXU_i_rv64_csrrs             ,
        output    logic                                          EXU_i_rv64_csrrw             ,
        output    logic                                          EXU_i_rv64_ecall             ,
        // ===========================================================================
        // mem
        input                                                    IDU_o_write_mem              ,
        input                                                    IDU_o_mem_byte               ,
        input                                                    IDU_o_mem_half               ,
        input                                                    IDU_o_mem_word               ,
        input                                                    IDU_o_mem_dword              ,
        input                                                    IDU_o_mem_byte_u             ,
        input                                                    IDU_o_mem_half_u             ,
        input                                                    IDU_o_mem_word_u             ,

        output   logic                                           EXU_i_write_mem              ,
        output   logic                                           EXU_i_mem_byte               ,
        output   logic                                           EXU_i_mem_half               ,
        output   logic                                           EXU_i_mem_word               ,
        output   logic                                           EXU_i_mem_dword              ,
        output   logic                                           EXU_i_mem_byte_u             ,
        output   logic                                           EXU_i_mem_half_u             ,
        output   logic                                           EXU_i_mem_word_u             ,
        // ===========================================================================
        // system
        input                                                    IDU_o_system_halt            ,
        output   logic                                           EXU_i_system_halt            
         
    );

    always_ff @(posedge clk) begin : update_data
        if(rst || (BRANCH_flushID & ~FORWARD_stallEX)) begin
            // Reset all EXU outputs
            EXU_i_pc           <=  `ysyx_23060136_PC_RST;
            EXU_i_inst         <=  `ysyx_23060136_NOP;
            EXU_i_pre_take     <=  `ysyx_23060136_false;
            EXU_i_commit       <=  `ysyx_23060136_false;
            EXU_i_rd           <=  `ysyx_23060136_false;
            EXU_i_rs1          <=  `ysyx_23060136_false;
            EXU_i_rs2          <=  `ysyx_23060136_false;
            EXU_i_imm          <=  `ysyx_23060136_false;
            EXU_i_rs1_data     <=  `ysyx_23060136_false;
            EXU_i_rs2_data     <=  `ysyx_23060136_false;
            EXU_i_csr_rd_1     <=  `ysyx_23060136_false;
            EXU_i_csr_rd_2     <=  `ysyx_23060136_false;
            EXU_i_csr_rs       <=  `ysyx_23060136_false;
            EXU_i_csr_rs_data  <=  `ysyx_23060136_false;

            EXU_i_ALU_add      <=  `ysyx_23060136_false;
            EXU_i_ALU_sub      <=  `ysyx_23060136_false;
            EXU_i_ALU_slt      <=  `ysyx_23060136_false;
            EXU_i_ALU_sltu     <=  `ysyx_23060136_false;
            EXU_i_ALU_or       <=  `ysyx_23060136_false;
            EXU_i_ALU_and      <=  `ysyx_23060136_false;
            EXU_i_ALU_xor      <=  `ysyx_23060136_false;
            EXU_i_ALU_sll      <=  `ysyx_23060136_false;
            EXU_i_ALU_srl      <=  `ysyx_23060136_false;
            EXU_i_ALU_sra      <=  `ysyx_23060136_false;

            EXU_i_ALU_mul      <=  `ysyx_23060136_false;   
            EXU_i_ALU_mul_hi   <=  `ysyx_23060136_false;   
            EXU_i_ALU_mul_u    <=  `ysyx_23060136_false;   
            EXU_i_ALU_mul_s    <=  `ysyx_23060136_false;   
            EXU_i_ALU_mul_su   <=  `ysyx_23060136_false;   
            EXU_i_ALU_div      <=  `ysyx_23060136_false;   
            EXU_i_ALU_div_u    <=  `ysyx_23060136_false;   
            EXU_i_ALU_div_s    <=  `ysyx_23060136_false;   
            EXU_i_ALU_rem      <=  `ysyx_23060136_false;   
            EXU_i_ALU_rem_u    <=  `ysyx_23060136_false;   
            EXU_i_ALU_rem_s    <=  `ysyx_23060136_false;   

            EXU_i_ALU_word_t   <=  `ysyx_23060136_false;
            EXU_i_ALU_explicit <=  `ysyx_23060136_false;
            EXU_i_ALU_i1_rs1   <=  `ysyx_23060136_false;
            EXU_i_ALU_i1_pc    <=  `ysyx_23060136_false;
            EXU_i_ALU_i2_rs2   <=  `ysyx_23060136_false;
            EXU_i_ALU_i2_imm   <=  `ysyx_23060136_false;
            EXU_i_ALU_i2_4     <=  `ysyx_23060136_false;
            EXU_i_ALU_i2_csr   <=  `ysyx_23060136_false;

            // Reset jump signals
            EXU_i_jump         <=  `ysyx_23060136_false;
            EXU_i_Btype        <=  `ysyx_23060136_false;
            EXU_i_pc_plus_imm  <=  `ysyx_23060136_false;
            EXU_i_rs1_plus_imm <=  `ysyx_23060136_false;
            EXU_i_csr_plus_imm <=  `ysyx_23060136_false;
            EXU_i_cmp_eq       <=  `ysyx_23060136_false;
            EXU_i_cmp_neq      <=  `ysyx_23060136_false;
            EXU_i_cmp_ge       <=  `ysyx_23060136_false;
            EXU_i_cmp_lt       <=  `ysyx_23060136_false;

            // Reset write back signals
            EXU_i_write_gpr    <=  `ysyx_23060136_false;
            EXU_i_write_csr_1  <=  `ysyx_23060136_false;
            EXU_i_write_csr_2  <=  `ysyx_23060136_false;
            EXU_i_mem_to_reg   <=  `ysyx_23060136_false;
            EXU_i_rv64_csrrs   <=  `ysyx_23060136_false;
            EXU_i_rv64_csrrw   <=  `ysyx_23060136_false;
            EXU_i_rv64_ecall   <=  `ysyx_23060136_false;

            // Reset mem signals
            EXU_i_write_mem    <=  `ysyx_23060136_false;
            EXU_i_mem_byte     <=  `ysyx_23060136_false;
            EXU_i_mem_half     <=  `ysyx_23060136_false;
            EXU_i_mem_word     <=  `ysyx_23060136_false;
            EXU_i_mem_byte_u   <=  `ysyx_23060136_false;
            EXU_i_mem_half_u   <=  `ysyx_23060136_false;
            EXU_i_mem_dword    <=  `ysyx_23060136_false;
            EXU_i_mem_word_u   <=  `ysyx_23060136_false;
            // Reset system signals
            EXU_i_system_halt  <=  `ysyx_23060136_false;
        end
        else begin
            EXU_i_pc           <=  FORWARD_stallEX  ?  EXU_i_pc      :  IDU_o_pc ;
            EXU_i_inst         <=  FORWARD_stallEX  ?  EXU_i_inst    :  IDU_o_inst ;
            EXU_i_commit       <=  FORWARD_stallEX  ?  EXU_i_commit  :  IDU_o_commit ;
            EXU_i_pre_take     <=  FORWARD_stallEX  ?  EXU_i_pre_take :  IDU_o_pre_take ;
            EXU_i_rd           <=  FORWARD_stallEX  ?  EXU_i_rd      :  IDU_o_rd;    
            EXU_i_rs1          <=  FORWARD_stallEX  ?  EXU_i_rs1     :  IDU_o_rs1;  
            EXU_i_rs2          <=  FORWARD_stallEX  ?  EXU_i_rs2     :  IDU_o_rs2;
            EXU_i_imm          <=  FORWARD_stallEX  ?  EXU_i_imm     :  IDU_o_imm;
            EXU_i_csr_rd_1     <=  FORWARD_stallEX  ? EXU_i_csr_rd_1  :  IDU_o_csr_rd_1;
            EXU_i_csr_rd_2     <=  FORWARD_stallEX  ? EXU_i_csr_rd_2  :  IDU_o_csr_rd_2;
            EXU_i_csr_rs       <=  FORWARD_stallEX  ? EXU_i_csr_rs    :  IDU_o_csr_rs; 

            EXU_i_ALU_add      <=  FORWARD_stallEX  ?   EXU_i_ALU_add       :   IDU_o_ALU_add     ;                                         
            EXU_i_ALU_sub      <=  FORWARD_stallEX  ?   EXU_i_ALU_sub       :   IDU_o_ALU_sub     ;                                        
            EXU_i_ALU_slt      <=  FORWARD_stallEX  ?   EXU_i_ALU_slt       :   IDU_o_ALU_slt     ;                                       
            EXU_i_ALU_sltu     <=  FORWARD_stallEX  ?   EXU_i_ALU_sltu      :   IDU_o_ALU_sltu    ;                                         
            EXU_i_ALU_or       <=  FORWARD_stallEX  ?   EXU_i_ALU_or        :   IDU_o_ALU_or      ;                                   
            EXU_i_ALU_and      <=  FORWARD_stallEX  ?   EXU_i_ALU_and       :   IDU_o_ALU_and     ;                                         
            EXU_i_ALU_xor      <=  FORWARD_stallEX  ?   EXU_i_ALU_xor       :   IDU_o_ALU_xor     ;                                         
            EXU_i_ALU_sll      <=  FORWARD_stallEX  ?   EXU_i_ALU_sll       :   IDU_o_ALU_sll     ;                                         
            EXU_i_ALU_srl      <=  FORWARD_stallEX  ?   EXU_i_ALU_srl       :   IDU_o_ALU_srl     ;                                         
            EXU_i_ALU_sra      <=  FORWARD_stallEX  ?   EXU_i_ALU_sra       :   IDU_o_ALU_sra     ;                                       
            EXU_i_ALU_mul      <=  FORWARD_stallEX  ?   EXU_i_ALU_mul       :   IDU_o_ALU_mul     ;                                           
            EXU_i_ALU_mul_hi   <=  FORWARD_stallEX  ?   EXU_i_ALU_mul_hi    :   IDU_o_ALU_mul_hi  ;                                                                                     
            EXU_i_ALU_mul_u    <=  FORWARD_stallEX  ?   EXU_i_ALU_mul_u     :   IDU_o_ALU_mul_u   ;                                           
            EXU_i_ALU_mul_s    <=  FORWARD_stallEX  ?   EXU_i_ALU_mul_s     :   IDU_o_ALU_mul_s   ;                                           
            EXU_i_ALU_mul_su   <=  FORWARD_stallEX  ?   EXU_i_ALU_mul_su    :   IDU_o_ALU_mul_su  ;                                           
            EXU_i_ALU_div      <=  FORWARD_stallEX  ?   EXU_i_ALU_div       :   IDU_o_ALU_div     ;                                           
            EXU_i_ALU_div_u    <=  FORWARD_stallEX  ?   EXU_i_ALU_div_u     :   IDU_o_ALU_div_u   ;                                           
            EXU_i_ALU_div_s    <=  FORWARD_stallEX  ?   EXU_i_ALU_div_s     :   IDU_o_ALU_div_s   ;                                           
            EXU_i_ALU_rem      <=  FORWARD_stallEX  ?   EXU_i_ALU_rem       :   IDU_o_ALU_rem     ;                                           
            EXU_i_ALU_rem_u    <=  FORWARD_stallEX  ?   EXU_i_ALU_rem_u     :   IDU_o_ALU_rem_u   ;                                           
            EXU_i_ALU_rem_s    <=  FORWARD_stallEX  ?   EXU_i_ALU_rem_s     :   IDU_o_ALU_rem_s   ;                                           
            EXU_i_ALU_explicit <=  FORWARD_stallEX  ?   EXU_i_ALU_explicit  :   IDU_o_ALU_explicit;                                           
            EXU_i_ALU_word_t   <=  FORWARD_stallEX  ?   EXU_i_ALU_word_t    :   IDU_o_ALU_word_t  ;                                        
            EXU_i_ALU_i1_rs1   <=  FORWARD_stallEX  ?   EXU_i_ALU_i1_rs1    :   IDU_o_ALU_i1_rs1  ;                                         
            EXU_i_ALU_i1_pc    <=  FORWARD_stallEX  ?   EXU_i_ALU_i1_pc     :   IDU_o_ALU_i1_pc   ;                                         
            EXU_i_ALU_i2_rs2   <=  FORWARD_stallEX  ?   EXU_i_ALU_i2_rs2    :   IDU_o_ALU_i2_rs2  ;                                         
            EXU_i_ALU_i2_imm   <=  FORWARD_stallEX  ?   EXU_i_ALU_i2_imm    :   IDU_o_ALU_i2_imm  ;                                         
            EXU_i_ALU_i2_4     <=  FORWARD_stallEX  ?   EXU_i_ALU_i2_4      :   IDU_o_ALU_i2_4    ;                                          
            EXU_i_ALU_i2_csr   <=  FORWARD_stallEX  ?   EXU_i_ALU_i2_csr    :   IDU_o_ALU_i2_csr  ;     
                                              
            EXU_i_jump         <=  FORWARD_stallEX  ?   EXU_i_jump          :   IDU_o_jump        ;    
            EXU_i_Btype        <=  FORWARD_stallEX  ?   EXU_i_Btype          :  IDU_o_Btype       ;                                   
            EXU_i_pc_plus_imm  <=  FORWARD_stallEX  ?   EXU_i_pc_plus_imm   :   IDU_o_pc_plus_imm ;                                             
            EXU_i_rs1_plus_imm <=  FORWARD_stallEX  ?   EXU_i_rs1_plus_imm  :   IDU_o_rs1_plus_imm;                                             
            EXU_i_csr_plus_imm <=  FORWARD_stallEX  ?   EXU_i_csr_plus_imm  :   IDU_o_csr_plus_imm;                                            
            EXU_i_cmp_eq       <=  FORWARD_stallEX  ?   EXU_i_cmp_eq        :   IDU_o_cmp_eq      ;                                   
            EXU_i_cmp_neq      <=  FORWARD_stallEX  ?   EXU_i_cmp_neq       :   IDU_o_cmp_neq     ;                                       
            EXU_i_cmp_ge       <=  FORWARD_stallEX  ?   EXU_i_cmp_ge        :   IDU_o_cmp_ge      ;                                   
            EXU_i_cmp_lt       <=  FORWARD_stallEX  ?   EXU_i_cmp_lt        :   IDU_o_cmp_lt      ;                                   
            EXU_i_write_gpr    <=  FORWARD_stallEX  ?   EXU_i_write_gpr     :   IDU_o_write_gpr   ;                                       
            EXU_i_write_csr_1  <=  FORWARD_stallEX  ?   EXU_i_write_csr_1   :   IDU_o_write_csr_1 ;                                           
            EXU_i_write_csr_2  <=  FORWARD_stallEX  ?   EXU_i_write_csr_2   :   IDU_o_write_csr_2 ;                                             
            EXU_i_mem_to_reg   <=  FORWARD_stallEX  ?   EXU_i_mem_to_reg    :   IDU_o_mem_to_reg  ;                                         
            EXU_i_rv64_csrrs   <=  FORWARD_stallEX  ?   EXU_i_rv64_csrrs    :   IDU_o_rv64_csrrs  ;                                         
            EXU_i_rv64_csrrw   <=  FORWARD_stallEX  ?   EXU_i_rv64_csrrw    :   IDU_o_rv64_csrrw  ;                                          
            EXU_i_rv64_ecall   <=  FORWARD_stallEX  ?   EXU_i_rv64_ecall    :   IDU_o_rv64_ecall  ;                                         
            EXU_i_write_mem    <=  FORWARD_stallEX  ?   EXU_i_write_mem     :   IDU_o_write_mem   ;                                         
            EXU_i_mem_byte     <=  FORWARD_stallEX  ?   EXU_i_mem_byte      :   IDU_o_mem_byte    ;                                         
            EXU_i_mem_half     <=  FORWARD_stallEX  ?   EXU_i_mem_half      :   IDU_o_mem_half    ;                                         
            EXU_i_mem_word     <=  FORWARD_stallEX  ?   EXU_i_mem_word      :   IDU_o_mem_word    ;                                         
            EXU_i_mem_byte_u   <=  FORWARD_stallEX  ?   EXU_i_mem_byte_u    :   IDU_o_mem_byte_u  ;                                         
            EXU_i_mem_half_u   <=  FORWARD_stallEX  ?   EXU_i_mem_half_u    :   IDU_o_mem_half_u  ;                                       
            EXU_i_mem_dword    <=  FORWARD_stallEX  ?   EXU_i_mem_dword     :   IDU_o_mem_dword   ;                                       
            EXU_i_mem_word_u   <=  FORWARD_stallEX  ?   EXU_i_mem_word_u    :   IDU_o_mem_word_u  ;                                       
            EXU_i_system_halt  <=  FORWARD_stallEX  ?   EXU_i_system_halt   :   IDU_o_system_halt ;
            
            
            if(!FORWARD_stallEX) begin
                // 判断数据来源
                EXU_i_rs1_data     <=  FORWARD_rs1_hazard_SEG ? FORWARD_rs1_data_SEG : IDU_o_rs1_data;  
                EXU_i_rs2_data     <=  FORWARD_rs2_hazard_SEG ? FORWARD_rs2_data_SEG : IDU_o_rs2_data;  
                EXU_i_csr_rs_data  <=  FORWARD_csr_rs_hazard_SEG ? FORWARD_csr_rs_data_SEG : IDU_o_csr_rs_data;
            end
            else begin
                EXU_i_rs1_data     <=  FORWARD_rs1_hazard_SEG_f ?    FORWARD_rs1_data_SEG    : EXU_i_rs1_data    ;
                EXU_i_rs2_data     <=  FORWARD_rs2_hazard_SEG_f ?    FORWARD_rs2_data_SEG    : EXU_i_rs2_data    ;
                EXU_i_csr_rs_data  <=  FORWARD_csr_rs_hazard_SEG_f ? FORWARD_csr_rs_data_SEG : EXU_i_csr_rs_data ;
            end
        end



        
    end

endmodule



