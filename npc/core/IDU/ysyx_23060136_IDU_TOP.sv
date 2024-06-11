/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 21:51:39 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 21:51:59
 */


 `include "ysyx_23060136_DEFINES.sv"


// Top module of IDU
// ===========================================================================
module ysyx_23060136_IDU_TOP ( 
        input                                                    clk                        ,
        input                                                    rst                        ,
        input              [  `ysyx_23060136_BITS_W-1:0]         IDU_i_pc                   ,
        input              [  `ysyx_23060136_INST_W-1:0]         IDU_i_inst                 ,
        input                                                    IDU_i_commit               ,
        input                                                    IDU_i_pre_take             ,
        // ===========================================================================
        // WB write back form WB unit
        input              [  `ysyx_23060136_GPR_W-1:0]          WB_o_rd                    ,
        input                                                    WB_o_RegWr                 ,
        input              [  `ysyx_23060136_BITS_W-1:0]         WB_o_rf_busW               ,

        input              [  `ysyx_23060136_CSR_W-1:0]          WB_o_csr_rd_1              ,
        input              [  `ysyx_23060136_CSR_W-1:0]          WB_o_csr_rd_2              ,
        input                                                    WB_o_CSRWr_1               ,
        input                                                    WB_o_CSRWr_2               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         WB_o_csr_busW_1            ,
        input              [  `ysyx_23060136_BITS_W-1:0]         WB_o_csr_busW_2            ,
        // ===========================================================================
        // general data
        // push singnal to the next stage
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_o_pc                   ,
        output             [  `ysyx_23060136_INST_W-1:0]         IDU_o_inst                 ,
        output                                                   IDU_o_commit               ,
        output                                                   IDU_o_pre_take             ,
        output             [  `ysyx_23060136_GPR_W-1:0]          IDU_o_rd                   ,
        // for later forward transition
        output             [  `ysyx_23060136_GPR_W-1:0]          IDU_o_rs1                  ,
        output             [  `ysyx_23060136_GPR_W-1:0]          IDU_o_rs2                  ,
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_o_imm                  ,
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_o_rs1_data             ,
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_o_rs2_data             ,
        // rd for , rs for forward
        output             [  `ysyx_23060136_CSR_W-1:0]          IDU_o_csr_rd_1             ,
        output             [  `ysyx_23060136_CSR_W-1:0]          IDU_o_csr_rd_2             ,
        output             [  `ysyx_23060136_CSR_W-1:0]          IDU_o_csr_rs               ,
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_o_csr_rs_data          ,
        // ===========================================================================
        // ALU signal
        // ALU calculating type define
        output                                                   IDU_o_ALU_word_t           ,
        output                                                   IDU_o_ALU_add              ,
        output                                                   IDU_o_ALU_sub              ,
        // 带符号小于
        output                                                   IDU_o_ALU_slt              ,
        // 无符号小于
        output                                                   IDU_o_ALU_sltu             ,
        // 与或异或运算
        output                                                   IDU_o_ALU_or               ,
        output                                                   IDU_o_ALU_and              ,
        output                                                   IDU_o_ALU_xor              ,
        // 移位运算
        output                                                   IDU_o_ALU_sll              ,
        output                                                   IDU_o_ALU_srl              ,
        output                                                   IDU_o_ALU_sra              ,
    
        output                                                   IDU_o_ALU_mul              ,
        output                                                   IDU_o_ALU_mul_hi           ,
        output                                                   IDU_o_ALU_mul_u            ,
        output                                                   IDU_o_ALU_mul_s            ,
        output                                                   IDU_o_ALU_mul_su           ,
    
        output                                                   IDU_o_ALU_div              ,
        output                                                   IDU_o_ALU_div_u            ,
        output                                                   IDU_o_ALU_div_s            ,
        output                                                   IDU_o_ALU_rem              ,
        output                                                   IDU_o_ALU_rem_u            ,
        output                                                   IDU_o_ALU_rem_s            ,
        // 直接输出
        output                                                   IDU_o_ALU_explicit         ,

        output                                                   IDU_o_ALU_i1_rs1           ,
        output                                                   IDU_o_ALU_i1_pc            ,
        output                                                   IDU_o_ALU_i2_rs2           ,
        output                                                   IDU_o_ALU_i2_imm           ,
        output                                                   IDU_o_ALU_i2_4             ,
        output                                                   IDU_o_ALU_i2_csr           ,
        // ===========================================================================
        // jump signal
        output                                                   IDU_o_jump                   ,
        output                                                   IDU_o_pc_plus_imm            ,
        output                                                   IDU_o_rs1_plus_imm           ,
        output                                                   IDU_o_csr_plus_imm           ,
        output                                                   IDU_o_cmp_eq                 ,
        output                                                   IDU_o_cmp_neq                ,
        output                                                   IDU_o_cmp_ge                 ,
        output                                                   IDU_o_cmp_lt                 ,
        // ===========================================================================
        // write back
        output                                                   IDU_o_write_gpr              ,
        output                                                   IDU_o_write_csr_1            ,
        output                                                   IDU_o_write_csr_2            ,
        output                                                   IDU_o_mem_to_reg             ,
        output                                                   IDU_o_rv64_csrrs             ,
        output                                                   IDU_o_rv64_csrrw             ,
        output                                                   IDU_o_rv64_ecall             ,
        // ===========================================================================
        // mem
        output                                                   IDU_o_write_mem              ,
        output                                                   IDU_o_mem_byte               ,
        output                                                   IDU_o_mem_half               ,
        output                                                   IDU_o_mem_word               ,
        output                                                   IDU_o_mem_dword              ,
        output                                                   IDU_o_mem_byte_u             ,
        output                                                   IDU_o_mem_half_u             ,
        output                                                   IDU_o_mem_word_u             ,
        // ===========================================================================
        // system
        output                                                   IDU_o_system_halt            
    );


    // 直接传递
    assign                   IDU_o_pc       =        IDU_i_pc;
    assign                   IDU_o_inst     =        IDU_i_inst;
    assign                   IDU_o_commit   =        IDU_i_commit;
    assign                   IDU_o_pre_take =        IDU_i_pre_take; 

    ysyx_23060136_IDU_DECODE  ysyx_23060136_IDU_DECODE_inst (
        .IDU_inst                          (IDU_i_inst                ),
        .IDU_rd                            (IDU_o_rd                  ),
        .IDU_rs1                           (IDU_o_rs1                 ),
        .IDU_rs2                           (IDU_o_rs2                 ),
        .IDU_csr_rs                        (IDU_o_csr_rs              ),
        .IDU_csr_rd_1                      (IDU_o_csr_rd_1            ),
        .IDU_csr_rd_2                      (IDU_o_csr_rd_2            ),
        .ALU_word_t                        (IDU_o_ALU_word_t          ),
        .ALU_add                           (IDU_o_ALU_add             ),
        .ALU_sub                           (IDU_o_ALU_sub             ),
        .ALU_slt                           (IDU_o_ALU_slt             ),
        .ALU_sltu                          (IDU_o_ALU_sltu            ),
        .ALU_or                            (IDU_o_ALU_or              ),
        .ALU_and                           (IDU_o_ALU_and             ),
        .ALU_xor                           (IDU_o_ALU_xor             ),
        .ALU_sll                           (IDU_o_ALU_sll             ),
        .ALU_srl                           (IDU_o_ALU_srl             ),
        .ALU_sra                           (IDU_o_ALU_sra             ),
        .ALU_mul                           (IDU_o_ALU_mul             ),
        .ALU_mul_hi                        (IDU_o_ALU_mul_hi          ),
        .ALU_mul_u                         (IDU_o_ALU_mul_u           ),
        .ALU_mul_s                         (IDU_o_ALU_mul_s           ),
        .ALU_mul_su                        (IDU_o_ALU_mul_su          ),
        .ALU_div                           (IDU_o_ALU_div             ),
        .ALU_div_u                         (IDU_o_ALU_div_u           ),
        .ALU_div_s                         (IDU_o_ALU_div_s           ),
        .ALU_rem                           (IDU_o_ALU_rem             ),
        .ALU_rem_u                         (IDU_o_ALU_rem_u           ),
        .ALU_rem_s                         (IDU_o_ALU_rem_s           ),
        .ALU_explicit                      (IDU_o_ALU_explicit        ),
        .ALU_i1_rs1                        (IDU_o_ALU_i1_rs1          ),
        .ALU_i1_pc                         (IDU_o_ALU_i1_pc           ),
        .ALU_i2_rs2                        (IDU_o_ALU_i2_rs2          ),
        .ALU_i2_imm                        (IDU_o_ALU_i2_imm          ),
        .ALU_i2_4                          (IDU_o_ALU_i2_4            ),
        .ALU_i2_csr                        (IDU_o_ALU_i2_csr          ),
        .jump                              (IDU_o_jump                ),
        .pc_plus_imm                       (IDU_o_pc_plus_imm         ),
        .rs1_plus_imm                      (IDU_o_rs1_plus_imm        ),
        .csr_plus_imm                      (IDU_o_csr_plus_imm        ),
        .cmp_eq                            (IDU_o_cmp_eq              ),
        .cmp_neq                           (IDU_o_cmp_neq             ),
        .cmp_ge                            (IDU_o_cmp_ge              ),
        .cmp_lt                            (IDU_o_cmp_lt              ),
        .write_gpr                         (IDU_o_write_gpr           ),
        .write_csr_1                       (IDU_o_write_csr_1         ),
        .write_csr_2                       (IDU_o_write_csr_2         ),
        .mem_to_reg                        (IDU_o_mem_to_reg          ),
        .rv64_csrrs                        (IDU_o_rv64_csrrs          ),
        .rv64_csrrw                        (IDU_o_rv64_csrrw          ),
        .rv64_ecall                        (IDU_o_rv64_ecall          ),
        .write_mem                         (IDU_o_write_mem           ),
        .mem_byte                          (IDU_o_mem_byte            ),
        .mem_half                          (IDU_o_mem_half            ),
        .mem_word                          (IDU_o_mem_word            ),
        .mem_dword                         (IDU_o_mem_dword           ),
        .mem_byte_u                        (IDU_o_mem_byte_u          ),
        .mem_half_u                        (IDU_o_mem_half_u          ),
        .mem_word_u                        (IDU_o_mem_word_u          ),
        .system_halt                       (IDU_o_system_halt         ),
        .IDU_imm                           (IDU_o_imm                 ) 
    );

    ysyx_23060136_IDU_GPR_FILE  ysyx_23060136_IDU_GPR_FILE_inst (
        .clk                               (clk                         ),
        .rst                               (rst                         ),
        .IDU_rs1                           (IDU_o_rs1                   ),
        .IDU_rs2                           (IDU_o_rs2                   ),
        .WBU_rd                            (WB_o_rd                     ),
        .RegWr                             (WB_o_RegWr                  ),
        .rf_busW                           (WB_o_rf_busW                ),
        .IDU_rs1_data                      (IDU_o_rs1_data              ),
        .IDU_rs2_data                      (IDU_o_rs2_data              )
      );

      ysyx_23060136_IDU_CSR_FILE  ysyx_23060136_IDU_CSR_FILE_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .IDU_csr_rs                        (IDU_o_csr_rs              ),
        .WBU_csr_rd_1                      (WB_o_csr_rd_1             ),
        .WBU_csr_rd_2                      (WB_o_csr_rd_2             ),
        .CSRWr_1                           (WB_o_CSRWr_1              ),
        .CSRWr_2                           (WB_o_CSRWr_2              ),
        .csr_busW_1                        (WB_o_csr_busW_1           ),
        .csr_busW_2                        (WB_o_csr_busW_2           ),
        .IDU_csr_rs_data                   (IDU_o_csr_rs_data         ) 
      );

endmodule



