
module top (
    input clk,
    input rst,
    input my_clk,
    output [7:0] seg_1,
    output [7:0] seg_2
);
    wire [3:0] seg_1_t;
    wire [3:0] seg_2_t;

    shifter shifter_8 (
        .clk(my_clk),
        .rst(rst),
        .dout({seg_2_t, seg_1_t})
    );
    seg_decode_hex hex_1 (
        .en(~rst),
        .in(seg_1_t),
        .out(seg_1) 
    );
    seg_decode_hex hex_2 (
        .en(~rst),
        .in(seg_2_t),
        .out(seg_2) 
    );
    
endmodule


