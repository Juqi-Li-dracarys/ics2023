/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 20:25:26 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 21:31:32
 */

// register file for RV32E

module REG_FILE #(parameter reg_num = 16, reg_width = 4)(
    input             clk,                      // clk for write
    input             rst,
    input   [31 : 0]  inst,
    input             RegWr,                    // write enable
    input   [31 : 0]  rf_busW,                  // write data
    output  [31 : 0]  rf_busA, rf_busB,         // read result
    output            reg_signal                // should be 0
);

    wire      [4 : 0]       rs1;
    wire      [4 : 0]       rs2;
    wire      [4 : 0]       rd;

    assign rs1 = inst[19 : 15];
    assign rs2 = inst[24 : 20];
    assign rd = inst[11 : 7];

    // DIP-C in verilog
    import "DPI-C" function void set_gpr_ptr(input logic [31 : 0] a []);

    reg  [31 : 0]   reg_file [0 : reg_num-1];

    // set the ptr to register
    initial begin
        set_gpr_ptr(reg_file);
    end

    // write the register in the next posedge
    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(RegWr && !rst && rd != 5'h0 && rd < reg_num) begin
            reg_file[rd[reg_width-1 : 0]] <= rf_busW;
        end
        else if(rst) begin
            for(i = 0; i < reg_num; i = i + 1) begin
                reg_file[i] <= 32'h0;
            end
        end
    end

    // read register
    assign rf_busA = reg_file[rs1[reg_width-1 : 0]];
    assign rf_busB = reg_file[rs2[reg_width-1 : 0]];

    // Error sinal
    assign reg_signal = RegWr && (rd == 5'h0 || rd >= reg_num);

endmodule


