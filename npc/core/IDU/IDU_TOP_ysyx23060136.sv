/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-19 13:23:33 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-28 23:52:11
 */


 `include "DEFINES_ysyx23060136.sv"


// top module of IDU
// ===========================================================================
module IDU_TOP_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
        input              [  31:0]         IDU_i_pc                   ,
        input              [  31:0]         IDU_i_inst                 ,
        input                               IDU_i_commit               ,
        // ===========================================================================
        // WB write back form WB unit
        input              [   4:0]         WB_o_rd                      ,
        input                               WB_o_RegWr                   ,
        input              [  31:0]         WB_o_rf_busW                 ,
        input              [   2:0]         WB_o_csr_rd                  ,
        input                               WB_o_CSRWr                   ,
        input              [  31:0]         WB_o_csr_busW                ,
        // ===========================================================================
        // general data
        // push singnal to the next stage
        output             [  31:0]         IDU_o_pc                     ,
        output             [  31:0]         IDU_o_inst                   ,
        output                              IDU_o_commit                 ,
        output             [   4:0]         IDU_o_rd                     ,
        // for later forward transition
        output             [   4:0]         IDU_o_rs1                    ,
        output             [   4:0]         IDU_o_rs2                    ,
        output             [  31:0]         IDU_o_imm                    ,
        output             [  31:0]         IDU_o_rs1_data               ,
        output             [  31:0]         IDU_o_rs2_data               ,
        // rd for WB, rs for forward
        output             [   2:0]         IDU_o_csr_rd                 ,
        output             [   2:0]         IDU_o_csr_rs                 ,
        output             [  31:0]         IDU_o_csr_rs_data            ,
        // ===========================================================================
        // ALU signal
        output                              IDU_o_ALU_add                ,
        output                              IDU_o_ALU_sub                ,
        output                              IDU_o_ALU_slt                ,
        output                              IDU_o_ALU_sltu               ,
        output                              IDU_o_ALU_or                 ,
        output                              IDU_o_ALU_and                ,
        output                              IDU_o_ALU_xor                ,
        output                              IDU_o_ALU_sll                ,
        output                              IDU_o_ALU_srl                ,
        output                              IDU_o_ALU_sra                ,
        output                              IDU_o_ALU_explicit           ,
        output                              IDU_o_ALU_i1_rs1             ,
        output                              IDU_o_ALU_i1_pc              ,
        output                              IDU_o_ALU_i2_rs2             ,
        output                              IDU_o_ALU_i2_imm             ,
        output                              IDU_o_ALU_i2_4               ,
        output                              IDU_o_ALU_i2_csr             ,
        // ===========================================================================
        // jump signal
        output                              IDU_o_jump                   ,
        output                              IDU_o_pc_plus_imm            ,
        output                              IDU_o_rs1_plus_imm           ,
        output                              IDU_o_csr_plus_imm           ,
        output                              IDU_o_cmp_eq                 ,
        output                              IDU_o_cmp_neq                ,
        output                              IDU_o_cmp_ge                 ,
        output                              IDU_o_cmp_lt                 ,
        // ===========================================================================
        // write back
        output                              IDU_o_write_gpr              ,
        output                              IDU_o_write_csr              ,
        output                              IDU_o_mem_to_reg             ,
        output                              IDU_o_rv32_csrrs             ,
        output                              IDU_o_rv32_csrrw             ,
        output                              IDU_o_rv32_ecall             ,
        // ===========================================================================
        // mem
        output                              IDU_o_write_mem              ,
        output                              IDU_o_mem_byte               ,
        output                              IDU_o_mem_half               ,
        output                              IDU_o_mem_word               ,
        output                              IDU_o_mem_byte_u             ,
        output                              IDU_o_mem_half_u             ,
        // ===========================================================================
        // system
        output                              IDU_o_system_halt            
    );


    // internal signal
    wire      [11 : 0]       IDU_csr_id;

    // 直接传递
    assign                   IDU_o_pc       =        IDU_i_pc;
    assign                   IDU_o_inst     =        IDU_i_inst;
    assign                   IDU_o_commit   =        IDU_i_commit;

    IDU_DECODE_ysyx23060136  IDU_DECODE_ysyx23060136_inst (
                                 .IDU_inst                          (IDU_i_inst                  ),
                                 .IDU_rd                            (IDU_o_rd                    ),
                                 .IDU_rs1                           (IDU_o_rs1                   ),
                                 .IDU_rs2                           (IDU_o_rs2                   ),
                                 .IDU_csr_id                        (IDU_csr_id                  ),
                                 .ALU_add                           (IDU_o_ALU_add               ),
                                 .ALU_sub                           (IDU_o_ALU_sub               ),
                                 .ALU_slt                           (IDU_o_ALU_slt               ),
                                 .ALU_sltu                          (IDU_o_ALU_sltu              ),
                                 .ALU_or                            (IDU_o_ALU_or                ),
                                 .ALU_and                           (IDU_o_ALU_and               ),
                                 .ALU_xor                           (IDU_o_ALU_xor               ),
                                 .ALU_sll                           (IDU_o_ALU_sll               ),
                                 .ALU_srl                           (IDU_o_ALU_srl               ),
                                 .ALU_sra                           (IDU_o_ALU_sra               ),
                                 .ALU_explicit                      (IDU_o_ALU_explicit          ),
                                 .ALU_i1_rs1                        (IDU_o_ALU_i1_rs1            ),
                                 .ALU_i1_pc                         (IDU_o_ALU_i1_pc             ),
                                 .ALU_i2_rs2                        (IDU_o_ALU_i2_rs2            ),
                                 .ALU_i2_imm                        (IDU_o_ALU_i2_imm            ),
                                 .ALU_i2_4                          (IDU_o_ALU_i2_4              ),
                                 .ALU_i2_csr                        (IDU_o_ALU_i2_csr            ),                           
                                 .jump                              (IDU_o_jump                  ),
                                 .pc_plus_imm                       (IDU_o_pc_plus_imm           ),
                                 .rs1_plus_imm                      (IDU_o_rs1_plus_imm          ),
                                 .csr_plus_imm                      (IDU_o_csr_plus_imm          ),

                                 .cmp_eq                            (IDU_o_cmp_eq                ),
                                 .cmp_neq                           (IDU_o_cmp_neq               ),
                                 .cmp_ge                            (IDU_o_cmp_ge                ),
                                 .cmp_lt                            (IDU_o_cmp_lt                ),

                                 .write_gpr                         (IDU_o_write_gpr             ),
                                 .write_csr                         (IDU_o_write_csr             ),
                                 .mem_to_reg                        (IDU_o_mem_to_reg            ),
                                 .rv32_csrrs                        (IDU_o_rv32_csrrs            ),
                                 .rv32_csrrw                        (IDU_o_rv32_csrrw            ),
                                 .rv32_ecall                        (IDU_o_rv32_ecall            ),
                                 .write_mem                         (IDU_o_write_mem             ),
                                 .mem_byte                          (IDU_o_mem_byte              ),
                                 .mem_half                          (IDU_o_mem_half              ),
                                 .mem_word                          (IDU_o_mem_word              ),
                                 .mem_byte_u                        (IDU_o_mem_byte_u            ),
                                 .mem_half_u                        (IDU_o_mem_half_u            ),
                                 .system_halt                       (IDU_o_system_halt           ),
                                 .IDU_imm                           (IDU_o_imm                   )
                             );

    IDU_GPR_FILE_ysyx_23060136  IDU_GPR_FILE_ysyx_23060136_inst (
                                    .clk                               (clk                       ),
                                    .rst                               (rst                       ),
                                    .IDU_rs1                           (IDU_o_rs1                 ),
                                    .IDU_rs2                           (IDU_o_rs2                 ),
                                    .WBU_rd                            (WB_o_rd                   ),
                                    .RegWr                             (WB_o_RegWr                ),
                                    .rf_busW                           (WB_o_rf_busW              ),
                                    .IDU_rs1_data                      (IDU_o_rs1_data            ),
                                    .IDU_rs2_data                      (IDU_o_rs2_data            ) 
                                );

    IDU_CSR_FILE_ysyx_23060136  IDU_CSR_FILE_ysyx_23060136_inst (
                                    .clk                               (clk                       ),
                                    .rst                               (rst                       ),
                                    .IDU_csr_rs                        (IDU_o_csr_rs              ),
                                    .WBU_csr_rd                        (WB_o_csr_rd               ),
                                    .CSRWr                             (WB_o_CSRWr                ),
                                    .csr_busW                          (WB_o_csr_busW             ),
                                    .IDU_csr_rs_data                   (IDU_o_csr_rs_data         ) 
                                );

    IDU_CSR_DECODE_ysyx_23060136  IDU_CSR_DECODE_ysyx_23060136_inst (
                                      .IDU_csr_id                        (IDU_csr_id                ),
                                      .IDU_csr_rs                        (IDU_o_csr_rs              ),
                                      .IDU_csr_rd                        (IDU_o_csr_rd              )
                                  );

endmodule



