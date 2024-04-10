/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-05 12:40:10 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 21:46:38
 */


`include "ysyx_23060136_DEFINES.sv"


// Interface for arbiter and cache
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
      output   logic     [  `ysyx_23060136_BITS_W-1:0]  ARBITER_IFU_pc             ,
      output   logic                                    ARBITER_IFU_pc_valid       ,

      input              [  `ysyx_23060136_BITS_W-1:0]  ARBITER_IFU_inst           ,
      input                                             ARBITER_IFU_inst_valid     ,
      output                                            ARBITER_IFU_inst_ready     ,

      // output for the next stage
      output   logic     [  `ysyx_23060136_INST_W-1:0]  IFU_o_inst                 ,

      output   logic                                    inst_valid                 ,
      output                                            IFU_error_signal                                           
);
    
    // PC 值非法检测(only for debug)
    wire                         pc_legal               =  (IFU1_pc >= `ysyx_23060136_MBASE && IFU1_pc < `ysyx_23060136_MEND)  ; 
    assign                       IFU_error_signal       =  ARBITER_IFU_pc_valid & !pc_legal                          ;
    
    // 传输地址完成后，我们直接准备接受数据
    assign                       ARBITER_IFU_inst_ready =  r_state_wait                                              ;
    
    wire                         r_state_idle           =  (r_state == `ysyx_23060136_idle)                          ;
    wire                         r_state_ready          =  (r_state == `ysyx_23060136_ready)                         ;
    wire                         r_state_wait           =  (r_state == `ysyx_23060136_wait)                          ;

    wire                         cache_hit              =  `ysyx_23060136_false;

    // state machine
    logic       [1 : 0]          r_state                                                                             ;
    logic       [1 : 0]          r_state_next                                                                        ;

    always_comb begin : r_state_trans
        // 当 AXI lite 发生握手，将转移到下一个状态
        unique case(r_state)
            `ysyx_23060136_idle: begin
                if(!FORWARD_stallIF & !cache_hit) begin
                    r_state_next = `ysyx_23060136_ready;
                end
                else begin
                    r_state_next = `ysyx_23060136_idle;
                end
            end
            `ysyx_23060136_ready: begin
                if(ARBITER_IFU_pc_ready & ARBITER_IFU_pc_valid) begin
                    r_state_next = `ysyx_23060136_wait;
                end
                else begin
                    r_state_next = `ysyx_23060136_ready;
                end
            end
            `ysyx_23060136_wait: begin
                if(ARBITER_IFU_inst_valid & ARBITER_IFU_inst_ready) begin
                    r_state_next = `ysyx_23060136_idle;
                end
                else begin
                    r_state_next = `ysyx_23060136_wait;
                end
            end
            default: r_state_next = `ysyx_23060136_idle;
        endcase
    end
    
    always_ff @(posedge clk) begin : state_machine
        if(rst || (BRANCH_flushIF & !FORWARD_stallIF)) begin
            r_state <=  `ysyx_23060136_idle;
        end
        else begin
            r_state <=  r_state_next;
        end
    end

    always_ff @(posedge clk) begin : pc_valid
        if(rst || (BRANCH_flushIF & !FORWARD_stallIF)) begin
            ARBITER_IFU_pc_valid <= `ysyx_23060136_false;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_IFU_pc_valid <=  `ysyx_23060136_true;
        end 
        else if((r_state_ready & r_state_next == `ysyx_23060136_wait)) begin
            ARBITER_IFU_pc_valid <= `ysyx_23060136_false;  
        end
    end

    always_ff @(posedge clk) begin : pc_update
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            ARBITER_IFU_pc <= `ysyx_23060136_PC_RST;       
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            ARBITER_IFU_pc <=  IFU1_pc;
        end
    end

    always_ff @(posedge clk) begin : inst_valid_trans
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            inst_valid <= `ysyx_23060136_true;
        end
        else if((r_state_idle & r_state_next == `ysyx_23060136_ready)) begin
            inst_valid <=  `ysyx_23060136_false;
        end
        else if((r_state_next == `ysyx_23060136_idle & r_state_wait)) begin
            inst_valid <= `ysyx_23060136_true;
        end
    end

    always_ff @(posedge clk) begin : inst_update
        if(rst || (BRANCH_flushIF & ~FORWARD_stallIF)) begin
            IFU_o_inst <= `ysyx_23060136_NOP;
        end
        else if((r_state_next == `ysyx_23060136_idle & r_state_wait))begin
            IFU_o_inst <= ARBITER_IFU_pc[2]  ?  ARBITER_IFU_inst[63 : 32] : ARBITER_IFU_inst[31 : 0] ;
        end
    end

endmodule


