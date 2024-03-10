
module seg_decode_hex (
  input [3:0] in,
  input en,
  output reg [7:0] out
);
  always @(in, en) begin
    if (en) begin
      case (in)
          4'b0000 : out = 8'b0000_0011;
          4'b0001 : out = 8'b1001_1111;
          4'b0010 : out = 8'b0010_0101;
          4'b0011 : out = 8'b0000_1101;
          4'b0100 : out = 8'b1001_1001;
          4'b0101 : out = 8'b0100_1001;
          4'b0110 : out = 8'b0100_0001;
          4'b0111 : out = 8'b0001_1111;
          4'b1000 : out = 8'b0000_0001;
          4'b1001 : out = 8'b0000_1001;
          4'b1010 : out = 8'b0001_0001;
          4'b1011 : out = 8'b1100_0001;
          4'b1100 : out = 8'b0110_0011;
          4'b1101 : out = 8'b1000_0101;
          4'b1110 : out = 8'b0110_0011;
          4'b1111 : out = 8'b0111_0001;
          default: out = 8'b1111_1111;
      endcase
    end
    else  out = 8'b1111_1111;
  end
endmodule