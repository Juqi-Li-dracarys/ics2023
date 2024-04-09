/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 14:31:11 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-08 12:25:46
 */


 `include "ysyx_23060136_DEFINES.sv"


// internal mini pipeline
// ===========================================================================
module ysyx_23060136_EXU_SEG (
    input                                                         clk                         ,
    input                                                         rst                         ,

    input                                                         BRANCH_flushEX1             ,
    input                                                         FORWARD_stallEX2            ,

    input                  [  `ysyx_23060136_BITS_W-1:0 ]         EXU1_pc                     ,
    input                  [  `ysyx_23060136_INST_W-1 :0]         EXU1_inst                   ,
    input                                                         EXU1_commit                 ,

    input                  [  `ysyx_23060136_GPR_W-1  :0]         EXU1_rd                     ,
    input                  [  `ysyx_23060136_GPR_W-1  :0]         EXU1_rs1                    ,
    input                  [  `ysyx_23060136_GPR_W-1  :0]         EXU1_rs2                    ,
    input                  [  `ysyx_23060136_CSR_W-1:0  ]         EXU1_csr_rd_1               ,
    input                  [  `ysyx_23060136_CSR_W-1:0  ]         EXU1_csr_rd_2               ,
    input                  [  `ysyx_23060136_CSR_W-1:0  ]         EXU1_csr_rs                 ,

    input                  [  `ysyx_23060136_BITS_W -1:0]         EXU1_HAZARD_rs1_data        ,
    input                  [  `ysyx_23060136_BITS_W -1:0]         EXU1_HAZARD_rs2_data        ,
    input                  [  `ysyx_23060136_BITS_W -1:0]         EXU1_HAZARD_csr_rs_data     ,
    input                  [  `ysyx_23060136_BITS_W -1:0]         EXU1_imm                    ,

    // jump target
    input                                                         EXU1_jump                   ,
    input                                                         EXU1_pc_plus_imm            ,
    input                                                         EXU1_rs1_plus_imm           ,
    input                                                         EXU1_csr_plus_imm           ,

    // signal is 0 means jump directly
    input                                                         EXU1_cmp_eq                 ,
    input                                                         EXU1_cmp_neq                ,
    input                                                         EXU1_cmp_ge                 ,
    input                                                         EXU1_cmp_lt                 ,

    // WB
    input                                                         EXU1_write_gpr              ,
    input                                                         EXU1_write_csr_1            ,
    input                                                         EXU1_write_csr_2            ,
    input                                                         EXU1_mem_to_reg             ,

    // memory write
    input                                                         EXU1_write_mem              ,
    input                                                         EXU1_mem_byte               ,
    input                                                         EXU1_mem_half               ,
    input                                                         EXU1_mem_word               ,
    input                                                         EXU1_mem_dword              ,
    input                                                         EXU1_mem_byte_u             ,
    input                                                         EXU1_mem_half_u             ,
    input                                                         EXU1_mem_word_u             ,

    input                                                         EXU1_system_halt            ,


    output    logic        [  `ysyx_23060136_BITS_W-1:0 ]         EXU2_pc                     ,
    output    logic        [  `ysyx_23060136_INST_W-1 :0]         EXU2_inst                   ,
    output    logic                                               EXU2_commit                 ,



    output    logic        [  `ysyx_23060136_GPR_W-1  :0]         EXU2_rd                     ,
    output    logic        [  `ysyx_23060136_GPR_W-1  :0]         EXU2_rs1                    ,
    output    logic        [  `ysyx_23060136_GPR_W-1  :0]         EXU2_rs2                    ,
    output    logic        [  `ysyx_23060136_CSR_W-1:0  ]         EXU2_csr_rd_1               ,
    output    logic        [  `ysyx_23060136_CSR_W-1:0  ]         EXU2_csr_rd_2               ,
    output    logic        [  `ysyx_23060136_CSR_W-1:0  ]         EXU2_csr_rs                 ,

    output    logic        [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_rs1_data        ,
    output    logic        [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_rs2_data        ,
    output    logic        [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_csr_rs_data     ,
    output    logic        [  `ysyx_23060136_BITS_W -1:0]         EXU2_imm                    ,

    // jump target
    output    logic                                               EXU2_jump                   ,
    output    logic                                               EXU2_pc_plus_imm            ,
    output    logic                                               EXU2_rs1_plus_imm           ,
    output    logic                                               EXU2_csr_plus_imm           ,

    // signal is 0 means jump directly
    output    logic                                               EXU2_cmp_eq                 ,
    output    logic                                               EXU2_cmp_neq                ,
    output    logic                                               EXU2_cmp_ge                 ,
    output    logic                                               EXU2_cmp_lt                 ,

    // WB
    output    logic                                               EXU2_write_gpr              ,
    output    logic                                               EXU2_write_csr_1            ,
    output    logic                                               EXU2_write_csr_2            ,
    output    logic                                               EXU2_mem_to_reg             ,

    // memory write
    output    logic                                               EXU2_write_mem              ,
    output    logic                                               EXU2_mem_byte               ,
    output    logic                                               EXU2_mem_half               ,
    output    logic                                               EXU2_mem_word               ,
    output    logic                                               EXU2_mem_dword              ,
    output    logic                                               EXU2_mem_byte_u             ,
    output    logic                                               EXU2_mem_half_u             ,
    output    logic                                               EXU2_mem_word_u             ,

    output    logic                                               EXU2_system_halt            
);

    always_ff @(posedge clk) begin : update_pc
        if(rst || (BRANCH_flushEX1 & ~FORWARD_stallEX2)) begin
            EXU2_pc                 <=   `ysyx_23060136_PC_RST;
            EXU2_inst               <=   `ysyx_23060136_NOP;       
            EXU2_commit             <=   `ysyx_23060136_false;
            
            EXU2_rd                 <=    `ysyx_23060136_false;
            EXU2_rs1                <=    `ysyx_23060136_false;
            EXU2_rs2                <=    `ysyx_23060136_false;
            EXU2_csr_rd_1           <=    `ysyx_23060136_false;
            EXU2_csr_rd_2           <=    `ysyx_23060136_false;
            EXU2_csr_rs             <=    `ysyx_23060136_false;
            
            EXU2_HAZARD_rs1_data    <=   `ysyx_23060136_false;
            EXU2_HAZARD_rs2_data    <=   `ysyx_23060136_false;                   
            EXU2_HAZARD_csr_rs_data <=   `ysyx_23060136_false;                                     
            EXU2_imm                <=   `ysyx_23060136_false;       
            EXU2_jump               <=   `ysyx_23060136_false; 
            EXU2_pc_plus_imm        <=   `ysyx_23060136_false; 
            EXU2_rs1_plus_imm       <=   `ysyx_23060136_false;
            EXU2_csr_plus_imm       <=   `ysyx_23060136_false; 
            EXU2_cmp_eq             <=   `ysyx_23060136_false; 
            EXU2_cmp_neq            <=   `ysyx_23060136_false; 
            EXU2_cmp_ge             <=   `ysyx_23060136_false; 
            EXU2_cmp_lt             <=   `ysyx_23060136_false; 
            EXU2_write_gpr          <=   `ysyx_23060136_false; 
            EXU2_write_csr_1        <=   `ysyx_23060136_false; 
            EXU2_write_csr_2        <=   `ysyx_23060136_false; 
            EXU2_mem_to_reg         <=   `ysyx_23060136_false; 
            EXU2_write_mem          <=   `ysyx_23060136_false; 
            EXU2_mem_byte           <=   `ysyx_23060136_false; 
            EXU2_mem_half           <=   `ysyx_23060136_false; 
            EXU2_mem_word           <=   `ysyx_23060136_false; 
            EXU2_mem_dword          <=   `ysyx_23060136_false; 
            EXU2_mem_byte_u         <=   `ysyx_23060136_false; 
            EXU2_mem_half_u         <=   `ysyx_23060136_false; 
            EXU2_mem_word_u         <=   `ysyx_23060136_false; 
            EXU2_system_halt        <=   `ysyx_23060136_false; 
        end
        else if(!FORWARD_stallEX2) begin
            EXU2_pc                 <=     EXU1_pc                 ;                              
            EXU2_inst               <=     EXU1_inst               ;                              
            EXU2_commit             <=     EXU1_commit             ; 
            
            EXU2_rd                 <=      EXU1_rd                ;                                      
            EXU2_rs1                <=      EXU1_rs1               ;                                      
            EXU2_rs2                <=      EXU1_rs2               ;                                      
            EXU2_csr_rd_1           <=      EXU1_csr_rd_1          ;                                      
            EXU2_csr_rd_2           <=      EXU1_csr_rd_2          ;                                      
            EXU2_csr_rs             <=      EXU1_csr_rs            ;                                      
            
            
            EXU2_HAZARD_rs1_data    <=     EXU1_HAZARD_rs1_data    ;
            EXU2_HAZARD_rs2_data    <=     EXU1_HAZARD_rs2_data    ;                              
            EXU2_HAZARD_csr_rs_data <=     EXU1_HAZARD_csr_rs_data ;                              
            EXU2_imm                <=     EXU1_imm                ;                              
            EXU2_jump               <=     EXU1_jump               ;                              
            EXU2_pc_plus_imm        <=     EXU1_pc_plus_imm        ;                              
            EXU2_rs1_plus_imm       <=     EXU1_rs1_plus_imm       ;                              
            EXU2_csr_plus_imm       <=     EXU1_csr_plus_imm       ;                              
            EXU2_cmp_eq             <=     EXU1_cmp_eq             ;                              
            EXU2_cmp_neq            <=     EXU1_cmp_neq            ;                              
            EXU2_cmp_ge             <=     EXU1_cmp_ge             ;                              
            EXU2_cmp_lt             <=     EXU1_cmp_lt             ;                              
            EXU2_write_gpr          <=     EXU1_write_gpr          ;                              
            EXU2_write_csr_1        <=     EXU1_write_csr_1        ;                              
            EXU2_write_csr_2        <=     EXU1_write_csr_2        ;                              
            EXU2_mem_to_reg         <=     EXU1_mem_to_reg         ;                              
            EXU2_write_mem          <=     EXU1_write_mem          ;                              
            EXU2_mem_byte           <=     EXU1_mem_byte           ;                              
            EXU2_mem_half           <=     EXU1_mem_half           ;                              
            EXU2_mem_word           <=     EXU1_mem_word           ;                              
            EXU2_mem_dword          <=     EXU1_mem_dword          ;                              
            EXU2_mem_byte_u         <=     EXU1_mem_byte_u         ;                              
            EXU2_mem_half_u         <=     EXU1_mem_half_u         ;                              
            EXU2_mem_word_u         <=     EXU1_mem_word_u         ;                              
            EXU2_system_halt        <=     EXU1_system_halt        ;                              
        end
    end

endmodule


