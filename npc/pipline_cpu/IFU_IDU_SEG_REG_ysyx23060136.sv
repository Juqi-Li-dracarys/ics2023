/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-14 21:49:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-23 14:45:20
 */

 `include "TOP_DEFINES_ysyx23060136.sv"

/*
      IFU -> IDU_IFU_REG -> IFU
*/

// ===========================================================================
module IFU_IDU_SEG_REG_ysyx23060136 (
        input                      clk,
        input                      rst,
        // forward unit signal
        input                      BRANCH_flushIF,
        input                      FORWARD_stallID,
        // detect handshake 
        input                      IFU_valid,
        input                      IDU_ready,
        // IDU buffer
        input         [31 : 0]     IFU_pc,
        input         [31 : 0]     IFU_inst,
        output logic  [31 : 0]     IDU_pc,
        output logic  [31 : 0]     IDU_inst
    );

    logic hand_shake_succsess = IFU_valid & IDU_ready  & ~FORWARD_stallID;
    
    always_ff @(posedge clk) begin : update_pc
        if(rst || (BRANCH_flushIF & ~FORWARD_stallID) ) begin
            IDU_pc   <= `PC_RST;
            IDU_inst <= `NOP;
        end
        else if(hand_shake_succsess) begin
            IDU_pc   <= IFU_pc;
            IDU_inst <= IFU_inst;
        end
    end
    

endmodule


