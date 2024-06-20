/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-11 21:41:45 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 23:33:23
 */


 `include "ysyx_23060136_DEFINES.sv"


// SoC interface simulation model
// ===========================================================================
module ysyxSoCFull(
    input       clock,
    input       reset
);

    wire                            io_interrupt                ;

    wire                            io_master_arready           ;
    wire                            io_master_arvalid           ;
    wire           [  31:0]         io_master_araddr            ;
    wire           [   3:0]         io_master_arid              ;
    wire           [   7:0]         io_master_arlen             ;
    wire           [   2:0]         io_master_arsize            ;
    wire           [   1:0]         io_master_arburst           ;
    wire                            io_master_rready            ;
    wire                            io_master_rvalid            ;
    wire           [   1:0]         io_master_rresp             ;
    wire           [  63:0]         io_master_rdata             ;
    wire                            io_master_rlast             ;
    wire           [   3:0]         io_master_rid               ;

    wire                            io_master_awready           ;
    wire                            io_master_awvalid           ;
    wire           [  31:0]         io_master_awaddr            ;
    wire           [   3:0]         io_master_awid              ;
    wire           [   7:0]         io_master_awlen             ;
    wire           [   2:0]         io_master_awsize            ;
    wire           [   1:0]         io_master_awburst           ;
    wire                            io_master_wready            ;
    wire                            io_master_wvalid            ;
    wire           [  63:0]         io_master_wdata             ;
    wire           [   7:0]         io_master_wstrb             ;
    wire                            io_master_wlast             ;
    wire                            io_master_bready            ;
    wire                            io_master_bvalid            ;
    wire           [   1:0]         io_master_bresp             ;
    wire           [   3:0]         io_master_bid               ;

    wire                            io_slave_awready            ;
    wire                            io_slave_awvalid            ;
    wire           [  31:0]         io_slave_awaddr             ;
    wire           [   3:0]         io_slave_awid               ;
    wire           [   7:0]         io_slave_awlen              ;
    wire           [   2:0]         io_slave_awsize             ;
    wire           [   1:0]         io_slave_awburst            ;
    wire                            io_slave_wready             ;
    wire                            io_slave_wvalid             ;
    wire           [  63:0]         io_slave_wdata              ;
    wire           [   7:0]         io_slave_wstrb              ;
    wire                            io_slave_wlast              ;
    wire                            io_slave_bready             ;
    wire                            io_slave_bvalid             ;
    wire           [   1:0]         io_slave_bresp              ;
    wire           [   3:0]         io_slave_bid                ;

    wire                            io_slave_arready            ;
    wire                            io_slave_arvalid            ;
    wire           [  31:0]         io_slave_araddr             ;
    wire           [   3:0]         io_slave_arid               ;
    wire           [   7:0]         io_slave_arlen              ;
    wire           [   2:0]         io_slave_arsize             ;
    wire           [   1:0]         io_slave_arburst            ;
    wire                            io_slave_rready             ;
    wire                            io_slave_rvalid             ;
    wire           [   1:0]         io_slave_rresp              ;
    wire           [  63:0]         io_slave_rdata              ;
    wire                            io_slave_rlast              ;
    wire           [   3:0]         io_slave_rid                ;


    wire            [   5:0]        io_sram0_addr               ;     
    wire                            io_sram0_cen                ;     
    wire                            io_sram0_wen                ;     
    wire            [ 127:0]        io_sram0_wmask              ;     
    wire            [ 127:0]        io_sram0_wdata              ;     
    wire            [ 127:0]        io_sram0_rdata              ;
    wire            [   5:0]        io_sram1_addr               ;     
    wire                            io_sram1_cen                ;     
    wire                            io_sram1_wen                ;     
    wire            [ 127:0]        io_sram1_wmask              ;     
    wire            [ 127:0]        io_sram1_wdata              ;     
    wire            [ 127:0]        io_sram1_rdata              ;
    wire            [   5:0]        io_sram2_addr               ;     
    wire                            io_sram2_cen                ;     
    wire                            io_sram2_wen                ;     
    wire            [ 127:0]        io_sram2_wmask              ;     
    wire            [ 127:0]        io_sram2_wdata              ;     
    wire            [ 127:0]        io_sram2_rdata              ;
    wire            [   5:0]        io_sram3_addr               ;     
    wire                            io_sram3_cen                ;     
    wire                            io_sram3_wen                ;     
    wire            [ 127:0]        io_sram3_wmask              ;     
    wire            [ 127:0]        io_sram3_wdata              ;     
    wire            [ 127:0]        io_sram3_rdata              ;
    wire            [   5:0]        io_sram4_addr               ;     
    wire                            io_sram4_cen                ;     
    wire                            io_sram4_wen                ;     
    wire            [ 127:0]        io_sram4_wmask              ;     
    wire            [ 127:0]        io_sram4_wdata              ;     
    wire            [ 127:0]        io_sram4_rdata              ;
    wire            [   5:0]        io_sram5_addr               ;     
    wire                            io_sram5_cen                ;     
    wire                            io_sram5_wen                ;     
    wire            [ 127:0]        io_sram5_wmask              ;     
    wire            [ 127:0]        io_sram5_wdata              ;     
    wire            [ 127:0]        io_sram5_rdata              ;
    wire            [   5:0]        io_sram6_addr               ;
    wire                            io_sram6_cen                ;     
    wire                            io_sram6_wen                ;     
    wire            [ 127:0]        io_sram6_wmask              ;     
    wire            [ 127:0]        io_sram6_wdata              ;     
    wire            [ 127:0]        io_sram6_rdata              ;      
    wire            [   5:0]        io_sram7_addr               ;     
    wire                            io_sram7_cen                ;     
    wire                            io_sram7_wen                ;     
    wire            [ 127:0]        io_sram7_wmask              ;     
    wire            [ 127:0]        io_sram7_wdata              ;     
    wire            [ 127:0]        io_sram7_rdata              ;         
          

    wire                                    inst_fetch              ;
    
    ysyx_23060136  cpu (
        .clock                             (clock                     ),
        .reset                             (reset                     ),
        .io_interrupt                      (io_interrupt              ),
        .inst_fetch                        (inst_fetch                ),

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
        .io_master_rid                     (io_master_rid             ),
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

        .io_slave_awready                  (io_slave_awready          ),    
        .io_slave_awvalid                  (io_slave_awvalid          ),                     
        .io_slave_awaddr                   (io_slave_awaddr           ),                     
        .io_slave_awid                     (io_slave_awid             ),                     
        .io_slave_awlen                    (io_slave_awlen            ),                     
        .io_slave_awsize                   (io_slave_awsize           ),                     
        .io_slave_awburst                  (io_slave_awburst          ),                     
        .io_slave_wready                   (io_slave_wready           ),                     
        .io_slave_wvalid                   (io_slave_wvalid           ),                     
        .io_slave_wdata                    (io_slave_wdata            ),                     
        .io_slave_wstrb                    (io_slave_wstrb            ),                     
        .io_slave_wlast                    (io_slave_wlast            ),                     
        .io_slave_bready                   (io_slave_bready           ),                     
        .io_slave_bvalid                   (io_slave_bvalid           ),                     
        .io_slave_bresp                    (io_slave_bresp            ),                     
        .io_slave_bid                      (io_slave_bid              ),    

        .io_slave_arready                  (io_slave_arready          ),                                               
        .io_slave_arvalid                  (io_slave_arvalid          ),                                               
        .io_slave_araddr                   (io_slave_araddr           ),                                               
        .io_slave_arid                     (io_slave_arid             ),                                               
        .io_slave_arlen                    (io_slave_arlen            ),                                               
        .io_slave_arsize                   (io_slave_arsize           ),                                               
        .io_slave_arburst                  (io_slave_arburst          ),                                               
        .io_slave_rready                   (io_slave_rready           ),                                               
        .io_slave_rvalid                   (io_slave_rvalid           ),                                               
        .io_slave_rresp                    (io_slave_rresp            ),                                               
        .io_slave_rdata                    (io_slave_rdata            ),                                               
        .io_slave_rlast                    (io_slave_rlast            ),                                               
        .io_slave_rid                      (io_slave_rid              ),                                               

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
        .io_sram3_rdata                    (io_sram3_rdata            ),

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
        .io_sram7_rdata                    (io_sram7_rdata            ) 
    );


 ysyx_23060136_SDRAM  SDRAM (
        .clk                               (clock                     ),
        .rst                               (reset                     ),
        .inst_fetch                        (inst_fetch                 ),
        .io_slave_awready                  (io_master_awready          ),
        .io_slave_awvalid                  (io_master_awvalid          ),
        .io_slave_awaddr                   (io_master_awaddr           ),
        .io_slave_awid                     (io_master_awid             ),
        .io_slave_awlen                    (io_master_awlen            ),
        .io_slave_awsize                   (io_master_awsize           ),
        .io_slave_awburst                  (io_master_awburst          ),
        .io_slave_wready                   (io_master_wready           ),
        .io_slave_wvalid                   (io_master_wvalid           ),
        .io_slave_wdata                    (io_master_wdata            ),
        .io_slave_wstrb                    (io_master_wstrb            ),
        .io_slave_wlast                    (io_master_wlast            ),
        .io_slave_bready                   (io_master_bready           ),
        .io_slave_bvalid                   (io_master_bvalid           ),
        .io_slave_bresp                    (io_master_bresp            ),
        .io_slave_bid                      (io_master_bid              ),
        
        .io_slave_arready                  (io_master_arready          ),
        .io_slave_arvalid                  (io_master_arvalid          ),
        .io_slave_araddr                   (io_master_araddr           ),
        .io_slave_arid                     (io_master_arid             ),
        .io_slave_arlen                    (io_master_arlen            ),
        .io_slave_arsize                   (io_master_arsize           ),
        .io_slave_arburst                  (io_master_arburst          ),
        .io_slave_rready                   (io_master_rready           ),
        .io_slave_rvalid                   (io_master_rvalid           ),
        .io_slave_rresp                    (io_master_rresp            ),
        .io_slave_rdata                    (io_master_rdata            ),
        .io_slave_rlast                    (io_master_rlast            ),
        .io_slave_rid                      (io_master_rid              ) 
  );


  S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst0 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram0_rdata            ),
        .CEN                               (io_sram0_cen              ),
        .WEN                               (io_sram0_wen              ),
        .BWEN                              (io_sram0_wmask            ),
        .A                                 (io_sram0_addr             ),
        .D                                 (io_sram0_wdata            )
  );

    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst1 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram1_rdata            ),
        .CEN                               (io_sram1_cen              ),
        .WEN                               (io_sram1_wen              ),
        .BWEN                              (io_sram1_wmask            ),
        .A                                 (io_sram1_addr             ),
        .D                                 (io_sram1_wdata            ) 
    );

    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst2 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram2_rdata            ),
        .CEN                               (io_sram2_cen              ),
        .WEN                               (io_sram2_wen              ),
        .BWEN                              (io_sram2_wmask            ),
        .A                                 (io_sram2_addr             ),
        .D                                 (io_sram2_wdata            ) 
    );

    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst3 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram3_rdata            ),
        .CEN                               (io_sram3_cen              ),
        .WEN                               (io_sram3_wen              ),
        .BWEN                              (io_sram3_wmask            ),
        .A                                 (io_sram3_addr             ),
        .D                                 (io_sram3_wdata            ) 
    );


    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst4 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram4_rdata            ),
        .CEN                               (io_sram4_cen              ),
        .WEN                               (io_sram4_wen              ),
        .BWEN                              (io_sram4_wmask            ),
        .A                                 (io_sram4_addr             ),
        .D                                 (io_sram4_wdata            ) 
    );


    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst5 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram5_rdata            ),
        .CEN                               (io_sram5_cen              ),
        .WEN                               (io_sram5_wen              ),
        .BWEN                              (io_sram5_wmask            ),
        .A                                 (io_sram5_addr             ),
        .D                                 (io_sram5_wdata            ) 
    );


    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst6 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram6_rdata            ),
        .CEN                               (io_sram6_cen              ),
        .WEN                               (io_sram6_wen              ),
        .BWEN                              (io_sram6_wmask            ),
        .A                                 (io_sram6_addr             ),
        .D                                 (io_sram6_wdata            ) 
    );


    S011HD1P_X32Y2D128_BW  S011HD1P_X32Y2D128_BW_inst7 (
        .CLK                               (clock                     ),
        .Q                                 (io_sram7_rdata            ),
        .CEN                               (io_sram7_cen              ),
        .WEN                               (io_sram7_wen              ),
        .BWEN                              (io_sram7_wmask            ),
        .A                                 (io_sram7_addr             ),
        .D                                 (io_sram7_wdata            ) 
    );


endmodule


