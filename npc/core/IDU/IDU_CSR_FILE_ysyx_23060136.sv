/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-21 20:20:38
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-16 12:00:17
 */


// csr file for RV32E

 
 `include "DEFINES_ysyx23060136.sv"


// ===========================================================================
module IDU_CSR_FILE_ysyx_23060136 (
    input                               clk                        ,
    input                               rst                        ,
    input              [   2:0]         IDU_csr_rs                 ,
    // write IN WBU
    input              [   2:0]         WBU_csr_rd                 ,
    // write enable
    input                               CSRWr                      ,
    // write data
    input              [  31:0]         csr_busW                   ,
    output             [  31:0]         IDU_csr_rs_data            
);


    // mstatus mtvec mepc mcause
    logic  [31 : 0]   csr_reg      [0 : 5];

    wire              w_e          [0 : 5];
    wire              r_e          [0 : 5];
    wire  [31 : 0]    data_out     [0 : 5] /*verilator split_var*/;


    // DIP-C in verilog
    import "DPI-C" function void set_csr_ptr(input logic [31 : 0] b []);

    // set the ptr to register
    initial begin
        set_csr_ptr(csr_reg);
    end

    integer i;
    always_ff @(posedge clk) begin
        if(rst) begin
            csr_reg[`mstatus]    <=    32'h1800;
            csr_reg[`mtvec]      <=    32'h0;
            csr_reg[`mepc]       <=    32'h0;
            // 这里做了简化，暂时存在 bug
            // 我们直接将 mcause 固化在了寄存器里
            csr_reg[`mcause]     <=    32'hb;
            // read only
            csr_reg[`mvendorid]  <=    32'h79737978;
            csr_reg[`marchid]    <=    32'h015fdea8;
        end
        else begin
            for(i = 0; i < 6; i = i + 1) begin
                csr_reg[i] <= w_e[i] ? csr_busW : csr_reg[i];
            end
        end
    end

    genvar j;
    generate
        for (j = 0; j < 4; j = j + 1) begin
            assign w_e [j]  =  CSRWr & (WBU_csr_rd == j)           ;
            assign r_e [j]  =  (IDU_csr_rs == j)                   ;
        end
            assign w_e [`mvendorid] =  `false                      ;
            assign w_e [`marchid]   =  `false                      ;
            assign r_e [`mvendorid] =  (IDU_csr_rs == `mvendorid)  ;
            assign r_e [`marchid]   =  (IDU_csr_rs == `marchid)    ;
    endgenerate

    generate
        assign data_out[0] = {32{r_e[0]}} & csr_reg[0];
        for (j = 1; j < 6; j = j + 1) begin
            assign data_out[j] = data_out[j- 1] | ({32{r_e[j]}} & csr_reg[j]);
        end
    endgenerate

    assign IDU_csr_rs_data = data_out[5];

endmodule


