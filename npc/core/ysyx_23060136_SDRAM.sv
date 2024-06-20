/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-16 21:53:25 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-16 21:54:24
 */

 `include "ysyx_23060136_DEFINES.sv"


// simulation model of memory
// ===========================================================================
module ysyx_23060136_SDRAM (
    input                               clk                        ,
    input                               rst                        ,
    input                               inst_fetch                 ,

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


    import "DPI-C" function longint pmem_read(int araddr, bit type_inst);
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
    logic          inst_fetch_buf;

    always_ff @(posedge clk) begin : raddr_buf_update
        if(rst) begin
            araddr_buffer  <=  `ysyx_23060136_false;
            inst_fetch_buf <=  `ysyx_23060136_false;
        end
        else if(r_state_idle & (next_r_state == `ysyx_23060136_ready))begin
            araddr_buffer  <=   io_slave_araddr;
            inst_fetch_buf <=   inst_fetch;
        end
    end

    always_ff @(posedge clk) begin : rdata_update
        if(rst) begin
            io_slave_rdata    <=  `ysyx_23060136_false;
        end
        else if(r_state_ready & (next_r_state == `ysyx_23060136_wait))begin
            io_slave_rdata    <=  pmem_read(araddr_buffer, inst_fetch_buf);
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


