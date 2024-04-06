/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 16:41:58 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 17:05:36
 */



// CSR file for RV64IM

 
 `include "ysyx_23060136_DEFINES.sv"


// ===========================================================================
module ysyx_23060136_IDU_CSR_FILE (
    input                                                    clk                        ,
    input                                                    rst                        ,
    input              [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rs                 ,
    // write IN WBU
    input              [   `ysyx_23060136_CSR_W-1:0]         WBU_csr_rd                 ,
    // write enable
    input                                                    CSRWr                      ,
    // write data
    input              [  `ysyx_23060136_BITS_W-1 :0]        csr_busW                   ,
    output             [  `ysyx_23060136_BITS_W-1 :0]        IDU_csr_rs_data            
);


    // mstatus mtvec mepc mcause
    logic  [`ysyx_23060136_BITS_W-1  : 0]   csr_reg      [0 : `ysyx_23060136_CSR_NUM-1];
    wire                                    w_e          [0 : `ysyx_23060136_CSR_NUM-1];
    wire                                    r_e          [0 : `ysyx_23060136_CSR_NUM-1];
    wire  [`ysyx_23060136_BITS_W-1  : 0]    data_out     [0 : `ysyx_23060136_CSR_NUM-1] /*verilator split_var*/;


    // DIP-C in verilog
    import "DPI-C" function void set_csr_ptr(input logic [`ysyx_23060136_BITS_W-1  : 0] b []);


    // set the ptr to register
    initial begin
        set_csr_ptr(csr_reg);
    end

    integer i;
    always_ff @(posedge clk) begin
        if(rst) begin
            csr_reg[`mstatus]    <=    `ysyx_23060136_BITS_W'h1800;
            csr_reg[`mtvec]      <=    `ysyx_23060136_BITS_W'h0;
            csr_reg[`mepc]       <=    `ysyx_23060136_BITS_W'h0;
            // 这里做了简化，暂时存在 bug
            // 我们直接将 mcause 固化在了寄存器里
            csr_reg[`mcause]     <=    `ysyx_23060136_BITS_W'hb;
            // read only
            csr_reg[`mvendorid]  <=    `ysyx_23060136_BITS_W'h79737978_015fdea8;
            csr_reg[`marchid]    <=    `ysyx_23060136_BITS_W'h0;
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


