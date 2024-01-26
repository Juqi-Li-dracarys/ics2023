/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 20:25:26 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-18 11:58:34
 */

// register file for RV32E


module REG_FILE #(parameter gpr_reg_num = 5'd16, csr_reg_num = 5'd4, gpr_reg_width = 4, csr_reg_width = 2)(
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
    import "DPI-C" function void set_csr_ptr(input logic [31 : 0] b []);


    // mstatus mtvec mepc mcause
    reg  [31 : 0]   gpr_reg  [0 : gpr_reg_num - 1];
    reg  [31 : 0]   csr_reg  [0 : csr_reg_num - 1];


    // set the ptr to register
    initial begin
        set_gpr_ptr(gpr_reg);
        set_csr_ptr(csr_reg);
    end


    // write the reg in the next posedge
    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(rst) begin
            for(i = 0; i < gpr_reg_num; i = i + 1) begin
                gpr_reg[i] <= 32'h0;
            end
            for(i = 1; i < csr_reg_num; i = i + 1) begin
                csr_reg[i] <= 32'h0;
            end
            csr_reg[0] <= 32'h1800;
        end
        else if(RegWr && rd != 5'b0) begin
            if(rd < gpr_reg_num)
                gpr_reg[rd[3 : 0]] <= rf_busW;
            else 
                csr_reg[{rd - gpr_reg_num}[1 : 0]] <= rf_busW;
        end
    end

    // read register
    assign rf_busA = rs1 < gpr_reg_num ? gpr_reg[rs1[3 : 0]] : csr_reg[{rs1 - gpr_reg_num}[1 : 0]];
    assign rf_busB = rs2 < gpr_reg_num ? gpr_reg[rs2[3 : 0]] : csr_reg[{rs2 - gpr_reg_num}[1 : 0]];

    // Error sinal
    assign reg_signal = RegWr && (rd >= gpr_reg_num + csr_reg_num);

endmodule


