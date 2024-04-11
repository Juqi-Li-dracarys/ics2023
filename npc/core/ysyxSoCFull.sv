/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-11 21:41:45 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-11 21:57:01
 */


 `include "ysyx_23060136_DEFINES.sv"


module ysyxSoCFull(
    input clock,
    input reset
);


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
          

ysyx_23060136  ysyx_23060136_inst (
    .clock                             (clock                     ),
    .reset                             (reset                     ),
    .io_interrupt                      (io_interrupt              ),
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

  
endmodule



module ysyx23060136_MEMORY (
        input                               clk                        ,
        input                               rst                        ,


    );
    

    import "DPI-C" function int  pmem_read(input int araddr);
    import "DPI-C" function void pmem_write(int waddr, int wdata, byte wmask);

    // r_state machine control
    logic [1 : 0]  r_state;
    // handshake -> go to the netx stage
    wire  [1 : 0]  next_r_state     =  ({2{r_state_idle}} & (XBAR_SRAM_arvalid & XBAR_SRAM_aready  ? `busy : `idle))   | 
                                       ({2{r_state_busy}} & (sram_r_valid                          ? `done : `busy))   | 
                                       ({2{r_state_done}} & (XBAR_SRAM_rready  & XBAR_SRAM_rvalid  ? `idle : `done))   ;

    // ===========================================================================
    // w_state machine control
    logic [1 : 0]  w_state;
    // handshake -> go to the netx stage
    wire  [1 : 0]  next_w_state     =  ({2{w_state_idle}} & (XBAR_SRAM_awvalid & XBAR_SRAM_awready ? `busy : `idle))   |
                                       ({2{w_state_busy}} & (XBAR_SRAM_wvalid                      ? `done : `busy))   |
                                       ({2{w_state_done}} & (XBAR_SRAM_bready & XBAR_SRAM_bvalid   ? `idle : `done))   ;
    

    wire           r_state_idle     =  (r_state == `idle);
    wire           r_state_busy     =  (r_state == `busy);
    wire           r_state_done     =  (r_state == `done);

    wire           w_state_idle     =  (w_state == `idle);
    wire           w_state_busy     =  (w_state == `busy);
    wire           w_state_done     =  (w_state == `done);


    // r_buffer
    logic [31 : 0] araddr_buffer;
    wire           update_addr_r_buf      =  r_state_idle & (next_r_state == `busy);
    wire           update_rdata           =  r_state_busy & (next_r_state == `done);
    assign         XBAR_SRAM_aready       =  r_state_idle;
    assign         XBAR_SRAM_rvalid       =  r_state_done;


    // w_buffer
    logic [31 : 0] awaddr_buffer;
    wire           update_addr_w_buf      =  w_state_idle & (next_w_state == `busy);
    wire           update_wdata           =  w_state_busy & (next_w_state == `done);
    wire  [7 : 0]  expand_wmask           =  {{4{1'b0}}, XBAR_SRAM_wstrb};
    assign         XBAR_SRAM_awready      =  w_state_idle;
    assign         XBAR_SRAM_wready       =  w_state_busy;
    assign         XBAR_SRAM_bvalid       =  sram_w_ready & w_state_done;


    // internal sram, we make some simplification
    // 立刻读完
    wire           sram_r_valid       = `true;
    // 立刻写完
    wire           sram_w_ready       = `true;

    // 默认无报错
    assign         XBAR_SRAM_rresp        = `false;
    assign         XBAR_SRAM_bresp        = `false;

    // ===========================================================================
    always_ff @(posedge clk) begin : r_state_machine
        if(rst) begin
            r_state       <=  `idle;
        end
        else begin
            r_state       <=   next_r_state;
        end
    end
    
    always_ff @(posedge clk) begin : raddr_buf_update
        if(rst) begin
            araddr_buffer  <=  `PC_RST;
        end
        else if(update_addr_r_buf)begin
            araddr_buffer  <=   XBAR_SRAM_araddr;
        end
    end

    always_ff @(posedge clk) begin : rdata_update
        if(rst) begin
            XBAR_SRAM_rdata    <=  32'b0;
        end
        else if(update_rdata)begin
            XBAR_SRAM_rdata    <=  pmem_read(araddr_buffer);
        end
    end

    // ===========================================================================

    always_ff @(posedge clk) begin : w_state_machine
        if(rst) begin
            w_state       <=  `idle;
        end
        else begin
            w_state       <=  next_w_state;
        end
    end

    always_ff @(posedge clk) begin : waddr_buf_update
        if(rst) begin
            awaddr_buffer  <=  `PC_RST;
        end
        else if(update_addr_w_buf)begin
            awaddr_buffer  <=   XBAR_SRAM_awaddr;
        end
    end

    always_ff @(posedge clk) begin : write_data
        if(update_wdata) begin
            pmem_write(awaddr_buffer, XBAR_SRAM_wdata, expand_wmask);
        end
    end

endmodule


