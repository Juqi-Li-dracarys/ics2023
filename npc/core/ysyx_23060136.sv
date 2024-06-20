/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-11 16:43:25 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-11 11:20:48
 */



`include "ysyx_23060136_DEFINES.sv"



// Top module of RISCV-64IM core with 7 stage pipeline
// ===========================================================================
module ysyx_23060136 (
        // YSYX-SoC AXI 标准总线接口，目前只考虑 CPU core 为 master
        input                              clock                       ,
        input                              reset                       ,
        // 外部中断
        input                              io_interrupt                ,
        output                             inst_fetch                  ,
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

        // AXI-full BUS on SoC(slave read, Not used now)
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
        output            [   3:0]         io_slave_rid                ,
        // ===========================================================================
        // sram
        output             [   5:0]        io_sram0_addr               ,             
        output                             io_sram0_cen                ,             
        output                             io_sram0_wen                ,             
        output             [ 127:0]        io_sram0_wmask              ,             
        output             [ 127:0]        io_sram0_wdata              ,             
        input              [ 127:0]        io_sram0_rdata              ,

        output             [   5:0]        io_sram1_addr               ,             
        output                             io_sram1_cen                ,             
        output                             io_sram1_wen                ,             
        output             [ 127:0]        io_sram1_wmask              ,             
        output             [ 127:0]        io_sram1_wdata              ,             
        input              [ 127:0]        io_sram1_rdata              ,

        output             [   5:0]        io_sram2_addr               ,             
        output                             io_sram2_cen                ,             
        output                             io_sram2_wen                ,             
        output             [ 127:0]        io_sram2_wmask              ,             
        output             [ 127:0]        io_sram2_wdata              ,             
        input              [ 127:0]        io_sram2_rdata              ,

        output             [   5:0]        io_sram3_addr               ,             
        output                             io_sram3_cen                ,             
        output                             io_sram3_wen                ,             
        output             [ 127:0]        io_sram3_wmask              ,             
        output             [ 127:0]        io_sram3_wdata              ,             
        input              [ 127:0]        io_sram3_rdata              ,

        output             [   5:0]        io_sram4_addr               ,             
        output                             io_sram4_cen                ,             
        output                             io_sram4_wen                ,             
        output             [ 127:0]        io_sram4_wmask              ,             
        output             [ 127:0]        io_sram4_wdata              ,             
        input              [ 127:0]        io_sram4_rdata              ,

        output             [   5:0]        io_sram5_addr               ,             
        output                             io_sram5_cen                ,             
        output                             io_sram5_wen                ,             
        output             [ 127:0]        io_sram5_wmask              ,             
        output             [ 127:0]        io_sram5_wdata              ,             
        input              [ 127:0]        io_sram5_rdata              , 

        output             [   5:0]        io_sram6_addr               ,
        output                             io_sram6_cen                ,             
        output                             io_sram6_wen                ,             
        output             [ 127:0]        io_sram6_wmask              ,             
        output             [ 127:0]        io_sram6_wdata              ,             
        input              [ 127:0]        io_sram6_rdata              ,
                      
        output             [   5:0]        io_sram7_addr               ,             
        output                             io_sram7_cen                ,             
        output                             io_sram7_wen                ,             
        output             [ 127:0]        io_sram7_wmask              ,             
        output             [ 127:0]        io_sram7_wdata              ,             
        input              [ 127:0]        io_sram7_rdata                         

    );
     
    
    // ===========================================================================
    // 仿真信号接口
     wire                                   clk                                           =    clock                           ;
     wire                                   rst                                           =    reset                           ;
    
     // IFU PC 地址错误
     wire                                   IFU_error_signal     /* verilator public */                                        ;
     // AXI 返回信息错误
     wire                                   MEM_error_signal     /* verilator public */                                        ;
     
     wire                                   inst_commit          /* verilator public */   =     WB_o_commit                    ;
     wire   [`ysyx_23060136_BITS_W-1 : 0]   pc_cur               /* verilator public */   =     WB_o_pc                        ;
     wire   [`ysyx_23060136_INST_W-1 : 0]   inst                 /* verilator public */   =     WB_o_inst                      ;
     wire                                   system_halt          /* verilator public */   =     WB_o_system_halt               ;


    // ===========================================================================
    // 暂时不考虑的信号
     assign          io_slave_awready        =     `ysyx_23060136_false    ;           
     assign          io_slave_wready         =     `ysyx_23060136_false    ;           
     assign          io_slave_bvalid         =     `ysyx_23060136_false    ;           
     assign          io_slave_bresp          =     `ysyx_23060136_false    ;           
     assign          io_slave_bid            =     `ysyx_23060136_false    ;           
     assign          io_slave_arready        =     `ysyx_23060136_false    ;           
     assign          io_slave_rvalid         =     `ysyx_23060136_false    ;           
     assign          io_slave_rresp          =     `ysyx_23060136_false    ;           
     assign          io_slave_rdata          =     `ysyx_23060136_false    ;           
     assign          io_slave_rlast          =     `ysyx_23060136_false    ;           
     assign          io_slave_rid            =     `ysyx_23060136_false    ;


    // ===========================================================================
    // IFU
    wire                                                      FORWARD_stallIF            ;
    wire                [  `ysyx_23060136_BITS_W-1:0]         BRANCH_branch_target       ;
    wire                                                      BRANCH_PCSrc               ;
    wire                [  `ysyx_23060136_INST_W-1:0]         IFU_o_inst                 ;
    wire                [  `ysyx_23060136_BITS_W-1:0]         IFU_o_pc                   ;
    wire                                                      IFU_o_valid                ;
    wire                                                      IFU_o_commit               ;


    wire                                                      ARBITER_IFU_arready        ;
    wire                                                      ARBITER_IFU_arvalid        ;
    wire                [  31:0]                              ARBITER_IFU_araddr         ;
    wire                [   3:0]                              ARBITER_IFU_arid           ;
    wire                [   7:0]                              ARBITER_IFU_arlen          ;
    wire                [   2:0]                              ARBITER_IFU_arsize         ;
    wire                [   1:0]                              ARBITER_IFU_arburst        ;
    wire                                                      ARBITER_IFU_rready         ;
    wire                                                      ARBITER_IFU_rvalid         ;
    wire                [   1:0]                              ARBITER_IFU_rresp          ;
    wire                [  63:0]                              ARBITER_IFU_rdata          ;
    wire                                                      ARBITER_IFU_rlast          ;
    wire                [   3:0]                              ARBITER_IFU_rid            ;
    wire                                                      IFU_error_signal           ;
  

    wire              [  `ysyx_23060136_BITS_W -1:0]   BHT_pc                            ;
    // correct predict
    wire                                               BHT_pre_true                      ;
    // wrong predict
    wire                                               BHT_pre_false                     ;
    wire                                               BHT_pre_take                      ; 


    ysyx_23060136_IFU_TOP  ysyx_23060136_IFU_TOP_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .BRANCH_flushIF                    (BRANCH_flushIF            ),
        .BRANCH_branch_target              (BRANCH_branch_target      ),
        .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
        .BHT_pc                            (BHT_pc                    ),
        .BHT_pre_true                      (BHT_pre_true              ),
        .BHT_pre_false                     (BHT_pre_false             ),
        .IFU_o_inst                        (IFU_o_inst                ),
        .IFU_o_pc                          (IFU_o_pc                  ),
        .IFU_o_valid                       (IFU_o_valid               ),
        .IFU_o_commit                      (IFU_o_commit              ),
        .BHT_pre_take                      (BHT_pre_take              ),
        .ARBITER_IFU_arready               (ARBITER_IFU_arready       ),
        .ARBITER_IFU_arvalid               (ARBITER_IFU_arvalid       ),
        .ARBITER_IFU_araddr                (ARBITER_IFU_araddr        ),
        .ARBITER_IFU_arid                  (ARBITER_IFU_arid          ),
        .ARBITER_IFU_arlen                 (ARBITER_IFU_arlen         ),
        .ARBITER_IFU_arsize                (ARBITER_IFU_arsize        ),
        .ARBITER_IFU_arburst               (ARBITER_IFU_arburst       ),
        .ARBITER_IFU_rready                (ARBITER_IFU_rready        ),
        .ARBITER_IFU_rvalid                (ARBITER_IFU_rvalid        ),
        .ARBITER_IFU_rresp                 (ARBITER_IFU_rresp         ),
        .ARBITER_IFU_rdata                 (ARBITER_IFU_rdata         ),
        .ARBITER_IFU_rlast                 (ARBITER_IFU_rlast         ),
        .ARBITER_IFU_rid                   (ARBITER_IFU_rid           ),
        .IFU_error_signal                  (IFU_error_signal          ),
        .io_sram0_addr                     (io_sram0_addr             ),
        .io_sram0_cen                      (io_sram0_cen              ),
        .io_sram0_wen                      (io_sram0_wen              ),
        .io_sram0_wmask                    (io_sram0_wmask            ),
        .io_sram0_wdata                    (io_sram0_wdata            ),
        .io_sram0_rdata                    (io_sram0_rdata            ),
        .io_sram1_addr                     (io_sram1_addr             ),
        .io_sram1_cen                      (io_sram1_cen              ),
        .io_sram1_wen                      (io_sram1_wen              ),
        .io_sram1_wmask                    (io_sram1_wmask            ),
        .io_sram1_wdata                    (io_sram1_wdata            ),
        .io_sram1_rdata                    (io_sram1_rdata            ),
        .io_sram2_addr                     (io_sram2_addr             ),
        .io_sram2_cen                      (io_sram2_cen              ),
        .io_sram2_wen                      (io_sram2_wen              ),
        .io_sram2_wmask                    (io_sram2_wmask            ),
        .io_sram2_wdata                    (io_sram2_wdata            ),
        .io_sram2_rdata                    (io_sram2_rdata            ),
        .io_sram3_addr                     (io_sram3_addr             ),
        .io_sram3_cen                      (io_sram3_cen              ),
        .io_sram3_wen                      (io_sram3_wen              ),
        .io_sram3_wmask                    (io_sram3_wmask            ),
        .io_sram3_wdata                    (io_sram3_wdata            ),
        .io_sram3_rdata                    (io_sram3_rdata            ) 
      );



    // ===========================================================================
    // IFU -> IDU SEG REG
    wire                                                      BRANCH_flushIF             ;
    wire                                                      FORWARD_stallID            ;
    wire                                                      IDU_i_commit               ;
    wire                [  `ysyx_23060136_BITS_W-1:0]         IDU_i_pc                   ;
    wire                [  `ysyx_23060136_INST_W-1:0]         IDU_i_inst                 ;
    wire                                                      IDU_i_pre_take             ;


    ysyx_23060136_IFU_IDU_SEG  ysyx_23060136_IFU_IDU_SEG_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .BRANCH_flushIF                    (BRANCH_flushIF            ),
        .FORWARD_stallID                   (FORWARD_stallID           ),
        .IFU_o_pc                          (IFU_o_pc                  ),
        .IFU_o_inst                        (IFU_o_inst                ),
        .IFU_o_commit                      (IFU_o_commit              ),
        .IDU_i_commit                      (IDU_i_commit              ),
        .IDU_i_pc                          (IDU_i_pc                  ),
        .IDU_i_inst                        (IDU_i_inst                ),
        .BHT_pre_take                      (BHT_pre_take              ),
        .IDU_i_pre_take                    (IDU_i_pre_take            )
      );


    
    // ===========================================================================
    // IDU
    wire               [    `ysyx_23060136_GPR_W-1:0]        WB_o_rd                      ;
    wire                                                     WB_o_RegWr                   ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_rf_busW                 ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         WB_o_csr_rd_1                ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         WB_o_csr_rd_2                ;
    wire                                                     WB_o_CSRWr_1                 ;
    wire                                                     WB_o_CSRWr_2                 ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_csr_busW_1              ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_csr_busW_2              ;

    wire               [  `ysyx_23060136_BITS_W-1:0]         IDU_o_pc                     ;
    wire               [  `ysyx_23060136_INST_W-1:0]         IDU_o_inst                   ;
    wire                                                     IDU_o_commit                 ;
    wire                                                     IDU_o_pre_take               ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        IDU_o_rd                     ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        IDU_o_rs1                    ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        IDU_o_rs2                    ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         IDU_o_imm                    ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         IDU_o_rs1_data               ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         IDU_o_rs2_data               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rd_1               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rd_2               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rs                 ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         IDU_o_csr_rs_data            ;

    wire                                                     IDU_o_ALU_word_t             ;
    wire                                                     IDU_o_ALU_add                ;
    wire                                                     IDU_o_ALU_sub                ;
    wire                                                     IDU_o_ALU_slt                ;
    wire                                                     IDU_o_ALU_sltu               ;
    wire                                                     IDU_o_ALU_or                 ;
    wire                                                     IDU_o_ALU_and                ;
    wire                                                     IDU_o_ALU_xor                ;
    wire                                                     IDU_o_ALU_sll                ;
    wire                                                     IDU_o_ALU_srl                ;
    wire                                                     IDU_o_ALU_sra                ;

    wire                                                     IDU_o_ALU_mul                ; 
    wire                                                     IDU_o_ALU_mul_hi             ; 
    wire                                                     IDU_o_ALU_mul_u              ; 
    wire                                                     IDU_o_ALU_mul_s              ; 
    wire                                                     IDU_o_ALU_mul_su             ; 
    wire                                                     IDU_o_ALU_div                ; 
    wire                                                     IDU_o_ALU_div_u              ; 
    wire                                                     IDU_o_ALU_div_s              ; 
    wire                                                     IDU_o_ALU_rem                ; 
    wire                                                     IDU_o_ALU_rem_u              ; 
    wire                                                     IDU_o_ALU_rem_s              ; 

    wire                                                     IDU_o_ALU_explicit           ;
    wire                                                     IDU_o_ALU_i1_rs1             ;
    wire                                                     IDU_o_ALU_i1_pc              ;
    wire                                                     IDU_o_ALU_i2_rs2             ;
    wire                                                     IDU_o_ALU_i2_imm             ;
    wire                                                     IDU_o_ALU_i2_4               ;
    wire                                                     IDU_o_ALU_i2_csr             ;
    wire                                                     IDU_o_jump                   ;
    wire                                                     IDU_o_Btype                  ;
    wire                                                     IDU_o_pc_plus_imm            ;
    wire                                                     IDU_o_rs1_plus_imm           ;
    wire                                                     IDU_o_csr_plus_imm           ;
    wire                                                     IDU_o_cmp_eq                 ;
    wire                                                     IDU_o_cmp_neq                ;
    wire                                                     IDU_o_cmp_ge                 ;
    wire                                                     IDU_o_cmp_lt                 ;
    wire                                                     IDU_o_write_gpr              ;
    wire                                                     IDU_o_write_csr_1            ;
    wire                                                     IDU_o_write_csr_2            ;


    wire                                                     IDU_o_mem_to_reg             ;
    wire                                                     IDU_o_rv64_csrrs             ;
    wire                                                     IDU_o_rv64_csrrw             ;
    wire                                                     IDU_o_rv64_ecall             ;
    wire                                                     IDU_o_write_mem              ;
    wire                                                     IDU_o_mem_byte               ;
    wire                                                     IDU_o_mem_half               ;
    wire                                                     IDU_o_mem_word               ;
    wire                                                     IDU_o_mem_byte_u             ;
    wire                                                     IDU_o_mem_half_u             ;
    wire                                                     IDU_o_mem_dword              ;
    wire                                                     IDU_o_mem_word_u             ;
    wire                                                     IDU_o_system_halt            ;



    ysyx_23060136_IDU_TOP  ysyx_23060136_IDU_TOP_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .IDU_i_pc                          (IDU_i_pc                  ),
        .IDU_i_inst                        (IDU_i_inst                ),
        .IDU_i_commit                      (IDU_i_commit              ),
        .IDU_i_pre_take                    (IDU_i_pre_take            ),
        .WB_o_rd                           (WB_o_rd                   ),
        .WB_o_RegWr                        (WB_o_RegWr                ),
        .WB_o_rf_busW                      (WB_o_rf_busW              ),
        .WB_o_csr_rd_1                     (WB_o_csr_rd_1             ),
        .WB_o_csr_rd_2                     (WB_o_csr_rd_2             ),
        .WB_o_CSRWr_1                      (WB_o_CSRWr_1              ),
        .WB_o_CSRWr_2                      (WB_o_CSRWr_2              ),
        .WB_o_csr_busW_1                   (WB_o_csr_busW_1           ),
        .WB_o_csr_busW_2                   (WB_o_csr_busW_2           ),
        .IDU_o_pc                          (IDU_o_pc                  ),
        .IDU_o_inst                        (IDU_o_inst                ),
        .IDU_o_commit                      (IDU_o_commit              ),
        .IDU_o_pre_take                    (IDU_o_pre_take            ),
        .IDU_o_rd                          (IDU_o_rd                  ),
        .IDU_o_rs1                         (IDU_o_rs1                 ),
        .IDU_o_rs2                         (IDU_o_rs2                 ),
        .IDU_o_imm                         (IDU_o_imm                 ),
        .IDU_o_rs1_data                    (IDU_o_rs1_data            ),
        .IDU_o_rs2_data                    (IDU_o_rs2_data            ),
        .IDU_o_csr_rd_1                    (IDU_o_csr_rd_1            ),
        .IDU_o_csr_rd_2                    (IDU_o_csr_rd_2            ),
        .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
        .IDU_o_csr_rs_data                 (IDU_o_csr_rs_data         ),
        .IDU_o_ALU_word_t                  (IDU_o_ALU_word_t          ),
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
        .IDU_o_ALU_mul                     (IDU_o_ALU_mul             ),
        .IDU_o_ALU_mul_hi                  (IDU_o_ALU_mul_hi          ),
        .IDU_o_ALU_mul_u                   (IDU_o_ALU_mul_u           ),
        .IDU_o_ALU_mul_s                   (IDU_o_ALU_mul_s           ),
        .IDU_o_ALU_mul_su                  (IDU_o_ALU_mul_su          ),
        .IDU_o_ALU_div                     (IDU_o_ALU_div             ),
        .IDU_o_ALU_div_u                   (IDU_o_ALU_div_u           ),
        .IDU_o_ALU_div_s                   (IDU_o_ALU_div_s           ),
        .IDU_o_ALU_rem                     (IDU_o_ALU_rem             ),
        .IDU_o_ALU_rem_u                   (IDU_o_ALU_rem_u           ),
        .IDU_o_ALU_rem_s                   (IDU_o_ALU_rem_s           ),
        .IDU_o_ALU_explicit                (IDU_o_ALU_explicit        ),
        .IDU_o_ALU_i1_rs1                  (IDU_o_ALU_i1_rs1          ),
        .IDU_o_ALU_i1_pc                   (IDU_o_ALU_i1_pc           ),
        .IDU_o_ALU_i2_rs2                  (IDU_o_ALU_i2_rs2          ),
        .IDU_o_ALU_i2_imm                  (IDU_o_ALU_i2_imm          ),
        .IDU_o_ALU_i2_4                    (IDU_o_ALU_i2_4            ),
        .IDU_o_ALU_i2_csr                  (IDU_o_ALU_i2_csr          ),
        .IDU_o_jump                        (IDU_o_jump                ),
        .IDU_o_Btype                       (IDU_o_Btype               ),
        .IDU_o_pc_plus_imm                 (IDU_o_pc_plus_imm         ),
        .IDU_o_rs1_plus_imm                (IDU_o_rs1_plus_imm        ),
        .IDU_o_csr_plus_imm                (IDU_o_csr_plus_imm        ),
        .IDU_o_cmp_eq                      (IDU_o_cmp_eq              ),
        .IDU_o_cmp_neq                     (IDU_o_cmp_neq             ),
        .IDU_o_cmp_ge                      (IDU_o_cmp_ge              ),
        .IDU_o_cmp_lt                      (IDU_o_cmp_lt              ),
        .IDU_o_write_gpr                   (IDU_o_write_gpr           ),
        .IDU_o_write_csr_1                 (IDU_o_write_csr_1         ),
        .IDU_o_write_csr_2                 (IDU_o_write_csr_2         ),
        .IDU_o_mem_to_reg                  (IDU_o_mem_to_reg          ),
        .IDU_o_rv64_csrrs                  (IDU_o_rv64_csrrs          ),
        .IDU_o_rv64_csrrw                  (IDU_o_rv64_csrrw          ),
        .IDU_o_rv64_ecall                  (IDU_o_rv64_ecall          ),
        .IDU_o_write_mem                   (IDU_o_write_mem           ),
        .IDU_o_mem_byte                    (IDU_o_mem_byte            ),
        .IDU_o_mem_half                    (IDU_o_mem_half            ),
        .IDU_o_mem_word                    (IDU_o_mem_word            ),
        .IDU_o_mem_dword                   (IDU_o_mem_dword           ),
        .IDU_o_mem_byte_u                  (IDU_o_mem_byte_u          ),
        .IDU_o_mem_half_u                  (IDU_o_mem_half_u          ),
        .IDU_o_mem_word_u                  (IDU_o_mem_word_u          ),
        .IDU_o_system_halt                 (IDU_o_system_halt         ) 
      );



    // ===========================================================================
    // IDU -> EXU
    wire                                                     BRANCH_flushID               ;
    wire                                                     FORWARD_stallEX              ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_SEG         ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_SEG         ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_SEG      ;

    wire                                                     FORWARD_rs1_hazard_SEG       ;
    wire                                                     FORWARD_rs2_hazard_SEG       ;
    wire                                                     FORWARD_csr_rs_hazard_SEG    ;

    wire                                                     FORWARD_rs1_hazard_SEG_f       ;
    wire                                                     FORWARD_rs2_hazard_SEG_f       ;
    wire                                                     FORWARD_csr_rs_hazard_SEG_f    ;

    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_i_pc                     ;
    wire               [  `ysyx_23060136_INST_W-1:0]         EXU_i_inst                   ;
    wire                                                     EXU_i_commit                 ;
    wire                                                     EXU_i_pre_take               ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        EXU_i_rd                     ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        EXU_i_rs1                    ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        EXU_i_rs2                    ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_i_imm                    ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_i_rs1_data               ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_i_rs2_data               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         EXU_i_csr_rd_1               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         EXU_i_csr_rd_2               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         EXU_i_csr_rs                 ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_i_csr_rs_data            ;

    wire                                                     EXU_i_ALU_word_t             ;
    wire                                                     EXU_i_ALU_add                ;
    wire                                                     EXU_i_ALU_sub                ;
    wire                                                     EXU_i_ALU_slt                ;
    wire                                                     EXU_i_ALU_sltu               ;
    wire                                                     EXU_i_ALU_or                 ;
    wire                                                     EXU_i_ALU_and                ;
    wire                                                     EXU_i_ALU_xor                ;
    wire                                                     EXU_i_ALU_sll                ;
    wire                                                     EXU_i_ALU_srl                ;
    wire                                                     EXU_i_ALU_sra                ;

    wire                                                     EXU_i_ALU_mul                ;   
    wire                                                     EXU_i_ALU_mul_hi             ;     
    wire                                                     EXU_i_ALU_mul_u              ;   
    wire                                                     EXU_i_ALU_mul_s              ;   
    wire                                                     EXU_i_ALU_mul_su             ;   
    wire                                                     EXU_i_ALU_div                ;   
    wire                                                     EXU_i_ALU_div_u              ;   
    wire                                                     EXU_i_ALU_div_s              ;   
    wire                                                     EXU_i_ALU_rem                ;   
    wire                                                     EXU_i_ALU_rem_u              ;   
    wire                                                     EXU_i_ALU_rem_s              ;   

    wire                                                     EXU_i_ALU_explicit           ;
    wire                                                     EXU_i_ALU_i1_rs1             ;
    wire                                                     EXU_i_ALU_i1_pc              ;
    wire                                                     EXU_i_ALU_i2_rs2             ;
    wire                                                     EXU_i_ALU_i2_imm             ;
    wire                                                     EXU_i_ALU_i2_4               ;
    wire                                                     EXU_i_ALU_i2_csr             ;

    wire                                                     EXU_i_jump                   ;
    wire                                                     EXU_i_Btype                  ;
    wire                                                     EXU_i_pc_plus_imm            ;
    wire                                                     EXU_i_rs1_plus_imm           ;
    wire                                                     EXU_i_csr_plus_imm           ;
    wire                                                     EXU_i_cmp_eq                 ;
    wire                                                     EXU_i_cmp_neq                ;
    wire                                                     EXU_i_cmp_ge                 ;
    wire                                                     EXU_i_cmp_lt                 ;
    wire                                                     EXU_i_write_gpr              ;
    wire                                                     EXU_i_write_csr_1            ;
    wire                                                     EXU_i_write_csr_2            ;
    wire                                                     EXU_i_mem_to_reg             ;
    wire                                                     EXU_i_rv64_csrrs             ;
    wire                                                     EXU_i_rv64_csrrw             ;
    wire                                                     EXU_i_rv64_ecall             ;
    wire                                                     EXU_i_write_mem              ;
    wire                                                     EXU_i_mem_byte               ;
    wire                                                     EXU_i_mem_half               ;
    wire                                                     EXU_i_mem_word               ;
    wire                                                     EXU_i_mem_dword              ;
    wire                                                     EXU_i_mem_byte_u             ;
    wire                                                     EXU_i_mem_half_u             ;
    wire                                                     EXU_i_mem_word_u             ;
    wire                                                     EXU_i_system_halt            ;



    ysyx_23060136_IDU_EXU_SEG  ysyx_23060136_IDU_EXU_SEG_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .BRANCH_flushID                    (BRANCH_flushID            ),
        .FORWARD_stallEX                   (FORWARD_stallEX           ),
        .IDU_o_pc                          (IDU_o_pc                  ),
        .IDU_o_inst                        (IDU_o_inst                ),
        .IDU_o_commit                      (IDU_o_commit              ),
        .IDU_o_pre_take                    (IDU_o_pre_take            ),
        .IDU_o_rd                          (IDU_o_rd                  ),
        .IDU_o_rs1                         (IDU_o_rs1                 ),
        .IDU_o_rs2                         (IDU_o_rs2                 ),
        .IDU_o_imm                         (IDU_o_imm                 ),
        .IDU_o_rs1_data                    (IDU_o_rs1_data            ),
        .IDU_o_rs2_data                    (IDU_o_rs2_data            ),
        .IDU_o_csr_rd_1                    (IDU_o_csr_rd_1            ),
        .IDU_o_csr_rd_2                    (IDU_o_csr_rd_2            ),
        .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
        .IDU_o_csr_rs_data                 (IDU_o_csr_rs_data         ),
        .FORWARD_rs1_data_SEG              (FORWARD_rs1_data_SEG      ),
        .FORWARD_rs2_data_SEG              (FORWARD_rs2_data_SEG      ),
        .FORWARD_csr_rs_data_SEG           (FORWARD_csr_rs_data_SEG   ),
        .FORWARD_rs1_hazard_SEG            (FORWARD_rs1_hazard_SEG    ),
        .FORWARD_rs2_hazard_SEG            (FORWARD_rs2_hazard_SEG    ),
        .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG ),
        .FORWARD_rs1_hazard_SEG_f          (FORWARD_rs1_hazard_SEG_f    ),
        .FORWARD_rs2_hazard_SEG_f          (FORWARD_rs2_hazard_SEG_f    ),
        .FORWARD_csr_rs_hazard_SEG_f       (FORWARD_csr_rs_hazard_SEG_f ),
        .EXU_i_pc                          (EXU_i_pc                  ),
        .EXU_i_inst                        (EXU_i_inst                ),
        .EXU_i_commit                      (EXU_i_commit              ),
        .EXU_i_pre_take                    (EXU_i_pre_take            ),
        .EXU_i_rd                          (EXU_i_rd                  ),
        .EXU_i_rs1                         (EXU_i_rs1                 ),
        .EXU_i_rs2                         (EXU_i_rs2                 ),
        .EXU_i_imm                         (EXU_i_imm                 ),
        .EXU_i_rs1_data                    (EXU_i_rs1_data            ),
        .EXU_i_rs2_data                    (EXU_i_rs2_data            ),
        .EXU_i_csr_rd_1                    (EXU_i_csr_rd_1            ),
        .EXU_i_csr_rd_2                    (EXU_i_csr_rd_2            ),
        .EXU_i_csr_rs                      (EXU_i_csr_rs              ),
        .EXU_i_csr_rs_data                 (EXU_i_csr_rs_data         ),
        .IDU_o_ALU_word_t                  (IDU_o_ALU_word_t          ),
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
        .IDU_o_ALU_mul                     (IDU_o_ALU_mul             ),
        .IDU_o_ALU_mul_hi                  (IDU_o_ALU_mul_hi          ),
        .IDU_o_ALU_mul_u                   (IDU_o_ALU_mul_u           ),
        .IDU_o_ALU_mul_s                   (IDU_o_ALU_mul_s           ),
        .IDU_o_ALU_mul_su                  (IDU_o_ALU_mul_su          ),
        .IDU_o_ALU_div                     (IDU_o_ALU_div             ),
        .IDU_o_ALU_div_u                   (IDU_o_ALU_div_u           ),
        .IDU_o_ALU_div_s                   (IDU_o_ALU_div_s           ),
        .IDU_o_ALU_rem                     (IDU_o_ALU_rem             ),
        .IDU_o_ALU_rem_u                   (IDU_o_ALU_rem_u           ),
        .IDU_o_ALU_rem_s                   (IDU_o_ALU_rem_s           ),
        .IDU_o_ALU_explicit                (IDU_o_ALU_explicit        ),
        .IDU_o_ALU_i1_rs1                  (IDU_o_ALU_i1_rs1          ),
        .IDU_o_ALU_i1_pc                   (IDU_o_ALU_i1_pc           ),
        .IDU_o_ALU_i2_rs2                  (IDU_o_ALU_i2_rs2          ),
        .IDU_o_ALU_i2_imm                  (IDU_o_ALU_i2_imm          ),
        .IDU_o_ALU_i2_4                    (IDU_o_ALU_i2_4            ),
        .IDU_o_ALU_i2_csr                  (IDU_o_ALU_i2_csr          ),
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
        .EXU_i_ALU_i1_rs1                  (EXU_i_ALU_i1_rs1          ),
        .EXU_i_ALU_i1_pc                   (EXU_i_ALU_i1_pc           ),
        .EXU_i_ALU_i2_rs2                  (EXU_i_ALU_i2_rs2          ),
        .EXU_i_ALU_i2_imm                  (EXU_i_ALU_i2_imm          ),
        .EXU_i_ALU_i2_4                    (EXU_i_ALU_i2_4            ),
        .EXU_i_ALU_i2_csr                  (EXU_i_ALU_i2_csr          ),
        .IDU_o_jump                        (IDU_o_jump                ),
        .IDU_o_Btype                       (IDU_o_Btype               ),
        .IDU_o_pc_plus_imm                 (IDU_o_pc_plus_imm         ),
        .IDU_o_rs1_plus_imm                (IDU_o_rs1_plus_imm        ),
        .IDU_o_csr_plus_imm                (IDU_o_csr_plus_imm        ),
        .IDU_o_cmp_eq                      (IDU_o_cmp_eq              ),
        .IDU_o_cmp_neq                     (IDU_o_cmp_neq             ),
        .IDU_o_cmp_ge                      (IDU_o_cmp_ge              ),
        .IDU_o_cmp_lt                      (IDU_o_cmp_lt              ),
        .EXU_i_jump                        (EXU_i_jump                ),
        .EXU_i_Btype                       (EXU_i_Btype               ),
        .EXU_i_pc_plus_imm                 (EXU_i_pc_plus_imm         ),
        .EXU_i_rs1_plus_imm                (EXU_i_rs1_plus_imm        ),
        .EXU_i_csr_plus_imm                (EXU_i_csr_plus_imm        ),
        .EXU_i_cmp_eq                      (EXU_i_cmp_eq              ),
        .EXU_i_cmp_neq                     (EXU_i_cmp_neq             ),
        .EXU_i_cmp_ge                      (EXU_i_cmp_ge              ),
        .EXU_i_cmp_lt                      (EXU_i_cmp_lt              ),
        .IDU_o_write_gpr                   (IDU_o_write_gpr           ),
        .IDU_o_write_csr_1                 (IDU_o_write_csr_1         ),
        .IDU_o_write_csr_2                 (IDU_o_write_csr_2         ),
        .IDU_o_mem_to_reg                  (IDU_o_mem_to_reg          ),
        .IDU_o_rv64_csrrs                  (IDU_o_rv64_csrrs          ),
        .IDU_o_rv64_csrrw                  (IDU_o_rv64_csrrw          ),
        .IDU_o_rv64_ecall                  (IDU_o_rv64_ecall          ),
        .EXU_i_write_gpr                   (EXU_i_write_gpr           ),
        .EXU_i_write_csr_1                 (EXU_i_write_csr_1         ),
        .EXU_i_write_csr_2                 (EXU_i_write_csr_2         ),
        .EXU_i_mem_to_reg                  (EXU_i_mem_to_reg          ),
        .EXU_i_rv64_csrrs                  (EXU_i_rv64_csrrs          ),
        .EXU_i_rv64_csrrw                  (EXU_i_rv64_csrrw          ),
        .EXU_i_rv64_ecall                  (EXU_i_rv64_ecall          ),
        .IDU_o_write_mem                   (IDU_o_write_mem           ),
        .IDU_o_mem_byte                    (IDU_o_mem_byte            ),
        .IDU_o_mem_half                    (IDU_o_mem_half            ),
        .IDU_o_mem_word                    (IDU_o_mem_word            ),
        .IDU_o_mem_dword                   (IDU_o_mem_dword           ),
        .IDU_o_mem_byte_u                  (IDU_o_mem_byte_u          ),
        .IDU_o_mem_half_u                  (IDU_o_mem_half_u          ),
        .IDU_o_mem_word_u                  (IDU_o_mem_word_u          ),
        .EXU_i_write_mem                   (EXU_i_write_mem           ),
        .EXU_i_mem_byte                    (EXU_i_mem_byte            ),
        .EXU_i_mem_half                    (EXU_i_mem_half            ),
        .EXU_i_mem_word                    (EXU_i_mem_word            ),
        .EXU_i_mem_dword                   (EXU_i_mem_dword           ),
        .EXU_i_mem_byte_u                  (EXU_i_mem_byte_u          ),
        .EXU_i_mem_half_u                  (EXU_i_mem_half_u          ),
        .EXU_i_mem_word_u                  (EXU_i_mem_word_u          ),
        .IDU_o_system_halt                 (IDU_o_system_halt         ),
        .EXU_i_system_halt                 (EXU_i_system_halt         ) 
  );



    // ===========================================================================
    // EXU
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_o_pc                 ;
    wire               [  `ysyx_23060136_INST_W-1:0]         EXU_o_inst               ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_o_ALU_ALUout         ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_o_ALU_CSR_out        ;
    wire                                                     EXU_o_commit             ;
    wire               [    `ysyx_23060136_GPR_W-1:0]        EXU_o_rd                 ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         EXU_o_HAZARD_rs2_data    ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         EXU_o_csr_rd_1           ;
    wire               [   `ysyx_23060136_CSR_W-1:0]         EXU_o_csr_rd_2           ;
    wire                                                     EXU_o_write_gpr          ;
    wire                                                     EXU_o_write_csr_1        ;
    wire                                                     EXU_o_write_csr_2        ;

    wire                                                     EXU_o_mem_to_reg         ;
    wire                                                     EXU_o_write_mem          ;
    wire                                                     EXU_o_mem_byte           ;
    wire                                                     EXU_o_mem_half           ;
    wire                                                     EXU_o_mem_word           ;
    wire                                                     EXU_o_mem_byte_u         ;
    wire                                                     EXU_o_mem_half_u         ;
    wire                                                     EXU_o_mem_dword          ;
    wire                                                     EXU_o_mem_word_u         ;
    wire                                                     EXU_o_valid              ;
    wire                                                     EXU_o_system_halt        ;

    wire                                                     FORWARD_stallEX2         ;
    wire                                                     FORWARD_flushEX1         ;


    ysyx_23060136_EXU_TOP  ysyx_23060136_EXU_TOP_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .FORWARD_stallEX2                  (FORWARD_stallEX2          ),
        .FORWARD_flushEX1                  (FORWARD_flushEX1          ),
        .EXU_i_pc                          (EXU_i_pc                  ),
        .EXU_i_inst                        (EXU_i_inst                ),
        .EXU_i_commit                      (EXU_i_commit              ),
        .EXU_i_pre_take                    (EXU_i_pre_take            ),

        .BHT_pc                            (BHT_pc                    ),
        .BHT_pre_false                     (BHT_pre_false             ),
        .BHT_pre_true                      (BHT_pre_true              ),

        .EXU_i_rd                          (EXU_i_rd                  ),
        .EXU_i_imm                         (EXU_i_imm                 ),
        .EXU_i_rs1_data                    (EXU_i_rs1_data            ),
        .EXU_i_rs2_data                    (EXU_i_rs2_data            ),
        .EXU_i_csr_rd_1                    (EXU_i_csr_rd_1            ),
        .EXU_i_csr_rd_2                    (EXU_i_csr_rd_2            ),
        .EXU_i_csr_rs_data                 (EXU_i_csr_rs_data         ),
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
        .EXU_i_ALU_i1_rs1                  (EXU_i_ALU_i1_rs1          ),
        .EXU_i_ALU_i1_pc                   (EXU_i_ALU_i1_pc           ),
        .EXU_i_ALU_i2_rs2                  (EXU_i_ALU_i2_rs2          ),
        .EXU_i_ALU_i2_imm                  (EXU_i_ALU_i2_imm          ),
        .EXU_i_ALU_i2_4                    (EXU_i_ALU_i2_4            ),
        .EXU_i_ALU_i2_csr                  (EXU_i_ALU_i2_csr          ),
        .EXU_i_jump                        (EXU_i_jump                ),
        .EXU_i_Btype                       (EXU_i_Btype               ),
        .EXU_i_pc_plus_imm                 (EXU_i_pc_plus_imm         ),
        .EXU_i_rs1_plus_imm                (EXU_i_rs1_plus_imm        ),
        .EXU_i_csr_plus_imm                (EXU_i_csr_plus_imm        ),
        .EXU_i_cmp_eq                      (EXU_i_cmp_eq              ),
        .EXU_i_cmp_neq                     (EXU_i_cmp_neq             ),
        .EXU_i_cmp_ge                      (EXU_i_cmp_ge              ),
        .EXU_i_cmp_lt                      (EXU_i_cmp_lt              ),
        .EXU_i_write_gpr                   (EXU_i_write_gpr           ),
        .EXU_i_write_csr_1                 (EXU_i_write_csr_1         ),
        .EXU_i_write_csr_2                 (EXU_i_write_csr_2         ),
        .EXU_i_mem_to_reg                  (EXU_i_mem_to_reg          ),
        .EXU_i_rv64_csrrs                  (EXU_i_rv64_csrrs          ),
        .EXU_i_rv64_csrrw                  (EXU_i_rv64_csrrw          ),
        .EXU_i_rv64_ecall                  (EXU_i_rv64_ecall          ),
        .EXU_i_write_mem                   (EXU_i_write_mem           ),
        .EXU_i_mem_byte                    (EXU_i_mem_byte            ),
        .EXU_i_mem_half                    (EXU_i_mem_half            ),
        .EXU_i_mem_word                    (EXU_i_mem_word            ),
        .EXU_i_mem_dword                   (EXU_i_mem_dword           ),
        .EXU_i_mem_byte_u                  (EXU_i_mem_byte_u          ),
        .EXU_i_mem_half_u                  (EXU_i_mem_half_u          ),
        .EXU_i_mem_word_u                  (EXU_i_mem_word_u          ),
        .EXU_i_system_halt                 (EXU_i_system_halt         ),
        .FORWARD_rs1_data_EXU1             (FORWARD_rs1_data_EXU      ),
        .FORWARD_rs2_data_EXU1             (FORWARD_rs2_data_EXU      ),
        .FORWARD_csr_rs_data_EXU1          (FORWARD_csr_rs_data_EXU   ),
        .FORWARD_rs1_hazard_EXU1           (FORWARD_rs1_hazard_EXU    ),
        .FORWARD_rs2_hazard_EXU1           (FORWARD_rs2_hazard_EXU    ),
        .FORWARD_csr_rs_hazard_EXU1        (FORWARD_csr_rs_hazard_EXU ),
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
        .EXU_o_HAZARD_rs2_data             (EXU_o_HAZARD_rs2_data     ),
        .EXU_o_csr_rd_1                    (EXU_o_csr_rd_1            ),
        .EXU_o_csr_rd_2                    (EXU_o_csr_rd_2            ),
        .EXU_o_write_gpr                   (EXU_o_write_gpr           ),
        .EXU_o_write_csr_1                 (EXU_o_write_csr_1         ),
        .EXU_o_write_csr_2                 (EXU_o_write_csr_2         ),
        .EXU_o_mem_to_reg                  (EXU_o_mem_to_reg          ),
        .EXU_o_write_mem                   (EXU_o_write_mem           ),
        .EXU_o_mem_byte                    (EXU_o_mem_byte            ),
        .EXU_o_mem_half                    (EXU_o_mem_half            ),
        .EXU_o_mem_word                    (EXU_o_mem_word            ),
        .EXU_o_mem_dword                   (EXU_o_mem_dword           ),
        .EXU_o_mem_byte_u                  (EXU_o_mem_byte_u          ),
        .EXU_o_mem_half_u                  (EXU_o_mem_half_u          ),
        .EXU_o_mem_word_u                  (EXU_o_mem_word_u          ),
        .EXU_o_system_halt                 (EXU_o_system_halt         ),
        .EXU_o_valid                       (EXU_o_valid               ) 
      );


    // ===========================================================================
    // EXU -> MEM
    wire                                                      FORWARD_flushEX    = `ysyx_23060136_false  ;
    wire                                                      FORWARD_stallME              ; 
    wire                                                      MEM_i_commit                 ;
    wire               [  `ysyx_23060136_BITS_W -1:0]         MEM_i_pc                     ;
    wire               [  `ysyx_23060136_INST_W -1:0]         MEM_i_inst                   ;
    wire               [  `ysyx_23060136_BITS_W -1:0]         MEM_i_ALU_ALUout             ;
    wire               [  `ysyx_23060136_BITS_W -1:0]         MEM_i_ALU_CSR_out            ;
    wire               [    `ysyx_23060136_GPR_W-1:0]         MEM_i_rd                     ;
    wire               [   `ysyx_23060136_CSR_W-1:0]          MEM_i_csr_rd_1               ;
    wire               [   `ysyx_23060136_CSR_W-1:0]          MEM_i_csr_rd_2               ;
    wire                                                      MEM_i_write_gpr              ;
    wire                                                      MEM_i_write_csr_1            ;
    wire                                                      MEM_i_write_csr_2            ;
    wire                                                      MEM_i_mem_to_reg             ;
    wire                                                      MEM_i_system_halt            ;



    ysyx_23060136_EXU_MEM_SEG  ysyx_23060136_EXU_MEM_SEG_inst (
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
        .EXU_o_csr_rd_1                    (EXU_o_csr_rd_1            ),
        .EXU_o_csr_rd_2                    (EXU_o_csr_rd_2            ),
        .EXU_o_write_gpr                   (EXU_o_write_gpr           ),
        .EXU_o_write_csr_1                 (EXU_o_write_csr_1         ),
        .EXU_o_write_csr_2                 (EXU_o_write_csr_2         ),
        .EXU_o_mem_to_reg                  (EXU_o_mem_to_reg          ),
        .EXU_o_system_halt                 (EXU_o_system_halt         ),
        .MEM_i_commit                      (MEM_i_commit              ),
        .MEM_i_pc                          (MEM_i_pc                  ),
        .MEM_i_inst                        (MEM_i_inst                ),
        .MEM_i_ALU_ALUout                  (MEM_i_ALU_ALUout          ),
        .MEM_i_ALU_CSR_out                 (MEM_i_ALU_CSR_out         ),
        .MEM_i_rd                          (MEM_i_rd                  ),
        .MEM_i_csr_rd_1                    (MEM_i_csr_rd_1            ),
        .MEM_i_csr_rd_2                    (MEM_i_csr_rd_2            ),
        .MEM_i_write_gpr                   (MEM_i_write_gpr           ),
        .MEM_i_write_csr_1                 (MEM_i_write_csr_1         ),
        .MEM_i_write_csr_2                 (MEM_i_write_csr_2         ),
        .MEM_i_mem_to_reg                  (MEM_i_mem_to_reg          ),
        .MEM_i_system_halt                 (MEM_i_system_halt         ) 
      );


    // ===========================================================================
    // MEM

    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_rs1_data                ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_rs2_data                ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_csr_rs_data_1             ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_o_csr_rs_data_2             ;

  
    wire                                                     MEM_o_commit              ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         MEM_o_pc                  ;
    wire               [  `ysyx_23060136_INST_W-1:0]         MEM_o_inst                ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         MEM_o_ALU_ALUout          ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         MEM_o_ALU_CSR_out         ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         MEM_o_rdata               ;
    wire                                                     MEM_o_write_gpr           ;
    wire                                                     MEM_o_write_csr_1         ;
    wire                                                     MEM_o_write_csr_2         ;
    wire                                                     MEM_o_mem_to_reg          ;

    wire               [    `ysyx_23060136_GPR_W-1:0]        MEM_o_rd                  ;
    wire               [   `ysyx_23060136_CSR_W -1:0]        MEM_o_csr_rd_1              ;
    wire               [   `ysyx_23060136_CSR_W -1:0]        MEM_o_csr_rd_2              ;
    wire                                                     MEM_o_system_halt         ;

    wire               [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_EXU       ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_EXU       ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_EXU    ;
    wire                                                     FORWARD_rs1_hazard_EXU     ;
    wire                                                     FORWARD_rs2_hazard_EXU     ;
    wire                                                     FORWARD_csr_rs_hazard_EXU  ;
    
    wire                                                     ARBITER_MEM_arready        ; 
    wire                                                     ARBITER_MEM_arvalid        ; 
    wire               [  31:0]                              ARBITER_MEM_araddr         ; 
    wire               [   3:0]                              ARBITER_MEM_arid           ; 
    wire               [   7:0]                              ARBITER_MEM_arlen          ; 
    wire               [   2:0]                              ARBITER_MEM_arsize         ; 
    wire               [   1:0]                              ARBITER_MEM_arburst        ; 
    wire                                                     ARBITER_MEM_rready         ; 
    wire                                                     ARBITER_MEM_rvalid         ; 
    wire               [   1:0]                              ARBITER_MEM_rresp          ; 
    wire               [  63:0]                              ARBITER_MEM_rdata          ; 
    wire                                                     ARBITER_MEM_rlast          ; 
    wire               [   3:0]                              ARBITER_MEM_rid            ;



    wire                                                     CLINT_MEM_raddr_ready      ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         CLINT_MEM_raddr            ;
    wire                                                     CLINT_MEM_raddr_valid      ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         CLINT_MEM_rdata            ;
    wire                                                     CLINT_MEM_rdata_valid      ;
    wire                                                     CLINT_MEM_rdata_ready      ;
    wire               [   2:0]                              CLINT_MEM_rsize            ;
  


      ysyx_23060136_MEM_TOP  ysyx_23060136_MEM_TOP_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .IFU_o_valid                       (IFU_o_valid               ),
        .IDU_o_rs1                         (IDU_o_rs1                 ),
        .IDU_o_rs2                         (IDU_o_rs2                 ),
        .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
        .EXU_i_rs1                         (EXU_i_rs1                 ),
        .EXU_i_rs2                         (EXU_i_rs2                 ),
        .EXU_i_csr_rs                      (EXU_i_csr_rs              ),
        .EXU_o_pc                          (EXU_o_pc                  ),
        .EXU_o_ALU_ALUout                  (EXU_o_ALU_ALUout          ),
        .EXU_o_HAZARD_rs2_data             (EXU_o_HAZARD_rs2_data     ),
        .EXU_o_write_mem                   (EXU_o_write_mem           ),
        .EXU_o_mem_to_reg                  (EXU_o_mem_to_reg          ),
        .EXU_o_mem_byte                    (EXU_o_mem_byte            ),
        .EXU_o_mem_half                    (EXU_o_mem_half            ),
        .EXU_o_mem_word                    (EXU_o_mem_word            ),
        .EXU_o_mem_dword                   (EXU_o_mem_dword           ),
        .EXU_o_mem_byte_u                  (EXU_o_mem_byte_u          ),
        .EXU_o_mem_half_u                  (EXU_o_mem_half_u          ),
        .EXU_o_mem_word_u                  (EXU_o_mem_word_u          ),
        .EXU_o_rd                          (EXU_o_rd                  ),
        .EXU_o_csr_rd_1                    (EXU_o_csr_rd_1            ),
        .EXU_o_csr_rd_2                    (EXU_o_csr_rd_2            ),
        .EXU_o_write_gpr                   (EXU_o_write_gpr           ),
        .EXU_o_write_csr_1                 (EXU_o_write_csr_1         ),
        .EXU_o_write_csr_2                 (EXU_o_write_csr_2         ),
        .EXU_o_valid                       (EXU_o_valid               ),
        .WB_o_rd                           (WB_o_rd                   ),
        .WB_o_csr_rd_1                     (WB_o_csr_rd_1             ),
        .WB_o_csr_rd_2                     (WB_o_csr_rd_2             ),
        .WB_o_write_gpr                    (WB_i_write_gpr            ),
        .WB_o_write_csr_1                  (WB_i_write_csr_1          ),
        .WB_o_write_csr_2                  (WB_i_write_csr_2          ),
        .WB_o_rs1_data                     (WB_o_rs1_data             ),
        .WB_o_rs2_data                     (WB_o_rs2_data             ),
        .WB_o_csr_rs_data_1                (WB_o_csr_rs_data_1        ),
        .WB_o_csr_rs_data_2                (WB_o_csr_rs_data_2        ),
        .MEM_i_commit                      (MEM_i_commit              ),
        .MEM_i_pc                          (MEM_i_pc                  ),
        .MEM_i_inst                        (MEM_i_inst                ),
        .MEM_i_ALU_ALUout                  (MEM_i_ALU_ALUout          ),
        .MEM_i_ALU_CSR_out                 (MEM_i_ALU_CSR_out         ),
        .MEM_i_rd                          (MEM_i_rd                  ),
        .MEM_i_csr_rd_1                    (MEM_i_csr_rd_1            ),
        .MEM_i_csr_rd_2                    (MEM_i_csr_rd_2            ),
        .MEM_i_write_gpr                   (MEM_i_write_gpr           ),
        .MEM_i_write_csr_1                 (MEM_i_write_csr_1         ),
        .MEM_i_write_csr_2                 (MEM_i_write_csr_2         ),
        .MEM_i_mem_to_reg                  (MEM_i_mem_to_reg          ),
        .MEM_i_system_halt                 (MEM_i_system_halt         ),
        .MEM_o_commit                      (MEM_o_commit              ),
        .MEM_o_pc                          (MEM_o_pc                  ),
        .MEM_o_inst                        (MEM_o_inst                ),
        .MEM_o_ALU_ALUout                  (MEM_o_ALU_ALUout          ),
        .MEM_o_ALU_CSR_out                 (MEM_o_ALU_CSR_out         ),
        .MEM_o_rdata                       (MEM_o_rdata               ),
        .MEM_o_write_gpr                   (MEM_o_write_gpr           ),
        .MEM_o_write_csr_1                 (MEM_o_write_csr_1         ),
        .MEM_o_write_csr_2                 (MEM_o_write_csr_2         ),
        .MEM_o_mem_to_reg                  (MEM_o_mem_to_reg          ),
        .MEM_o_rd                          (MEM_o_rd                  ),
        .MEM_o_csr_rd_1                    (MEM_o_csr_rd_1            ),
        .MEM_o_csr_rd_2                    (MEM_o_csr_rd_2            ),
        .MEM_o_system_halt                 (MEM_o_system_halt         ),
        .BRANCH_PCSrc                      (BRANCH_PCSrc              ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .FORWARD_stallID                   (FORWARD_stallID           ),
        .FORWARD_stallME                   (FORWARD_stallME           ),
        .FORWARD_stallEX                   (FORWARD_stallEX           ),
        .FORWARD_stallWB                   (FORWARD_stallWB           ),
        .FORWARD_stallEX2                  (FORWARD_stallEX2          ),
        .FORWARD_flushEX1                  (FORWARD_flushEX1          ),
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
        .FORWARD_rs1_hazard_SEG_f          (FORWARD_rs1_hazard_SEG_f  ),
        .FORWARD_rs2_hazard_SEG_f          (FORWARD_rs2_hazard_SEG_f  ),
        .FORWARD_csr_rs_hazard_SEG_f       (FORWARD_csr_rs_hazard_SEG_f),
        .ARBITER_MEM_arready               (ARBITER_MEM_arready       ),
        .ARBITER_MEM_arvalid               (ARBITER_MEM_arvalid       ),
        .ARBITER_MEM_araddr                (ARBITER_MEM_araddr        ),
        .ARBITER_MEM_arid                  (ARBITER_MEM_arid          ),
        .ARBITER_MEM_arlen                 (ARBITER_MEM_arlen         ),
        .ARBITER_MEM_arsize                (ARBITER_MEM_arsize        ),
        .ARBITER_MEM_arburst               (ARBITER_MEM_arburst       ),
        .ARBITER_MEM_rready                (ARBITER_MEM_rready        ),
        .ARBITER_MEM_rvalid                (ARBITER_MEM_rvalid        ),
        .ARBITER_MEM_rresp                 (ARBITER_MEM_rresp         ),
        .ARBITER_MEM_rdata                 (ARBITER_MEM_rdata         ),
        .ARBITER_MEM_rlast                 (ARBITER_MEM_rlast         ),
        .ARBITER_MEM_rid                   (ARBITER_MEM_rid           ),
        .CLINT_MEM_raddr_ready             (CLINT_MEM_raddr_ready     ),
        .CLINT_MEM_raddr                   (CLINT_MEM_raddr           ),
        .CLINT_MEM_rsize                   (CLINT_MEM_rsize           ),
        .CLINT_MEM_raddr_valid             (CLINT_MEM_raddr_valid     ),
        .CLINT_MEM_rdata                   (CLINT_MEM_rdata           ),
        .CLINT_MEM_rdata_valid             (CLINT_MEM_rdata_valid     ),
        .CLINT_MEM_rdata_ready             (CLINT_MEM_rdata_ready     ),
        .io_sram4_addr                     (io_sram4_addr             ),
        .io_sram4_cen                      (io_sram4_cen              ),
        .io_sram4_wen                      (io_sram4_wen              ),
        .io_sram4_wmask                    (io_sram4_wmask            ),
        .io_sram4_wdata                    (io_sram4_wdata            ),
        .io_sram4_rdata                    (io_sram4_rdata            ),
        .io_sram5_addr                     (io_sram5_addr             ),
        .io_sram5_cen                      (io_sram5_cen              ),
        .io_sram5_wen                      (io_sram5_wen              ),
        .io_sram5_wmask                    (io_sram5_wmask            ),
        .io_sram5_wdata                    (io_sram5_wdata            ),
        .io_sram5_rdata                    (io_sram5_rdata            ),
        .io_sram6_addr                     (io_sram6_addr             ),
        .io_sram6_cen                      (io_sram6_cen              ),
        .io_sram6_wen                      (io_sram6_wen              ),
        .io_sram6_wmask                    (io_sram6_wmask            ),
        .io_sram6_wdata                    (io_sram6_wdata            ),
        .io_sram6_rdata                    (io_sram6_rdata            ),
        .io_sram7_addr                     (io_sram7_addr             ),
        .io_sram7_cen                      (io_sram7_cen              ),
        .io_sram7_wen                      (io_sram7_wen              ),
        .io_sram7_wmask                    (io_sram7_wmask            ),
        .io_sram7_wdata                    (io_sram7_wdata            ),
        .io_sram7_rdata                    (io_sram7_rdata            ),
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
    wire                                                     FORWARD_flushME    = `ysyx_23060136_false  ;
    wire                                                     FORWARD_stallWB              ;
    wire                                                     WB_i_commit                  ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_i_pc                      ;
    wire               [  `ysyx_23060136_INST_W-1:0]         WB_i_inst                    ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_i_ALU_ALUout              ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_i_ALU_CSR_out             ;
    wire               [  `ysyx_23060136_BITS_W-1:0]         WB_i_rdata                   ;
    wire                                                     WB_i_mem_to_reg              ;
    wire                                                     WB_i_system_halt             ;
    wire                                                     WB_i_write_gpr               ;
    wire                                                     WB_i_write_csr_1             ;
    wire                                                     WB_i_write_csr_2             ;
    wire               [ `ysyx_23060136_GPR_W-1 : 0]         WB_i_rd                      ;
    wire               [`ysyx_23060136_CSR_W-1 : 0]          WB_i_csr_rd_1                ;
    wire               [`ysyx_23060136_CSR_W-1 : 0]          WB_i_csr_rd_2                ;
                        

    ysyx_23060136_MEM_WB_SEG  ysyx_23060136_MEM_WB_SEG_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .FORWARD_flushME                   (FORWARD_flushME           ),
        .FORWARD_stallWB                   (FORWARD_stallWB           ),
        .MEM_o_commit                      (MEM_o_commit              ),
        .MEM_o_pc                          (MEM_o_pc                  ),
        .MEM_o_inst                        (MEM_o_inst                ),
        .MEM_o_ALU_ALUout                  (MEM_o_ALU_ALUout          ),
        .MEM_o_ALU_CSR_out                 (MEM_o_ALU_CSR_out         ),
        .MEM_o_rdata                       (MEM_o_rdata               ),
        .MEM_o_write_gpr                   (MEM_o_write_gpr           ),
        .MEM_o_write_csr_1                 (MEM_o_write_csr_1         ),
        .MEM_o_write_csr_2                 (MEM_o_write_csr_2         ),
        .MEM_o_mem_to_reg                  (MEM_o_mem_to_reg          ),
        .MEM_o_rd                          (MEM_o_rd                  ),
        .MEM_o_csr_rd_1                    (MEM_o_csr_rd_1            ),
        .MEM_o_csr_rd_2                    (MEM_o_csr_rd_2            ),
        .MEM_o_system_halt                 (MEM_o_system_halt         ),
        .WB_i_commit                       (WB_i_commit               ),
        .WB_i_pc                           (WB_i_pc                   ),
        .WB_i_inst                         (WB_i_inst                 ),
        .WB_i_ALU_ALUout                   (WB_i_ALU_ALUout           ),
        .WB_i_ALU_CSR_out                  (WB_i_ALU_CSR_out          ),
        .WB_i_rdata                        (WB_i_rdata                ),
        .WB_i_write_gpr                    (WB_i_write_gpr            ),
        .WB_i_write_csr_1                  (WB_i_write_csr_1          ),
        .WB_i_write_csr_2                  (WB_i_write_csr_2          ),
        .WB_i_mem_to_reg                   (WB_i_mem_to_reg           ),
        .WB_i_rd                           (WB_i_rd                   ),
        .WB_i_csr_rd_1                     (WB_i_csr_rd_1             ),
        .WB_i_csr_rd_2                     (WB_i_csr_rd_2             ),
        .WB_i_system_halt                  (WB_i_system_halt          ) 
      );

           
    // ===========================================================================
    // WBU
    wire                                                    WB_o_commit        ;
    wire              [  `ysyx_23060136_BITS_W-1:0]         WB_o_pc            ;
    wire              [  `ysyx_23060136_INST_W-1:0]         WB_o_inst          ;
    wire                                                    WB_o_system_halt   ;

    ysyx_23060136_WB_TOP  ysyx_23060136_WB_TOP_inst (
        .WB_i_commit                       (WB_i_commit               ),
        .WB_i_pc                           (WB_i_pc                   ),
        .WB_i_inst                         (WB_i_inst                 ),
        .WB_i_ALU_ALUout                   (WB_i_ALU_ALUout           ),
        .WB_i_ALU_CSR_out                  (WB_i_ALU_CSR_out          ),
        .WB_i_rdata                        (WB_i_rdata                ),
        .WB_i_write_gpr                    (WB_i_write_gpr            ),
        .WB_i_write_csr_1                  (WB_i_write_csr_1          ),
        .WB_i_write_csr_2                  (WB_i_write_csr_2          ),
        .WB_i_mem_to_reg                   (WB_i_mem_to_reg           ),
        .WB_i_rd                           (WB_i_rd                   ),
        .WB_i_csr_rd_1                     (WB_i_csr_rd_1             ),
        .WB_i_csr_rd_2                     (WB_i_csr_rd_2             ),
        .WB_i_system_halt                  (WB_i_system_halt          ),
        .WB_o_rf_busW                      (WB_o_rf_busW              ),
        .WB_o_csr_busW_1                   (WB_o_csr_busW_1           ),
        .WB_o_csr_busW_2                   (WB_o_csr_busW_2           ),
        .WB_o_rd                           (WB_o_rd                   ),
        .WB_o_csr_rd_1                     (WB_o_csr_rd_1             ),
        .WB_o_csr_rd_2                     (WB_o_csr_rd_2             ),
        .WB_o_RegWr                        (WB_o_RegWr                ),
        .WB_o_CSRWr_1                      (WB_o_CSRWr_1              ),
        .WB_o_CSRWr_2                      (WB_o_CSRWr_2              ),
        .WB_o_rs1_data                     (WB_o_rs1_data             ),
        .WB_o_rs2_data                     (WB_o_rs2_data             ),
        .WB_o_csr_rs_data_1                (WB_o_csr_rs_data_1        ),
        .WB_o_csr_rs_data_2                (WB_o_csr_rs_data_2        ),
        .WB_o_pc                           (WB_o_pc                   ),
        .WB_o_inst                         (WB_o_inst                 ),
        .WB_o_commit                       (WB_o_commit               ),
        .WB_o_system_halt                  (WB_o_system_halt          ) 
  );


    // ===========================================================================
  
      ysyx_23060136_CLINT  ysyx_23060136_CLINT_inst (
        .clk(clk),
        .rst(rst),
        .CLINT_MEM_raddr(CLINT_MEM_raddr),
        .CLINT_MEM_rsize(CLINT_MEM_rsize),
        .CLINT_MEM_raddr_valid(CLINT_MEM_raddr_valid),
        .CLINT_MEM_raddr_ready(CLINT_MEM_raddr_ready),
        .CLINT_MEM_rdata(CLINT_MEM_rdata),
        .CLINT_MEM_rdata_valid(CLINT_MEM_rdata_valid),
        .CLINT_MEM_rdata_ready(CLINT_MEM_rdata_ready)
      );


      ysyx_23060136_ARBITER  ysyx_23060136_ARBITER_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .inst_fetch                        (inst_fetch                ),
        .ARBITER_IFU_arready               (ARBITER_IFU_arready       ),
        .ARBITER_IFU_arvalid               (ARBITER_IFU_arvalid       ),
        .ARBITER_IFU_araddr                (ARBITER_IFU_araddr        ),
        .ARBITER_IFU_arid                  (ARBITER_IFU_arid          ),
        .ARBITER_IFU_arlen                 (ARBITER_IFU_arlen         ),
        .ARBITER_IFU_arsize                (ARBITER_IFU_arsize        ),
        .ARBITER_IFU_arburst               (ARBITER_IFU_arburst       ),
        .ARBITER_IFU_rready                (ARBITER_IFU_rready        ),
        .ARBITER_IFU_rvalid                (ARBITER_IFU_rvalid        ),
        .ARBITER_IFU_rresp                 (ARBITER_IFU_rresp         ),
        .ARBITER_IFU_rdata                 (ARBITER_IFU_rdata         ),
        .ARBITER_IFU_rlast                 (ARBITER_IFU_rlast         ),
        .ARBITER_IFU_rid                   (ARBITER_IFU_rid           ),
        .ARBITER_MEM_arready               (ARBITER_MEM_arready       ),
        .ARBITER_MEM_arvalid               (ARBITER_MEM_arvalid       ),
        .ARBITER_MEM_araddr                (ARBITER_MEM_araddr        ),
        .ARBITER_MEM_arid                  (ARBITER_MEM_arid          ),
        .ARBITER_MEM_arlen                 (ARBITER_MEM_arlen         ),
        .ARBITER_MEM_arsize                (ARBITER_MEM_arsize        ),
        .ARBITER_MEM_arburst               (ARBITER_MEM_arburst       ),
        .ARBITER_MEM_rready                (ARBITER_MEM_rready        ),
        .ARBITER_MEM_rvalid                (ARBITER_MEM_rvalid        ),
        .ARBITER_MEM_rresp                 (ARBITER_MEM_rresp         ),
        .ARBITER_MEM_rdata                 (ARBITER_MEM_rdata         ),
        .ARBITER_MEM_rlast                 (ARBITER_MEM_rlast         ),
        .ARBITER_MEM_rid                   (ARBITER_MEM_rid           ),
        .io_master_arready                 (io_master_arready         ),
        .io_master_arvalid                 (io_master_arvalid         ),
        .io_master_araddr                  (io_master_araddr          ),
        .io_master_arid                    (io_master_arid            ),
        .io_master_arlen                   (io_master_arlen           ),
        .io_master_arsize                  (io_master_arsize          ),
        .io_master_arburst                 (io_master_arburst         ),
        .io_master_rready                  (io_master_rready          ),
        .io_master_rvalid                  (io_master_rvalid          ),
        .io_master_rresp                   (io_master_rresp           ),
        .io_master_rdata                   (io_master_rdata           ),
        .io_master_rlast                   (io_master_rlast           ),
        .io_master_rid                     (io_master_rid             ) 
      );
    
                           
endmodule


