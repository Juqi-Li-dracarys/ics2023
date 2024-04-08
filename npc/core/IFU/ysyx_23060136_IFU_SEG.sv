/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 15:25:15 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-07 14:35:17
 */

 
`include "ysyx_23060136_DEFINES.sv"

// internal mini pipeline
// ===========================================================================
module ysyx_23060136_IFU_SEG(
    input                                                 clk                        ,
    input                                                 rst                        ,
    input                                                 BRANCH_flushIF             ,
    input                                                 FORWARD_stallIF            ,
    input              [`ysyx_23060136_BITS_W - 1 : 0]    IFU1_pc                    ,
    output      logic  [`ysyx_23060136_BITS_W - 1 : 0]    IFU2_pc                               
);

    always_ff @(posedge clk) begin : update_pc
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            IFU2_pc  <=  `ysyx_23060136_PC_RST;
        end
        else if(!FORWARD_stallIF) begin
            IFU2_pc  <=  IFU1_pc;
        end
    end

endmodule


