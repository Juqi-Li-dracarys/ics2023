
module mux #(
  parameter data_width = 2,
  parameter data_num = 4)
  (
  input  [data_num*data_width-1:0] in,
  input [1:0] s,
  output reg [data_width-1:0] out
);
  always @(s, in)
  begin
    case (s)
      2'b00: out = in[1:0];
      2'b01: out = in[3:2];
      2'b10: out = in[5:4];
      2'b11: out = in[7:6];
      default: out = 2'b00;
    endcase
  end

endmodule

