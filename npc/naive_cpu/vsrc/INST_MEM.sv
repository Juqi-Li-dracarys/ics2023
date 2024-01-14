/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 19:29:14 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 18:20:25
 */

// instruction cache

module INST_MEM #(parameter PC_RST = 32'h80000000) (
    input      [31 : 0]   next_addr,
    input                 clk,
    input                 rst,
    output reg [31 : 0]   inst
);

    // DIP-C in verilog
    import "DPI-C" function int vaddr_ifetch(input int addr, input int len);

    always_ff(posedge clk) begin
        if(rst)
            inst <= vaddr_ifetch(PC_RST, 32'h4);
        else
            inst <= vaddr_ifetch(addr, 32'h4);
    end

endmodule


