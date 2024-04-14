/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 12:26:04 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 18:05:15
 */


 `include "ysyx_23060136_DEFINES.sv"
 

// PC counter of CPU in IFU1
// mini pipeline in IFU 
// ===========================================================================
module ysyx_23060136_IFU_PC (
    input                                                 clk                        ,
    input                                                 rst                        ,
    input                                                 BRANCH_PCSrc               ,
    input                                                 FORWARD_stallIF            ,
    input              [`ysyx_23060136_BITS_W - 1 : 0]    BRANCH_branch_target       ,
    // IFU1_pc
    output      logic  [`ysyx_23060136_BITS_W - 1 : 0]    IFU1_pc                                                 
);

    // jump signal
    wire      [`ysyx_23060136_BITS_W - 1 : 0]     pc_update  =  BRANCH_PCSrc     ? BRANCH_branch_target : IFU1_pc + `ysyx_23060136_BITS_W'h4;
    wire      [`ysyx_23060136_BITS_W - 1 : 0]     pc_next    =  FORWARD_stallIF  ? IFU1_pc              : pc_update;

    always_ff @(posedge clk) begin : pc_count_update
        if(rst) begin
            IFU1_pc   <= `ysyx_23060136_PC_RST;
        end
        else begin
            IFU1_pc   <=  pc_next;
        end
    end

endmodule


