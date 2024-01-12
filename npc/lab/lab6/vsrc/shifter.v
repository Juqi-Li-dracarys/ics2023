module shifter (
    input clk, 
    input rst,                          
    output reg [7:0] dout
);
    wire t_data;
    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            dout <= 8'b1;
        end
        else if(dout == 8'b0) begin
            dout <= 8'b1;
        end
        else begin
            dout <= {t_data ,dout[7:1]};
        end
    end
    assign t_data = dout[0] ^ dout[2] ^ dout[3] ^ dout[4];

endmodule
