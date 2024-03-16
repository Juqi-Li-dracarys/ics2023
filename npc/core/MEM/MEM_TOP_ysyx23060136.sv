/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-28 13:07:41 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-16 14:49:31
 */

 `include "DEFINES_ysyx23060136.sv"

// Top module for SoC memory write and read
// ===========================================================================
module MEM_TOP_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
        // ===========================================================================
        // forward signal
        input                               IFU_o_valid                  ,

        input             [4 : 0]           IDU_o_rs1                    ,
        input             [4 : 0]           IDU_o_rs2                    ,
        input             [2 : 0]           IDU_o_csr_rs                 ,

        input             [4 : 0]           EXU_o_rs1                    ,
        input             [4 : 0]           EXU_o_rs2                    ,
        input             [2 : 0]           EXU_o_csr_rs                 ,

        // signal from WB to FORWARD in MEM
        input             [4 : 0]           WB_o_rd                      ,
        input             [2 : 0]           WB_o_csr_rd                  ,
        input                               WB_o_write_gpr               ,
        input                               WB_o_write_csr               ,
        input             [31 : 0]          WB_o_rs1_data                ,
        input             [31 : 0]          WB_o_rs2_data                ,
        input             [31 : 0]          WB_o_csr_rs_data             ,

        // 更新读写逻辑的脉冲信号
        input                               MEM_i_raddr_change           ,  
        input                               MEM_i_waddr_change           ,
        // ===========================================================================
        // general signal
        input                               MEM_i_commit                 ,
        input             [31 : 0]          MEM_i_pc                     ,
        input             [31 : 0]          MEM_i_inst                   ,
        input             [31 : 0]          MEM_i_ALU_ALUout             ,
        input             [31 : 0]          MEM_i_ALU_CSR_out            ,

        input             [4 : 0]           MEM_i_rd                     ,
        input             [31 : 0]          MEM_i_rs2_data               ,
        // mem
        input             [2 : 0]           MEM_i_csr_rd                 ,
        // mem
        input                               MEM_i_write_gpr              ,
        input                               MEM_i_write_csr              ,
        input                               MEM_i_mem_to_reg             ,

        input                               MEM_i_write_mem              ,
        input                               MEM_i_mem_byte               ,
        input                               MEM_i_mem_half               ,
        input                               MEM_i_mem_word               ,
        input                               MEM_i_mem_byte_u             ,
        input                               MEM_i_mem_half_u             ,
        // system signal
        input                               MEM_i_system_halt            ,
        // ===========================================================================

        output                              MEM_o_commit                 ,
        output            [31 : 0]          MEM_o_pc                     ,
        output            [31 : 0]          MEM_o_inst                   ,

        output            [31 : 0]          MEM_o_ALU_ALUout             ,
        output            [31 : 0]          MEM_o_ALU_CSR_out            ,
        output            [31 : 0]          MEM_o_rdata                  ,

        output                              MEM_o_write_gpr              ,
        output                              MEM_o_write_csr              ,
        output                              MEM_o_mem_to_reg             ,

        output            [4 : 0]           MEM_o_rd                     ,
        output            [2 : 0]           MEM_o_csr_rd                 ,
        // system signal
        output                              MEM_o_system_halt            ,
        // ===========================================================================
        // stall and flush
        output                              FORWARD_stallIF              ,
        output                              FORWARD_stallID              ,
        output                              FORWARD_stallME              ,
        output                              FORWARD_stallEX              ,
        output                              FORWARD_stallWB              ,

        output            [31 : 0]          FORWARD_rs1_data_EXU         ,
        output            [31 : 0]          FORWARD_rs2_data_EXU         ,
        output            [31 : 0]          FORWARD_csr_rs_data_EXU      ,
        output                              FORWARD_rs1_hazard_EXU       ,
        output                              FORWARD_rs2_hazard_EXU       ,
        output                              FORWARD_csr_rs_hazard_EXU    ,
        output            [31 : 0]          FORWARD_rs1_data_SEG         ,
        output            [31 : 0]          FORWARD_rs2_data_SEG         ,
        output            [31 : 0]          FORWARD_csr_rs_data_SEG      ,
        output                              FORWARD_rs1_hazard_SEG       ,
        output                              FORWARD_rs2_hazard_SEG       ,
        output                              FORWARD_csr_rs_hazard_SEG    ,
        // ===========================================================================
        // interface for arbiter(read)
        input                               ARBITER_MEM_raddr_ready      ,
        output             [  31:0]         ARBITER_MEM_raddr            ,
        output                              ARBITER_MEM_raddr_valid      ,
        output             [   2:0]         ARBITER_MEM_rsize            ,

        input              [  63:0]         ARBITER_MEM_rdata            ,
        input                               ARBITER_MEM_rdata_valid      ,
        output                              ARBITER_MEM_rdata_ready      ,

        input                               CLINT_MEM_raddr_ready        ,
        output             [  31:0]         CLINT_MEM_raddr              ,
        output                              CLINT_MEM_raddr_valid        ,
        output             [   2:0]         CLINT_MEM_rsize              ,

        input              [  63:0]         CLINT_MEM_rdata              ,
        input                               CLINT_MEM_rdata_valid        ,
        output                              CLINT_MEM_rdata_ready        ,
        // ===========================================================================
        // interface for AXI-full(write)
        input                               io_master_awready            ,
        output                              io_master_awvalid            ,
        output             [  31:0]         io_master_awaddr             ,
        output             [   3:0]         io_master_awid               ,
        output             [   7:0]         io_master_awlen              ,
        output             [   2:0]         io_master_awsize             ,
        output             [   1:0]         io_master_awburst            ,
        input                               io_master_wready             ,
        output                              io_master_wvalid             , 
        output             [  63:0]         io_master_wdata              ,
        output             [   7:0]         io_master_wstrb              ,
        output                              io_master_wlast              ,
        output                              io_master_bready             ,
        input                               io_master_bvalid             ,
        input              [   1:0]         io_master_bresp              ,
        input              [   3:0]         io_master_bid                ,
        // system
        output                              MEM_error_signal
    );



    wire       [  31:0]            MEM_raddr          =  MEM_i_ALU_ALUout;
    // read enable
    wire       [  31:0]            MEM_waddr          =  MEM_i_ALU_ALUout;
    wire       [  31:0]            MEM_wdata          =  MEM_i_rs2_data;

    // internal read/write ready
    wire                           MEM_rvalid;
    wire                           MEM_wready;

    assign                         MEM_o_commit       =   MEM_i_commit ;
    assign                         MEM_o_pc           =   MEM_i_pc     ;
    assign                         MEM_o_inst         =   MEM_i_inst   ;
    assign                         MEM_o_ALU_ALUout   =   MEM_i_ALU_ALUout;
    assign                         MEM_o_ALU_CSR_out  =   MEM_i_ALU_CSR_out;
    assign                         MEM_o_rd           =   MEM_i_rd;
    assign                         MEM_o_csr_rd       =   MEM_i_csr_rd;
    assign                         MEM_o_system_halt  =   MEM_i_system_halt;
    assign                         MEM_o_write_gpr    =   MEM_i_write_gpr;
    assign                         MEM_o_write_csr    =   MEM_i_write_csr;
    assign                         MEM_o_mem_to_reg   =   MEM_i_mem_to_reg;
    



    MEM_DATA_MEM_ysyx23060136  MEM_DATA_MEM_ysyx23060136_inst (
                               .clk                               (clk                       ),
                               .rst                               (rst                       ),
                               .MEM_i_raddr_change                (MEM_i_raddr_change        ),
                               .MEM_i_waddr_change                (MEM_i_waddr_change        ),
                               .MEM_raddr                         (MEM_raddr                 ),
                               .MEM_rdata                         (MEM_o_rdata               ),
                               .MEM_waddr                         (MEM_waddr                 ),
                               .MEM_wdata                         (MEM_wdata                 ),
                               .MEM_mem_byte                      (MEM_i_mem_byte            ),
                               .MEM_mem_half                      (MEM_i_mem_half            ),
                               .MEM_mem_word                      (MEM_i_mem_word            ),
                               .MEM_mem_byte_u                    (MEM_i_mem_byte_u          ),
                               .MEM_mem_half_u                    (MEM_i_mem_half_u          ),
                               .CLINT_MEM_raddr_ready             (CLINT_MEM_raddr_ready     ),    
                               .CLINT_MEM_raddr                   (CLINT_MEM_raddr           ),    
                               .CLINT_MEM_rsize                   (CLINT_MEM_rsize           ),    
                               .CLINT_MEM_raddr_valid             (CLINT_MEM_raddr_valid     ),    
                               .CLINT_MEM_rdata                   (CLINT_MEM_rdata           ),    
                               .CLINT_MEM_rdata_valid             (CLINT_MEM_rdata_valid     ),    
                               .CLINT_MEM_rdata_ready             (CLINT_MEM_rdata_ready     ),    

                               .ARBITER_MEM_raddr_ready           (ARBITER_MEM_raddr_ready   ),
                               .ARBITER_MEM_raddr                 (ARBITER_MEM_raddr         ),
                               .ARBITER_MEM_rsize                 (ARBITER_MEM_rsize         ),
                               .ARBITER_MEM_raddr_valid           (ARBITER_MEM_raddr_valid   ),
                               .ARBITER_MEM_rdata                 (ARBITER_MEM_rdata         ),
                               .ARBITER_MEM_rdata_valid           (ARBITER_MEM_rdata_valid   ),
                               .ARBITER_MEM_rdata_ready           (ARBITER_MEM_rdata_ready   ),
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
                               .MEM_wready                        (MEM_wready                ),
                               .MEM_error_signal                  (MEM_error_signal          )
                           );

    


    MEM_FORWARD_ysyx23060136  MEM_FORWARD_ysyx23060136_inst (
                                    .IFU_o_valid                       (IFU_o_valid               ),
                                    .MEM_rvalid                        (MEM_rvalid                ),
                                    .MEM_wready                        (MEM_wready                ),
                                    .IDU_o_rs1                         (IDU_o_rs1                 ),
                                    .IDU_o_rs2                         (IDU_o_rs2                 ),
                                    .IDU_o_csr_rs                      (IDU_o_csr_rs              ),
                                    .EXU_o_rs1                         (EXU_o_rs1                 ),
                                    .EXU_o_rs2                         (EXU_o_rs2                 ),
                                    .EXU_o_csr_rs                      (EXU_o_csr_rs              ),
                                    .MEM_i_mem_to_reg                  (MEM_i_mem_to_reg          ),
                                    .MEM_i_rd                          (MEM_i_rd                  ),
                                    .MEM_i_csr_rd                      (MEM_i_csr_rd              ),
                                    .MEM_i_write_gpr                   (MEM_i_write_gpr           ),
                                    .MEM_i_write_csr                   (MEM_i_write_csr           ),
                                    .MEM_o_rdata                       (MEM_o_rdata               ),
                                    .MEM_i_ALU_ALUout                  (MEM_i_ALU_ALUout          ),
                                    .MEM_i_ALU_CSR_out                 (MEM_i_ALU_CSR_out         ),
                                    .WB_o_rd                           (WB_o_rd                   ),
                                    .WB_o_csr_rd                       (WB_o_csr_rd               ),
                                    .WB_o_write_gpr                    (WB_o_write_gpr            ),
                                    .WB_o_write_csr                    (WB_o_write_csr            ),
                                    .WB_o_rs1_data                     (WB_o_rs1_data             ),
                                    .WB_o_rs2_data                     (WB_o_rs2_data             ),
                                    .WB_o_csr_rs_data                  (WB_o_csr_rs_data          ),
                                    .FORWARD_stallIF                   (FORWARD_stallIF           ),
                                    .FORWARD_stallID                   (FORWARD_stallID           ),
                                    .FORWARD_stallEX                   (FORWARD_stallEX           ),
                                    .FORWARD_stallME                   (FORWARD_stallME           ),
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
                                    .FORWARD_csr_rs_hazard_SEG         (FORWARD_csr_rs_hazard_SEG ) 
                              );

endmodule

