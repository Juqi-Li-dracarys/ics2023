/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 21:51:01 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 21:59:32
 */


 `include "ysyx_23060136_DEFINES.sv"

/*
      IFU -> IDU_IFU_REG -> IFU
*/

// ===========================================================================
module ysyx_23060136_IFU_IDU_SEG (
        input                                                   clk                        ,
        input                                                   rst                        ,
         // forward unit signal
        input                                                   BRANCH_flushIF             ,
        // FORWARD unit remote control
        input                                                   FORWARD_stallID            ,
        // IDU buffer
        input              [  `ysyx_23060136_BITS_W-1:0]         IFU_o_pc                   ,
        input              [  `ysyx_23060136_INST_W-1:0]         IFU_o_inst                 ,
        output      logic                                       IDU_i_commit               ,
        output      logic  [`ysyx_23060136_BITS_W-1 : 0]         IDU_i_pc                   ,
        output      logic  [`ysyx_23060136_INST_W-1 : 0]         IDU_i_inst        
    );

    
    always_ff @(posedge clk) begin : update_pc
        if(rst || (BRANCH_flushIF & ~FORWARD_stallID)) begin
            IDU_i_pc     <=  `ysyx_23060136_PC_RST;
            IDU_i_inst   <=  `ysyx_23060136_NOP;
            IDU_i_commit <=  `ysyx_23060136_false;
        end
        else if(!FORWARD_stallID) begin
            IDU_i_pc     <=   IFU_o_pc;
            IDU_i_inst   <=   IFU_o_inst;
            IDU_i_commit <=  `ysyx_23060136_true;
        end
    end
    

endmodule


