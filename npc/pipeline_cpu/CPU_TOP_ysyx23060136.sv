/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-29 08:39:12 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 08:47:45
 */

`include "DEFINES_ysyx23060136.sv"


// ===========================================================================
module CPU_TOP_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
        // 当 commit 被拉高时，说明当前指令有效，此时进行 diff test,并对异常信号进行检测
        output                              inst_commit                ,
        output             [  31:0]         pc_cur                     ,
        output             [  31:0]         inst                       ,
        
        output                              system_halt                ,
        output                              op_valid                   ,
        output                              ALU_valid             
    );

     assign     inst_commit   =            WB_o_commit             ;
     assign     pc_cur        =            WB_o_pc                 ;
     assign     inst          =            WB_o_inst               ;
     assign     system_halt   =            WB_o_system_halt        ;
     assign     op_valid      =            WB_o_op_valid           ;
     assign     ALU_valid     =            WB_o_ALU_valid          ;


    // ===========================================================================
    // IFU
    logic                                FORWARD_stallIF            ;
    logic               [  31:0]         BRANCH_branch_target       ;
    logic                                BRANCH_PCSrc               ;
    logic               [  31:0]         IFU_o_inst                 ;
    logic               [  31:0]         IFU_o_pc                   ;
    logic                                IFU_o_valid                ;

    IFU_TOP_ysyx23060136  IFU_TOP_ysyx23060136_inst (
                              .clk                               (clk                       ),
                              .rst                               (rst                       ),
                              .FORWARD_stallIF                   (FORWARD_stallIF           ),
                              .BRANCH_branch_target              (BRANCH_branch_target      ),
                              .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
                              .IFU_o_inst                        (IFU_o_inst                ),
                              .IFU_o_pc                          (IFU_o_pc                  ),
                              .IFU_o_valid                       (IFU_o_valid               )
                          );


    // ===========================================================================
    // IFU -> IDU
    logic                                BRANCH_flushIF             ;
    logic                                FORWARD_stallID            ;
    logic                                IDU_i_commit               ;
    logic               [  31:0]         IDU_i_pc                   ;
    logic               [  31:0]         IDU_i_inst                 ;


    IFU_IDU_SEG_REG_ysyx23060136  IFU_IDU_SEG_REG_ysyx23060136_inst (
                                    .clk                               (clk                       ),
                                    .rst                               (rst                       ),
                                    .BRANCH_flushIF                    (BRANCH_flushIF            ),
                                    .FORWARD_stallID                   (FORWARD_stallID           ),
                                    .IFU_o_pc                          (IFU_o_pc                    ),
                                    .IFU_o_inst                        (IFU_o_inst                  ),
                                    .IDU_i_commit                      (IDU_i_commit                ),
                                    .IDU_i_pc                          (IDU_i_pc                    ),
                                    .IDU_i_inst                        (IDU_i_inst                  )
                    );


    
    // ===========================================================================
    // IDU
    logic              [   4:0]         WB_o_rd                    ;
    logic                               WB_o_RegWr                 ;
    logic              [  31:0]         WB_o_rf_busW               ;
    logic              [   1:0]         WB_o_csr_rd                ;
    logic                               WB_o_CSRWr                 ;
    logic              [  31:0]         WB_o_csr_busW              ;

    logic              [  31:0]         IDU_o_pc                 ;
    logic              [  31:0]         IDU_o_inst               ;
    logic                               IDU_o_commit             ;
    logic              [   4:0]         IDU_o_rd                     ;
    logic              [   4:0]         IDU_o_rs1                    ;
    logic              [   4:0]         IDU_o_rs2                    ;
    logic              [  31:0]         IDU_o_imm                    ;
    logic              [  31:0]         IDU_o_rs1_data               ;
    logic              [  31:0]         IDU_o_rs2_data               ;
    logic              [   1:0]         IDU_o_csr_rd                 ;
    logic              [   1:0]         IDU_o_csr_rs                 ;
    logic              [  31:0]         IDU_o_csr_rs_data            ;
    logic                               IDU_o_ALU_add                ;
    logic                               IDU_o_ALU_sub                ;
    logic                               IDU_o_ALU_slt                ;
    logic                               IDU_o_ALU_sltu               ;
    logic                               IDU_o_ALU_or                 ;
    logic                               IDU_o_ALU_and                ;
    logic                               IDU_o_ALU_xor                ;
    logic                               IDU_o_ALU_sll                ;
    logic                               IDU_o_ALU_srl                ;
    logic                               IDU_o_ALU_sra                ;
    logic                               IDU_o_ALU_explicit           ;
    logic                               IDU_o_ALU_i1_rs1             ;
    logic                               IDU_o_ALU_i1_pc              ;
    logic                               IDU_o_ALU_i2_rs2             ;
    logic                               IDU_o_ALU_i2_imm             ;
    logic                               IDU_o_ALU_i2_4               ;
    logic                               IDU_o_ALU_i2_csr             ;
    logic                               IDU_o_jump                   ;
    logic                               IDU_o_pc_plus_imm            ;
    logic                               IDU_o_rs1_plus_imm           ;
    logic                               IDU_o_csr_plus_imm           ;
    logic                               IDU_o_cmp_eq                 ;
    logic                               IDU_o_cmp_neq                ;
    logic                               IDU_o_cmp_ge                 ;
    logic                               IDU_o_cmp_lt                 ;
    logic                               IDU_o_write_gpr              ;
    logic                               IDU_o_write_csr              ;


    logic                               IDU_o_mem_to_reg             ;
    logic                               IDU_o_rv32_csrrs             ;
    logic                               IDU_o_rv32_csrrw             ;
    logic                               IDU_o_rv32_ecall             ;
    logic                               IDU_o_write_mem              ;
    logic                               IDU_o_mem_byte               ;
    logic                               IDU_o_mem_half               ;
    logic                               IDU_o_mem_word               ;
    logic                               IDU_o_mem_byte_u             ;
    logic                               IDU_o_mem_half_u             ;
    logic                               IDU_o_system_halt            ;
    logic                               IDU_o_op_valid               ;



    IDU_TOP_ysyx23060136  IDU_TOP_ysyx23060136_inst (
                              .clk                               (clk                       ),
                              .rst                               (rst                       ),
                              .IDU_i_pc                          (IDU_i_pc                  ),
                              .IDU_i_inst                        (IDU_i_inst                ),
                              .IDU_i_commit                      (IDU_i_commit              ),
                              .WB_o_rd                           (WB_o_rd                   ),
                              .WB_o_RegWr                        (WB_o_RegWr                ),
                              .WB_o_rf_busW                      (WB_o_rf_busW              ),
                              .WB_o_csr_rd                       (WB_o_csr_rd               ),
                              .WB_o_CSRWr                        (WB_o_CSRWr                ),
                              .WB_o_csr_busW                     (WB_o_csr_busW             ),
                              .IDU_o_pc                          (IDU_o_pc                  ),
                              .IDU_o_inst                        (IDU_o_inst                ),
                              .IDU_o_commit                      (IDU_o_commit              ),
                              .IDU_o_rd                          (IDU_o_rd                  ),
                              .IDU_o_rs1                         (IDU_o_rs1                 ),
                              .IDU_o_rs2                         (IDU_o_rs2                 ),
                              .IDU_o_imm                         (IDU_o_imm                 ),
                              .IDU_o_rs1_data                    (IDU_o_rs1_data            ),
                              .IDU_o_rs2_data                    (IDU_o_rs2_data            ),
                              .IDU_o_csr_rd                      (IDU_o_csr_rd              ),
                              .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
                              .IDU_o_csr_rs_data                 (IDU_o_csr_rs_data         ),
                              .IDU_o_ALU_add                     (IDU_o_ALU_add             ),
                              .IDU_o_ALU_sub                     (IDU_o_ALU_sub             ),
                              .IDU_o_ALU_slt                     (IDU_o_ALU_slt             ),
                              .IDU_o_ALU_sltu                    (IDU_o_ALU_sltu            ),
                              .IDU_o_ALU_or                      (IDU_o_ALU_or              ),
                              .IDU_o_ALU_and                     (IDU_o_ALU_and             ),
                              .IDU_o_ALU_xor                     (IDU_o_ALU_xor             ),
                              .IDU_o_ALU_sll                     (IDU_o_ALU_sll             ),
                              .IDU_o_ALU_srl                     (IDU_o_ALU_srl             ),
                              .IDU_o_ALU_sra                     (IDU_o_ALU_sra             ),
                              .IDU_o_ALU_explicit                (IDU_o_ALU_explicit        ),
                              .IDU_o_ALU_i1_rs1                  (IDU_o_ALU_i1_rs1          ),
                              .IDU_o_ALU_i1_pc                   (IDU_o_ALU_i1_pc           ),
                              .IDU_o_ALU_i2_rs2                  (IDU_o_ALU_i2_rs2          ),
                              .IDU_o_ALU_i2_imm                  (IDU_o_ALU_i2_imm          ),
                              .IDU_o_ALU_i2_4                    (IDU_o_ALU_i2_4            ),
                              .IDU_o_ALU_i2_csr                  (IDU_o_ALU_i2_csr          ),
                              .IDU_o_jump                        (IDU_o_jump                ),
                              .IDU_o_pc_plus_imm                 (IDU_o_pc_plus_imm         ),
                              .IDU_o_rs1_plus_imm                (IDU_o_rs1_plus_imm        ),
                              .IDU_o_csr_plus_imm                (IDU_o_csr_plus_imm        ),
                              .IDU_o_cmp_eq                      (IDU_o_cmp_eq              ),
                              .IDU_o_cmp_neq                     (IDU_o_cmp_neq             ),
                              .IDU_o_cmp_ge                      (IDU_o_cmp_ge              ),
                              .IDU_o_cmp_lt                      (IDU_o_cmp_lt              ),
                              .IDU_o_write_gpr                   (IDU_o_write_gpr           ),
                              .IDU_o_write_csr                   (IDU_o_write_csr           ),
                              .IDU_o_mem_to_reg                  (IDU_o_mem_to_reg          ),
                              .IDU_o_rv32_csrrs                  (IDU_o_rv32_csrrs          ),
                              .IDU_o_rv32_csrrw                  (IDU_o_rv32_csrrw          ),
                              .IDU_o_rv32_ecall                  (IDU_o_rv32_ecall          ),
                              .IDU_o_write_mem                   (IDU_o_write_mem           ),
                              .IDU_o_mem_byte                    (IDU_o_mem_byte            ),
                              .IDU_o_mem_half                    (IDU_o_mem_half            ),
                              .IDU_o_mem_word                    (IDU_o_mem_word            ),
                              .IDU_o_mem_byte_u                  (IDU_o_mem_byte_u          ),
                              .IDU_o_mem_half_u                  (IDU_o_mem_half_u          ),
                              .IDU_o_system_halt                 (IDU_o_system_halt         ),
                              .IDU_o_op_valid                    (IDU_o_op_valid            )
                          );



    // ===========================================================================
    // IDU -> EXU
    logic                               BRANCH_flushID               ;
    logic                               FORWARD_stallEX              ;
    logic              [  31:0]         FORWARD_rs1_data_SEG         ;
    logic              [  31:0]         FORWARD_rs2_data_SEG         ;
    logic              [  31:0]         FORWARD_csr_rs_data_SEG      ;
    logic                               FORWARD_rs1_hazard_SEG       ;
    logic                               FORWARD_rs2_hazard_SEG       ;
    logic                               FORWARD_csr_rs_hazard_SEG    ;
    logic              [  31:0]         EXU_i_pc                     ;
    logic              [  31:0]         EXU_i_inst                   ;
    logic                               EXU_i_commit                 ;
    logic              [   4:0]         EXU_i_rd                     ;
    logic              [   4:0]         EXU_i_rs1                    ;
    logic              [   4:0]         EXU_i_rs2                    ;
    logic              [  31:0]         EXU_i_imm                    ;
    logic              [  31:0]         EXU_i_rs1_data               ;
    logic              [  31:0]         EXU_i_rs2_data               ;
    logic              [   1:0]         EXU_i_csr_rd                 ;
    logic              [   1:0]         EXU_i_csr_rs                 ;
    logic              [  31:0]         EXU_i_csr_rs_data            ;

    logic                               EXU_i_ALU_add                ;
    logic                               EXU_i_ALU_sub                ;
    logic                               EXU_i_ALU_slt                ;
    logic                               EXU_i_ALU_sltu               ;
    logic                               EXU_i_ALU_or                 ;
    logic                               EXU_i_ALU_and                ;
    logic                               EXU_i_ALU_xor                ;
    logic                               EXU_i_ALU_sll                ;
    logic                               EXU_i_ALU_srl                ;
    logic                               EXU_i_ALU_sra                ;
    logic                               EXU_i_ALU_explicit           ;
    logic                               EXU_i_ALU_i1_rs1             ;
    logic                               EXU_i_ALU_i1_pc              ;
    logic                               EXU_i_ALU_i2_rs2             ;
    logic                               EXU_i_ALU_i2_imm             ;
    logic                               EXU_i_ALU_i2_4               ;
    logic                               EXU_i_ALU_i2_csr             ;
    logic                               EXU_i_jump                   ;
    logic                               EXU_i_pc_plus_imm            ;
    logic                               EXU_i_rs1_plus_imm           ;
    logic                               EXU_i_csr_plus_imm           ;
    logic                               EXU_i_cmp_eq                 ;
    logic                               EXU_i_cmp_neq                ;
    logic                               EXU_i_cmp_ge                 ;
    logic                               EXU_i_cmp_lt                 ;
    logic                               EXU_i_write_gpr              ;
    logic                               EXU_i_write_csr              ;
    logic                               EXU_i_mem_to_reg             ;
    logic                               EXU_i_rv32_csrrs             ;
    logic                               EXU_i_rv32_csrrw             ;
    logic                               EXU_i_rv32_ecall             ;
    logic                               EXU_i_write_mem              ;
    logic                               EXU_i_mem_byte               ;
    logic                               EXU_i_mem_half               ;
    logic                               EXU_i_mem_word               ;
    logic                               EXU_i_mem_byte_u             ;
    logic                               EXU_i_mem_half_u             ;
    logic                               EXU_i_system_halt            ;
    logic                               EXU_i_op_valid               ;



    IDU_EXU_SEG_REG_ysyx23060136  IDU_EXU_SEG_REG_ysyx23060136_inst(
                                      .clk                               (clk                       ),
                                      .rst                               (rst                       ),
                                      .BRANCH_flushID                    (BRANCH_flushID            ),
                                      .FORWARD_stallEX                   (FORWARD_stallEX           ),
                                      .IDU_o_pc                          (IDU_o_pc                  ),
                                      .IDU_o_inst                        (IDU_o_inst                ),
                                      .IDU_o_commit                      (IDU_o_commit              ),
                                      .IDU_o_rd                          (IDU_o_rd                  ),
                                      .IDU_o_rs1                         (IDU_o_rs1                 ),
                                      .IDU_o_rs2                         (IDU_o_rs2                 ),
                                      .IDU_o_imm                         (IDU_o_imm                 ),
                                      .IDU_o_rs1_data                    (IDU_o_rs1_data            ),
                                      .IDU_o_rs2_data                    (IDU_o_rs2_data            ),
                                      .IDU_o_csr_rd                      (IDU_o_csr_rd              ),
                                      .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
                                      .IDU_o_csr_rs_data                 (IDU_o_csr_rs_data         ),
                                      .FORWARD_rs1_data_SEG              (FORWARD_rs1_data_SEG      ),
                                      .FORWARD_rs2_data_SEG              (FORWARD_rs2_data_SEG      ),
                                      .FORWARD_csr_rs_data_SEG           (FORWARD_csr_rs_data_SEG   ),
                                      .FORWARD_rs1_hazard_SEG            (FORWARD_rs1_hazard_SEG    ),
                                      .FORWARD_rs2_hazard_SEG            (FORWARD_rs2_hazard_SEG    ),
                                      .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG ),
                                      .EXU_i_pc                          (EXU_i_pc                  ),
                                      .EXU_i_inst                        (EXU_i_inst                ),
                                      .EXU_i_commit                      (EXU_i_commit              ),
                                      .EXU_i_rd                          (EXU_i_rd                  ),
                                      .EXU_i_rs1                         (EXU_i_rs1                 ),
                                      .EXU_i_rs2                         (EXU_i_rs2                 ),
                                      .EXU_i_imm                         (EXU_i_imm                 ),
                                      .EXU_i_rs1_data                    (EXU_i_rs1_data            ),
                                      .EXU_i_rs2_data                    (EXU_i_rs2_data            ),
                                      .EXU_i_csr_rd                      (EXU_i_csr_rd              ),
                                      .EXU_i_csr_rs                      (EXU_i_csr_rs              ),
                                      .EXU_i_csr_rs_data                 (EXU_i_csr_rs_data         ),
                                      .IDU_o_ALU_add                     (IDU_o_ALU_add             ),
                                      .IDU_o_ALU_sub                     (IDU_o_ALU_sub             ),
                                      .IDU_o_ALU_slt                     (IDU_o_ALU_slt             ),
                                      .IDU_o_ALU_sltu                    (IDU_o_ALU_sltu            ),
                                      .IDU_o_ALU_or                      (IDU_o_ALU_or              ),
                                      .IDU_o_ALU_and                     (IDU_o_ALU_and             ),
                                      .IDU_o_ALU_xor                     (IDU_o_ALU_xor             ),
                                      .IDU_o_ALU_sll                     (IDU_o_ALU_sll             ),
                                      .IDU_o_ALU_srl                     (IDU_o_ALU_srl             ),
                                      .IDU_o_ALU_sra                     (IDU_o_ALU_sra             ),
                                      .IDU_o_ALU_explicit                (IDU_o_ALU_explicit        ),
                                      .IDU_o_ALU_i1_rs1                  (IDU_o_ALU_i1_rs1          ),
                                      .IDU_o_ALU_i1_pc                   (IDU_o_ALU_i1_pc           ),
                                      .IDU_o_ALU_i2_rs2                  (IDU_o_ALU_i2_rs2          ),
                                      .IDU_o_ALU_i2_imm                  (IDU_o_ALU_i2_imm          ),
                                      .IDU_o_ALU_i2_4                    (IDU_o_ALU_i2_4            ),
                                      .IDU_o_ALU_i2_csr                  (IDU_o_ALU_i2_csr          ),
                                      .EXU_i_ALU_add                     (EXU_i_ALU_add             ),
                                      .EXU_i_ALU_sub                     (EXU_i_ALU_sub             ),
                                      .EXU_i_ALU_slt                     (EXU_i_ALU_slt             ),
                                      .EXU_i_ALU_sltu                    (EXU_i_ALU_sltu            ),
                                      .EXU_i_ALU_or                      (EXU_i_ALU_or              ),
                                      .EXU_i_ALU_and                     (EXU_i_ALU_and             ),
                                      .EXU_i_ALU_xor                     (EXU_i_ALU_xor             ),
                                      .EXU_i_ALU_sll                     (EXU_i_ALU_sll             ),
                                      .EXU_i_ALU_srl                     (EXU_i_ALU_srl             ),
                                      .EXU_i_ALU_sra                     (EXU_i_ALU_sra             ),
                                      .EXU_i_ALU_explicit                (EXU_i_ALU_explicit        ),
                                      .EXU_i_ALU_i1_rs1                  (EXU_i_ALU_i1_rs1          ),
                                      .EXU_i_ALU_i1_pc                   (EXU_i_ALU_i1_pc           ),
                                      .EXU_i_ALU_i2_rs2                  (EXU_i_ALU_i2_rs2          ),
                                      .EXU_i_ALU_i2_imm                  (EXU_i_ALU_i2_imm          ),
                                      .EXU_i_ALU_i2_4                    (EXU_i_ALU_i2_4            ),
                                      .EXU_i_ALU_i2_csr                  (EXU_i_ALU_i2_csr          ),
                                      .IDU_o_jump                        (IDU_o_jump                ),
                                      .IDU_o_pc_plus_imm                 (IDU_o_pc_plus_imm         ),
                                      .IDU_o_rs1_plus_imm                (IDU_o_rs1_plus_imm        ),
                                      .IDU_o_csr_plus_imm                (IDU_o_csr_plus_imm        ),
                                      .IDU_o_cmp_eq                      (IDU_o_cmp_eq              ),
                                      .IDU_o_cmp_neq                     (IDU_o_cmp_neq             ),
                                      .IDU_o_cmp_ge                      (IDU_o_cmp_ge              ),
                                      .IDU_o_cmp_lt                      (IDU_o_cmp_lt              ),
                                      .EXU_i_jump                        (EXU_i_jump                ),
                                      .EXU_i_pc_plus_imm                 (EXU_i_pc_plus_imm         ),
                                      .EXU_i_rs1_plus_imm                (EXU_i_rs1_plus_imm        ),
                                      .EXU_i_csr_plus_imm                (EXU_i_csr_plus_imm        ),
                                      .EXU_i_cmp_eq                      (EXU_i_cmp_eq              ),
                                      .EXU_i_cmp_neq                     (EXU_i_cmp_neq             ),
                                      .EXU_i_cmp_ge                      (EXU_i_cmp_ge              ),
                                      .EXU_i_cmp_lt                      (EXU_i_cmp_lt              ),
                                      .IDU_o_write_gpr                   (IDU_o_write_gpr           ),
                                      .IDU_o_write_csr                   (IDU_o_write_csr           ),
                                      .IDU_o_mem_to_reg                  (IDU_o_mem_to_reg          ),
                                      .IDU_o_rv32_csrrs                  (IDU_o_rv32_csrrs          ),
                                      .IDU_o_rv32_csrrw                  (IDU_o_rv32_csrrw          ),
                                      .IDU_o_rv32_ecall                  (IDU_o_rv32_ecall          ),
                                      .EXU_i_write_gpr                   (EXU_i_write_gpr           ),
                                      .EXU_i_write_csr                   (EXU_i_write_csr           ),
                                      .EXU_i_mem_to_reg                  (EXU_i_mem_to_reg          ),
                                      .EXU_i_rv32_csrrs                  (EXU_i_rv32_csrrs          ),
                                      .EXU_i_rv32_csrrw                  (EXU_i_rv32_csrrw          ),
                                      .EXU_i_rv32_ecall                  (EXU_i_rv32_ecall          ),
                                      .IDU_o_write_mem                   (IDU_o_write_mem           ),
                                      .IDU_o_mem_byte                    (IDU_o_mem_byte            ),
                                      .IDU_o_mem_half                    (IDU_o_mem_half            ),
                                      .IDU_o_mem_word                    (IDU_o_mem_word            ),
                                      .IDU_o_mem_byte_u                  (IDU_o_mem_byte_u          ),
                                      .IDU_o_mem_half_u                  (IDU_o_mem_half_u          ),
                                      .EXU_i_write_mem                   (EXU_i_write_mem           ),
                                      .EXU_i_mem_byte                    (EXU_i_mem_byte            ),
                                      .EXU_i_mem_half                    (EXU_i_mem_half            ),
                                      .EXU_i_mem_word                    (EXU_i_mem_word            ),
                                      .EXU_i_mem_byte_u                  (EXU_i_mem_byte_u          ),
                                      .EXU_i_mem_half_u                  (EXU_i_mem_half_u          ),
                                      .IDU_o_system_halt                 (IDU_o_system_halt         ),
                                      .IDU_o_op_valid                    (IDU_o_op_valid            ),
                                      .EXU_i_system_halt                 (EXU_i_system_halt         ),
                                      .EXU_i_op_valid                    (EXU_i_op_valid            )
                                  );


    // ===========================================================================
    // EXU
    logic              [  31:0]         EXU_o_pc                 ;
    logic              [  31:0]         EXU_o_inst               ;
    logic              [  31:0]         EXU_o_ALU_ALUout         ;
    logic              [  31:0]         EXU_o_ALU_CSR_out        ;
    logic                               EXU_o_commit             ;
    logic                               EXU_o_ALU_valid          ;
    logic              [   4:0]         EXU_o_rd                 ;
    logic              [   4:0]         EXU_o_rs1                ;
    logic              [   4:0]         EXU_o_rs2                ;
    logic              [  31:0]         EXU_o_HAZARD_rs2_data    ;
    logic              [   1:0]         EXU_o_csr_rd             ;
    logic              [   1:0]         EXU_o_csr_rs             ;
    logic                               EXU_o_write_gpr          ;
    logic                               EXU_o_write_csr          ;

    logic                               EXU_o_mem_to_reg         ;
    logic                               EXU_o_write_mem          ;
    logic                               EXU_o_mem_byte           ;
    logic                               EXU_o_mem_half           ;
    logic                               EXU_o_mem_word           ;
    logic                               EXU_o_mem_byte_u         ;
    logic                               EXU_o_mem_half_u         ;
    logic                               EXU_o_system_halt        ;
    logic                               EXU_o_op_valid           ;



    EXU_TOP_ysyx23060136  EXU_TOP_ysyx23060136_inst (
                              .EXU_i_pc                          (EXU_i_pc                  ),
                              .EXU_i_inst                        (EXU_i_inst                ),
                              .EXU_i_commit                      (EXU_i_commit              ),
                              .EXU_i_rd                          (EXU_i_rd                  ),
                              .EXU_i_rs1                         (EXU_i_rs1                 ),
                              .EXU_i_rs2                         (EXU_i_rs2                 ),
                              .EXU_i_imm                         (EXU_i_imm                 ),
                              .EXU_i_rs1_data                    (EXU_i_rs1_data            ),
                              .EXU_i_rs2_data                    (EXU_i_rs2_data            ),
                              .EXU_i_csr_rd                      (EXU_i_csr_rd              ),
                              .EXU_i_csr_rs                      (EXU_i_csr_rs              ),
                              .EXU_i_csr_rs_data                 (EXU_i_csr_rs_data         ),
                              .EXU_i_ALU_add                     (EXU_i_ALU_add             ),
                              .EXU_i_ALU_sub                     (EXU_i_ALU_sub             ),
                              .EXU_i_ALU_slt                     (EXU_i_ALU_slt             ),
                              .EXU_i_ALU_sltu                    (EXU_i_ALU_sltu            ),
                              .EXU_i_ALU_or                      (EXU_i_ALU_or              ),
                              .EXU_i_ALU_and                     (EXU_i_ALU_and             ),
                              .EXU_i_ALU_xor                     (EXU_i_ALU_xor             ),
                              .EXU_i_ALU_sll                     (EXU_i_ALU_sll             ),
                              .EXU_i_ALU_srl                     (EXU_i_ALU_srl             ),
                              .EXU_i_ALU_sra                     (EXU_i_ALU_sra             ),
                              .EXU_i_ALU_explicit                (EXU_i_ALU_explicit        ),
                              .EXU_i_ALU_i1_rs1                  (EXU_i_ALU_i1_rs1          ),
                              .EXU_i_ALU_i1_pc                   (EXU_i_ALU_i1_pc           ),
                              .EXU_i_ALU_i2_rs2                  (EXU_i_ALU_i2_rs2          ),
                              .EXU_i_ALU_i2_imm                  (EXU_i_ALU_i2_imm          ),
                              .EXU_i_ALU_i2_4                    (EXU_i_ALU_i2_4            ),
                              .EXU_i_ALU_i2_csr                  (EXU_i_ALU_i2_csr          ),
                              .EXU_i_jump                        (EXU_i_jump                ),
                              .EXU_i_pc_plus_imm                 (EXU_i_pc_plus_imm         ),
                              .EXU_i_rs1_plus_imm                (EXU_i_rs1_plus_imm        ),
                              .EXU_i_csr_plus_imm                (EXU_i_csr_plus_imm        ),
                              .EXU_i_cmp_eq                      (EXU_i_cmp_eq              ),
                              .EXU_i_cmp_neq                     (EXU_i_cmp_neq             ),
                              .EXU_i_cmp_ge                      (EXU_i_cmp_ge              ),
                              .EXU_i_cmp_lt                      (EXU_i_cmp_lt              ),
                              .EXU_i_write_gpr                   (EXU_i_write_gpr           ),
                              .EXU_i_write_csr                   (EXU_i_write_csr           ),
                              .EXU_i_mem_to_reg                  (EXU_i_mem_to_reg          ),
                              .EXU_i_rv32_csrrs                  (EXU_i_rv32_csrrs          ),
                              .EXU_i_rv32_csrrw                  (EXU_i_rv32_csrrw          ),
                              .EXU_i_rv32_ecall                  (EXU_i_rv32_ecall          ),
                              .EXU_i_write_mem                   (EXU_i_write_mem           ),
                              .EXU_i_mem_byte                    (EXU_i_mem_byte            ),
                              .EXU_i_mem_half                    (EXU_i_mem_half            ),
                              .EXU_i_mem_word                    (EXU_i_mem_word            ),
                              .EXU_i_mem_byte_u                  (EXU_i_mem_byte_u          ),
                              .EXU_i_mem_half_u                  (EXU_i_mem_half_u          ),
                              .EXU_i_system_halt                 (EXU_i_system_halt         ),
                              .EXU_i_op_valid                    (EXU_i_op_valid            ),
                              .FORWARD_rs1_data_EXU              (FORWARD_rs1_data_EXU      ),
                              .FORWARD_rs2_data_EXU              (FORWARD_rs2_data_EXU      ),
                              .FORWARD_csr_rs_data_EXU           (FORWARD_csr_rs_data_EXU   ),
                              .FORWARD_rs1_hazard_EXU            (FORWARD_rs1_hazard_EXU    ),
                              .FORWARD_rs2_hazard_EXU            (FORWARD_rs2_hazard_EXU    ),
                              .FORWARD_csr_rs_hazard_EXU         (FORWARD_csr_rs_hazard_EXU ),

                              .EXU_o_pc                          (EXU_o_pc                  ),
                              .EXU_o_inst                        (EXU_o_inst                ),
                              .EXU_o_ALU_ALUout                  (EXU_o_ALU_ALUout          ),
                              .EXU_o_ALU_CSR_out                 (EXU_o_ALU_CSR_out         ),
                              .EXU_o_commit                      (EXU_o_commit              ),
                              .BRANCH_branch_target              (BRANCH_branch_target      ),
                              .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
                              .BRANCH_flushIF                    (BRANCH_flushIF            ),
                              .BRANCH_flushID                    (BRANCH_flushID            ),
                              .EXU_o_ALU_valid                   (EXU_o_ALU_valid           ),
                              .EXU_o_rd                          (EXU_o_rd                  ),
                              .EXU_o_rs1                         (EXU_o_rs1                 ),
                              .EXU_o_rs2                         (EXU_o_rs2                 ),
                              .EXU_o_HAZARD_rs2_data             (EXU_o_HAZARD_rs2_data     ),
                              .EXU_o_csr_rd                      (EXU_o_csr_rd              ),
                              .EXU_o_csr_rs                      (EXU_o_csr_rs              ),
                              .EXU_o_write_gpr                   (EXU_o_write_gpr           ),
                              .EXU_o_write_csr                   (EXU_o_write_csr           ),
                              .EXU_o_mem_to_reg                  (EXU_o_mem_to_reg          ),
                              .EXU_o_write_mem                   (EXU_o_write_mem           ),
                              .EXU_o_mem_byte                    (EXU_o_mem_byte            ),
                              .EXU_o_mem_half                    (EXU_o_mem_half            ),
                              .EXU_o_mem_word                    (EXU_o_mem_word            ),
                              .EXU_o_mem_byte_u                  (EXU_o_mem_byte_u          ),
                              .EXU_o_mem_half_u                  (EXU_o_mem_half_u          ),
                              .EXU_o_system_halt                 (EXU_o_system_halt         ),
                              .EXU_o_op_valid                    (EXU_o_op_valid            ) 
                          );


    // ===========================================================================
    // EXU -> MEM
    logic                               FORWARD_flushEX    = `false  ;
    logic                               FORWARD_stallME              ; 
    logic                               MEM_i_commit                 ;
    logic              [  31:0]         MEM_i_pc                     ;
    logic              [  31:0]         MEM_i_inst                   ;
    logic              [  31:0]         MEM_i_ALU_ALUout             ;
    logic              [  31:0]         MEM_i_ALU_CSR_out            ;
    logic              [   4:0]         MEM_i_rd                     ;
    logic              [  31:0]         MEM_i_rs2_data               ;
    logic              [   1:0]         MEM_i_csr_rd                 ;
    logic                               MEM_i_write_gpr              ;
    logic                               MEM_i_write_csr              ;
    logic                               MEM_i_mem_to_reg             ;
    logic                               MEM_i_write_mem              ;
    logic                               MEM_i_mem_byte               ;
    logic                               MEM_i_mem_half               ;
    logic                               MEM_i_mem_word               ;
    logic                               MEM_i_mem_byte_u             ;
    logic                               MEM_i_mem_half_u             ;
    logic                               MEM_i_system_halt            ;
    logic                               MEM_i_op_valid               ;
    logic                               MEM_i_ALU_valid              ;


    EXU_MEM_SEG_REG_ysyx23060136  EXU_MEM_SEG_REG_ysyx23060136_inst (
                                      .clk                               (clk                       ),
                                      .rst                               (rst                       ),
                                      .FORWARD_flushEX                   (FORWARD_flushEX           ),
                                      .FORWARD_stallME                   (FORWARD_stallME           ),
                                      .EXU_o_commit                      (EXU_o_commit              ),
                                      .EXU_o_pc                          (EXU_o_pc                  ),
                                      .EXU_o_inst                        (EXU_o_inst                ),
                                      .EXU_o_ALU_ALUout                  (EXU_o_ALU_ALUout          ),
                                      .EXU_o_ALU_CSR_out                 (EXU_o_ALU_CSR_out         ),
                                      .EXU_o_rd                          (EXU_o_rd                  ),
                                      .EXU_o_HAZARD_rs2_data             (EXU_o_HAZARD_rs2_data     ),
                                      .EXU_o_csr_rd                      (EXU_o_csr_rd              ),
                                      .EXU_o_write_gpr                   (EXU_o_write_gpr           ),
                                      .EXU_o_write_csr                   (EXU_o_write_csr           ),
                                      .EXU_o_mem_to_reg                  (EXU_o_mem_to_reg          ),
                                      .EXU_o_write_mem                   (EXU_o_write_mem           ),
                                      .EXU_o_mem_byte                    (EXU_o_mem_byte            ),
                                      .EXU_o_mem_half                    (EXU_o_mem_half            ),
                                      .EXU_o_mem_word                    (EXU_o_mem_word            ),
                                      .EXU_o_mem_byte_u                  (EXU_o_mem_byte_u          ),
                                      .EXU_o_mem_half_u                  (EXU_o_mem_half_u          ),
                                      .EXU_o_system_halt                 (EXU_o_system_halt         ),
                                      .EXU_o_op_valid                    (EXU_o_op_valid            ),
                                      .EXU_o_ALU_valid                   (EXU_o_ALU_valid           ),

                                      .MEM_i_commit                      (MEM_i_commit              ),
                                      .MEM_i_pc                          (MEM_i_pc                  ),
                                      .MEM_i_inst                        (MEM_i_inst                ),
                                      .MEM_i_ALU_ALUout                  (MEM_i_ALU_ALUout          ),
                                      .MEM_i_ALU_CSR_out                 (MEM_i_ALU_CSR_out         ),
                                      .MEM_i_rd                          (MEM_i_rd                  ),
                                      .MEM_i_rs2_data                    (MEM_i_rs2_data            ),
                                      .MEM_i_csr_rd                      (MEM_i_csr_rd              ),
                                      .MEM_i_write_gpr                   (MEM_i_write_gpr           ),
                                      .MEM_i_write_csr                   (MEM_i_write_csr           ),
                                      .MEM_i_mem_to_reg                  (MEM_i_mem_to_reg          ),
                                      .MEM_i_write_mem                   (MEM_i_write_mem           ),
                                      .MEM_i_mem_byte                    (MEM_i_mem_byte            ),
                                      .MEM_i_mem_half                    (MEM_i_mem_half            ),
                                      .MEM_i_mem_word                    (MEM_i_mem_word            ),
                                      .MEM_i_mem_byte_u                  (MEM_i_mem_byte_u          ),
                                      .MEM_i_mem_half_u                  (MEM_i_mem_half_u          ),
                                      .MEM_i_system_halt                 (MEM_i_system_halt         ),
                                      .MEM_i_op_valid                    (MEM_i_op_valid            ),
                                      .MEM_i_ALU_valid                   (MEM_i_ALU_valid           )
                                  );


    // ===========================================================================
    // MEM

    logic              [  31:0]         WB_o_rs1_data                ;
    logic              [  31:0]         WB_o_rs2_data                ;
    logic              [  31:0]         WB_o_csr_rs_data             ;

  
    logic                               MEM_o_commit              ;
    logic              [  31:0]         MEM_o_pc                  ;
    logic              [  31:0]         MEM_o_inst                ;
    logic              [  31:0]         MEM_o_ALU_ALUout          ;
    logic              [  31:0]         MEM_o_ALU_CSR_out         ;
    logic              [  31:0]         MEM_o_rdata               ;
    logic                               MEM_o_write_gpr           ;
    logic                               MEM_o_write_csr           ;
    logic                               MEM_o_mem_to_reg          ;
    logic              [   4:0]         MEM_o_rd                  ;
    logic              [   1:0]         MEM_o_csr_rd              ;
    logic                               MEM_o_system_halt         ;
    logic                               MEM_o_op_valid            ;
    logic                               MEM_o_ALU_valid           ;

    logic              [  31:0]         FORWARD_rs1_data_EXU       ;
    logic              [  31:0]         FORWARD_rs2_data_EXU       ;
    logic              [  31:0]         FORWARD_csr_rs_data_EXU    ;
    logic                               FORWARD_rs1_hazard_EXU     ;
    logic                               FORWARD_rs2_hazard_EXU     ;
    logic                               FORWARD_csr_rs_hazard_EXU  ;

                            
    MEM_TOP_ysyx23060136  MEM_TOP_ysyx23060136_inst (
                              .clk                               (clk                       ),
                              .rst                               (rst                       ),

                              .IFU_o_valid                       (IFU_o_valid               ),
                              .IDU_o_rs1                         (IDU_o_rs1                 ),
                              .IDU_o_rs2                         (IDU_o_rs2                 ),
                              .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
                              .EXU_o_rs1                         (EXU_o_rs1                 ),
                              .EXU_o_rs2                         (EXU_o_rs2                 ),
                              .EXU_o_csr_rs                      (EXU_o_csr_rs              ),

                              .WB_o_rd                           (WB_o_rd                   ),
                              .WB_o_csr_rd                       (WB_o_csr_rd               ),
                              .WB_o_write_gpr                    (WB_o_RegWr                ),
                              .WB_o_write_csr                    (WB_o_CSRWr                ),
                              .WB_o_rs1_data                     (WB_o_rs1_data             ),
                              .WB_o_rs2_data                     (WB_o_rs2_data             ),
                              .WB_o_csr_rs_data                  (WB_o_csr_rs_data          ),

                              .MEM_i_commit                      (MEM_i_commit              ),
                              .MEM_i_pc                          (MEM_i_pc                  ),
                              .MEM_i_inst                        (MEM_i_inst                ),
                              .MEM_i_ALU_ALUout                  (MEM_i_ALU_ALUout          ),
                              .MEM_i_ALU_CSR_out                 (MEM_i_ALU_CSR_out         ),
                              .MEM_i_rd                          (MEM_i_rd                  ),
                              .MEM_i_rs2_data                    (MEM_i_rs2_data            ),
                              .MEM_i_csr_rd                      (MEM_i_csr_rd              ),
                              .MEM_i_write_gpr                   (MEM_i_write_gpr           ),
                              .MEM_i_write_csr                   (MEM_i_write_csr           ),
                              .MEM_i_mem_to_reg                  (MEM_i_mem_to_reg          ),
                              .MEM_i_write_mem                   (MEM_i_write_mem           ),
                              .MEM_i_mem_byte                    (MEM_i_mem_byte            ),
                              .MEM_i_mem_half                    (MEM_i_mem_half            ),
                              .MEM_i_mem_word                    (MEM_i_mem_word            ),
                              .MEM_i_mem_byte_u                  (MEM_i_mem_byte_u          ),
                              .MEM_i_mem_half_u                  (MEM_i_mem_half_u          ),
                              .MEM_i_system_halt                 (MEM_i_system_halt         ),
                              .MEM_i_op_valid                    (MEM_i_op_valid            ),
                              .MEM_i_ALU_valid                   (MEM_i_ALU_valid           ),

                              .MEM_o_commit                      (MEM_o_commit              ),
                              .MEM_o_pc                          (MEM_o_pc                  ),
                              .MEM_o_inst                        (MEM_o_inst                ),
                              .MEM_o_ALU_ALUout                  (MEM_o_ALU_ALUout          ),
                              .MEM_o_ALU_CSR_out                 (MEM_o_ALU_CSR_out         ),
                              .MEM_o_rdata                       (MEM_o_rdata               ),
                              .MEM_o_write_gpr                   (MEM_o_write_gpr           ),
                              .MEM_o_write_csr                   (MEM_o_write_csr           ),
                              .MEM_o_mem_to_reg                  (MEM_o_mem_to_reg          ),
                              .MEM_o_rd                          (MEM_o_rd                  ),
                              .MEM_o_csr_rd                      (MEM_o_csr_rd              ),
                              .MEM_o_system_halt                 (MEM_o_system_halt         ),
                              .MEM_o_op_valid                    (MEM_o_op_valid            ),
                              .MEM_o_ALU_valid                   (MEM_o_ALU_valid           ),

                              .FORWARD_stallIF                   (FORWARD_stallIF           ),
                              .FORWARD_stallID                   (FORWARD_stallID           ),
                              .FORWARD_stallME                   (FORWARD_stallME           ),
                              .FORWARD_flushME                   (FORWARD_flushME           ),
                              .FORWARD_stallEX                   (FORWARD_stallEX           ),
                              .FORWARD_rs1_data_EXU              (FORWARD_rs1_data_EXU      ),
                              .FORWARD_rs2_data_EXU              (FORWARD_rs2_data_EXU      ),
                              .FORWARD_csr_rs_data_EXU           (FORWARD_csr_rs_data_EXU   ),
                              .FORWARD_rs1_hazard_EXU            (FORWARD_rs1_hazard_EXU    ),
                              .FORWARD_rs2_hazard_EXU            (FORWARD_rs2_hazard_EXU    ),
                              .FORWARD_csr_rs_hazard_EXU         (FORWARD_csr_rs_hazard_EXU ),
                              .FORWARD_rs1_data_SEG              (FORWARD_rs1_data_SEG      ),
                              .FORWARD_rs2_data_SEG              (FORWARD_rs2_data_SEG      ),
                              .FORWARD_csr_rs_data_SEG           (FORWARD_csr_rs_data_SEG   ),
                              .FORWARD_rs1_hazard_SEG            (FORWARD_rs1_hazard_SEG    ),
                              .FORWARD_rs2_hazard_SEG            (FORWARD_rs2_hazard_SEG    ),
                              .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG )
                          );


    // ===========================================================================
    // MEM -> WB
    logic                               FORWARD_flushME              ;
    logic                               FORWARD_stallWB    = `false  ; 
    logic                               WB_i_commit                  ;
    logic              [  31:0]         WB_i_pc                      ;
    logic              [  31:0]         WB_i_inst                    ;
    logic              [  31:0]         WB_i_ALU_ALUout              ;
    logic              [  31:0]         WB_i_ALU_CSR_out             ;
    logic              [  31:0]         WB_i_rdata                   ;
    logic                               WB_i_mem_to_reg              ;
    logic                               WB_i_system_halt             ;
    logic                               WB_i_op_valid                ;
    logic                               WB_i_ALU_valid               ;
    logic                               WB_i_write_gpr               ;
    logic                               WB_i_write_csr               ;
    logic              [4 : 0]          WB_i_rd                      ;
    logic              [1 : 0]          WB_i_csr_rd                  ;
                        

    MEM_WB_SEG_REG_ysyx23060136  MEM_WB_SEG_REG_ysyx23060136_inst (
                                     .clk                               (clk                        ),
                                     .rst                               (rst                        ),
                                     .FORWARD_flushME                   (FORWARD_flushME            ),
                                     .FORWARD_stallWB                   (FORWARD_stallWB            ),
                                     .MEM_o_commit                      (MEM_o_commit               ),
                                     .MEM_o_pc                          (MEM_o_pc                   ),
                                     .MEM_o_inst                        (MEM_o_inst                 ),
                                     .MEM_o_ALU_ALUout                  (MEM_o_ALU_ALUout           ),
                                     .MEM_o_ALU_CSR_out                 (MEM_o_ALU_CSR_out          ),
                                     .MEM_o_rdata                       (MEM_o_rdata                ),
                                     .MEM_o_write_gpr                   (MEM_o_write_gpr            ),
                                     .MEM_o_write_csr                   (MEM_o_write_csr            ),
                                     .MEM_o_mem_to_reg                  (MEM_o_mem_to_reg           ),
                                     .MEM_o_rd                          (MEM_o_rd                   ),
                                     .MEM_o_csr_rd                      (MEM_o_csr_rd               ),
                                     .MEM_o_system_halt                 (MEM_o_system_halt          ),
                                     .MEM_o_op_valid                    (MEM_o_op_valid             ),
                                     .MEM_o_ALU_valid                   (MEM_o_ALU_valid            ),

                                     .WB_i_commit                       (WB_i_commit                 ),
                                     .WB_i_pc                           (WB_i_pc                     ),
                                     .WB_i_inst                         (WB_i_inst                   ),
                                     .WB_i_ALU_ALUout                   (WB_i_ALU_ALUout             ),
                                     .WB_i_ALU_CSR_out                  (WB_i_ALU_CSR_out            ),
                                     .WB_i_rdata                        (WB_i_rdata                  ),
                                     .WB_i_write_gpr                    (WB_i_write_gpr              ),
                                     .WB_i_write_csr                    (WB_i_write_csr              ),
                                     .WB_i_mem_to_reg                   (WB_i_mem_to_reg             ),
                                     .WB_i_rd                           (WB_i_rd                     ),
                                     .WB_i_csr_rd                       (WB_i_csr_rd                 ),
                                     .WB_i_system_halt                  (WB_i_system_halt            ),
                                     .WB_i_op_valid                     (WB_i_op_valid               ),
                                     .WB_i_ALU_valid                    (WB_i_ALU_valid              )
            );


                               
    // ===========================================================================
    // WBU
    logic                              WB_o_commit        ;
    logic             [  31:0]         WB_o_pc            ;
    logic             [  31:0]         WB_o_inst          ;
    logic                              WB_o_system_halt   ;
    logic                              WB_o_op_valid      ;
    logic                              WB_o_ALU_valid     ;


    WB_TOP_ysyx23060136  WB_TOP_ysyx23060136_inst (
                             .WB_i_commit                         (WB_i_commit                 ),
                             .WB_i_pc                             (WB_i_pc                     ),
                             .WB_i_inst                           (WB_i_inst                   ),
                             .WB_i_ALU_ALUout                     (WB_i_ALU_ALUout             ),
                             .WB_i_ALU_CSR_out                    (WB_i_ALU_CSR_out            ),
                             .WB_i_rdata                          (WB_i_rdata                  ),
                             .WB_i_rd                             (WB_i_rd                     ),
                             .WB_i_csr_rd                         (WB_i_csr_rd                 ),
                             .WB_i_write_gpr                      (WB_i_write_gpr              ),
                             .WB_i_write_csr                      (WB_i_write_csr              ),
                             .WB_i_mem_to_reg                     (WB_i_mem_to_reg             ),
                             .WB_i_system_halt                    (WB_i_system_halt            ),
                             .WB_i_op_valid                       (WB_i_op_valid               ),
                             .WB_i_ALU_valid                      (WB_i_ALU_valid              ),

                             .WB_o_rf_busW                        (WB_o_rf_busW                ),
                             .WB_o_csr_busW                       (WB_o_csr_busW               ),
                             .WB_o_rd                             (WB_o_rd                     ),
                             .WB_o_csr_rd                         (WB_o_csr_rd                 ),

                             .WB_o_rs1_data                       (WB_o_rs1_data               ),
                             .WB_o_rs2_data                       (WB_o_rs2_data               ),
                             .WB_o_csr_rs_data                    (WB_o_csr_rs_data            ),

                             .WB_o_RegWr                          (WB_o_RegWr                  ),
                             .WB_o_CSRWr                          (WB_o_CSRWr                  ),
                             .WB_o_commit                         (WB_o_commit                 ),
                             .WB_o_system_halt                    (WB_o_system_halt            ),
                             .WB_o_op_valid                       (WB_o_op_valid               ),
                             .WB_o_ALU_valid                      (WB_o_ALU_valid              ),
                             .WB_o_pc                             (WB_o_pc                     ),
                             .WB_o_inst                           (WB_o_inst                   )
                         );
endmodule


