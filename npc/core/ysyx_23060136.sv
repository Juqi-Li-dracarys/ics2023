/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-07 20:07:19 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-15 11:13:22
 */


`include "DEFINES_ysyx23060136.sv"


// Top module of riscv32 core
// ===========================================================================
module ysyx_23060136 (
        // YSYX-SoC 标准总线接口，目前只考虑 Core 为 master
        input                              clock                       ,
        input                              reset                       ,
        // 外部中断
        input                              io_interrupt                ,
        // AXI-full BUS on SoC(master read)
        input                              io_master_arready           , 
        output                             io_master_arvalid           , 
        output            [  31:0]         io_master_araddr            , 
        output            [   3:0]         io_master_arid              , 
        output            [   7:0]         io_master_arlen             , 
        output            [   2:0]         io_master_arsize            , 
        output            [   1:0]         io_master_arburst           , 
        output                             io_master_rready            , 
        input                              io_master_rvalid            , 
        input             [   1:0]         io_master_rresp             , 
        input             [  63:0]         io_master_rdata             , 
        input                              io_master_rlast             , 
        input             [   3:0]         io_master_rid               ,
        // AXI-full BUS on SoC(master write)
        input                              io_master_awready           ,
        output                             io_master_awvalid           ,
        output            [  31:0]         io_master_awaddr            ,
        output            [   3:0]         io_master_awid              ,
        output            [   7:0]         io_master_awlen             ,
        output            [   2:0]         io_master_awsize            ,
        output            [   1:0]         io_master_awburst           ,
        input                              io_master_wready            ,
        output                             io_master_wvalid            , 
        output            [  63:0]         io_master_wdata             ,
        output            [   7:0]         io_master_wstrb             ,
        output                             io_master_wlast             ,
        output                             io_master_bready            ,
        input                              io_master_bvalid            ,
        input             [   1:0]         io_master_bresp             ,
        input             [   3:0]         io_master_bid               ,
        // AXI-full BUS on SoC(slave read)
        
        output                             io_slave_awready            ,
        input                              io_slave_awvalid            ,
        input             [  31:0]         io_slave_awaddr             ,
        input             [   3:0]         io_slave_awid               ,
        input             [   7:0]         io_slave_awlen              ,
        input             [   2:0]         io_slave_awsize             ,
        input             [   1:0]         io_slave_awburst            ,
        output                             io_slave_wready             ,
        input                              io_slave_wvalid             ,
        input             [  63:0]         io_slave_wdata              ,
        input             [   7:0]         io_slave_wstrb              ,
        input                              io_slave_wlast              ,
        input                              io_slave_bready             ,
        output                             io_slave_bvalid             ,
        output            [   1:0]         io_slave_bresp              ,
        output            [   3:0]         io_slave_bid                ,
        output                             io_slave_arready            ,
        input                              io_slave_arvalid            ,
        input             [  31:0]         io_slave_araddr             ,
        input             [   3:0]         io_slave_arid               ,
        input             [   7:0]         io_slave_arlen              ,
        input             [   2:0]         io_slave_arsize             ,
        input             [   1:0]         io_slave_arburst            ,
        input                              io_slave_rready             ,
        output                             io_slave_rvalid             ,
        output            [   1:0]         io_slave_rresp              ,
        output            [  63:0]         io_slave_rdata              ,
        output                             io_slave_rlast              ,
        output            [   3:0]         io_slave_rid                

    );
     
    
    // ===========================================================================
    // 仿真信号接口
     wire            clk                                           =    clock                           ;
     wire            rst                                           =    reset                           ;

     wire            MEM_error_signal     /* verilator public */                                        ;
     wire            ARBITER_error_signal /* verilator public */                                        ;
     wire            inst_commit          /* verilator public */   =     WB_o_commit                    ;
     wire   [31 : 0] pc_cur               /* verilator public */   =     WB_o_pc                        ;
     wire   [31 : 0] inst                 /* verilator public */   =     WB_o_inst                      ;
     wire            system_halt          /* verilator public */   =     WB_o_system_halt               ;


    // ===========================================================================
    // 暂时不考虑的信号
     assign          io_slave_awready        =            `false                  ;           
     assign          io_slave_wready         =            `false                  ;           
     assign          io_slave_bvalid         =            `false                  ;           
     assign          io_slave_bresp          =            `false                  ;           
     assign          io_slave_bid            =            `false                  ;           
     assign          io_slave_arready        =            `false                  ;           
     assign          io_slave_rvalid         =            `false                  ;           
     assign          io_slave_rresp          =            `false                  ;           
     assign          io_slave_rdata          =            `false                  ;           
     assign          io_slave_rlast          =            `false                  ;           
     assign          io_slave_rid            =            `false                  ;           


    // ===========================================================================
    // IFU
    wire                                 FORWARD_stallIF            ;
    wire                [  31:0]         BRANCH_branch_target       ;
    wire                                 BRANCH_PCSrc               ;
    wire                [  31:0]         IFU_o_inst                 ;
    wire                [  31:0]         IFU_o_pc                   ;
    wire                                 IFU_o_valid                ;

    wire                [  63:0]         ARBITER_IFU_inst           ;
    wire                                 ARBITER_IFU_inst_valid     ;
    wire                                 ARBITER_IFU_pc_ready       ;
    wire                [  31:0]         ARBITER_IFU_pc             ;
    wire                                 ARBITER_IFU_pc_valid       ;
    wire                                 ARBITER_IFU_inst_ready     ;
  

    IFU_TOP_ysyx23060136  IFU_TOP_ysyx23060136_inst (
                            .clk                               (clk                       ),
                            .rst                               (rst                       ),
                            .FORWARD_stallIF                   (FORWARD_stallIF           ),
                            .BRANCH_branch_target              (BRANCH_branch_target      ),
                            .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
                            .IFU_o_inst                        (IFU_o_inst                ),
                            .IFU_o_pc                          (IFU_o_pc                  ),
                            .IFU_o_valid                       (IFU_o_valid               ),
                            .ARBITER_IFU_inst                  (ARBITER_IFU_inst          ),
                            .ARBITER_IFU_inst_valid            (ARBITER_IFU_inst_valid    ),
                            .ARBITER_IFU_pc_ready              (ARBITER_IFU_pc_ready      ),
                            .ARBITER_IFU_pc                    (ARBITER_IFU_pc            ),
                            .ARBITER_IFU_pc_valid              (ARBITER_IFU_pc_valid      ),
                            .ARBITER_IFU_inst_ready            (ARBITER_IFU_inst_ready    )
                        );



    // ===========================================================================
    // IFU -> IDU SEG REG
    wire                                 BRANCH_flushIF             ;
    wire                                 FORWARD_stallID            ;
    wire                                 IDU_i_commit               ;
    wire                [  31:0]         IDU_i_pc                   ;
    wire                [  31:0]         IDU_i_inst                 ;


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
    wire               [   4:0]         WB_o_rd                      ;
    wire                                WB_o_RegWr                   ;
    wire               [  31:0]         WB_o_rf_busW                 ;
    wire               [   2:0]         WB_o_csr_rd                  ;
    wire                                WB_o_CSRWr                   ;
    wire               [  31:0]         WB_o_csr_busW                ;

    wire               [  31:0]         IDU_o_pc                     ;
    wire               [  31:0]         IDU_o_inst                   ;
    wire                                IDU_o_commit                 ;
    wire               [   4:0]         IDU_o_rd                     ;
    wire               [   4:0]         IDU_o_rs1                    ;
    wire               [   4:0]         IDU_o_rs2                    ;
    wire               [  31:0]         IDU_o_imm                    ;
    wire               [  31:0]         IDU_o_rs1_data               ;
    wire               [  31:0]         IDU_o_rs2_data               ;
    wire               [   2:0]         IDU_o_csr_rd                 ;
    wire               [   2:0]         IDU_o_csr_rs                 ;
    wire               [  31:0]         IDU_o_csr_rs_data            ;
    wire                                IDU_o_ALU_add                ;
    wire                                IDU_o_ALU_sub                ;
    wire                                IDU_o_ALU_slt                ;
    wire                                IDU_o_ALU_sltu               ;
    wire                                IDU_o_ALU_or                 ;
    wire                                IDU_o_ALU_and                ;
    wire                                IDU_o_ALU_xor                ;
    wire                                IDU_o_ALU_sll                ;
    wire                                IDU_o_ALU_srl                ;
    wire                                IDU_o_ALU_sra                ;
    wire                                IDU_o_ALU_explicit           ;
    wire                                IDU_o_ALU_i1_rs1             ;
    wire                                IDU_o_ALU_i1_pc              ;
    wire                                IDU_o_ALU_i2_rs2             ;
    wire                                IDU_o_ALU_i2_imm             ;
    wire                                IDU_o_ALU_i2_4               ;
    wire                                IDU_o_ALU_i2_csr             ;
    wire                                IDU_o_jump                   ;
    wire                                IDU_o_pc_plus_imm            ;
    wire                                IDU_o_rs1_plus_imm           ;
    wire                                IDU_o_csr_plus_imm           ;
    wire                                IDU_o_cmp_eq                 ;
    wire                                IDU_o_cmp_neq                ;
    wire                                IDU_o_cmp_ge                 ;
    wire                                IDU_o_cmp_lt                 ;
    wire                                IDU_o_write_gpr              ;
    wire                                IDU_o_write_csr              ;


    wire                                IDU_o_mem_to_reg             ;
    wire                                IDU_o_rv32_csrrs             ;
    wire                                IDU_o_rv32_csrrw             ;
    wire                                IDU_o_rv32_ecall             ;
    wire                                IDU_o_write_mem              ;
    wire                                IDU_o_mem_byte               ;
    wire                                IDU_o_mem_half               ;
    wire                                IDU_o_mem_word               ;
    wire                                IDU_o_mem_byte_u             ;
    wire                                IDU_o_mem_half_u             ;
    wire                                IDU_o_system_halt            ;



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
                              .IDU_o_system_halt                 (IDU_o_system_halt         )
                          );



    // ===========================================================================
    // IDU -> EXU
    wire                                BRANCH_flushID               ;
    wire                                FORWARD_stallEX              ;
    wire               [  31:0]         FORWARD_rs1_data_SEG         ;
    wire               [  31:0]         FORWARD_rs2_data_SEG         ;
    wire               [  31:0]         FORWARD_csr_rs_data_SEG      ;
    wire                                FORWARD_rs1_hazard_SEG       ;
    wire                                FORWARD_rs2_hazard_SEG       ;
    wire                                FORWARD_csr_rs_hazard_SEG    ;
    wire               [  31:0]         EXU_i_pc                     ;
    wire               [  31:0]         EXU_i_inst                   ;
    wire                                EXU_i_commit                 ;
    wire               [   4:0]         EXU_i_rd                     ;
    wire               [   4:0]         EXU_i_rs1                    ;
    wire               [   4:0]         EXU_i_rs2                    ;
    wire               [  31:0]         EXU_i_imm                    ;
    wire               [  31:0]         EXU_i_rs1_data               ;
    wire               [  31:0]         EXU_i_rs2_data               ;
    wire               [   2:0]         EXU_i_csr_rd                 ;
    wire               [   2:0]         EXU_i_csr_rs                 ;
    wire               [  31:0]         EXU_i_csr_rs_data            ;

    wire                                EXU_i_ALU_add                ;
    wire                                EXU_i_ALU_sub                ;
    wire                                EXU_i_ALU_slt                ;
    wire                                EXU_i_ALU_sltu               ;
    wire                                EXU_i_ALU_or                 ;
    wire                                EXU_i_ALU_and                ;
    wire                                EXU_i_ALU_xor                ;
    wire                                EXU_i_ALU_sll                ;
    wire                                EXU_i_ALU_srl                ;
    wire                                EXU_i_ALU_sra                ;
    wire                                EXU_i_ALU_explicit           ;
    wire                                EXU_i_ALU_i1_rs1             ;
    wire                                EXU_i_ALU_i1_pc              ;
    wire                                EXU_i_ALU_i2_rs2             ;
    wire                                EXU_i_ALU_i2_imm             ;
    wire                                EXU_i_ALU_i2_4               ;
    wire                                EXU_i_ALU_i2_csr             ;
    wire                                EXU_i_jump                   ;
    wire                                EXU_i_pc_plus_imm            ;
    wire                                EXU_i_rs1_plus_imm           ;
    wire                                EXU_i_csr_plus_imm           ;
    wire                                EXU_i_cmp_eq                 ;
    wire                                EXU_i_cmp_neq                ;
    wire                                EXU_i_cmp_ge                 ;
    wire                                EXU_i_cmp_lt                 ;
    wire                                EXU_i_write_gpr              ;
    wire                                EXU_i_write_csr              ;
    wire                                EXU_i_mem_to_reg             ;
    wire                                EXU_i_rv32_csrrs             ;
    wire                                EXU_i_rv32_csrrw             ;
    wire                                EXU_i_rv32_ecall             ;
    wire                                EXU_i_write_mem              ;
    wire                                EXU_i_mem_byte               ;
    wire                                EXU_i_mem_half               ;
    wire                                EXU_i_mem_word               ;
    wire                                EXU_i_mem_byte_u             ;
    wire                                EXU_i_mem_half_u             ;
    wire                                EXU_i_system_halt            ;



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
                                      .EXU_i_system_halt                 (EXU_i_system_halt         )
                                  );


    // ===========================================================================
    // EXU
    wire               [  31:0]         EXU_o_pc                 ;
    wire               [  31:0]         EXU_o_inst               ;
    wire               [  31:0]         EXU_o_ALU_ALUout         ;
    wire               [  31:0]         EXU_o_ALU_CSR_out        ;
    wire                                EXU_o_commit             ;
    wire               [   4:0]         EXU_o_rd                 ;
    wire               [   4:0]         EXU_o_rs1                ;
    wire               [   4:0]         EXU_o_rs2                ;
    wire               [  31:0]         EXU_o_HAZARD_rs2_data    ;
    wire               [   2:0]         EXU_o_csr_rd             ;
    wire               [   2:0]         EXU_o_csr_rs             ;
    wire                                EXU_o_write_gpr          ;
    wire                                EXU_o_write_csr          ;

    wire                                EXU_o_mem_to_reg         ;
    wire                                EXU_o_write_mem          ;
    wire                                EXU_o_mem_byte           ;
    wire                                EXU_o_mem_half           ;
    wire                                EXU_o_mem_word           ;
    wire                                EXU_o_mem_byte_u         ;
    wire                                EXU_o_mem_half_u         ;
    wire                                EXU_o_system_halt        ;


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
                              .EXU_o_system_halt                 (EXU_o_system_halt         )
                          );


    // ===========================================================================
    // EXU -> MEM
    wire                                FORWARD_flushEX    = `false  ;
    wire                                FORWARD_stallME              ; 
    wire                                MEM_i_commit                 ;
    wire               [  31:0]         MEM_i_pc                     ;
    wire               [  31:0]         MEM_i_inst                   ;
    wire               [  31:0]         MEM_i_ALU_ALUout             ;
    wire               [  31:0]         MEM_i_ALU_CSR_out            ;
    wire               [   4:0]         MEM_i_rd                     ;
    wire               [  31:0]         MEM_i_rs2_data               ;
    wire               [   2:0]         MEM_i_csr_rd                 ;
    wire                                MEM_i_write_gpr              ;
    wire                                MEM_i_write_csr              ;
    wire                                MEM_i_mem_to_reg             ;
    wire                                MEM_i_write_mem              ;
    wire                                MEM_i_mem_byte               ;
    wire                                MEM_i_mem_half               ;
    wire                                MEM_i_mem_word               ;
    wire                                MEM_i_mem_byte_u             ;
    wire                                MEM_i_mem_half_u             ;
    wire                                MEM_i_system_halt            ;
    wire                                MEM_i_raddr_change           ;  
    wire                                MEM_i_waddr_change           ;


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
                                      .MEM_i_raddr_change                (MEM_i_raddr_change        ),
                                      .MEM_i_waddr_change                (MEM_i_waddr_change        )       
                                  );


    // ===========================================================================
    // MEM

    wire               [  31:0]         WB_o_rs1_data                ;
    wire               [  31:0]         WB_o_rs2_data                ;
    wire               [  31:0]         WB_o_csr_rs_data             ;

  
    wire                                MEM_o_commit              ;
    wire               [  31:0]         MEM_o_pc                  ;
    wire               [  31:0]         MEM_o_inst                ;
    wire               [  31:0]         MEM_o_ALU_ALUout          ;
    wire               [  31:0]         MEM_o_ALU_CSR_out         ;
    wire               [  31:0]         MEM_o_rdata               ;
    wire                                MEM_o_write_gpr           ;
    wire                                MEM_o_write_csr           ;
    wire                                MEM_o_mem_to_reg          ;
    wire               [   4:0]         MEM_o_rd                  ;
    wire               [   2:0]         MEM_o_csr_rd              ;
    wire                                MEM_o_system_halt         ;

    wire               [  31:0]         FORWARD_rs1_data_EXU       ;
    wire               [  31:0]         FORWARD_rs2_data_EXU       ;
    wire               [  31:0]         FORWARD_csr_rs_data_EXU    ;
    wire                                FORWARD_rs1_hazard_EXU     ;
    wire                                FORWARD_rs2_hazard_EXU     ;
    wire                                FORWARD_csr_rs_hazard_EXU  ;


  
    wire                                ARBITER_MEM_raddr_ready    ;
    wire               [  31:0]         ARBITER_MEM_raddr          ;
    wire                                ARBITER_MEM_raddr_valid    ;
    wire               [  63:0]         ARBITER_MEM_rdata          ;
    wire                                ARBITER_MEM_rdata_valid    ;
    wire                                ARBITER_MEM_rdata_ready    ;
    wire               [   2:0]         ARBITER_MEM_rsize          ;
  

                            
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
                          .MEM_i_raddr_change                (MEM_i_raddr_change        ),
                          .MEM_i_waddr_change                (MEM_i_waddr_change        ),
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
                          .FORWARD_stallIF                   (FORWARD_stallIF           ),
                          .FORWARD_stallID                   (FORWARD_stallID           ),
                          .FORWARD_stallME                   (FORWARD_stallME           ),
                          .FORWARD_stallEX                   (FORWARD_stallEX           ),
                          .FORWARD_stallWB                   (FORWARD_stallWB           ),
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
                          .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG ),
                          .ARBITER_MEM_raddr_ready           (ARBITER_MEM_raddr_ready   ),
                          .ARBITER_MEM_raddr                 (ARBITER_MEM_raddr         ),
                          .ARBITER_MEM_raddr_valid           (ARBITER_MEM_raddr_valid   ),
                          .ARBITER_MEM_rdata                 (ARBITER_MEM_rdata         ),
                          .ARBITER_MEM_rdata_valid           (ARBITER_MEM_rdata_valid   ),
                          .ARBITER_MEM_rdata_ready           (ARBITER_MEM_rdata_ready   ),
                          .ARBITER_MEM_rsize                 (ARBITER_MEM_rsize         ),
                          .io_master_awready                 (io_master_awready         ),
                          .io_master_awvalid                 (io_master_awvalid         ),
                          .io_master_awaddr                  (io_master_awaddr          ),
                          .io_master_awid                    (io_master_awid            ),
                          .io_master_awlen                   (io_master_awlen           ),
                          .io_master_awsize                  (io_master_awsize          ),
                          .io_master_awburst                 (io_master_awburst         ),
                          .io_master_wready                  (io_master_wready          ),
                          .io_master_wvalid                  (io_master_wvalid          ),
                          .io_master_wdata                   (io_master_wdata           ),
                          .io_master_wstrb                   (io_master_wstrb           ),
                          .io_master_wlast                   (io_master_wlast           ),
                          .io_master_bready                  (io_master_bready          ),
                          .io_master_bvalid                  (io_master_bvalid          ),
                          .io_master_bresp                   (io_master_bresp           ),
                          .io_master_bid                     (io_master_bid             ),
                          .MEM_error_signal                  (MEM_error_signal          )
                      );



    // ===========================================================================
    // MEM -> WB
    wire                                FORWARD_flushME    = `false  ;
    wire                                FORWARD_stallWB              ;
    wire                                WB_i_commit                  ;
    wire               [  31:0]         WB_i_pc                      ;
    wire               [  31:0]         WB_i_inst                    ;
    wire               [  31:0]         WB_i_ALU_ALUout              ;
    wire               [  31:0]         WB_i_ALU_CSR_out             ;
    wire               [  31:0]         WB_i_rdata                   ;
    wire                                WB_i_mem_to_reg              ;
    wire                                WB_i_system_halt             ;
    wire                                WB_i_write_gpr               ;
    wire                                WB_i_write_csr               ;
    wire               [4 : 0]          WB_i_rd                      ;
    wire               [2 : 0]          WB_i_csr_rd                  ;
                        

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
                                     .WB_i_system_halt                  (WB_i_system_halt            )
            );


                               
    // ===========================================================================
    // WBU
    wire                               WB_o_commit        ;
    wire              [  31:0]         WB_o_pc            ;
    wire              [  31:0]         WB_o_inst          ;
    wire                               WB_o_system_halt   ;


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
                             .WB_o_pc                             (WB_o_pc                     ),
                             .WB_o_inst                           (WB_o_inst                   )
                         );


    PUBLIC_ARBITER_ysyx23060136  PUBLIC_ARBITER_ysyx23060136_inst (
                                .clk(clk),
                                .rst(rst),
                                .ARBITER_IFU_pc(ARBITER_IFU_pc),
                                .ARBITER_IFU_pc_valid(ARBITER_IFU_pc_valid),
                                .ARBITER_IFU_pc_ready(ARBITER_IFU_pc_ready),
                                .ARBITER_IFU_inst_ready(ARBITER_IFU_inst_ready),
                                .ARBITER_IFU_inst(ARBITER_IFU_inst),
                                .ARBITER_IFU_inst_valid(ARBITER_IFU_inst_valid),
                                .ARBITER_MEM_raddr(ARBITER_MEM_raddr),
                                .ARBITER_MEM_rsize(ARBITER_MEM_rsize),
                                .ARBITER_MEM_raddr_valid(ARBITER_MEM_raddr_valid),
                                .ARBITER_MEM_raddr_ready(ARBITER_MEM_raddr_ready),
                                .ARBITER_MEM_rdata(ARBITER_MEM_rdata),
                                .ARBITER_MEM_rdata_valid(ARBITER_MEM_rdata_valid),
                                .ARBITER_MEM_rdata_ready(ARBITER_MEM_rdata_ready),
                                .ARBITER_error_signal(ARBITER_error_signal),
                                .io_master_arready(io_master_arready),
                                .io_master_arvalid(io_master_arvalid),
                                .io_master_araddr(io_master_araddr),
                                .io_master_arid(io_master_arid),
                                .io_master_arlen(io_master_arlen),
                                .io_master_arsize(io_master_arsize),
                                .io_master_arburst(io_master_arburst),
                                .io_master_rready(io_master_rready),
                                .io_master_rvalid(io_master_rvalid),
                                .io_master_rresp(io_master_rresp),
                                .io_master_rdata(io_master_rdata),
                                .io_master_rlast(io_master_rlast),
                                .io_master_rid(io_master_rid)
                              );
                           
endmodule


