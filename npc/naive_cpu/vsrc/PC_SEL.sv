/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 17:52:15 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 20:37:25
 */

// Control the next PC

module PC_SEL(
    input     [31 : 0]     pc,
    input     [31 : 0]     rs1,
    input     [31 : 0]     imm,
    input                  PCAsrc,
    input                  PCBsrc,
    output    [31 : 0]     next_pc
);

    wire   [32 : 0]    A_line;
    wire   [32 : 0]    B_line;
    wire               cout;
    
    MuxKey #(2, 1, 32) M1 (
        A_line, 
        PCAsrc, {
            1'b0, 32'h4,
            1'b1, imm
        }
    );
    
    MuxKey #(2, 1, 32) M2 (
        B_line, 
        PCBsrc, {
            1'b0, pc,
            1'b1, rs1
        }
    );

    ADDER A1 (
        A_line,
        B_line,
        1'b0,
        next_pc,
        cout
    );

endmodule


