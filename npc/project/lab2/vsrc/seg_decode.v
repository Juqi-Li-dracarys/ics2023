
module seg_decode(in, en, out);
  input wire [2:0] in;
  input wire en;
  output reg [7:0] out;

  always @(in, en) begin
    if (en) begin
      case (in)
          3'b000 : out = 8'b0000_0011;
          3'b001 : out = 8'b1001_1111;
          3'b010 : out = 8'b0010_0101;
          3'b011 : out = 8'b0000_1101;
          3'b100 : out = 8'b1001_1001;
          3'b101 : out = 8'b0100_1001;
          3'b110 : out = 8'b0100_0001;
          3'b111 : out = 8'b0001_1111;
          default: out = 8'b1111_1111;
      endcase
    end
    else  out = 8'b1111_1111;
  end
endmodule