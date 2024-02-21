/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 20:20:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 21:17:45
 */


// csr file for RV32E

`include "IDU_DEFINES_ysyx23060136.sv"


// ===========================================================================
module IDU_CSR_FILE_ysyx_23060136 (
        input             clk,                      // clk for write
        input             rst,
        input   [1 : 0]   IDU_csr_rs,               // read in IDU
        input   [1 : 0]   WBU_csr_rd,               // write IN WBU
        input             CSRWr,                    // write enable
        input   [31 : 0]  csr_busW,                 // write data
        output  [31 : 0]  IDU_csr_rs_data                  // read result
    );


    // mstatus mtvec mepc mcause
    logic  [31 : 0]   csr_reg      [0 : 3];

    logic             w_e          [0 : 3];
    logic             r_e          [0 : 3];
    logic  [31 : 0]   data_out     [0 : 3] /*verilator split_var*/;


    // DIP-C in verilog
    import "DPI-C" function void set_csr_ptr(input logic [31 : 0] b []);

    // set the ptr to register
    initial begin
        set_csr_ptr(csr_reg);
    end

    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(rst) begin
            // mstatus
            csr_reg[`mstatus] <= 32'h1800;
            csr_reg[`mtvec]   <= 32'h0;
            csr_reg[`mepc]    <= 32'h0;
            csr_reg[`mcause]  <= 32'hb;
        end
        else begin
            for(i = 0; i < 4; i = i + 1) begin
                csr_reg[i] <= w_e[i] ? csr_busW : csr_reg[i];
            end
        end
    end

    genvar j;
    generate
        for (j = 0; j < 4; j = j + 1) begin
            assign w_e[j] = CSRWr & (WBU_csr_rd == j);
            assign r_e[j] = (IDU_csr_rs == j);
        end
    endgenerate

    generate
        assign data_out[0] = {32{r_e[0]}} & csr_reg[0];
        for (j = 1; j < 4; j = j + 1) begin
            assign data_out[j] = data_out[j- 1] | ({32{r_e[j]}} & csr_reg[j]);
        end
    endgenerate


    assign IDU_csr_rs_data = data_out[3];

endmodule


