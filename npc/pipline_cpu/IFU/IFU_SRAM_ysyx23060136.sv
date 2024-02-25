/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-26 00:39:34 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-02-26 00:39:34 
 */


 `include "IFU_DEFINES_ysyx23060136.sv"

/* 
 We set SRAM as the slave module for CPU
 目前采用 AXI-lite 版本，不考虑猝发传输等复杂机制

          araddr  ---> -+     
          arvalid --->  AR
          <--- arready -+
        
          <--- rdata   -+
          <--- rresp    |
          <--- rvalid   R
          rready  ---> -+
        
 CPU      awaddr  ---> -+      SRAM
          awvalid --->  AW
          <--- awready -+
        
          wdata   ---> -+
          wstrb   --->  |
          wvalid  --->  W
          <--- wready  -+  

          <--- bresp   -+
          <--- bvalid   B
          bready  ---> -+

 */

// ===========================================================================
module IFU_SRAM_ysyx23060136(
        input                       clk,
        input                       rst,
        // ===========================================================================
        // 1. read addr
        // rvalid 指示CPU发送的 araddr 有效
        input                       s_axi_arvalid,
        input        [31 : 0]       s_axi_araddr,
        output                      s_axi_aready,
        // ===========================================================================
        // 2. read data
        // rready 指示 CPU 可以接受数据
        input                       s_axi_rready,
        output logic [31 : 0]       s_axi_rdata,
        output                      s_axi_rvalid,
        // read response(don't need handshake)
        output       [1 : 0]        s_axi_rresp,
        // ===========================================================================
        // 3. write addr
        input        [31 : 0]       s_axi_awaddr,
        input                       s_axi_awvalid,
        output                      s_axi_awready,
        // ===========================================================================
        // 4. write data
        input        [31 : 0]       s_axi_wdata,
        input        [3 : 0]        s_axi_wstrb,
        input                       s_axi_wvalid,
        output                      s_axi_wready,
        // ===========================================================================
        // 5. response signal
        // backward(write) response signal
        output       [1 : 0]        s_axi_bresp,
        // handshake for backward response signal
        input                       s_axi_bready,
        output                      s_axi_bvalid
    );
    

    import "DPI-C" function int  pmem_read(input int araddr);
    import "DPI-C" function void pmem_write(int waddr, int wdata, byte wmask);

    // r_state machine control
    logic [1 : 0]  r_state;
    logic [1 : 0]  next_r_state     =  ({2{r_state_idle}} & (s_axi_arvalid                 ? `busy : `idle))   | 
                                       ({2{r_state_busy}} & (sram_r_valid                  ? `done : `busy))   | 
                                       ({2{r_state_done}} & (s_axi_rready                  ? `idle : `done))   ;


    // w_state machine control
    logic [1 : 0]  w_state;
    logic [1 : 0]  next_w_state     =  ({2{w_state_idle}} & (s_axi_awvalid                 ? `busy : `idle))   |
                                       ({2{w_state_busy}} & (s_axi_wvalid                  ? `done : `busy))   |
                                       ({2{w_state_done}} & (s_axi_bready & s_axi_bvalid   ? `idle : `done))   ;
    

    logic          r_state_idle     =  (r_state == `idle);
    logic          r_state_busy     =  (r_state == `busy);
    logic          r_state_done     =  (r_state == `done);

    logic          w_state_idle     =  (w_state == `idle);
    logic          w_state_busy     =  (w_state == `busy);
    logic          w_state_done     =  (w_state == `done);


    // r_buffer
    logic [31 : 0] araddr_buffer;
    logic          update_addr_r_buf  =  r_state_idle & (next_r_state == `busy);
    logic          update_rdata       =  r_state_busy & (next_r_state == `done);
    assign         s_axi_aready       =  r_state_idle;
    assign         s_axi_rvalid       =  r_state_done;


    // w_buffer
    logic [31 : 0] awaddr_buffer;
    logic          update_addr_w_buf  =  w_state_idle & (next_w_state == `busy);
    logic          update_wdata       =  w_state_busy & (next_w_state == `done);
    logic [7 : 0]  expand_wmask       =  {{4{1'b0}}, s_axi_wstrb};
    assign         s_axi_awready      =  w_state_idle;
    assign         s_axi_wready       =  w_state_busy;
    assign         s_axi_bvalid       =  sram_w_ready & w_state_done;


    // internal sram, we make some simplification
    // 立刻读完
    logic          sram_r_valid       = `true;
    // 立刻写完
    logic          sram_w_ready       = `true;

    assign         s_axi_rresp        = `false;
    assign         s_axi_bresp        = `false;

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
            araddr_buffer  <=   s_axi_araddr;
        end
    end

    always_ff @(posedge clk) begin : rdata_update
        if(rst) begin
            s_axi_rdata    <=  32'b0;
        end
        else if(update_rdata)begin
            s_axi_rdata    <=  pmem_read(araddr_buffer);
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
            awaddr_buffer  <=   s_axi_awaddr;
        end
    end

    always_ff @(posedge clk) begin : write_data
        if(update_wdata) begin
            pmem_write(awaddr_buffer, s_axi_wdata, expand_wmask);
        end
    end

endmodule



