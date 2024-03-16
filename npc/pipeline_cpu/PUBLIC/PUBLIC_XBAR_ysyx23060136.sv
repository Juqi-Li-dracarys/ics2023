/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-04 13:10:44 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-04 21:53:30
 */

 // naive xbar for AXI-lite

/* verilator lint_off UNUSED */

 `include "DEFINES_ysyx23060136.sv"


// ===========================================================================
 module PUBLIC_XBAR_ysyx23060136 (
    input                                clk                         ,
    input                                rst                         ,
    // interface for arbiter read
    input               [  31:0]         ARBITER_XBAR_raddr          ,
    input                                ARBITER_XBAR_raddr_valid    ,
    output                               ARBITER_XBAR_raddr_ready    ,

    input                                ARBITER_XBAR_rdata_ready    ,
    output    logic     [  31:0]         ARBITER_XBAR_rdata          ,
    output                               ARBITER_XBAR_rdata_valid    ,
    // ===========================================================================
    // interface for MEM_write
    input               [  31:0]         XBAR_MEM_waddr              ,
    input               [   3:0]         XBAR_MEM_wstrb              ,
    input                                XBAR_MEM_waddr_valid        ,
    output                               XBAR_MEM_waddr_ready        ,

    input               [  31:0]         XBAR_MEM_wdata              ,
    input                                XBAR_MEM_wdata_valid        ,
    output                               XBAR_MEM_wdata_ready        ,
    
    input                                XBAR_MEM_bready             ,
    output   logic      [   1:0]         XBAR_MEM_bresp              ,
    output                               XBAR_MEM_bvalid             ,
    // ===========================================================================
    // interface for sram(下游设备)
    // read
    input                                XBAR_SRAM_aready            ,
    output                               XBAR_SRAM_arvalid           ,
    output   logic      [  31:0]         XBAR_SRAM_araddr            ,
 
    input               [  31:0]         XBAR_SRAM_rdata             ,
    input                                XBAR_SRAM_rvalid            ,
    output                               XBAR_SRAM_rready            ,

    input               [   1:0]         XBAR_SRAM_rresp             ,
    // ===========================================================================
    // write
    input                                XBAR_SRAM_awready           ,
    output    logic     [  31:0]         XBAR_SRAM_awaddr            ,
    output                               XBAR_SRAM_awvalid           ,

    input                                XBAR_SRAM_wready            ,
    output    logic     [  31:0]         XBAR_SRAM_wdata             ,
    output    logic     [   3:0]         XBAR_SRAM_wstrb             ,
    output                               XBAR_SRAM_wvalid            ,
    // ===========================================================================
    // response signal
    input               [   1:0]         XBAR_SRAM_bresp             ,
    input                                XBAR_SRAM_bvalid            ,
    output                               XBAR_SRAM_bready           
 );



   assign       ARBITER_XBAR_raddr_ready    =  r_state_0             ;
   assign       XBAR_SRAM_arvalid           =  r_state_1             ;
   assign       XBAR_SRAM_rready            =  r_state_2             ;
   assign       ARBITER_XBAR_rdata_valid    =  r_state_3             ;


   assign       XBAR_MEM_waddr_ready        =  w_state_0             ;
   assign       XBAR_MEM_wdata_ready        =  w_state_1             ;
   assign       XBAR_SRAM_awvalid           =  w_state_2             ;
   assign       XBAR_SRAM_wvalid            =  w_state_3             ;
   assign       XBAR_SRAM_bready            =  w_state_4             ;
   assign       XBAR_MEM_bvalid             =  w_state_5             ;

   // ===========================================================================
   wire                       r_state_0     =  (r_state == `state_0) ;
   wire                       r_state_1     =  (r_state == `state_1) ;
   wire                       r_state_2     =  (r_state == `state_2) ;
   wire                       r_state_3     =  (r_state == `state_3) ;

   logic        [2 : 0]       r_state       ;
   wire         [2 : 0]       r_state_next  =  ({3{r_state_0}} & ((ARBITER_XBAR_raddr_ready & ARBITER_XBAR_raddr_valid) ? `state_1 : `state_0)) |
                                               ({3{r_state_1}} & ((XBAR_SRAM_aready         & XBAR_SRAM_arvalid)        ? `state_2 : `state_1)) |
                                               ({3{r_state_2}} & ((XBAR_SRAM_rready         & XBAR_SRAM_rvalid)         ? `state_3 : `state_2)) |
                                               ({3{r_state_3}} & ((ARBITER_XBAR_rdata_ready & ARBITER_XBAR_rdata_valid) ? `state_0 : `state_3)) ;


   wire                       w_state_0     =  (w_state == `state_0) ;
   wire                       w_state_1     =  (w_state == `state_1) ;
   wire                       w_state_2     =  (w_state == `state_2) ;
   wire                       w_state_3     =  (w_state == `state_3) ;
   wire                       w_state_4     =  (w_state == `state_4) ;
   wire                       w_state_5     =  (w_state == `state_5) ;



   logic        [2 : 0]       w_state       ;  
   wire         [2 : 0]       w_state_next  =  ({3{w_state_0}} & ((XBAR_MEM_waddr_ready & XBAR_MEM_waddr_valid)        ? `state_1 : `state_0)) |
                                               ({3{w_state_1}} & ((XBAR_MEM_wdata_ready & XBAR_MEM_wdata_valid)        ? `state_2 : `state_1)) |
                                               ({3{w_state_2}} & ((XBAR_SRAM_awready    & XBAR_SRAM_awvalid)           ? `state_3 : `state_2)) |
                                               ({3{w_state_3}} & ((XBAR_SRAM_wready     & XBAR_SRAM_wvalid)            ? `state_4 : `state_3)) |
                                               ({3{w_state_4}} & ((XBAR_SRAM_bready     & XBAR_SRAM_bvalid)            ? `state_5 : `state_4)) |
                                               ({3{w_state_5}} & ((XBAR_MEM_bready      & XBAR_MEM_bvalid)             ? `state_0 : `state_5)) ;

   // ===========================================================================
  
  always_ff @(posedge clk) begin : update_r_state
    if(rst) begin
        r_state  <= `state_0;
    end
    else begin
        r_state  <=  r_state_next;
    end
  end

  always_ff @(posedge clk) begin : trans_raddr
    if(rst) begin
        XBAR_SRAM_araddr <= `PC_RST;
    end
    else if(r_state_next == `state_1) begin
        XBAR_SRAM_araddr <= ARBITER_XBAR_raddr;
    end
  end

  always_ff @(posedge clk) begin : trans_rdata
    if(rst) begin
        ARBITER_XBAR_rdata <= 32'b0;
    end
    else if(r_state_next == `state_3) begin
        ARBITER_XBAR_rdata <= XBAR_SRAM_rdata;
    end
  end

// ===========================================================================

  always_ff @(posedge clk) begin : update_w_state
    if(rst) begin
        w_state           <= `state_0;
    end
    else begin
        w_state           <=  w_state_next;
    end
  end


  always_ff @(posedge clk) begin : trans_waddr
    if(rst) begin
        XBAR_SRAM_awaddr  <= `PC_RST;
        XBAR_SRAM_wstrb   <=  4'b0;
    end
    else if(w_state == `state_1)begin
        XBAR_SRAM_awaddr  <=  XBAR_MEM_waddr;
        XBAR_SRAM_wstrb   <=  XBAR_MEM_wstrb;
    end
  end


  always_ff @(posedge clk) begin : trans_wdata
    if(rst) begin
        XBAR_SRAM_wdata  <=   32'b0;
    end
    else if(w_state == `state_2)begin
        XBAR_SRAM_wdata  <=   XBAR_MEM_wdata;
    end
  end


  always_ff @(posedge clk) begin : trans_respon
    if(rst) begin
        XBAR_MEM_bresp  <=   'b0;
    end
    else if(w_state == `state_5) begin
        XBAR_MEM_bresp  <=   XBAR_SRAM_bresp;
    end
  end


 endmodule


