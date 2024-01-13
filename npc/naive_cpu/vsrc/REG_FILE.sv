/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 20:25:26 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-12 21:11:19
 */

// register file

module REG_FILE (
    input             clk,                      // clk for write
    input             rst,
    input   [31 : 0]  inst,
    input             RegWr,                    // write enable
    input   [31 : 0]  rf_busW,                  // write data
    output  [31 : 0]  rf_busA, rf_busB          // read result
);

    wire      [4 : 0]       rs1;
    wire      [4 : 0]       rs2;
    wire      [4 : 0]       rd;

    assign rs1 = inst[19 : 15];
    assign rs2 = inst[24 : 20];
    assign rd = inst[11 : 7];

    // DIP-C in verilog
    import "DPI-C" function void set_gpr_ptr(input logic [31 : 0] a []);
    reg [31 : 0]   reg_file   [0 : 31];

    // set the ptr to register
    initial begin
        set_gpr_ptr(reg_file);
    end

    // write the register in the next posedge
    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(RegWr && rd != 5'h0 && rd < 32) begin
            reg_file[rd] <= rf_busW;
        end
        else begin
            
        end

        if(rst) begin
            for(i = 0; i < 32; i = i + 1) begin
                reg_file[i] <= 32'h0;
            end
        end
    end

    // read register
    assign rf_busA = reg_file[rs1];
    assign rf_busB = reg_file[rs2];

endmodule


