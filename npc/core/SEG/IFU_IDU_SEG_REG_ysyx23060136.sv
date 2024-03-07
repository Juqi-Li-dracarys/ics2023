/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-14 21:49:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-23 14:45:20
 */

 `include "DEFINES_ysyx23060136.sv"

/*
      IFU -> IDU_IFU_REG -> IFU
*/

// ===========================================================================
module IFU_IDU_SEG_REG_ysyx23060136 (
        input                               clk                        ,
        input                               rst                        ,
         // forward unit signal
        input                               BRANCH_flushIF             ,
        // FORWARD unit remote control
        input                               FORWARD_stallID            ,
        // IDU buffer
        input              [  31:0]         IFU_o_pc                   ,
        input              [  31:0]         IFU_o_inst                 ,
        output      logic                   IDU_i_commit               ,
        output      logic  [31 : 0]         IDU_i_pc                   ,
        output      logic  [31 : 0]         IDU_i_inst        
    );

    
    always_ff @(posedge clk) begin : update_pc
        if(rst || (BRANCH_flushIF & ~FORWARD_stallID)) begin
            IDU_i_pc     <= `PC_RST;
            IDU_i_inst   <= `NOP;
            IDU_i_commit <= `false;
        end
        // 正常情况下，更新段寄存器
        else if(!FORWARD_stallID) begin
            IDU_i_pc     <= IFU_o_pc;
            IDU_i_inst   <= IFU_o_inst;
            IDU_i_commit <= `true;
        end
    end
    

endmodule


