/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-28 18:04:31 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-05 21:43:36
 */



 `include "DEFINES_ysyx_23060136.sv"


 // FORWARD unit for CPU( Hazard and  latency handler )
 // ===========================================================================
 module MEM_FORWARD_ysyx_23060136 (
    // 这一部分信号是当前流水线 CPU 的瓶颈
    // 只有全部拉高时，流水线工作
    input                               IFU_o_valid                ,
    input                               MEM_rvalid                 ,
    input                               MEM_wready                 ,

    // forward siganl from IDU
    input              [   4:0]         IDU_o_rs1                  ,
    input              [   4:0]         IDU_o_rs2                  ,
    input              [   2:0]         IDU_o_csr_rs               ,
    // forward signal from EXU
    input              [   4:0]         EXU_o_rs1                  ,
    input              [   4:0]         EXU_o_rs2                  ,
    input              [   2:0]         EXU_o_csr_rs               ,

    // MEM 段的比较与前传数据
    input                               MEM_i_mem_to_reg           ,
    input              [   4:0]         MEM_i_rd                   ,
    input              [   2:0]         MEM_i_csr_rd               ,
    input                               MEM_i_write_gpr            ,
    input                               MEM_i_write_csr            ,
    input              [  31:0]         MEM_o_rdata                ,

    input              [  31:0]         MEM_i_ALU_ALUout           ,
    input              [  31:0]         MEM_i_ALU_CSR_out          ,

    // forward signal from WB
    input              [   4:0]         WB_o_rd                    ,
    input              [   2:0]         WB_o_csr_rd                ,
    input                               WB_o_write_gpr             ,
    input                               WB_o_write_csr             ,

    // forward data form WB
    input             [  31:0]          WB_o_rs1_data              ,
    input             [  31:0]          WB_o_rs2_data              ,
    input             [  31:0]          WB_o_csr_rs_data           ,
    // ===========================================================================
    // siganl for seg reg
    output                              FORWARD_stallIF            ,
    output                              FORWARD_stallID            ,
    output                              FORWARD_stallEX            ,
    output                              FORWARD_stallME            ,
    output                              FORWARD_stallWB            ,

    // signal for hazard unit in EXU
    output             [  31:0]         FORWARD_rs1_data_EXU           ,
    output             [  31:0]         FORWARD_rs2_data_EXU           ,
    output             [  31:0]         FORWARD_csr_rs_data_EXU        ,
    output                              FORWARD_rs1_hazard_EXU         ,
    output                              FORWARD_rs2_hazard_EXU         ,
    output                              FORWARD_csr_rs_hazard_EXU      ,       

    // signal for hazard in ID-EX seg register
    output             [  31:0]         FORWARD_rs1_data_SEG           ,
    output             [  31:0]         FORWARD_rs2_data_SEG           ,
    output             [  31:0]         FORWARD_csr_rs_data_SEG        ,
    output                              FORWARD_rs1_hazard_SEG         ,
    output                              FORWARD_rs2_hazard_SEG         ,
    output                              FORWARD_csr_rs_hazard_SEG                
 );
   
   // 判断是否是写寄存器 X0
   wire       WB_rd_x0               =  (WB_o_rd    == 'b0);
   wire       MEM_rd_x0              =  (MEM_i_rd   == 'b0);
   
    // 三级消费者数据冒险
    // 此时 WB 还未将数据写入寄存器，
    // 但读寄存器操作需要该数据(WB->IDU)
    // 解决方法为数据前传到 ID_EX 段寄存器
    wire     third_stage_hazard_rs1  =  (IDU_o_rs1 == WB_o_rd)           & WB_o_write_gpr & ~WB_rd_x0;
    wire     third_stage_hazard_rs2  =  (IDU_o_rs2 == WB_o_rd)           & WB_o_write_gpr & ~WB_rd_x0;
    wire     third_stage_hazard_csr  =  (IDU_o_csr_rs == WB_o_csr_rd)    & WB_o_write_csr            ;


    // 二级消费者数据冒险
    // 此时 WB 还未写入寄存器
    // 但是 EXU 需要该寄存器数据来计算
    // 解决方法为数据前传到 EXU_HAZARD
    wire     second_stage_hazard_rs1 =  (EXU_o_rs1    == WB_o_rd)        & WB_o_write_gpr & ~WB_rd_x0;  
    wire     second_stage_hazard_rs2 =  (EXU_o_rs2    == WB_o_rd)        & WB_o_write_gpr & ~WB_rd_x0; 
    wire     second_stage_hazard_csr =  (EXU_o_csr_rs == WB_o_csr_rd)    & WB_o_write_csr            ;


    // 一级消费者数据冒险
    //  MEM 阶段保存的 ALU_out 需要被前一级使用
    // 该数据将在之后的 WB 写入寄存器
    // 解决方法为我们将数据前传到 EXU
    wire     first_stage_hazard_rs1  =  (EXU_o_rs1    == MEM_i_rd)        & MEM_i_write_gpr  &  ~MEM_i_mem_to_reg & ~MEM_rd_x0;
    wire     first_stage_hazard_rs2  =  (EXU_o_rs2    == MEM_i_rd)        & MEM_i_write_gpr  &  ~MEM_i_mem_to_reg & ~MEM_rd_x0;
    wire     first_stage_hazard_csr  =  (EXU_o_csr_rs == MEM_i_csr_rd)    & MEM_i_write_csr  &  ~MEM_i_mem_to_reg             ;


    // load use 数据冒险
    // SRAM 的数据需要被 EXU_rs_data 使用
    // 该数据将在之后的 WB 写入寄存器
    // 考虑到 MEM 的读写自带数据延迟，我们的操作只是将数据前传
    wire     load_use_hazard_rs1    =  (EXU_o_rs1    == MEM_i_rd)         & MEM_i_write_gpr   &  MEM_i_mem_to_reg & ~MEM_rd_x0;
    wire     load_use_hazard_rs2    =  (EXU_o_rs2    == MEM_i_rd)         & MEM_i_write_gpr   &  MEM_i_mem_to_reg & ~MEM_rd_x0;
    wire     load_use_hazard_csr    =  (EXU_o_csr_rs == MEM_i_csr_rd)     & MEM_i_write_csr   &  MEM_i_mem_to_reg             ;

    
    // 流水段上所有的读写操作已经完成
    wire     mem_process_over     =  IFU_o_valid & MEM_rvalid & MEM_wready;


    // stall and flush signal
    assign  FORWARD_stallIF       =   ~mem_process_over;
    assign  FORWARD_stallID       =   ~mem_process_over;
    assign  FORWARD_stallEX       =   ~mem_process_over;
    assign  FORWARD_stallME       =   ~mem_process_over;
    assign  FORWARD_stallWB       =   ~mem_process_over;


    // forward sel for EXU
    assign  FORWARD_rs1_hazard_EXU    =  second_stage_hazard_rs1 | first_stage_hazard_rs1 | load_use_hazard_rs1;
    assign  FORWARD_rs2_hazard_EXU    =  second_stage_hazard_rs2 | first_stage_hazard_rs2 | load_use_hazard_rs2;
    assign  FORWARD_csr_rs_hazard_EXU =  second_stage_hazard_csr | first_stage_hazard_csr | load_use_hazard_csr;


    // forward sel for IDU-EXU seg register
    assign  FORWARD_rs1_hazard_SEG    =  third_stage_hazard_rs1;
    assign  FORWARD_rs2_hazard_SEG    =  third_stage_hazard_rs2;
    assign  FORWARD_csr_rs_hazard_SEG =  third_stage_hazard_csr;

    // ===========================================================================
    // forward data for EXU
    // 前传数据时注意优先级关系
    // 例如 stage_2 和 load_use 同时为 true，则优先考虑 load_store
    assign  FORWARD_rs1_data_EXU     =    (({32{second_stage_hazard_rs1}}  & (~({32{load_use_hazard_rs1}} | {32{first_stage_hazard_rs1}}))) & WB_o_rs1_data)        |
                                          ({ 32{load_use_hazard_rs1}}      & MEM_o_rdata)                                                                           |
                                          ({ 32{first_stage_hazard_rs1}}   & MEM_i_ALU_ALUout)                                                                      ;

    assign  FORWARD_rs2_data_EXU     =    (({32{second_stage_hazard_rs2}}  & (~({32{load_use_hazard_rs2}} | {32{first_stage_hazard_rs2}}))) & WB_o_rs2_data)        |
                                          ({ 32{load_use_hazard_rs2}}      & MEM_o_rdata)                                                                           |
                                          ({ 32{first_stage_hazard_rs2}}   & MEM_i_ALU_ALUout)                                                                      ; 

    assign  FORWARD_csr_rs_data_EXU  =    (({32{second_stage_hazard_csr}}  & (~({32{load_use_hazard_csr}} | {32{first_stage_hazard_csr}}))) & WB_o_csr_rs_data)     |   
                                          ({ 32{load_use_hazard_csr}}      & MEM_o_rdata)                                                                           |
                                          ({ 32{first_stage_hazard_csr}}   & MEM_i_ALU_CSR_out)                                                                     ;


    // forward data for IDU_EXU_REG
    assign  FORWARD_rs1_data_SEG     =    {32{third_stage_hazard_rs1}}    &  WB_o_rs1_data     ;
    assign  FORWARD_rs2_data_SEG     =    {32{third_stage_hazard_rs2}}    &  WB_o_rs2_data     ;
    assign  FORWARD_csr_rs_data_SEG  =    {32{third_stage_hazard_csr}}    &  WB_o_csr_rs_data  ;   


endmodule



 
