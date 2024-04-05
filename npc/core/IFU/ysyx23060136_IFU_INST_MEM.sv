/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 12:40:10 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 17:41:45
 */


`include "ysyx23060136_DEFINES.sv"


// Interface for arbiter
// protocol: AXI-lite
// ===========================================================================
module ysyx23060136_IFU_INST_MEM (
      // data from pc counter
      input                                             clk                        ,
      input                                             rst                        ,
      
      input              [  `BITS_W_23060136-1:0]       IFU1_pc                    ,

      input                                             BRANCH_flushIF             ,
      input                                             FORWARD_stallIF            ,

      // arbiter interface 握手信号
      input                                             ARBITER_IFU_pc_ready       ,
      output             [  `BITS_W_23060136-1:0]       ARBITER_IFU_pc             ,
      output   logic                                    ARBITER_IFU_pc_valid       ,

      input              [  `BITS_W_23060136-1:0]       ARBITER_IFU_inst           ,
      input                                             ARBITER_IFU_inst_valid     ,
      output                                            ARBITER_IFU_inst_ready     ,

      // output for the next stage
      output             [  `INST_W_23060136-1:0]       IFU_o_inst                 ,

      output   logic                                    inst_valid                 ,
      output                                            IFU_error_signal                                           
);
    
    // PC 值非法检测(only for debug)
    wire                         pc_legal               =  (IFU1_pc >= `MBASE_23060136 && IFU1_pc < `MEND_23060136)  ; 
    assign                       IFU_error_signal       =  ARBITER_IFU_pc_valid & !pc_legal                          ;
    
    assign                       ARBITER_IFU_pc         =  IFU1_pc                                                   ;
    // 传输地址完成后，我们直接准备接受数据
    assign                       ARBITER_IFU_inst_ready =  r_state_busy                                              ;
    // 对齐问题
    assign                       IFU_o_inst             =  (BRANCH_flushIF & ~FORWARD_stallIF) ?  `NOP_23060136      :
                                                            IFU1_pc[2]     ?  ARBITER_IFU_inst[63 : 32] : ARBITER_IFU_inst[31 : 0] ;

    wire                         r_state_idle           =  (r_state == `idle_23060136)                               ;
    wire                         r_state_busy           =  (r_state == `busy_23060136)                               ;

    // state machine
    logic                        r_state                                                                             ;
    logic                        r_state_next                                                                        ;

    always_comb begin : r_state_trans
        // 当 AXI lite 发生握手，将转移到下一个状态
        unique case(r_state)
            `idle_23060136: begin
                if(ARBITER_IFU_pc_ready & ARBITER_IFU_pc_valid) begin
                    r_state_next = `busy_23060136;
                end
                else begin
                    r_state_next = `idle_23060136;
                end
            end
            `busy_23060136: begin
                if(ARBITER_IFU_inst_valid & ARBITER_IFU_inst_ready) begin
                    r_state_next = `idle_23060136;
                end
                else begin
                    r_state_next = `busy_23060136;
                end
            end
            default: r_state_next = `idle_23060136;
        endcase
    end
    
    always_ff @(posedge clk) begin : state_machine
        if(rst) begin
            r_state <=  `idle_23060136;
        end
        else begin
            r_state <=  r_state_next;
        end
    end

    always_ff @(posedge clk) begin : pc_valid
        if(rst || (r_state_idle & !FORWARD_stallIF)) begin
            ARBITER_IFU_pc_valid <= `true_23060136;
        end
        else if(r_state_next == `busy_23060136) begin
            ARBITER_IFU_pc_valid <=  `false_23060136;
        end
    end

    always_ff @(posedge clk) begin : inst_valid_trans
        if(rst || (r_state_idle & !FORWARD_stallIF)) begin
            inst_valid <= `false_23060136;
        end
        else if(r_state_next == `idle_23060136 && r_state_busy) begin
            inst_valid <=  `true_23060136;
        end
    end

endmodule


