
module top #(
    parameter data_width = 2,
    parameter data_num = 4) 
(
    input [data_num*data_width-1:0] sw1,
    input [1:0] sw2,
    input clk,
    input rst,
    output [data_width-1:0] led
);
    mux mux_4_1(
        .in(sw1),
        .s(sw2),
        .out(led)
    );

endmodule

