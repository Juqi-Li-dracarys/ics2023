/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-14 21:49:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 17:05:23
 */

 `include "TOP_DEFINES_ysyx23060136.sv"

/*
      IFU -> IDU_IFU_REG -> IFU
*/

// ===========================================================================
module IFU_IDU_REG_ysyx23060136 (
        input                      clk,
        input                      rst,
        // forward unit signal
        input                      FORWARD_flushIF,
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

    logic [31  : 0] next_pc    =   ({32{hand_shake_succsess}}    &  IFU_pc) 
                                  |({32{~(hand_shake_succsess)}} &  IDU_pc);
    
    logic [31  : 0] next_inst  =  ({32{hand_shake_succsess}}     &  IFU_inst) 
                                 |({32{~(hand_shake_succsess)}}  &  IDU_inst);
    
    
    // ===========================================================================
    always_ff @(posedge clk) begin : update_pc
        if(rst || FORWARD_flushIF) begin
            IDU_pc <=  `PC_RST;
        end
        else begin
            IDU_pc <= next_pc;
        end
    end

    always_ff @(posedge clk) begin : update_inst
        if(rst || FORWARD_flushIF) begin
            IDU_inst <= `NOP;
        end
        else begin
            IDU_inst <= next_inst;
        end
    end
    

endmodule


