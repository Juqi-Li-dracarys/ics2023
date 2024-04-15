/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-11 21:41:45 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-11 21:57:01
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
          

    ysyx_23060136  cpu (
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


 ysyx_23060136_SDRAM  SDRAM (
        .clk                               (clock                     ),
        .rst                               (reset                     ),
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

  
endmodule





// simulation model of memory
// ===========================================================================
module ysyx_23060136_SDRAM (
        input                               clk                        ,
        input                               rst                        ,

        output                              io_slave_awready           ,
        input                               io_slave_awvalid           ,
        input             [  31:0]          io_slave_awaddr            ,
        input             [   3:0]          io_slave_awid              ,
        input             [   7:0]          io_slave_awlen             ,
        input             [   2:0]          io_slave_awsize            ,
        input             [   1:0]          io_slave_awburst           ,
        output                              io_slave_wready            ,
        input                               io_slave_wvalid            ,
        input             [  63:0]          io_slave_wdata             ,
        input             [   7:0]          io_slave_wstrb             ,
        input                               io_slave_wlast             ,
        input                               io_slave_bready            ,
        output                              io_slave_bvalid            ,
        output            [   1:0]          io_slave_bresp             ,
        output            [   3:0]          io_slave_bid               ,

        output                              io_slave_arready           ,
        input                               io_slave_arvalid           ,
        input             [  31:0]          io_slave_araddr            ,
        input             [   3:0]          io_slave_arid              ,
        input             [   7:0]          io_slave_arlen             ,
        input             [   2:0]          io_slave_arsize            ,
        input             [   1:0]          io_slave_arburst           ,
        input                               io_slave_rready            ,
        output                              io_slave_rvalid            ,
        output            [   1:0]          io_slave_rresp             ,
        output   logic    [  63:0]          io_slave_rdata             ,
        output                              io_slave_rlast             ,
        output            [   3:0]          io_slave_rid               
    );
    

    import "DPI-C" function longint pmem_read(input int araddr);
    import "DPI-C" function void pmem_write(int waddr, longint wdata, byte wmask);


    // 立刻读完
    wire           memory_r_valid       = `ysyx_23060136_true;
    // 立刻写完
    wire           memory_w_valid       = `ysyx_23060136_true;


    // r_state machine control
    logic [1 : 0]  r_state;
    // handshake -> go to the netx stage
    logic [1 : 0]  next_r_state;


    wire           r_state_idle      =  (r_state == `ysyx_23060136_idle);
    wire           r_state_ready     =  (r_state == `ysyx_23060136_ready);
    wire           r_state_wait      =  (r_state == `ysyx_23060136_wait);

    assign         io_slave_arready     =  r_state_idle;
    assign         io_slave_rvalid      =  r_state_wait;
    assign         io_slave_rid         =  io_slave_arid;

    assign         io_slave_rlast       =  r_state_wait;

    
    always_comb begin : r_state_update
        case(r_state)
            `ysyx_23060136_idle: begin
                if(io_slave_arready & io_slave_arvalid) begin
                    next_r_state = `ysyx_23060136_ready;
                end
                else begin
                    next_r_state = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(memory_r_valid) begin
                    next_r_state = `ysyx_23060136_wait;
                end
                else begin
                    next_r_state = `ysyx_23060136_ready;
                end
            end
            `ysyx_23060136_wait: begin
                if(io_slave_rready & io_slave_rvalid) begin
                    next_r_state = `ysyx_23060136_idle;
                end
                else begin
                    next_r_state = `ysyx_23060136_wait;
                end
            end
            default: next_r_state = `ysyx_23060136_idle;
        endcase
    end

    always_ff @(posedge clk) begin : r_state_machine
        if(rst) begin
            r_state       <=  `ysyx_23060136_idle;
        end
        else begin
            r_state       <=   next_r_state;
        end
    end


    logic [31 : 0] araddr_buffer;

    always_ff @(posedge clk) begin : raddr_buf_update
        if(rst) begin
            araddr_buffer  <=  `ysyx_23060136_false;
        end
        else if(r_state_idle & (next_r_state == `ysyx_23060136_ready))begin
            araddr_buffer  <=   io_slave_araddr;
        end
    end

    always_ff @(posedge clk) begin : rdata_update
        if(rst) begin
            io_slave_rdata    <=  `ysyx_23060136_false;
        end
        else if(r_state_ready & (next_r_state == `ysyx_23060136_wait))begin
            io_slave_rdata    <=  pmem_read(araddr_buffer);
        end
    end


    // ===========================================================================
    // w_state machine control
    logic  [1 : 0]   w_state;
    // handshake -> go to the netx stage
    logic  [1 : 0]   next_w_state;

    wire           w_state_idle      =  (w_state == `ysyx_23060136_idle);
    wire           w_state_ready     =  (w_state == `ysyx_23060136_ready);
    wire           w_state_wait      =  (w_state == `ysyx_23060136_wait);



    assign         io_slave_awready      =  w_state_idle;
    assign         io_slave_wready       =  w_state_idle;
    assign         io_slave_bvalid       =  w_state_wait;

    // 默认无报错
    assign         io_slave_rresp        = `ysyx_23060136_false;
    assign         io_slave_bresp        = `ysyx_23060136_false;

    assign         io_slave_bid          =  io_slave_arid;      

            
    
    always_comb begin : w_state_update
        case(w_state)
            `ysyx_23060136_idle: begin
                if(io_slave_awvalid & io_slave_awready & io_slave_wvalid & io_slave_wready) begin
                    next_w_state = `ysyx_23060136_ready;
                end
                else begin
                    next_w_state = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(memory_w_valid) begin
                    next_w_state = `ysyx_23060136_wait;
                end
                else begin
                    next_w_state = `ysyx_23060136_ready;
                end
            end
            `ysyx_23060136_wait: begin
                if(io_slave_bready & io_slave_bvalid) begin
                    next_w_state = `ysyx_23060136_idle;
                end
                else begin
                    next_w_state = `ysyx_23060136_wait;
                end
            end
            default: next_w_state = `ysyx_23060136_idle;
        endcase
    end

    always_ff @(posedge clk) begin : w_state_machine
        if(rst) begin
            w_state       <=   `ysyx_23060136_idle;
        end
        else begin
            w_state       <=  next_w_state;
        end
    end


    // w_buffer
    logic       [31 : 0]    awaddr_buffer       ;
    logic       [63 : 0]    wdata_buffer        ;
    logic       [7 : 0]     wstrb_buffer        ;

    always_ff @(posedge clk) begin : buf_update
        if(rst) begin
            awaddr_buffer  <=  `ysyx_23060136_false;
            wdata_buffer   <=  `ysyx_23060136_false;
            wstrb_buffer   <=  `ysyx_23060136_false;
        end
        else if(w_state_idle & (next_w_state == `ysyx_23060136_ready))begin
            awaddr_buffer  <=   io_slave_awaddr;
            wdata_buffer   <=   io_slave_wdata;
            wstrb_buffer   <=   io_slave_wstrb;
        end
    end


    always_ff @(posedge clk) begin : write_data
        if(w_state_ready & (next_w_state == `ysyx_23060136_wait)) begin
            pmem_write(awaddr_buffer[31 : 0], wdata_buffer, wstrb_buffer);
        end
    end

endmodule


// 1KB size SRAM
// Block size: 8B (2^3)
// Row_number: 128  (2^7)

// Set_number: 64

// ===========================================================================
module S011HD1P_X32Y2D128_BW (
        Q, CLK, CEN, WEN, BWEN, A, D
    );
    parameter                           Bits = 128                 ;
    parameter                           Word_Depth = 64            ;
    parameter                           Add_Width = 6              ;
    parameter                           Wen_Width = 128            ;

    output reg         [Bits-1:0]       Q                          ;
    input                               CLK                        ;
    input                               CEN                        ;
    input                               WEN                        ;
    input              [Wen_Width-1:0]  BWEN                       ;
    input              [Add_Width-1:0]  A                          ;
    input              [Bits-1:0]       D                          ;

    wire                                cen  = ~CEN                ;
    wire                                wen  = ~WEN                ;
    wire               [Wen_Width-1:0]  bwen = ~BWEN               ;

    reg                [Bits-1:0]       ram [0:Word_Depth-1]       ;

    always @(posedge CLK) begin
        if(cen && wen) begin
            ram[A] <= (D & bwen) | (ram[A] & ~bwen);
        end
        Q <= cen && !wen ? ram[A] : {4{$random}};
    end

endmodule


