/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 17:52:15 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 10:14:27
 */

// Control the next PC

module PC_SEL(
    input     [31 : 0]     pc_cur,
    input     [31 : 0]     rs1,
    input     [31 : 0]     imm,
    input                  PCAsrc,
    input                  PCBsrc,
    output    [31 : 0]     pc_next
);

    wire   [31 : 0]    A_line;
    wire   [31 : 0]    B_line;
    
    MuxKey #(2, 1, 32) M1 (
        .out(A_line), 
        .key(PCAsrc), 
        .lut ({
            1'b0, 32'h4,
            1'b1, imm
        })
    );
    
    MuxKey #(2, 1, 32) M2 (
        .out(B_line), 
        .key(PCBsrc), 
        .lut({
            1'b0, pc_cur,
            1'b1, rs1
        })
    );

    assign pc_next = A_line + B_line;
    
endmodule


