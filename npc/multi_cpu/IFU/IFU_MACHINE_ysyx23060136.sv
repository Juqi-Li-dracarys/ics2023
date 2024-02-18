/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-14 21:49:38 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-18 20:56:03
 */

 `include "IFU_DEFINES_ysyx23060136.sv"

/*
    state transition of master:
 
    +-+ valid = 0
    | v         valid = 1
    1. idle ----------------> 2. wait_ready(inst_valid=true) <-+
    ^                          |      |    | ready = 0
    +--------------------------+      +----+
                ready = 1
*/

// ===========================================================================

module IFU_MACHINE_ysyx23060136 (
        input                      clk,
        input                      rst,
        input                      inst_mem_valid,
        input   logic [31 : 0]     pc_cur,
        input   logic [31 : 0]     inst_cur,
        input                      WBU_ready,
        output                     IFU_valid,
        output  logic [31 : 0]     pc,
        output  logic [31 : 0]     inst
    );

    logic IFU_state;

    // current state of IFU
    logic state_1 = (IFU_state == `idle)       & (inst_mem_valid == `true);
    logic state_2 = (IFU_state == `idle)       & (inst_mem_valid == `false);
    logic state_3 = (IFU_state == `wait_ready) & (WBU_ready == `true);
    logic state_4 = (IFU_state == `wait_ready) & (WBU_ready == `false);


    logic next_state =   (state_1  & `wait_ready) 
                        |(state_2  & `idle) 
                        |(state_3  & `idle)
                        |(state_4  & `wait_ready);

    logic [31  : 0] next_pc    =   ({32{state_1}}   & pc_cur) 
                                  |({32{~state_1}}  & pc);
    
    logic [31  : 0] next_inst  =  ({32{state_1}}  &  inst_cur) 
                                 |({32{~state_1}} &  inst);
    
    // ===========================================================================
    always_ff @(posedge clk) begin : state_update
        if(rst) begin
            IFU_state <=   `idle;
        end
        else begin
            IFU_state <=   next_state;
        end
    end

    
    always_ff @(posedge clk) begin : pc_update
        if(rst) begin
            pc        <=  `PC_RST;
        end
        else begin
            pc        <=   next_pc;
        end
    end


    always_ff @(posedge clk) begin : inst_update
        if(rst) begin
            inst      <=   32'b0;
        end
        else begin
            inst      <=   next_inst;
        end
    end

    assign IFU_valid = (IFU_state == `wait_ready);

endmodule


