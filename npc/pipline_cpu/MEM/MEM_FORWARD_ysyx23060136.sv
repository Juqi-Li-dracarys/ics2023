/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-28 18:04:31 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-29 00:08:48
 */



 `include "MEM_DEFINES_ysyx23060136.sv"


 // FORWARD unit for CPU( Hazard and  latency handler )
 // ===========================================================================
 module MEM_FORWARD_ysyx23060136 (
    // 这一部分信号是当前流水线 CPU 的瓶颈
    // 只有全部拉高时，流水线工作
    input                               IFU_valid                  ,
    input                               MEM_rvalid                 ,
    input                               MEM_wready                 ,

    // forward siganl from IDU
    input              [   4:0]         IDU_rs1                    ,
    input              [   4:0]         IDU_rs2                    ,
    input              [   1:0]         IDU_csr_rs                 ,
    // forward signal from EXU
    input              [   4:0]         EXU_rs1_MEM                ,
    input              [   4:0]         EXU_rs2_MEM                ,
    input              [   1:0]         EXU_csr_rs_MEM             ,

    // MEM 段的比较与前传数据
    input                               MEM_mem_to_reg             ,
    input              [   4:0]         MEM_rd                     ,
    input              [   1:0]         MEM_csr_rd                 ,
    input                               MEM_write_gpr              ,
    input                               MEM_write_csr              ,
    input              [  31:0]         MEM_rdata                  ,

    input              [  31:0]         MEM_ALU_ALUout             ,
    input              [  31:0]         MEM_ALU_CSR_out            ,

    // forward signal from WB
    input              [   4:0]         WB_rd                      ,
    input              [   1:0]         WB_csr_rd                  ,
    input                               WB_write_gpr               ,
    input                               WB_write_csr               ,

    // forward data form WB
    input             [  31:0]          WB_rs1_data_EXU            ,
    input             [  31:0]          WB_rs2_data_EXU            ,
    input             [  31:0]          WB_csr_rs_data_EXU         ,

    // siganl for seg reg
    output                              FORWARD_stallIF            ,
    output                              FORWARD_stallID            ,
    output                              FORWARD_stallEX            ,
    output                              FORWARD_stallME            ,
    output                              FORWARD_flushWB            ,

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
   
    // 三级消费者数据冒险
    // 此时 WB 还未将数据写入寄存器，但读寄存器操作需要该数据(WM->IDU)
    // 解决方法为数据前传到 ID——EX 段寄存器
    logic    third_stage_hazard_rs1  =  (IDU_rs1 == WB_rd)        & WB_write_gpr;
    logic    third_stage_hazard_rs2  =  (IDU_rs2 == WB_rd)        & WB_write_gpr;
    logic    third_stage_hazard_csr  =  (IDU_csr_rs == WB_csr_rd) & WB_write_csr;

    // 二级消费者数据冒险
    // 此时 WB 还未写入寄存器，但是 EXU 需要该寄存器数据来计算
    // 解决方法为数据前传到 HAZARD
    logic    second_stage_hazard_rs1 =  (EXU_rs1_MEM == WB_rd)        & WB_write_gpr;  
    logic    second_stage_hazard_rs2 =  (EXU_rs2_MEM == WB_rd)        & WB_write_gpr; 
    logic    second_stage_hazard_csr =  (EXU_csr_rs_MEM == WB_csr_rd) & WB_write_csr;

    // 一级消费者数据冒险
    // 此时数据还在 MEM 阶段，但是 EXU 需要该数据来计算
    //  MEM 阶段保存的 rs_data 需要被前一级使用
    // 我们的操作数据前传
    logic    first_stage_hazard_rs1  =  (EXU_rs1_MEM == MEM_rd)        & MEM_write_gpr  &  ~MEM_mem_to_reg;
    logic    first_stage_hazard_rs2  =  (EXU_rs2_MEM == MEM_rd)        & MEM_write_gpr  &  ~MEM_mem_to_reg;
    logic    first_stage_hazard_csr  =  (EXU_csr_rs_MEM == MEM_csr_rd) & MEM_write_csr  &  ~MEM_mem_to_reg;


    // load use 数据冒险
    // 此时数据还在 MEM 阶段，但是 EXU 需要该数据来计算
    // SRAM 的数据需要被 EXU_rs_data 使用
    // 考虑到 MEM 的读写自带数据延迟，我们的操作均是将数据前传
    logic    load_use_hazard_rs1    =  (EXU_rs1_MEM == MEM_rd)        & MEM_write_gpr  &  MEM_mem_to_reg;
    logic    load_use_hazard_rs2    =  (EXU_rs2_MEM == MEM_rd)        & MEM_write_gpr  &  MEM_mem_to_reg;
    logic    load_use_hazard_csr    =  (EXU_csr_rs_MEM == MEM_csr_rd) & MEM_write_csr  &  MEM_mem_to_reg;

    
    // 所有的读写操作已经完成
    logic    mem_process_over    =  IFU_valid & MEM_rvalid & MEM_wready;


    // stall and flush signal
    assign  FORWARD_stallIF       =   ~mem_process_over;
    assign  FORWARD_stallID       =   ~mem_process_over;
    assign  FORWARD_stallEX       =   ~mem_process_over;
    assign  FORWARD_stallME       =   ~mem_process_over;
    assign  FORWARD_flushWB       =   ~mem_process_over;

    // forward sel for EXU
    assign  FORWARD_rs1_hazard_EXU    =  second_stage_hazard_rs1 | first_stage_hazard_rs1 | load_use_hazard_rs1;
    assign  FORWARD_rs2_hazard_EXU    =  second_stage_hazard_rs2 | first_stage_hazard_rs2 | load_use_hazard_rs2;
    assign  FORWARD_csr_rs_hazard_EXU =  second_stage_hazard_csr | first_stage_hazard_csr | load_use_hazard_csr;

    // forward sel for IDU-EXU seg register
    assign  FORWARD_rs1_hazard_SEG    =  third_stage_hazard_rs1;
    assign  FORWARD_rs2_hazard_SEG    =  third_stage_hazard_rs2;
    assign  FORWARD_csr_rs_hazard_SEG =  third_stage_hazard_csr;

    // forward data for EXU
    // 注意优先级关系
    // 如果 stage_2 或者 load_use 为 true，则优先考虑 load_stroe
    assign  FORWARD_rs1_data_EXU     =    (({32{second_stage_hazard_rs1}} & (~({32{load_use_hazard_rs1}} | {32{first_stage_hazard_rs1}}))) & WB_rs1_data_EXU)    |
                                          ({32{load_use_hazard_rs1}}      & MEM_rdata)                                                                           |
                                          ({32{first_stage_hazard_rs1}}   & MEM_ALU_ALUout)                                                                      ;

    assign  FORWARD_rs2_data_EXU     =    (({32{second_stage_hazard_rs2}} & (~({32{load_use_hazard_rs2}} | {32{first_stage_hazard_rs2}}))) & WB_rs2_data_EXU)    |
                                          ({32{load_use_hazard_rs2}}      & MEM_rdata)                                                                           |
                                          ({32{first_stage_hazard_rs2}}   & MEM_ALU_ALUout)                                                                      ; 

    assign  FORWARD_csr_rs_data_EXU  =    (({32{second_stage_hazard_csr}} & (~({32{load_use_hazard_csr}} | {32{first_stage_hazard_csr}}))) & WB_csr_rs_data_EXU) |
                                          ({32{load_use_hazard_csr}}      & MEM_rdata)                                                                           |
                                          ({32{first_stage_hazard_csr}}   & MEM_ALU_CSR_out)                                                                     ;

    // forward data for IDU_EXU_REG
    assign  FORWARD_rs1_data_SEG     =    {32{third_stage_hazard_rs1}}   & WB_rs1_data_EXU     ;
    assign  FORWARD_rs2_data_SEG     =    {32{third_stage_hazard_rs2}}   & WB_rs2_data_EXU     ;
    assign  FORWARD_csr_rs_data_SEG  =    {32{third_stage_hazard_csr}}   & WB_csr_rs_data_EXU  ;   


endmodule



 
