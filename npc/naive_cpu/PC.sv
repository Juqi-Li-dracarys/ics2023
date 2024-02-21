/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 16:36:22 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 21:04:41
 */


// PC counter of CPU

module PC #(parameter PC_RST = 32'h80000000) (
    input             clk, rst,
    input   [31 : 0]  pc_next,
    output  [31 : 0]  pc_cur
);

    reg   [31 : 0]   pc;

    always_ff @(posedge clk) begin
        if(rst)
            pc <= PC_RST;
        else
            pc <= pc_next;
    end

    assign  pc_cur = pc;

endmodule

