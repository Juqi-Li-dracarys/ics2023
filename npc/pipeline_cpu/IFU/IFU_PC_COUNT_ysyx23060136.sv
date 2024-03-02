/*
 * @Author: Juqi Li @ NJU
 * @Date: 2024-02-15 22:21:15
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-18 20:57:27
 */

 `include "DEFINES_ysyx23060136.sv"

// PC counter of CPU
// ===========================================================================

module IFU_PC_COUNT_ysyx23060136 (
    input                               clk                        ,
    input                               rst                        ,
    input                               BRANCH_PCSrc               ,
    input                               FORWARD_stallIF            ,
    input              [31 : 0]         BRANCH_branch_target       ,
    output      logic  [31 : 0]         IFU_o_pc                   
);


    // jump
    wire      [31 : 0]     pc_update  =  BRANCH_PCSrc     ? BRANCH_branch_target : IFU_o_pc + 32'h4;;
    wire      [31 : 0]     pc_next    =  FORWARD_stallIF  ? IFU_o_pc             : pc_update;

    always_ff @(posedge clk) begin
        if(rst) begin
            IFU_o_pc   <= `PC_RST;
        end
        else begin
            IFU_o_pc   <=  pc_next;
        end
    end

endmodule


