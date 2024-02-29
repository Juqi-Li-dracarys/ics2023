/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-29 08:39:12 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 08:47:45
 */

`include "TOP_DEFINES_ysyx23060136.sv"

// ===========================================================================
module CPU_TOP_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        
    );

    logic                                FORWARD_stallIF            ;
    logic               [  31:0]         branch_target              ;
    logic                                PCSrc                      ;
    logic               [  31:0]         IFU_inst                   ;
    logic               [  31:0]         IFU_pc                     ;
    logic                                IFU_valid                  ;
  

    IFU_TOP_ysyx23060136  IFU_TOP_ysyx23060136_inst (
                              .clk                               (clk                       ),
                              .rst                               (rst                       ),
                              .FORWARD_stallIF                   (FORWARD_stallIF           ),
                              .branch_target                     (branch_target             ),
                              .PCSrc                             (PCSrc                     ),
                              .IFU_inst                          (IFU_inst                  ),
                              .IFU_pc                            (IFU_pc                    ),
                              .IFU_valid                         (IFU_valid                 )
                          );


    logic                                BRANCH_flushIF             ;
    logic                                FORWARD_stallID            ;
    logic                                IDU_commit                 ;
    logic               [  31:0]         IDU_pc                     ;
    logic               [  31:0]         IDU_inst                   ;
                        


    IFU_IDU_SEG_REG_ysyx23060136  IFU_IDU_SEG_REG_ysyx23060136_inst (
                            .clk                               (clk                       ),
                            .rst                               (rst                       ),
                            .BRANCH_flushIF                    (BRANCH_flushIF            ),
                            .FORWARD_stallID                   (FORWARD_stallID           ),
                            .IFU_pc                            (IFU_pc                    ),
                            .IFU_inst                          (IFU_inst                  ),
                            .IDU_commit                        (IDU_commit                ),
                            .IDU_pc                            (IDU_pc                    ),
                            .IDU_inst                          (IDU_inst                  ) 
                          );

    logic              [   4:0]         WBU_rd                     ;
    logic                               RegWr                      ;
    logic              [  31:0]         rf_busW                    ;
    logic              [   1:0]         WBU_csr_rd                 ;
    logic                               CSRWr                      ;
    logic              [  31:0]         csr_busW                   ;
    logic              [  31:0]         IDU_pc_EXU                 ;
    logic              [  31:0]         IDU_inst_EXU               ;
    logic                               IDU_commit_EXU             ;
    logic              [   4:0]         IDU_rd                     ;
    logic              [   4:0]         IDU_rs1                    ;
    logic              [   4:0]         IDU_rs2                    ;
    logic              [  31:0]         IDU_imm                    ;
    logic              [  31:0]         IDU_rs1_data               ;
    logic              [  31:0]         IDU_rs2_data               ;
    logic              [   1:0]         IDU_csr_rd                 ;
    logic              [   1:0]         IDU_csr_rs                 ;
    logic              [  31:0]         IDU_csr_rs_data            ;
    logic                               IDU_ALU_add                ;
    logic                               IDU_ALU_sub                ;
    logic                               IDU_ALU_slt                ;
    logic                               IDU_ALU_sltu               ;
    logic                               IDU_ALU_or                 ;
    logic                               IDU_ALU_and                ;
    logic                               IDU_ALU_xor                ;
    logic                               IDU_ALU_sll                ;
    logic                               IDU_ALU_srl                ;
    logic                               IDU_ALU_sra                ;
    logic                               IDU_ALU_explicit           ;
    logic                               IDU_ALU_i1_rs1             ;
    logic                               IDU_ALU_i1_pc              ;
    logic                               IDU_ALU_i2_rs2             ;
    logic                               IDU_ALU_i2_imm             ;
    logic                               IDU_ALU_i2_4               ;
    logic                               IDU_ALU_i2_csr             ;
    logic                               IDU_jump                   ;
    logic                               IDU_pc_plus_imm            ;
    logic                               IDU_rs1_plus_imm           ;
    logic                               IDU_csr_plus_imm           ;
    logic                               IDU_cmp_eq                 ;
    logic                               IDU_cmp_neq                ;
    logic                               IDU_cmp_ge                 ;
    logic                               IDU_cmp_lt                 ;
    logic                               IDU_write_gpr              ;
    logic                               IDU_write_csr              ;


    logic                               IDU_mem_to_reg             ;
    logic                               IDU_rv32_csrrs             ;
    logic                               IDU_rv32_csrrw             ;
    logic                               IDU_rv32_ecall             ;
    logic                               IDU_write_mem              ;
    logic                               IDU_mem_byte               ;
    logic                               IDU_mem_half               ;
    logic                               IDU_mem_word               ;
    logic                               IDU_mem_byte_u             ;
    logic                               IDU_mem_half_u             ;
    logic                               IDU_system_halt            ;
    logic                               IDU_op_valid               ;
  


    IDU_TOP_ysyx23060136  IDU_TOP_ysyx23060136_inst (
                              .clk                               (clk                       ),
                              .rst                               (rst                       ),
                              .IDU_pc                            (IDU_pc                    ),
                              .IDU_inst                          (IDU_inst                  ),
                              .IDU_commit                        (IDU_commit                ),
                              .WBU_rd                            (WBU_rd                    ),
                              .RegWr                             (RegWr                     ),
                              .rf_busW                           (rf_busW                   ),
                              .WBU_csr_rd                        (WBU_csr_rd                ),
                              .CSRWr                             (CSRWr                     ),
                              .csr_busW                          (csr_busW                  ),
                              .IDU_pc_EXU                        (IDU_pc_EXU                ),
                              .IDU_inst_EXU                      (IDU_inst_EXU              ),
                              .IDU_commit_EXU                    (IDU_commit_EXU            ),
                              .IDU_rd                            (IDU_rd                    ),
                              .IDU_rs1                           (IDU_rs1                   ),
                              .IDU_rs2                           (IDU_rs2                   ),
                              .IDU_imm                           (IDU_imm                   ),
                              .IDU_rs1_data                      (IDU_rs1_data              ),
                              .IDU_rs2_data                      (IDU_rs2_data              ),
                              .IDU_csr_rd                        (IDU_csr_rd                ),
                              .IDU_csr_rs                        (IDU_csr_rs                ),
                              .IDU_csr_rs_data                   (IDU_csr_rs_data           ),
                              .IDU_ALU_add                       (IDU_ALU_add               ),
                              .IDU_ALU_sub                       (IDU_ALU_sub               ),
                              .IDU_ALU_slt                       (IDU_ALU_slt               ),
                              .IDU_ALU_sltu                      (IDU_ALU_sltu              ),
                              .IDU_ALU_or                        (IDU_ALU_or                ),
                              .IDU_ALU_and                       (IDU_ALU_and               ),
                              .IDU_ALU_xor                       (IDU_ALU_xor               ),
                              .IDU_ALU_sll                       (IDU_ALU_sll               ),
                              .IDU_ALU_srl                       (IDU_ALU_srl               ),
                              .IDU_ALU_sra                       (IDU_ALU_sra               ),
                              .IDU_ALU_explicit                  (IDU_ALU_explicit          ),
                              .IDU_ALU_i1_rs1                    (IDU_ALU_i1_rs1            ),
                              .IDU_ALU_i1_pc                     (IDU_ALU_i1_pc             ),
                              .IDU_ALU_i2_rs2                    (IDU_ALU_i2_rs2            ),
                              .IDU_ALU_i2_imm                    (IDU_ALU_i2_imm            ),
                              .IDU_ALU_i2_4                      (IDU_ALU_i2_4              ),
                              .IDU_ALU_i2_csr                    (IDU_ALU_i2_csr            ),
                              .IDU_jump                          (IDU_jump                  ),
                              .IDU_pc_plus_imm                   (IDU_pc_plus_imm           ),
                              .IDU_rs1_plus_imm                  (IDU_rs1_plus_imm          ),
                              .IDU_csr_plus_imm                  (IDU_csr_plus_imm          ),
                              .IDU_cmp_eq                        (IDU_cmp_eq                ),
                              .IDU_cmp_neq                       (IDU_cmp_neq               ),
                              .IDU_cmp_ge                        (IDU_cmp_ge                ),
                              .IDU_cmp_lt                        (IDU_cmp_lt                ),
                              .IDU_write_gpr                     (IDU_write_gpr             ),
                              .IDU_write_csr                     (IDU_write_csr             ),
                              .IDU_mem_to_reg                    (IDU_mem_to_reg            ),
                              .IDU_rv32_csrrs                    (IDU_rv32_csrrs            ),
                              .IDU_rv32_csrrw                    (IDU_rv32_csrrw            ),
                              .IDU_rv32_ecall                    (IDU_rv32_ecall            ),
                              .IDU_write_mem                     (IDU_write_mem             ),
                              .IDU_mem_byte                      (IDU_mem_byte              ),
                              .IDU_mem_half                      (IDU_mem_half              ),
                              .IDU_mem_word                      (IDU_mem_word              ),
                              .IDU_mem_byte_u                    (IDU_mem_byte_u            ),
                              .IDU_mem_half_u                    (IDU_mem_half_u            ),
                              .IDU_system_halt                   (IDU_system_halt           ),
                              .IDU_op_valid                      (IDU_op_valid              ) 
                            );




    logic                               BRANCH_flushID             ;
    logic                               FORWARD_stallEX            ;
    logic              [  31:0]         FORWARD_rs1_data_SEG       ;
    logic              [  31:0]         FORWARD_rs2_data_SEG       ;
    logic              [  31:0]         FORWARD_csr_rs_data_SEG    ;
    logic                               FORWARD_rs1_hazard_SEG     ;
    logic                               FORWARD_rs2_hazard_SEG     ;
    logic                               FORWARD_csr_rs_hazard_SEG  ;
    logic              [  31:0]         EXU_pc                     ;
    logic              [  31:0]         EXU_inst                   ;
    logic                               EXU_commit                 ;
    logic              [   4:0]         EXU_rd                     ;
    logic              [   4:0]         EXU_rs1                    ;
    logic              [   4:0]         EXU_rs2                    ;
    logic              [  31:0]         EXU_imm                    ;
    logic              [  31:0]         EXU_rs1_data               ;
    logic              [  31:0]         EXU_rs2_data               ;
    logic              [   1:0]         EXU_csr_rd                 ;
    logic              [   1:0]         EXU_csr_rs                 ;
    logic              [  31:0]         EXU_csr_rs_data            ;

    logic                               EXU_ALU_add                ;
    logic                               EXU_ALU_sub                ;
    logic                               EXU_ALU_slt                ;
    logic                               EXU_ALU_sltu               ;
    logic                               EXU_ALU_or                 ;
    logic                               EXU_ALU_and                ;
    logic                               EXU_ALU_xor                ;
    logic                               EXU_ALU_sll                ;
    logic                               EXU_ALU_srl                ;
    logic                               EXU_ALU_sra                ;
    logic                               EXU_ALU_explicit           ;
    logic                               EXU_ALU_i1_rs1             ;
    logic                               EXU_ALU_i1_pc              ;
    logic                               EXU_ALU_i2_rs2             ;
    logic                               EXU_ALU_i2_imm             ;
    logic                               EXU_ALU_i2_4               ;
    logic                               EXU_ALU_i2_csr             ;
    logic                               EXU_jump                   ;
    logic                               EXU_pc_plus_imm            ;
    logic                               EXU_rs1_plus_imm           ;
    logic                               EXU_csr_plus_imm           ;
    logic                               EXU_cmp_eq                 ;
    logic                               EXU_cmp_neq                ;
    logic                               EXU_cmp_ge                 ;
    logic                               EXU_cmp_lt                 ;
    logic                               EXU_write_gpr              ;
    logic                               EXU_write_csr              ;
    logic                               EXU_mem_to_reg             ;
    logic                               EXU_rv32_csrrs             ;
    logic                               EXU_rv32_csrrw             ;
    logic                               EXU_rv32_ecall             ;
    logic                               EXU_write_mem              ;
    logic                               EXU_mem_byte               ;
    logic                               EXU_mem_half               ;
    logic                               EXU_mem_word               ;
    logic                               EXU_mem_byte_u             ;
    logic                               EXU_mem_half_u             ;
    logic                               EXU_system_halt            ;
    logic                               EXU_op_valid               ;
                          
      

      IDU_EXU_SEG_REG_ysyx23060136  IDU_EXU_SEG_REG_ysyx23060136_inst (
                              .clk                               (clk                       ),
                              .rst                               (rst                       ),
                              .BRANCH_flushID                    (BRANCH_flushID            ),
                              .FORWARD_stallEX                   (FORWARD_stallEX           ),
                              .IDU_pc_EXU                        (IDU_pc_EXU                ),
                              .IDU_inst_EXU                      (IDU_inst_EXU              ),
                              .IDU_commit_EXU                    (IDU_commit_EXU            ),
                              .IDU_rd                            (IDU_rd                    ),
                              .IDU_rs1                           (IDU_rs1                   ),
                              .IDU_rs2                           (IDU_rs2                   ),
                              .IDU_imm                           (IDU_imm                   ),
                              .IDU_rs1_data                      (IDU_rs1_data              ),
                              .IDU_rs2_data                      (IDU_rs2_data              ),
                              .IDU_csr_rd                        (IDU_csr_rd                ),
                              .IDU_csr_rs                        (IDU_csr_rs                ),
                              .IDU_csr_rs_data                   (IDU_csr_rs_data           ),
                              .FORWARD_rs1_data_SEG              (FORWARD_rs1_data_SEG      ),
                              .FORWARD_rs2_data_SEG              (FORWARD_rs2_data_SEG      ),
                              .FORWARD_csr_rs_data_SEG           (FORWARD_csr_rs_data_SEG   ),
                              .FORWARD_rs1_hazard_SEG            (FORWARD_rs1_hazard_SEG    ),
                              .FORWARD_rs2_hazard_SEG            (FORWARD_rs2_hazard_SEG    ),
                              .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG ),
                              .EXU_pc                            (EXU_pc                    ),
                              .EXU_inst                          (EXU_inst                  ),
                              .EXU_commit                        (EXU_commit                ),
                              .EXU_rd                            (EXU_rd                    ),
                              .EXU_rs1                           (EXU_rs1                   ),
                              .EXU_rs2                           (EXU_rs2                   ),
                              .EXU_imm                           (EXU_imm                   ),
                              .EXU_rs1_data                      (EXU_rs1_data              ),
                              .EXU_rs2_data                      (EXU_rs2_data              ),
                              .EXU_csr_rd                        (EXU_csr_rd                ),
                              .EXU_csr_rs                        (EXU_csr_rs                ),
                              .EXU_csr_rs_data                   (EXU_csr_rs_data           ),
                              .IDU_ALU_add                       (IDU_ALU_add               ),
                              .IDU_ALU_sub                       (IDU_ALU_sub               ),
                              .IDU_ALU_slt                       (IDU_ALU_slt               ),
                              .IDU_ALU_sltu                      (IDU_ALU_sltu              ),
                              .IDU_ALU_or                        (IDU_ALU_or                ),
                              .IDU_ALU_and                       (IDU_ALU_and               ),
                              .IDU_ALU_xor                       (IDU_ALU_xor               ),
                              .IDU_ALU_sll                       (IDU_ALU_sll               ),
                              .IDU_ALU_srl                       (IDU_ALU_srl               ),
                              .IDU_ALU_sra                       (IDU_ALU_sra               ),
                              .IDU_ALU_explicit                  (IDU_ALU_explicit          ),
                              .IDU_ALU_i1_rs1                    (IDU_ALU_i1_rs1            ),
                              .IDU_ALU_i1_pc                     (IDU_ALU_i1_pc             ),
                              .IDU_ALU_i2_rs2                    (IDU_ALU_i2_rs2            ),
                              .IDU_ALU_i2_imm                    (IDU_ALU_i2_imm            ),
                              .IDU_ALU_i2_4                      (IDU_ALU_i2_4              ),
                              .IDU_ALU_i2_csr                    (IDU_ALU_i2_csr            ),
                              .EXU_ALU_add                       (EXU_ALU_add               ),
                              .EXU_ALU_sub                       (EXU_ALU_sub               ),
                              .EXU_ALU_slt                       (EXU_ALU_slt               ),
                              .EXU_ALU_sltu                      (EXU_ALU_sltu              ),
                              .EXU_ALU_or                        (EXU_ALU_or                ),
                              .EXU_ALU_and                       (EXU_ALU_and               ),
                              .EXU_ALU_xor                       (EXU_ALU_xor               ),
                              .EXU_ALU_sll                       (EXU_ALU_sll               ),
                              .EXU_ALU_srl                       (EXU_ALU_srl               ),
                              .EXU_ALU_sra                       (EXU_ALU_sra               ),
                              .EXU_ALU_explicit                  (EXU_ALU_explicit          ),
                              .EXU_ALU_i1_rs1                    (EXU_ALU_i1_rs1            ),
                              .EXU_ALU_i1_pc                     (EXU_ALU_i1_pc             ),
                              .EXU_ALU_i2_rs2                    (EXU_ALU_i2_rs2            ),
                              .EXU_ALU_i2_imm                    (EXU_ALU_i2_imm            ),
                              .EXU_ALU_i2_4                      (EXU_ALU_i2_4              ),
                              .EXU_ALU_i2_csr                    (EXU_ALU_i2_csr            ),
                              .IDU_jump                          (IDU_jump                  ),
                              .IDU_pc_plus_imm                   (IDU_pc_plus_imm           ),
                              .IDU_rs1_plus_imm                  (IDU_rs1_plus_imm          ),
                              .IDU_csr_plus_imm                  (IDU_csr_plus_imm          ),
                              .IDU_cmp_eq                        (IDU_cmp_eq                ),
                              .IDU_cmp_neq                       (IDU_cmp_neq               ),
                              .IDU_cmp_ge                        (IDU_cmp_ge                ),
                              .IDU_cmp_lt                        (IDU_cmp_lt                ),
                              .EXU_jump                          (EXU_jump                  ),
                              .EXU_pc_plus_imm                   (EXU_pc_plus_imm           ),
                              .EXU_rs1_plus_imm                  (EXU_rs1_plus_imm          ),
                              .EXU_csr_plus_imm                  (EXU_csr_plus_imm          ),
                              .EXU_cmp_eq                        (EXU_cmp_eq                ),
                              .EXU_cmp_neq                       (EXU_cmp_neq               ),
                              .EXU_cmp_ge                        (EXU_cmp_ge                ),
                              .EXU_cmp_lt                        (EXU_cmp_lt                ),
                              .IDU_write_gpr                     (IDU_write_gpr             ),
                              .IDU_write_csr                     (IDU_write_csr             ),
                              .IDU_mem_to_reg                    (IDU_mem_to_reg            ),
                              .IDU_rv32_csrrs                    (IDU_rv32_csrrs            ),
                              .IDU_rv32_csrrw                    (IDU_rv32_csrrw            ),
                              .IDU_rv32_ecall                    (IDU_rv32_ecall            ),
                              .EXU_write_gpr                     (EXU_write_gpr             ),
                              .EXU_write_csr                     (EXU_write_csr             ),
                              .EXU_mem_to_reg                    (EXU_mem_to_reg            ),
                              .EXU_rv32_csrrs                    (EXU_rv32_csrrs            ),
                              .EXU_rv32_csrrw                    (EXU_rv32_csrrw            ),
                              .EXU_rv32_ecall                    (EXU_rv32_ecall            ),
                              .IDU_write_mem                     (IDU_write_mem             ),
                              .IDU_mem_byte                      (IDU_mem_byte              ),
                              .IDU_mem_half                      (IDU_mem_half              ),
                              .IDU_mem_word                      (IDU_mem_word              ),
                              .IDU_mem_byte_u                    (IDU_mem_byte_u            ),
                              .IDU_mem_half_u                    (IDU_mem_half_u            ),
                              .EXU_write_mem                     (EXU_write_mem             ),
                              .EXU_mem_byte                      (EXU_mem_byte              ),
                              .EXU_mem_half                      (EXU_mem_half              ),
                              .EXU_mem_word                      (EXU_mem_word              ),
                              .EXU_mem_byte_u                    (EXU_mem_byte_u            ),
                              .EXU_mem_half_u                    (EXU_mem_half_u            ),
                              .IDU_system_halt                   (IDU_system_halt           ),
                              .IDU_op_valid                      (IDU_op_valid              ),
                              .EXU_system_halt                   (EXU_system_halt           ),
                              .EXU_op_valid                      (EXU_op_valid              ) 
  );

endmodule


