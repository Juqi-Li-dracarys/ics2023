/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-26 00:41:18 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-04 21:46:01
 */


`include "DEFINES_ysyx23060136.sv"


// interface for read arbiter
// protocol: AXI-lite
// ===========================================================================
module IFU_INST_MEM_ysyx23060136 (
      // data from pc counter
      input                               clk                        ,
      input                               rst                        ,
      
      input              [  31:0]         IFU_o_pc                   ,
      input                               pc_change                  ,
      // arbiter interface 握手信号
      input              [  31:0]         ARBITER_IFU_inst           ,
      input                               ARBITER_IFU_inst_valid     ,
      input                               ARBITER_IFU_pc_ready       ,

      output             [  31:0]         ARBITER_IFU_pc             ,
      output                              ARBITER_IFU_pc_valid       ,
      output                              ARBITER_IFU_inst_ready     , 
      // output for the next stage
      output             [  31:0]         IFU_o_inst                 ,
      output                              inst_valid             
    );


    assign                       ARBITER_IFU_pc         =  IFU_o_pc                              ;
    assign                       ARBITER_IFU_pc_valid   =  r_state_idle & new_pc                 ;
    // 传输地址完成后，我们直接准备接受数据
    assign                       ARBITER_IFU_inst_ready =  r_state_busy                          ; 
    assign                       IFU_o_inst             =  ARBITER_IFU_inst                      ;
    assign                       inst_valid             =  r_state_idle & ~pc_change & ~new_pc;  ;


    // 当 PC 变化时，pc_change 暂时拉高，下一个周期之后，pc_change 会保存在 new_pc 中
    // 当状态机处于 busy 时， new_pc 会被自动清0，否则一致保持true，作为读请求信号

    logic         new_pc ;  

    wire          r_state_idle     =  (r_state == `idle);
    wire          r_state_busy     =  (r_state == `busy);

    // read mater state machine
    logic        [1 : 0]       r_state;
    // 当 AXI lite 发生握手，将转移到下一个状态
    wire         [1 : 0]       r_state_next   =  ({2{r_state_idle}} & ((ARBITER_IFU_pc_ready   & ARBITER_IFU_pc_valid)    ? `busy : `idle)) |
                                                 ({2{r_state_busy}} & ((ARBITER_IFU_inst_valid & ARBITER_IFU_inst_ready)  ? `idle : `busy)) ;

    // new pc 在被拉高后，会阻塞在第一阶段，直到握手完成
    // 第二阶段清0
    wire                       new_pc_next    =  (r_state_idle &  (new_pc ? new_pc : pc_change)) | 
                                                 (r_state_busy &  `false                       ) ;


    always_ff @(posedge clk) begin : state_machine
      if(rst) begin
          r_state <=  `idle;
      end
      else begin
          r_state <=  r_state_next;
      end
    end

    always_ff @(posedge clk) begin : new_pc_update
        if(rst) begin
            new_pc  <= `false;
        end
        else begin
            new_pc  <=  new_pc_next;
        end
    end
  
endmodule


