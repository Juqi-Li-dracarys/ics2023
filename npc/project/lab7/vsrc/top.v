
module top (
    input clk,
    input rst,
    input ps2_clk,
    input ps2_data,
    output [7:0] seg_1,
    output [7:0] seg_2
);

    wire [3:0] seg_1_t;
    wire [3:0] seg_2_t;
    wire ready;
    wire overflow;
    wire [7:0] data;
    reg read_n;
    reg [7:0] scan_code;

    ps2_keyboard key_board(
        .clk(clk),
        .rst_n(~rst),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .read_n(read_n),
        .data(data),
        .ready(ready),
        .overflow(overflow)
    );

    seg_decode_hex seg1(
        .in(seg_1_t),
        .en(~rst),
        .out(seg_1)
    );

    seg_decode_hex seg2(
        .in(seg_2_t),
        .en(~rst),
        .out(seg_2)
    );

    always @(negedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            read_n <= 1'b1;
            scan_code <= 8'b0;
        end
        else begin
            if(ready == 1) begin
                scan_code <= data;
                read_n <= 1'b0;
            end
            else begin
                read_n <= 1'b0;
            end
        end
    end

    
endmodule

