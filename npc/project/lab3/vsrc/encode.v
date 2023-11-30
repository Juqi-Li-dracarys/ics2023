
module encode(in, en, out);
  input wire [7:0] in;
  input wire en;
  output reg [2:0] out;

  always @(in, en) begin
    if (en) begin
      casez (in)
          8'b0000_0001 : out = 3'b000;
          8'b0000_001z : out = 3'b001;
          8'b0000_01zz : out = 3'b010;
          8'b0000_1zzz : out = 3'b011;
          8'b0001_zzzz : out = 3'b100;
          8'b001z_zzzz : out = 3'b101;
          8'b01zz_zzzz : out = 3'b110;
          8'b1zzz_zzzz : out = 3'b111;
          default: out = 3'b000;
      endcase
    end
    else  out = 3'b00;
  end
endmodule

