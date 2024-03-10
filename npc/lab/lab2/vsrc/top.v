
module top (
    input [7:0] sw,
    input en,
    input clk,
    input rst,
    output [3:0] led,
    output [7:0] seg0
);
    wire [2:0] code;

    encode my_encode (
        .in(sw),
        .en(en),
        .out(code)
    );

    seg_decode my_decode(
        .in(code),
        .en(led[3]),
        .out(seg0)
    );

    assign led [2:0] = code;
    assign led [3] = (sw == 8'b0) ? 1'b0 : 1'b1;

endmodule

