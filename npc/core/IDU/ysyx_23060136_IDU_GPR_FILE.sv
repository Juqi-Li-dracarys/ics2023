/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 16:25:18 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 16:57:37
 */


// GPR file for RV64IM


`include "ysyx_23060136_DEFINES.sv"


// ===========================================================================
module ysyx_23060136_IDU_GPR_FILE (
        input                                                    clk                        ,
        input                                                    rst                        ,
        input              [   `ysyx_23060136_GPR_W-1:0]         IDU_rs1                    ,
        input              [   `ysyx_23060136_GPR_W-1:0]         IDU_rs2                    ,
        // rd is from WBU
        input              [   `ysyx_23060136_GPR_W-1:0]         WBU_rd                     ,
        // write gpr reg enable
        input                                                    RegWr                      ,
        // write gpr data
        input              [  `ysyx_23060136_BITS_W-1:0]         rf_busW                    ,
        // gpr read result
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_rs1_data               ,
        output             [  `ysyx_23060136_BITS_W-1:0]         IDU_rs2_data               
    );

    // DIP-C in verilog
    import "DPI-C" function void set_gpr_ptr(input logic [`ysyx_23060136_BITS_W-1 : 0] a []);

    // set the ptr to register
    initial begin
        set_gpr_ptr(gpr_reg);
    end

    logic  [`ysyx_23060136_BITS_W-1 : 0]  gpr_reg      [`ysyx_23060136_GPR_NUM-1 : 0];
    // write enable
    wire             w_e          [`ysyx_23060136_GPR_NUM-1 : 0];
    // read enable in 2 channels
    wire             r_e_1        [`ysyx_23060136_GPR_NUM-1 : 0];
    wire             r_e_2        [`ysyx_23060136_GPR_NUM-1 : 0];
    // data_out(temp data)
    wire   [`ysyx_23060136_BITS_W-1 : 0]  data_out_1   [`ysyx_23060136_GPR_NUM-1 : 0] /*verilator split_var*/;
    wire   [`ysyx_23060136_BITS_W-1 : 0]  data_out_2   [`ysyx_23060136_GPR_NUM-1 : 0] /*verilator split_var*/; 
    
    
    integer i;
    always_ff @(posedge clk) begin
        // should not write $0
        if(rst) begin
            for(i = 0; i < `ysyx_23060136_GPR_NUM ; i = i + 1) begin
                gpr_reg[i] <= `ysyx_23060136_BITS_W'h0;
            end
        end
        else begin
            for(i = 0; i < `ysyx_23060136_GPR_NUM ; i = i + 1) begin
                gpr_reg[i] <= w_e[i] ? rf_busW : gpr_reg[i];
            end
        end
    end

    genvar j;
    generate
        for (j = 0; j < `ysyx_23060136_GPR_NUM; j = j + 1) begin
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
        assign data_out_1[0] = {`ysyx_23060136_BITS_W{r_e_1[0]}} & gpr_reg[0];
        assign data_out_2[0] = {`ysyx_23060136_BITS_W{r_e_2[0]}} & gpr_reg[0];
        for (j = 1; j < `ysyx_23060136_GPR_NUM; j = j + 1) begin
            assign data_out_1[j] = data_out_1[j- 1] | ({`ysyx_23060136_BITS_W{r_e_1[j]}} & gpr_reg[j]);
            assign data_out_2[j] = data_out_2[j- 1] | ({`ysyx_23060136_BITS_W{r_e_2[j]}} & gpr_reg[j]);
        end
    endgenerate

    assign IDU_rs1_data = data_out_1[`ysyx_23060136_GPR_NUM-1];
    assign IDU_rs2_data = data_out_2[`ysyx_23060136_GPR_NUM-1];

endmodule


