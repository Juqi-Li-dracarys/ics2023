/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-06-10 22:26:43 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-06-10 22:26:43 
 */



 `include "ysyx_23060136_DEFINES.sv"
 

// PC counter of CPU in IFU1
// mini pipeline in IFU 
// ===========================================================================
module ysyx_23060136_IFU_PC (
    input                                                 clk                        ,
    input                                                 rst                        ,
    input                                                 FORWARD_stallIF            ,

    input                                                 BRANCH_PCSrc               ,
    input              [`ysyx_23060136_BITS_W - 1 : 0]    BRANCH_branch_target       ,

    input                                                 BHT_PCSrc                  ,
    input              [`ysyx_23060136_BITS_W - 1 : 0]    BHT_branch_target          ,

    // IFU1_pc
    output      logic  [`ysyx_23060136_BITS_W - 1 : 0]    IFU1_pc                                                 
);

    wire                                          PCSrc          =  BRANCH_PCSrc | BHT_PCSrc;
    wire      [`ysyx_23060136_BITS_W - 1 : 0]     branch_target  =  BRANCH_PCSrc ? BRANCH_branch_target : 
                                                                    BHT_PCSrc    ? BHT_branch_target    : 'b0 ;
    

    // jump signal
    wire      [`ysyx_23060136_BITS_W - 1 : 0]     pc_update  =  PCSrc            ? branch_target        : IFU1_pc + `ysyx_23060136_BITS_W'h4;
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


