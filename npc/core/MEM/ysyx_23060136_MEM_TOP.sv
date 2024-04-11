/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-10 17:02:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-10 17:04:42
 */



 `include "ysyx_23060136_DEFINES.sv"


// Top module for SoC memory write and read
// ===========================================================================
module ysyx_23060136_MEM_TOP (
        input                                                     clk                         ,
        input                                                     rst                         ,
        // ===========================================================================
        // forward signal
        input                                                     IFU_o_valid                  ,

        input             [`ysyx_23060136_GPR_W -1 : 0]           IDU_o_rs1                    ,
        input             [`ysyx_23060136_GPR_W -1 : 0]           IDU_o_rs2                    ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            IDU_o_csr_rs                 ,

        input             [`ysyx_23060136_GPR_W -1 : 0]           EXU_i_rs1                    ,
        input             [`ysyx_23060136_GPR_W -1 : 0]           EXU_i_rs2                    ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            EXU_i_csr_rs                 ,

        input             [`ysyx_23060136_BITS_W -1 : 0]          EXU_o_ALU_ALUout             , 
        input             [`ysyx_23060136_BITS_W -1 : 0]          EXU_o_HAZARD_rs2_data        ,
        input                                                     EXU_o_write_mem              ,  
        input                                                     EXU_o_mem_to_reg             ,  
        input                                                     EXU_o_mem_byte               ,  
        input                                                     EXU_o_mem_half               ,  
        input                                                     EXU_o_mem_word               ,  
        input                                                     EXU_o_mem_dword              ,  
        input                                                     EXU_o_mem_byte_u             ,  
        input                                                     EXU_o_mem_half_u             ,  
        input                                                     EXU_o_mem_word_u             , 

        input             [`ysyx_23060136_GPR_W -1 : 0]           EXU_o_rd                      ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            EXU_o_csr_rd_1                ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            EXU_o_csr_rd_2                ,
        input                                                     EXU_o_write_gpr               ,
        input                                                     EXU_o_write_csr_1             ,
        input                                                     EXU_o_write_csr_2             ,

        input                                                     EXU_o_valid                  ,

        // signal from WB to FORWARD in MEM
        input             [`ysyx_23060136_GPR_W -1 : 0]           WB_o_rd                      ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            WB_o_csr_rd_1                ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            WB_o_csr_rd_2                ,
        input                                                     WB_o_write_gpr               ,
        input                                                     WB_o_write_csr_1             ,
        input                                                     WB_o_write_csr_2             ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          WB_o_rs1_data                ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          WB_o_rs2_data                ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          WB_o_csr_rs_data_1           ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          WB_o_csr_rs_data_2           ,

        // ===========================================================================
        // general signal
        input                                                     MEM_i_commit                 ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          MEM_i_pc                     ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          MEM_i_inst                   ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          MEM_i_ALU_ALUout             ,
        input             [`ysyx_23060136_BITS_W -1 : 0]          MEM_i_ALU_CSR_out            ,

        input             [`ysyx_23060136_GPR_W -1 : 0]           MEM_i_rd                     ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            MEM_i_csr_rd_1               ,
        input             [`ysyx_23060136_CSR_W-1 : 0]            MEM_i_csr_rd_2               ,

        input                                                     MEM_i_write_gpr              ,
        input                                                     MEM_i_write_csr_1            ,
        input                                                     MEM_i_write_csr_2            ,
        input                                                     MEM_i_mem_to_reg             ,
        // system signal
        input                                                     MEM_i_system_halt            ,
        // ===========================================================================

        output                                                    MEM_o_commit                 ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          MEM_o_pc                     ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          MEM_o_inst                   ,

        output            [`ysyx_23060136_BITS_W -1 : 0]          MEM_o_ALU_ALUout             ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          MEM_o_ALU_CSR_out            ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          MEM_o_rdata                  ,

        output                                                    MEM_o_write_gpr              ,
        output                                                    MEM_o_write_csr_1            ,
        output                                                    MEM_o_write_csr_2            ,
        output                                                    MEM_o_mem_to_reg             ,

        output            [`ysyx_23060136_GPR_W -1 : 0]           MEM_o_rd                     ,
        output            [`ysyx_23060136_CSR_W-1 : 0]            MEM_o_csr_rd_1               ,
        output            [`ysyx_23060136_CSR_W-1 : 0]            MEM_o_csr_rd_2               ,
        // system signal
        output                                                    MEM_o_system_halt            ,
        // ===========================================================================
        // stall and flush
        output                                                    FORWARD_stallIF              ,
        output                                                    FORWARD_stallID              ,
        output                                                    FORWARD_stallME              ,
        output                                                    FORWARD_stallEX              ,
        output                                                    FORWARD_stallWB              ,
        output                                                    FORWARD_stallEX2             ,
        output                                                    FORWARD_flushEX1             ,

        output            [`ysyx_23060136_BITS_W -1 : 0]          FORWARD_rs1_data_EXU         ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          FORWARD_rs2_data_EXU         ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          FORWARD_csr_rs_data_EXU      ,
        output                                                    FORWARD_rs1_hazard_EXU       ,
        output                                                    FORWARD_rs2_hazard_EXU       ,
        output                                                    FORWARD_csr_rs_hazard_EXU    ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          FORWARD_rs1_data_SEG         ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          FORWARD_rs2_data_SEG         ,
        output            [`ysyx_23060136_BITS_W -1 : 0]          FORWARD_csr_rs_data_SEG      ,
        output                                                    FORWARD_rs1_hazard_SEG       ,
        output                                                    FORWARD_rs2_hazard_SEG       ,
        output                                                    FORWARD_csr_rs_hazard_SEG    ,
        // ===========================================================================
        // interface for arbiter(read)
        input                                                       ARBITER_MEM_raddr_ready      ,
        output             [  `ysyx_23060136_BITS_W -1:0]           ARBITER_MEM_raddr            ,
        output                                                      ARBITER_MEM_raddr_valid      ,
        output             [   2:0]                                 ARBITER_MEM_rsize            ,

        input              [  `ysyx_23060136_BITS_W -1:0]           ARBITER_MEM_rdata            ,
        input                                                       ARBITER_MEM_rdata_valid      ,
        output                                                      ARBITER_MEM_rdata_ready      ,

        input                                                       CLINT_MEM_raddr_ready        ,
        output             [  `ysyx_23060136_BITS_W -1:0]           CLINT_MEM_raddr              ,
        output                                                      CLINT_MEM_raddr_valid        ,
        output             [   2:0]                                 CLINT_MEM_rsize              ,

        input              [  `ysyx_23060136_BITS_W -1:0]           CLINT_MEM_rdata              ,
        input                                                       CLINT_MEM_rdata_valid        ,
        output                                                      CLINT_MEM_rdata_ready        ,
        // ===========================================================================
        // interface for AXI-full(write)
        input                                                     io_master_awready            ,
        output                                                    io_master_awvalid            ,
        output             [  31:0]                               io_master_awaddr             ,
        output             [   3:0]                               io_master_awid               ,
        output             [   7:0]                               io_master_awlen              ,
        output             [   2:0]                               io_master_awsize             ,
        output             [   1:0]                               io_master_awburst            ,
        input                                                     io_master_wready             ,
        output                                                    io_master_wvalid             , 
        output             [  63:0]                               io_master_wdata              ,
        output             [   7:0]                               io_master_wstrb              ,
        output                                                    io_master_wlast              ,
        output                                                    io_master_bready             ,
        input                                                     io_master_bvalid             ,
        input              [   1:0]                               io_master_bresp              ,
        input              [   3:0]                               io_master_bid                ,
        // system
        output                                                    MEM_error_signal
    );



    wire       [  `ysyx_23060136_BITS_W -1:0]       MEM_addr     =  EXU_o_ALU_ALUout;
    wire       [  `ysyx_23060136_BITS_W -1:0]       MEM_wdata    =  EXU_o_HAZARD_rs2_data ;

    // internal read/write ready
    wire                                            MEM_rvalid;
    wire                                            MEM_wdone;

    assign                                          MEM_o_commit       =   MEM_i_commit ;
    assign                                          MEM_o_pc           =   MEM_i_pc     ;
    assign                                          MEM_o_inst         =   MEM_i_inst   ;
    assign                                          MEM_o_ALU_ALUout   =   MEM_i_ALU_ALUout;
    assign                                          MEM_o_ALU_CSR_out  =   MEM_i_ALU_CSR_out;
    assign                                          MEM_o_rd           =   MEM_i_rd;
    assign                                          MEM_o_csr_rd_1     =   MEM_i_csr_rd_1;
    assign                                          MEM_o_csr_rd_2     =   MEM_i_csr_rd_2;
    assign                                          MEM_o_system_halt  =   MEM_i_system_halt;
    assign                                          MEM_o_write_gpr    =   MEM_i_write_gpr;
    assign                                          MEM_o_write_csr_1  =   MEM_i_write_csr_1;
    assign                                          MEM_o_write_csr_2  =   MEM_i_write_csr_2;
    assign                                          MEM_o_mem_to_reg   =   MEM_i_mem_to_reg;


    ysyx_23060136_MEM_DATA_MEM  ysyx_23060136_MEM_DATA_MEM_inst (
        .clk                               (clk                       ),
        .rst                               (rst                       ),
        .FORWARD_flushEX                   (`ysyx_23060136_false      ),
        .FORWARD_stallME                   (FORWARD_stallME           ),
        .MEM_addr                          (MEM_addr                  ),
        .MEM_wdata                         (MEM_wdata                 ),
        .MEM_o_rdata                       (MEM_o_rdata               ),
        .EXU_o_write_mem                   (EXU_o_write_mem           ),
        .EXU_o_mem_to_reg                  (EXU_o_mem_to_reg          ),
        .EXU_o_mem_byte                    (EXU_o_mem_byte            ),
        .EXU_o_mem_half                    (EXU_o_mem_half            ),
        .EXU_o_mem_word                    (EXU_o_mem_word            ),
        .EXU_o_mem_dword                   (EXU_o_mem_dword           ),
        .EXU_o_mem_byte_u                  (EXU_o_mem_byte_u          ),
        .EXU_o_mem_half_u                  (EXU_o_mem_half_u          ),
        .EXU_o_mem_word_u                  (EXU_o_mem_word_u          ),
        .ARBITER_MEM_raddr_ready           (ARBITER_MEM_raddr_ready   ),
        .ARBITER_MEM_raddr                 (ARBITER_MEM_raddr         ),
        .ARBITER_MEM_rsize                 (ARBITER_MEM_rsize         ),
        .ARBITER_MEM_raddr_valid           (ARBITER_MEM_raddr_valid   ),
        .ARBITER_MEM_rdata                 (ARBITER_MEM_rdata         ),
        .ARBITER_MEM_rdata_valid           (ARBITER_MEM_rdata_valid   ),
        .ARBITER_MEM_rdata_ready           (ARBITER_MEM_rdata_ready   ),
        .CLINT_MEM_raddr_ready             (CLINT_MEM_raddr_ready     ),
        .CLINT_MEM_raddr                   (CLINT_MEM_raddr           ),
        .CLINT_MEM_rsize                   (CLINT_MEM_rsize           ),
        .CLINT_MEM_raddr_valid             (CLINT_MEM_raddr_valid     ),
        .CLINT_MEM_rdata                   (CLINT_MEM_rdata           ),
        .CLINT_MEM_rdata_valid             (CLINT_MEM_rdata_valid     ),
        .CLINT_MEM_rdata_ready             (CLINT_MEM_rdata_ready     ),
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
        .MEM_rvalid                        (MEM_rvalid                ),
        .MEM_wdone                         (MEM_wdone                 ),
        .MEM_error_signal                  (MEM_error_signal          ) 
  );



  ysyx_23060136_MEM_FORWARD  ysyx_23060136_MEM_FORWARD_inst (
        .IFU_o_valid                       (IFU_o_valid               ),
        .EXU_o_valid                       (EXU_o_valid               ),
        .MEM_rvalid                        (MEM_rvalid                ),
        .MEM_wdone                         (MEM_wdone                 ),
        .IDU_o_rs1                         (IDU_o_rs1                 ),
        .IDU_o_rs2                         (IDU_o_rs2                 ),
        .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
        .EXU_i_rs1                         (EXU_i_rs1                 ),
        .EXU_i_rs2                         (EXU_i_rs2                 ),
        .EXU_i_csr_rs                      (EXU_i_csr_rs              ),
        .EXU_o_rd                          (EXU_o_rd                  ),
        .EXU_o_csr_rd_1                    (EXU_o_csr_rd_1            ),
        .EXU_o_csr_rd_2                    (EXU_o_csr_rd_2            ),
        .EXU_o_write_gpr                   (EXU_o_write_gpr           ),
        .EXU_o_write_csr_1                 (EXU_o_write_csr_1         ),
        .EXU_o_write_csr_2                 (EXU_o_write_csr_2         ),
        .MEM_i_rd                          (MEM_i_rd                  ),
        .MEM_i_csr_rd_1                    (MEM_i_csr_rd_1            ),
        .MEM_i_csr_rd_2                    (MEM_i_csr_rd_2            ),
        .MEM_i_write_gpr                   (MEM_i_write_gpr           ),
        .MEM_i_write_csr_1                 (MEM_i_write_csr_1         ),
        .MEM_i_write_csr_2                 (MEM_i_write_csr_2         ),
        .MEM_i_mem_to_reg                  (MEM_i_mem_to_reg          ),
        .MEM_o_rdata                       (MEM_o_rdata               ),
        .MEM_i_ALU_ALUout                  (MEM_i_ALU_ALUout          ),
        .MEM_i_ALU_CSR_out                 (MEM_i_ALU_CSR_out         ),
        .WB_o_rd                           (WB_o_rd                   ),
        .WB_o_csr_rd_1                     (WB_o_csr_rd_1             ),
        .WB_o_csr_rd_2                     (WB_o_csr_rd_2             ),
        .WB_o_write_gpr                    (WB_o_write_gpr            ),
        .WB_o_write_csr_1                  (WB_o_write_csr_1          ),
        .WB_o_write_csr_2                  (WB_o_write_csr_2          ),
        .WB_o_rs1_data                     (WB_o_rs1_data             ),
        .WB_o_rs2_data                     (WB_o_rs2_data             ),
        .WB_o_csr_rs_data_1                (WB_o_csr_rs_data_1        ),
        .WB_o_csr_rs_data_2                (WB_o_csr_rs_data_2        ),
        .FORWARD_stallIF                   (FORWARD_stallIF           ),
        .FORWARD_stallID                   (FORWARD_stallID           ),
        .FORWARD_stallEX                   (FORWARD_stallEX           ),
        .FORWARD_stallEX2                  (FORWARD_stallEX2          ),
        .FORWARD_stallME                   (FORWARD_stallME           ),
        .FORWARD_stallWB                   (FORWARD_stallWB           ),
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
        .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG ) 
  );
    


endmodule

