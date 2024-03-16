/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 19:29:14 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 21:20:32
 */

// instruction cache

module INST_MEM #(parameter PC_RST = 32'h80000000) (
    input      [31 : 0]   pc_next,
    input                 clk,
    input                 rst,
    output reg [31 : 0]   inst
);

    // DIP-C in verilog
    import "DPI-C" function int  pmem_read(input int araddr);

    always_ff @(posedge clk) begin
        if(rst)
            inst <= pmem_read(PC_RST);
        else
            inst <= pmem_read(pc_next);
    end

endmodule


