/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-06 16:25:18 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-06 16:57:37
 */


// GPR file for RV64IM with 2 read channel


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
    wire                                  w_e          [`ysyx_23060136_GPR_NUM-1 : 0];
    
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
        end
    endgenerate

    assign IDU_rs1_data = gpr_reg[IDU_rs1];
    assign IDU_rs2_data = gpr_reg[IDU_rs2];

endmodule


