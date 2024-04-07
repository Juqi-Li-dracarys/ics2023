/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 16:41:58 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 17:21:09
 */


// CSR file for RV64IM with 2 write channels

 
`include "ysyx_23060136_DEFINES.sv"

// ===========================================================================
module ysyx_23060136_IDU_CSR_FILE (
    input                                                    clk                        ,
    input                                                    rst                        ,
    input              [   `ysyx_23060136_CSR_W-1:0]         IDU_csr_rs                 ,
    // write IN WBU
    input              [   `ysyx_23060136_CSR_W-1:0]         WBU_csr_rd_1               ,
    input              [   `ysyx_23060136_CSR_W-1:0]         WBU_csr_rd_2               ,
    // write enable
    input                                                    CSRWr_1                    ,
    input                                                    CSRWr_2                    ,
    // write data
    input              [  `ysyx_23060136_BITS_W-1 :0]        csr_busW_1                 ,
    input              [  `ysyx_23060136_BITS_W-1 :0]        csr_busW_2                 ,
    output             [  `ysyx_23060136_BITS_W-1 :0]        IDU_csr_rs_data            
);


    logic  [`ysyx_23060136_BITS_W-1  : 0]   csr_reg      [0 : `ysyx_23060136_CSR_NUM-1];
    wire                                    w_e_1        [0 : `ysyx_23060136_CSR_NUM-1];
    wire                                    w_e_2        [0 : `ysyx_23060136_CSR_NUM-1];
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
            csr_reg[`ysyx_23060136_mstatus]    <=    `ysyx_23060136_BITS_W'ha00001800;
            csr_reg[`ysyx_23060136_mtvec]      <=    `ysyx_23060136_BITS_W'h0;
            csr_reg[`ysyx_23060136_mepc]       <=    `ysyx_23060136_BITS_W'h0;
            csr_reg[`ysyx_23060136_mcause]     <=    `ysyx_23060136_BITS_W'h0;
            // ysyx-23060136-LJQ-211870293
            csr_reg[`ysyx_23060136_mvendorid]  <=    `ysyx_23060136_BITS_W'h7973_7978_015F_DEA8;
            csr_reg[`ysyx_23060136_marchid]    <=    `ysyx_23060136_BITS_W'h4C4A_5100_0CA0_E255;
        end
        else begin
            for(i = 0; i < `ysyx_23060136_CSR_NUM; i = i + 1) begin
                if(w_e_1[i]) begin
                    csr_reg[i]  <=  csr_busW_1;
                end
                else if(w_e_2[i]) begin
                    csr_reg[i]  <=  csr_busW_2;
                end
            end
        end
    end

    genvar j;
    generate
        for (j = 0; j < `ysyx_23060136_CSR_NUM; j = j + 1) begin
            assign w_e_1 [j]  =  CSRWr_1 & (WBU_csr_rd_1 == j)           ;
            assign w_e_2 [j]  =  CSRWr_2 & (WBU_csr_rd_2 == j)           ;
            assign r_e [j]    =  (IDU_csr_rs == j)                       ;
        end
    endgenerate

    generate
        assign data_out[0] = {`ysyx_23060136_BITS_W{r_e[0]}} & csr_reg[0];
        for (j = 1; j < `ysyx_23060136_CSR_NUM; j = j + 1) begin
            assign data_out[j] = data_out[j- 1] | ({`ysyx_23060136_BITS_W{r_e[j]}} & csr_reg[j]);
        end
    endgenerate

    assign IDU_csr_rs_data = data_out[`ysyx_23060136_CSR_NUM-1];


endmodule


