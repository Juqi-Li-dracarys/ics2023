/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 12:40:10 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 21:46:38
 */


`include "ysyx_23060136_DEFINES.sv"


// Interface for arbiter
// protocol: AXI-lite
// ===========================================================================
module ysyx_23060136_IFU_INST_MEM (
      // data from pc counter
      input                                             clk                        ,
      input                                             rst                        ,
      
      input              [  `ysyx_23060136_BITS_W-1:0]  IFU1_pc                    ,

      input                                             BRANCH_flushIF             ,
      input                                             FORWARD_stallIF            ,

      // arbiter interface 握手信号
      input                                             ARBITER_IFU_pc_ready       ,
      output             [  `ysyx_23060136_BITS_W-1:0]  ARBITER_IFU_pc             ,
      output   logic                                    ARBITER_IFU_pc_valid       ,

      input              [  `ysyx_23060136_BITS_W-1:0]  ARBITER_IFU_inst           ,
      input                                             ARBITER_IFU_inst_valid     ,
      output                                            ARBITER_IFU_inst_ready     ,

      // output for the next stage
      output             [  `ysyx_23060136_INST_W-1:0]  IFU_o_inst                 ,

      output   logic                                    inst_valid                 ,
      output                                            IFU_error_signal                                           
);
    
    // PC 值非法检测(only for debug)
    wire                         pc_legal               =  (IFU1_pc >= `ysyx_23060136_MBASE && IFU1_pc < `ysyx_23060136_MEND)  ; 
    assign                       IFU_error_signal       =  ARBITER_IFU_pc_valid & !pc_legal                          ;
    
    assign                       ARBITER_IFU_pc         =  IFU1_pc                                                   ;
    // 传输地址完成后，我们直接准备接受数据
    assign                       ARBITER_IFU_inst_ready =  r_state_busy                                              ;
    // 对齐问题
    assign                       IFU_o_inst             =  (BRANCH_flushIF & ~FORWARD_stallIF) ?  `ysyx_23060136_NOP :
                                                            IFU1_pc[2]     ?  ARBITER_IFU_inst[63 : 32] : ARBITER_IFU_inst[31 : 0] ;

    wire                         r_state_idle           =  (r_state == `ysyx_23060136_idle)                          ;
    wire                         r_state_busy           =  (r_state == `ysyx_23060136_busy)                          ;

    // state machine
    logic                        r_state                                                                             ;
    logic                        r_state_next                                                                        ;

    always_comb begin : r_state_trans
        // 当 AXI lite 发生握手，将转移到下一个状态
        unique case(r_state)
            `ysyx_23060136_idle: begin
                if(ARBITER_IFU_pc_ready & ARBITER_IFU_pc_valid) begin
                    r_state_next = `ysyx_23060136_busy;
                end
                else begin
                    r_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_busy: begin
                if(ARBITER_IFU_inst_valid & ARBITER_IFU_inst_ready) begin
                    r_state_next = `ysyx_23060136_idle;
                end
                else begin
                    r_state_next = `ysyx_23060136_busy;
                end
            end
            default: r_state_next = `ysyx_23060136_idle;
        endcase
    end
    
    always_ff @(posedge clk) begin : state_machine
        if(rst) begin
            r_state <=  `ysyx_23060136_idle;
        end
        else begin
            r_state <=  r_state_next;
        end
    end

    always_ff @(posedge clk) begin : pc_valid
        if(rst || (r_state_idle & !FORWARD_stallIF)) begin
            ARBITER_IFU_pc_valid <= `ysyx_23060136_true;
        end
        else if(r_state_next == `ysyx_23060136_busy) begin
            ARBITER_IFU_pc_valid <=  `ysyx_23060136_false;
        end
    end

    always_ff @(posedge clk) begin : inst_valid_trans
        if(rst || (r_state_idle & !FORWARD_stallIF)) begin
            inst_valid <= `ysyx_23060136_false;
        end
        else if((r_state_next == `ysyx_23060136_idle && r_state_busy)) begin
            inst_valid <=  `ysyx_23060136_true;
        end
    end

endmodule


