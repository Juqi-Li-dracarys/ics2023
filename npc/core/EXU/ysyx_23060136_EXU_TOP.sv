/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 16:26:18 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 20:42:56
 */


 `include "ysyx_23060136_DEFINES.sv"


// Top module of EXU
// ===========================================================================
module ysyx_23060136_EXU_TOP (
        input                                                     clk                          ,
        input                                                     rst                          ,

        input                                                     FORWARD_stallEX2             ,
        input                                                     FORWARD_flushEX1             ,

        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_pc                     ,
        input              [  `ysyx_23060136_INST_W-1 :0]         EXU_i_inst                   ,
        input                                                     EXU_i_commit                 ,
        input                                                     EXU_i_pre_take               ,

        input              [  `ysyx_23060136_GPR_W-1  :0]         EXU_i_rd                     ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_imm                    ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_rs1_data               ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_rs2_data               ,
        input              [  `ysyx_23060136_CSR_W-1:0  ]         EXU_i_csr_rd_1               ,
        input              [  `ysyx_23060136_CSR_W-1:0  ]         EXU_i_csr_rd_2               ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         EXU_i_csr_rs_data            ,

        // ===========================================================================
        // ALU
        input                                                     EXU_i_ALU_word_t             ,
        input                                                     EXU_i_ALU_add                ,
        input                                                     EXU_i_ALU_sub                ,
        input                                                     EXU_i_ALU_slt                ,
        input                                                     EXU_i_ALU_sltu               ,
        input                                                     EXU_i_ALU_or                 ,
        input                                                     EXU_i_ALU_and                ,
        input                                                     EXU_i_ALU_xor                ,
        input                                                     EXU_i_ALU_sll                ,
        input                                                     EXU_i_ALU_srl                ,
        input                                                     EXU_i_ALU_sra                ,
        input                                                     EXU_i_ALU_mul                ,
        input                                                     EXU_i_ALU_mul_hi             ,
        input                                                     EXU_i_ALU_mul_u              ,
        input                                                     EXU_i_ALU_mul_s              ,
        input                                                     EXU_i_ALU_mul_su             ,
        input                                                     EXU_i_ALU_div                ,
        input                                                     EXU_i_ALU_div_u              ,
        input                                                     EXU_i_ALU_div_s              ,
        input                                                     EXU_i_ALU_rem                ,
        input                                                     EXU_i_ALU_rem_u              ,
        input                                                     EXU_i_ALU_rem_s              ,
        input                                                     EXU_i_ALU_explicit           ,
        
        input                                                     EXU_i_ALU_i1_rs1             ,
        input                                                     EXU_i_ALU_i1_pc              ,
        input                                                     EXU_i_ALU_i2_rs2             ,
        input                                                     EXU_i_ALU_i2_imm             ,
        input                                                     EXU_i_ALU_i2_4               ,
        input                                                     EXU_i_ALU_i2_csr             ,
        // ===========================================================================
        input                                                     EXU_i_jump                   ,
        input                                                     EXU_i_pc_plus_imm            ,
        input                                                     EXU_i_rs1_plus_imm           ,
        input                                                     EXU_i_csr_plus_imm           ,
        input                                                     EXU_i_cmp_eq                 ,
        input                                                     EXU_i_cmp_neq                ,
        input                                                     EXU_i_cmp_ge                 ,
        input                                                     EXU_i_cmp_lt                 ,

        input                                                     EXU_i_write_gpr              ,
        input                                                     EXU_i_write_csr_1            ,
        input                                                     EXU_i_write_csr_2            ,
        input                                                     EXU_i_mem_to_reg             ,
        input                                                     EXU_i_rv64_csrrs             ,
        input                                                     EXU_i_rv64_csrrw             ,
        input                                                     EXU_i_rv64_ecall             ,

        input                                                     EXU_i_write_mem              ,
        input                                                     EXU_i_mem_byte               ,
        input                                                     EXU_i_mem_half               ,
        input                                                     EXU_i_mem_word               ,
        input                                                     EXU_i_mem_dword              ,
        input                                                     EXU_i_mem_byte_u             ,
        input                                                     EXU_i_mem_half_u             ,
        input                                                     EXU_i_mem_word_u             ,

        input                                                     EXU_i_system_halt            ,

        // Forward to ALU input
        input              [  `ysyx_23060136_BITS_W-1 :0]         FORWARD_rs1_data_EXU1       ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         FORWARD_rs2_data_EXU1       ,
        input              [  `ysyx_23060136_BITS_W-1 :0]         FORWARD_csr_rs_data_EXU1    ,
        input                                                     FORWARD_rs1_hazard_EXU1     ,
        input                                                     FORWARD_rs2_hazard_EXU1     ,
        input                                                     FORWARD_csr_rs_hazard_EXU1  ,
        
        // ===========================================================================
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_pc                   ,
        output             [  `ysyx_23060136_INST_W-1 :0]         EXU_o_inst                 ,
        output             [  `ysyx_23060136_BITS_W-1 :0]         BHT_pc                     ,

        output                                                    BHT_pre_true               ,
        output                                                    BHT_pre_false              ,
   
        // mem
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_ALU_ALUout           ,
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_ALU_CSR_out          ,
        output                                                    EXU_o_commit               ,
        // IFU
        output             [  `ysyx_23060136_BITS_W-1 :0]         BRANCH_branch_target       ,
        output                                                    BRANCH_PCSrc               ,
        output                                                    BRANCH_flushIF             ,
        output                                                    BRANCH_flushID             ,
        // ===========================================================================
        // origin signal pushed to the next stage
        // mem
        output             [   `ysyx_23060136_GPR_W-1:0]          EXU_o_rd                 ,
        // mem write data
        output             [  `ysyx_23060136_BITS_W-1 :0]         EXU_o_HAZARD_rs2_data    ,
        output             [   `ysyx_23060136_CSR_W-1:0]          EXU_o_csr_rd_1           ,
        output             [   `ysyx_23060136_CSR_W-1:0]          EXU_o_csr_rd_2           ,
        // forward unit
        // mem
        output                                                    EXU_o_write_gpr          ,
        output                                                    EXU_o_write_csr_1        ,
        output                                                    EXU_o_write_csr_2        ,
        output                                                    EXU_o_mem_to_reg         ,

        output                                                    EXU_o_write_mem          ,
        output                                                    EXU_o_mem_byte           ,
        output                                                    EXU_o_mem_half           ,
        output                                                    EXU_o_mem_word           ,
        output                                                    EXU_o_mem_dword          ,
        output                                                    EXU_o_mem_byte_u         ,
        output                                                    EXU_o_mem_half_u         ,
        output                                                    EXU_o_mem_word_u         ,

        output                                                    EXU_o_system_halt        ,
        output                                                    EXU_o_valid                

    );

    // internal signal
    wire        [`ysyx_23060136_BITS_W-1  : 0]      HAZARD_rs1_data_EXU1;
    wire        [`ysyx_23060136_BITS_W-1  : 0]      HAZARD_rs2_data_EXU1;
    wire        [`ysyx_23060136_BITS_W-1  : 0]      HAZARD_csr_rs_data_EXU1;

    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU_ALU_da;
    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU_ALU_db;

    wire                                            EXU_ALU_Less;
    wire                                            EXU_ALU_Zero;


    wire                                            BRANCH_flushEX1;

    wire        [`ysyx_23060136_BITS_W-1  : 0]      EXU2_HAZARD_rs1_data ;


    ysyx_23060136_EXU_HAZARD  ysyx_23060136_EXU_HAZARD_inst (
        .EXU1_rs1_data                     (EXU_i_rs1_data            ),
        .EXU1_rs2_data                     (EXU_i_rs2_data            ),
        .EXU1_csr_rs_data                  (EXU_i_csr_rs_data         ),
        .EXU1_pc                           (EXU_i_pc                  ),
        .EXU1_imm                          (EXU_i_imm                 ),

        .FORWARD_rs1_data_EXU1             (FORWARD_rs1_data_EXU1     ),
        .FORWARD_rs2_data_EXU1             (FORWARD_rs2_data_EXU1     ),
        .FORWARD_csr_rs_data_EXU1          (FORWARD_csr_rs_data_EXU1  ),

        .FORWARD_rs1_hazard_EXU1           (FORWARD_rs1_hazard_EXU1   ),
        .FORWARD_rs2_hazard_EXU1           (FORWARD_rs2_hazard_EXU1   ),
        .FORWARD_csr_rs_hazard_EXU1        (FORWARD_csr_rs_hazard_EXU1),
        
        .HAZARD_rs1_data_EXU1              (HAZARD_rs1_data_EXU1      ),
        .HAZARD_rs2_data_EXU1              (HAZARD_rs2_data_EXU1      ),
        .HAZARD_csr_rs_data_EXU1           (HAZARD_csr_rs_data_EXU1   ),
        
        .EXU1_ALU_i1_rs1                   (EXU_i_ALU_i1_rs1          ),
        .EXU1_ALU_i1_pc                    (EXU_i_ALU_i1_pc           ),
        .EXU1_ALU_i2_rs2                   (EXU_i_ALU_i2_rs2          ),
        .EXU1_ALU_i2_imm                   (EXU_i_ALU_i2_imm          ),
        .EXU1_ALU_i2_4                     (EXU_i_ALU_i2_4            ),
        .EXU1_ALU_i2_csr                   (EXU_i_ALU_i2_csr          ),
        .EXU1_ALU_da                       (EXU_ALU_da                ),
        .EXU1_ALU_db                       (EXU_ALU_db                ) 
  );


  ysyx_23060136_EXU_ALU  ysyx_23060136_EXU_ALU_inst (
    .clk                               (clk                       ),
    .rst                               (rst                       ),
    .BRANCH_flushEX1                   (BRANCH_flushEX1           ),
    .FORWARD_flushEX1                  (FORWARD_flushEX1           ),
    .FORWARD_stallEX2                  (FORWARD_stallEX2          ),
    .EXU_ALU_da                        (EXU_ALU_da                ),
    .EXU_ALU_db                        (EXU_ALU_db                ),
    .EXU_i_ALU_word_t                  (EXU_i_ALU_word_t          ),
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
    .EXU_i_ALU_mul                     (EXU_i_ALU_mul             ),
    .EXU_i_ALU_mul_hi                  (EXU_i_ALU_mul_hi          ),
    .EXU_i_ALU_mul_u                   (EXU_i_ALU_mul_u           ),
    .EXU_i_ALU_mul_s                   (EXU_i_ALU_mul_s           ),
    .EXU_i_ALU_mul_su                  (EXU_i_ALU_mul_su          ),
    .EXU_i_ALU_div                     (EXU_i_ALU_div             ),
    .EXU_i_ALU_div_u                   (EXU_i_ALU_div_u           ),
    .EXU_i_ALU_div_s                   (EXU_i_ALU_div_s           ),
    .EXU_i_ALU_rem                     (EXU_i_ALU_rem             ),
    .EXU_i_ALU_rem_u                   (EXU_i_ALU_rem_u           ),
    .EXU_i_ALU_rem_s                   (EXU_i_ALU_rem_s           ),
    .EXU_i_ALU_explicit                (EXU_i_ALU_explicit        ),
    .ALU_valid                         (EXU_o_valid               ),
    .EXU_ALU_Less                      (EXU_ALU_Less              ),
    .EXU_ALU_Zero                      (EXU_ALU_Zero              ),
    .EXU_ALU_ALUout                    (EXU_o_ALU_ALUout          ),
    .mul_valid                         (mul_valid                 ),
    .mulw                              (mulw                      ),
    .mul_signed                        (mul_signed                ),
    .multiplicand                      (multiplicand              ),
    .multiplier                        (multiplier                ),
    .mul_ready                         (mul_ready                 ),
    .mul_out_valid                     (mul_out_valid             ),
    .result_hi                         (result_hi                 ),
    .result_lo                         (result_lo                 ),
    .div_valid                         (div_valid                 ),
    .dividend                          (dividend                  ),
    .divisor                           (divisor                   ),
    .divw                              (divw                      ),
    .div_signed                        (div_signed                ),
    .div_ready                         (div_ready                 ),
    .div_out_valid                     (div_out_valid             ),
    .quotient                          (quotient                  ),
    .remainder                         (remainder                 ),
    .EXU_pc                            (EXU_i_pc                  ),
    .EXU_HAZARD_rs1_data               (HAZARD_rs1_data_EXU1      ),
    .EXU_HAZARD_csr_rs_data            (HAZARD_csr_rs_data_EXU1   ),
    .EXU_rv64_csrrs                    (EXU_i_rv64_csrrs          ),
    .EXU_rv64_csrrw                    (EXU_i_rv64_csrrw          ),
    .EXU_rv64_ecall                    (EXU_i_rv64_ecall          ),
    .EXU_ALU_CSR_out                   (EXU_o_ALU_CSR_out         ) 
  );


  wire              EXU2_pre_take           ;

  ysyx_23060136_EXU_SEG  ysyx_23060136_EXU_SEG_inst (
        .clk                               (clk                        ),
        .rst                               (rst                        ),
        .BRANCH_flushEX1                   (BRANCH_flushEX1            ),
        .FORWARD_flushEX1                  (FORWARD_flushEX1           ),
        .FORWARD_stallEX2                  (FORWARD_stallEX2           ),
        .EXU1_pc                           (EXU_i_pc                   ),
        .EXU1_inst                         (EXU_i_inst                 ),
        .EXU1_commit                       (EXU_i_commit               ),
        .EXU_i_pre_take                    (EXU_i_pre_take             ),

        .EXU1_rd                           (EXU_i_rd                   ),
        .EXU1_csr_rd_1                     (EXU_i_csr_rd_1             ),
        .EXU1_csr_rd_2                     (EXU_i_csr_rd_2             ),

        .EXU1_HAZARD_rs1_data              (HAZARD_rs1_data_EXU1       ),
        .EXU1_HAZARD_rs2_data              (HAZARD_rs2_data_EXU1       ),
        .EXU1_HAZARD_csr_rs_data           (HAZARD_csr_rs_data_EXU1    ),
        .EXU1_imm                          (EXU_i_imm                  ),
        .EXU1_jump                         (EXU_i_jump                 ),
        .EXU1_pc_plus_imm                  (EXU_i_pc_plus_imm          ),
        .EXU1_rs1_plus_imm                 (EXU_i_rs1_plus_imm         ),
        .EXU1_csr_plus_imm                 (EXU_i_csr_plus_imm         ),
        .EXU1_cmp_eq                       (EXU_i_cmp_eq               ),
        .EXU1_cmp_neq                      (EXU_i_cmp_neq              ),
        .EXU1_cmp_ge                       (EXU_i_cmp_ge               ),
        .EXU1_cmp_lt                       (EXU_i_cmp_lt               ),
        .EXU1_write_gpr                    (EXU_i_write_gpr            ),
        .EXU1_write_csr_1                  (EXU_i_write_csr_1          ),
        .EXU1_write_csr_2                  (EXU_i_write_csr_2          ),
        .EXU1_mem_to_reg                   (EXU_i_mem_to_reg           ),
        .EXU1_write_mem                    (EXU_i_write_mem            ),
        .EXU1_mem_byte                     (EXU_i_mem_byte             ),
        .EXU1_mem_half                     (EXU_i_mem_half             ),
        .EXU1_mem_word                     (EXU_i_mem_word             ),
        .EXU1_mem_dword                    (EXU_i_mem_dword            ),
        .EXU1_mem_byte_u                   (EXU_i_mem_byte_u           ),
        .EXU1_mem_half_u                   (EXU_i_mem_half_u           ),
        .EXU1_mem_word_u                   (EXU_i_mem_word_u           ),
        .EXU1_system_halt                  (EXU_i_system_halt          ),

        .EXU2_pc                           (EXU_o_pc                   ),
        .EXU2_inst                         (EXU_o_inst                 ),
        .EXU2_commit                       (EXU_o_commit               ),
        .EXU2_pre_take                     (EXU2_pre_take              ),

        .EXU2_rd                           (EXU_o_rd                    ), 
        .EXU2_csr_rd_1                     (EXU_o_csr_rd_1              ), 
        .EXU2_csr_rd_2                     (EXU_o_csr_rd_2              ), 

        .EXU2_HAZARD_rs1_data              (EXU2_HAZARD_rs1_data       ),
        .EXU2_HAZARD_rs2_data              (EXU_o_HAZARD_rs2_data      ),
        .EXU2_HAZARD_csr_rs_data           (EXU2_HAZARD_csr_rs_data    ),
        .EXU2_imm                          (EXU2_imm                   ),
        .EXU2_jump                         (EXU2_jump                  ),
        .EXU2_pc_plus_imm                  (EXU2_pc_plus_imm           ),
        .EXU2_rs1_plus_imm                 (EXU2_rs1_plus_imm          ),
        .EXU2_csr_plus_imm                 (EXU2_csr_plus_imm          ),
        .EXU2_cmp_eq                       (EXU2_cmp_eq                ),
        .EXU2_cmp_neq                      (EXU2_cmp_neq               ),
        .EXU2_cmp_ge                       (EXU2_cmp_ge                ),
        .EXU2_cmp_lt                       (EXU2_cmp_lt                ),
        .EXU2_write_gpr                    (EXU_o_write_gpr            ),
        .EXU2_write_csr_1                  (EXU_o_write_csr_1          ),
        .EXU2_write_csr_2                  (EXU_o_write_csr_2          ),
        .EXU2_mem_to_reg                   (EXU_o_mem_to_reg           ),
        .EXU2_write_mem                    (EXU_o_write_mem            ),
        .EXU2_mem_byte                     (EXU_o_mem_byte             ),
        .EXU2_mem_half                     (EXU_o_mem_half             ),
        .EXU2_mem_word                     (EXU_o_mem_word             ),
        .EXU2_mem_dword                    (EXU_o_mem_dword            ),
        .EXU2_mem_byte_u                   (EXU_o_mem_byte_u           ),
        .EXU2_mem_half_u                   (EXU_o_mem_half_u           ),
        .EXU2_mem_word_u                   (EXU_o_mem_word_u           ),
        .EXU2_system_halt                  (EXU_o_system_halt          ) 
  );


    wire   [`ysyx_23060136_BITS_W-1  : 0]            EXU2_HAZARD_csr_rs_data  ;
    wire   [`ysyx_23060136_BITS_W-1  : 0]            EXU2_imm                 ;
    wire                                             EXU2_jump                ;
    wire                                             EXU2_pc_plus_imm         ;
    wire                                             EXU2_rs1_plus_imm        ;
    wire                                             EXU2_csr_plus_imm        ;
    wire                                             EXU2_cmp_eq              ;
    wire                                             EXU2_cmp_neq             ;
    wire                                             EXU2_cmp_ge              ;
    wire                                             EXU2_cmp_lt              ;
    

    ysyx_23060136_EXU_BRANCH  ysyx_23060136_EXU_BRANCH_inst (
        .EXU2_pc                           (EXU_o_pc                  ),
        .EXU2_HAZARD_rs1_data              (EXU2_HAZARD_rs1_data      ),
        .EXU2_HAZARD_csr_rs_data           (EXU2_HAZARD_csr_rs_data   ),
        .EXU2_imm                          (EXU2_imm                  ),
        .EXU2_ALU_Less                     (EXU_ALU_Less              ),
        .EXU2_ALU_Zero                     (EXU_ALU_Zero              ),
        .EXU2_jump                         (EXU2_jump                 ),
        .EXU2_pc_plus_imm                  (EXU2_pc_plus_imm          ),
        .EXU2_rs1_plus_imm                 (EXU2_rs1_plus_imm         ),
        .EXU2_csr_plus_imm                 (EXU2_csr_plus_imm         ),
        .EXU2_cmp_eq                       (EXU2_cmp_eq               ),
        .EXU2_cmp_neq                      (EXU2_cmp_neq              ),
        .EXU2_cmp_ge                       (EXU2_cmp_ge               ),
        .EXU2_cmp_lt                       (EXU2_cmp_lt               ),
        .branch_target                     (BRANCH_branch_target      ),
        .PCSrc                             (BRANCH_PCSrc              ),
        .BRANCH_flushIF                    (BRANCH_flushIF            ),
        .BRANCH_flushID                    (BRANCH_flushID            ),
        .BRANCH_flushEX1                   (BRANCH_flushEX1           ),
        .EXU2_pre_take                     (EXU2_pre_take             ),
        .BHT_pc                            (BHT_pc                    ),        
        .BHT_pre_true                      (BHT_pre_true              ),
        .BHT_pre_false                     (BHT_pre_false             )
  );


    wire                                    mul_valid         ; 
    wire                                    mulw              ; 
    wire  [1 : 0]                           mul_signed        ; 
    wire  [`ysyx_23060136_BITS_W-1  : 0]    multiplicand      ; 
    wire  [`ysyx_23060136_BITS_W-1  : 0]    multiplier        ; 
    wire                                    mul_ready         ; 
    wire                                    mul_out_valid     ; 
    wire  [`ysyx_23060136_BITS_W-1  : 0]    result_hi         ; 
    wire  [`ysyx_23060136_BITS_W-1  : 0]    result_lo         ; 


  ysyx_23060136_EXU_MUL  ysyx_23060136_EXU_MUL_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .mul_valid                         (mul_valid                 ),
        .mulw                              (mulw                      ),
        .mul_signed                        (mul_signed                ),
        .multiplicand                      (multiplicand              ),
        .multiplier                        (multiplier                ),
        .mul_ready                         (mul_ready                 ),
        .mul_out_valid                     (mul_out_valid             ),
        .result_hi                         (result_hi                 ),
        .result_lo                         (result_lo                 ) 
  );



     wire                                        div_valid      ; 
     wire   [`ysyx_23060136_BITS_W-1  : 0]       dividend       ; 
     wire   [`ysyx_23060136_BITS_W-1  : 0]       divisor        ; 
     wire                                        divw           ; 
     wire                                        div_signed     ; 
     wire                                        div_ready      ; 
     wire                                        div_out_valid  ; 
     wire   [`ysyx_23060136_BITS_W-1  : 0]       quotient       ; 
     wire   [`ysyx_23060136_BITS_W-1  : 0]       remainder      ; 



  ysyx_23060136_EXU_DIV  ysyx_23060136_EXU_DIV_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .dividend                          (dividend                  ),
        .divisor                           (divisor                   ),
        .div_valid                         (div_valid                 ),
        .divw                              (divw                      ),
        .div_signed                        (div_signed                ),
        .div_ready                         (div_ready                 ),
        .div_out_valid                     (div_out_valid             ),
        .quotient                          (quotient                  ),
        .remainder                         (remainder                 ) 
  );

endmodule


