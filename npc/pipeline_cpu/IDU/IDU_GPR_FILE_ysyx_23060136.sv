/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-19 17:45:55 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 21:18:01
 */


// gpr file for RV32E

 `include "IDU_DEFINES_ysyx23060136.sv"

// ===========================================================================
module IDU_GPR_FILE_ysyx_23060136 (
        input             clk,                       // clk for write
        input             rst,
        input   [4 : 0]   IDU_rs1,
        input   [4 : 0]   IDU_rs2,
        // rd is from WBU
        input   [4 : 0]   WBU_rd,
        input             RegWr,                     // write gpr reg enable
        input   [31 : 0]  rf_busW,                   // write gpr data
        output  [31 : 0]  IDU_rs1_data, 
        output  [31 : 0]  IDU_rs2_data               // gpr read result
    );

    // DIP-C in verilog
    import "DPI-C" function void set_gpr_ptr(input logic [31 : 0] a []);

    // set the ptr to register
    initial begin
        set_gpr_ptr(gpr_reg);
    end

    logic  [31 : 0]  gpr_reg      [15 : 0];
    // write enable
    logic            w_e          [15 : 0];
    // read enable
    logic            r_e_1        [15 : 0];
    logic            r_e_2        [15 : 0];
    // data_out(temp data)
    logic  [31 : 0]  data_out_1   [15 : 0] /*verilator split_var*/;
    logic  [31 : 0]  data_out_2   [15 : 0] /*verilator split_var*/; 
    
    
    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(rst) begin
            for(i = 0; i < 16; i = i + 1) begin
                gpr_reg[i] <= 32'h0;
            end
        end
        else begin
            for(i = 0; i < 16; i = i + 1) begin
                gpr_reg[i] <= w_e[i] ? rf_busW : gpr_reg[i];
            end
        end
    end

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin
            if (j == 0) begin
                assign w_e[j] = 1'b0;
            end
            else begin
                assign w_e[j] = RegWr & (WBU_rd == j);
            end
            assign r_e_1[j] = (IDU_rs1 == j);
            assign r_e_2[j] = (IDU_rs2 == j);
        end
    endgenerate

    generate
        assign data_out_1[0] = {32{r_e_1[0]}} & gpr_reg[0];
        assign data_out_2[0] = {32{r_e_2[0]}} & gpr_reg[0];
        for (j = 1; j < 16; j = j + 1) begin
            assign data_out_1[j] = data_out_1[j- 1] | ({32{r_e_1[j]}} & gpr_reg[j]);
            assign data_out_2[j] = data_out_2[j- 1] | ({32{r_e_2[j]}} & gpr_reg[j]);
        end
    endgenerate

    assign IDU_rs1_data = data_out_1[15];
    assign IDU_rs2_data = data_out_2[15];

endmodule


