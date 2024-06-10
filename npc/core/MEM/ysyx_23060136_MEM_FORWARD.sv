/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-10 15:23:51 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 11:37:34
 */


 `include "ysyx_23060136_DEFINES.sv"


 // FORWARD unit for CPU (data hazard handler)
 // ===========================================================================
 module ysyx_23060136_MEM_FORWARD (
    // instruction fetch successfully
    input                                                    IFU_o_valid                ,
    // ALU result valid
    input                                                    EXU_o_valid                ,
    // MEM read valid
    input                                                    MEM_rvalid                 ,
    // MEM write finish
    input                                                    MEM_wdone                  ,
    // ===========================================================================
    // forward siganl from IDU
    input              [   `ysyx_23060136_GPR_W-1:0]         IDU_o_rs1                  ,
    input              [   `ysyx_23060136_GPR_W-1:0]         IDU_o_rs2                  ,
    input              [   `ysyx_23060136_CSR_W-1:0]         IDU_o_csr_rs               ,
    // forward signal from EXU
    input              [   `ysyx_23060136_GPR_W-1:0]         EXU_i_rs1                  ,
    input              [   `ysyx_23060136_GPR_W-1:0]         EXU_i_rs2                  ,
    input              [   `ysyx_23060136_CSR_W-1:0]         EXU_i_csr_rs               ,
    
    // ===========================================================================
    // forward signal from EXU2
    input              [   `ysyx_23060136_GPR_W-1:0]         EXU_o_rd                   ,
    input              [   `ysyx_23060136_CSR_W-1:0]         EXU_o_csr_rd_1             ,
    input              [   `ysyx_23060136_CSR_W-1:0]         EXU_o_csr_rd_2             ,
    input                                                    EXU_o_write_gpr            ,
    input                                                    EXU_o_write_csr_1          ,
    input                                                    EXU_o_write_csr_2          ,


    // forward signal from MEM
    input              [   `ysyx_23060136_GPR_W-1:0]         MEM_i_rd                   ,
    input              [   `ysyx_23060136_CSR_W-1:0]         MEM_i_csr_rd_1             ,
    input              [   `ysyx_23060136_CSR_W-1:0]         MEM_i_csr_rd_2             ,
    input                                                    MEM_i_write_gpr            ,
    input                                                    MEM_i_write_csr_1          ,
    input                                                    MEM_i_write_csr_2          ,
    input                                                    MEM_i_mem_to_reg           ,
    // forward data from MEM
    input              [  `ysyx_23060136_BITS_W-1:0]         MEM_o_rdata                ,
    input              [  `ysyx_23060136_BITS_W-1:0]         MEM_i_ALU_ALUout           ,
    input              [  `ysyx_23060136_BITS_W-1:0]         MEM_i_ALU_CSR_out          ,


    // forward signal from WB
    input              [   `ysyx_23060136_GPR_W-1:0]         WB_o_rd                    ,
    input              [   `ysyx_23060136_CSR_W-1:0]         WB_o_csr_rd_1              ,
    input              [   `ysyx_23060136_CSR_W-1:0]         WB_o_csr_rd_2              ,
    input                                                    WB_o_write_gpr             ,
    input                                                    WB_o_write_csr_1           ,
    input                                                    WB_o_write_csr_2           ,
    // forward data form WB
    input             [  `ysyx_23060136_BITS_W-1:0]          WB_o_rs1_data              ,
    input             [  `ysyx_23060136_BITS_W-1:0]          WB_o_rs2_data              ,
    input             [  `ysyx_23060136_BITS_W-1:0]          WB_o_csr_rs_data_1         ,
    input             [  `ysyx_23060136_BITS_W-1:0]          WB_o_csr_rs_data_2         ,


    // ===========================================================================
    // siganl for seg reg
    input                                                    BRANCH_PCSrc               ,

    output                                                   FORWARD_stallIF            ,
    output                                                   FORWARD_stallID            ,
    output                                                   FORWARD_stallEX            ,
    output                                                   FORWARD_stallEX2           ,
    output                                                   FORWARD_stallME            ,
    output                                                   FORWARD_stallWB            ,
    output                                                   FORWARD_flushEX1           ,  
    
    
    // signal for hazard unit in EXU
    output   logic     [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_EXU           ,
    output   logic     [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_EXU           ,
    output   logic     [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_EXU        ,

    output                                                   FORWARD_rs1_hazard_EXU         ,
    output                                                   FORWARD_rs2_hazard_EXU         ,
    output                                                   FORWARD_csr_rs_hazard_EXU      , 
    
    
    // signal for hazard in ID-EX seg register
    output   logic     [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_SEG           ,
    output   logic     [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_SEG           ,
    output   logic     [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_SEG        ,

    output                                                   FORWARD_rs1_hazard_SEG         ,
    output                                                   FORWARD_rs2_hazard_SEG         ,
    output                                                   FORWARD_csr_rs_hazard_SEG      ,
    
    // force to insert data in stall(to deal with first stage hazard)
    output                                                   FORWARD_rs1_hazard_SEG_f        ,
    output                                                   FORWARD_rs2_hazard_SEG_f        ,
    output                                                   FORWARD_csr_rs_hazard_SEG_f         
 );
   
    // 判断是否是写寄存器 X0
    wire       WB_rd_x0                 =  (WB_o_rd    == 'b0);
    wire       MEM_rd_x0                =  (MEM_i_rd   == 'b0);
    wire       EXU_rd_x0                =  (EXU_o_rd   == 'b0);

    // 4级数据冒险
    wire     fourth_stage_hazard_rs1     =  (IDU_o_rs1    == WB_o_rd)           & WB_o_write_gpr & ~WB_rd_x0 & ~BRANCH_PCSrc ;
    wire     fourth_stage_hazard_rs2     =  (IDU_o_rs2    == WB_o_rd)           & WB_o_write_gpr & ~WB_rd_x0 & ~BRANCH_PCSrc ;  
    wire     fourth_stage_hazard_csr_1   =  (IDU_o_csr_rs == WB_o_csr_rd_1)     & WB_o_write_csr_1 & ~BRANCH_PCSrc           ;
    wire     fourth_stage_hazard_csr_2   =  (IDU_o_csr_rs == WB_o_csr_rd_2)     & WB_o_write_csr_2 & ~BRANCH_PCSrc           ;

    // 3级数据冒险
    wire     third_stage_hazard_rs1      =  (EXU_i_rs1    == WB_o_rd)          & WB_o_write_gpr & ~WB_rd_x0 & ~BRANCH_PCSrc ;  
    wire     third_stage_hazard_rs2      =  (EXU_i_rs2    == WB_o_rd)          & WB_o_write_gpr & ~WB_rd_x0 & ~BRANCH_PCSrc ; 
    wire     third_stage_hazard_csr_1    =  (EXU_i_csr_rs == WB_o_csr_rd_1)    & WB_o_write_csr_1           & ~BRANCH_PCSrc ;
    wire     third_stage_hazard_csr_2    =  (EXU_i_csr_rs == WB_o_csr_rd_2)    & WB_o_write_csr_2           & ~BRANCH_PCSrc ;


    // 2级数据冒险
    wire     second_stage_hazard_rs1      =  (EXU_i_rs1    == MEM_i_rd)        & MEM_i_write_gpr   & ~MEM_i_mem_to_reg & ~MEM_rd_x0 & ~BRANCH_PCSrc ;  
    wire     second_stage_hazard_rs2      =  (EXU_i_rs2    == MEM_i_rd)        & MEM_i_write_gpr   & ~MEM_i_mem_to_reg & ~MEM_rd_x0 & ~BRANCH_PCSrc ; 
    wire     second_stage_hazard_csr_1    =  (EXU_i_csr_rs == MEM_i_csr_rd_1)  & MEM_i_write_csr_1 & ~MEM_i_mem_to_reg              & ~BRANCH_PCSrc ;
    wire     second_stage_hazard_csr_2    =  (EXU_i_csr_rs == MEM_i_csr_rd_2)  & MEM_i_write_csr_2 & ~MEM_i_mem_to_reg              & ~BRANCH_PCSrc ;


    // 1级数据冒险
    wire     first_stage_hazard_rs1       =  (EXU_i_rs1     ==  EXU_o_rd)          & EXU_o_write_gpr    & ~EXU_rd_x0               & ~BRANCH_PCSrc ;
    wire     first_stage_hazard_rs2       =  (EXU_i_rs2     ==  EXU_o_rd)          & EXU_o_write_gpr    & ~EXU_rd_x0               & ~BRANCH_PCSrc ;
    wire     first_stage_hazard_csr_1     =  (EXU_i_csr_rs  ==  EXU_o_csr_rd_1)    & EXU_o_write_csr_1                             & ~BRANCH_PCSrc ;
    wire     first_stage_hazard_csr_2     =  (EXU_i_csr_rs  ==  EXU_o_csr_rd_2)    & EXU_o_write_csr_2                             & ~BRANCH_PCSrc ;
    wire     first_stage_hazard           =  first_stage_hazard_rs1  | first_stage_hazard_rs2  | first_stage_hazard_csr_1  | first_stage_hazard_csr_2; 


    // load use 数据冒险(2 level)     
    wire     load_use_hazard_rs1          =  (EXU_i_rs1    == MEM_i_rd)        & MEM_i_write_gpr   & MEM_i_mem_to_reg & ~MEM_rd_x0 & ~BRANCH_PCSrc ;
    wire     load_use_hazard_rs2          =  (EXU_i_rs2    == MEM_i_rd)        & MEM_i_write_gpr   & MEM_i_mem_to_reg & ~MEM_rd_x0 & ~BRANCH_PCSrc ;
    wire     load_use_hazard_csr_1        =  (EXU_i_csr_rs == MEM_i_csr_rd_1)  & MEM_i_write_csr_1 & MEM_i_mem_to_reg              & ~BRANCH_PCSrc ;
    wire     load_use_hazard_csr_2        =  (EXU_i_csr_rs == MEM_i_csr_rd_2)  & MEM_i_write_csr_2 & MEM_i_mem_to_reg              & ~BRANCH_PCSrc ;


    // 流水段上所有操作已经完成
    wire     all_process_over     =   IFU_o_valid   &  EXU_o_valid   &  MEM_rvalid   &  MEM_wdone ;

    // stall and flush signal
    assign  FORWARD_stallIF       =   ~all_process_over | first_stage_hazard;
    assign  FORWARD_stallID       =   ~all_process_over | first_stage_hazard;
    assign  FORWARD_stallEX       =   ~all_process_over | first_stage_hazard;
    assign  FORWARD_stallEX2      =   ~all_process_over;
    assign  FORWARD_stallME       =   ~all_process_over;
    assign  FORWARD_stallWB       =   ~all_process_over;

    assign  FORWARD_flushEX1      =   first_stage_hazard;


    // ===========================================================================
    // forward sel signal for EXU hazard
    // second(load use) or third stage forward without first stage forward
    assign  FORWARD_rs1_hazard_EXU      =  (second_stage_hazard_rs1    | third_stage_hazard_rs1   | load_use_hazard_rs1) & !first_stage_hazard ;
    assign  FORWARD_rs2_hazard_EXU      =  (second_stage_hazard_rs2    | third_stage_hazard_rs2   | load_use_hazard_rs2) & !first_stage_hazard ;
    assign  FORWARD_csr_rs_hazard_EXU   =  (second_stage_hazard_csr_1  | third_stage_hazard_csr_1 | load_use_hazard_csr_1 | second_stage_hazard_csr_2  | third_stage_hazard_csr_2 | load_use_hazard_csr_2) & !first_stage_hazard;

    // forward sel for IDU-EXU seg register
    // fourth stage forward
    assign  FORWARD_rs1_hazard_SEG      =  (fourth_stage_hazard_rs1 & ~first_stage_hazard);                                 
    assign  FORWARD_rs2_hazard_SEG      =  (fourth_stage_hazard_rs2 & ~first_stage_hazard);                                 
    assign  FORWARD_csr_rs_hazard_SEG   =  ((fourth_stage_hazard_csr_1 | fourth_stage_hazard_csr_2) & ~first_stage_hazard); 

    // force to write seg reg to deal with first stage hazard
    assign  FORWARD_rs1_hazard_SEG_f    =  (second_stage_hazard_rs1    | third_stage_hazard_rs1   | load_use_hazard_rs1) & first_stage_hazard       ;  
    assign  FORWARD_rs2_hazard_SEG_f    =  (second_stage_hazard_rs2    | third_stage_hazard_rs2   | load_use_hazard_rs2) & first_stage_hazard       ;  
    assign  FORWARD_csr_rs_hazard_SEG_f =  (second_stage_hazard_csr_1  | third_stage_hazard_csr_1 | load_use_hazard_csr_1 | second_stage_hazard_csr_2  | third_stage_hazard_csr_2 | load_use_hazard_csr_2) & first_stage_hazard      ;  
    // ===========================================================================
    // forward data for EXU
    // 前传数据时注意优先级关系
    // 例如 level 3 和 level 2 同时为 true，则优先考虑 level 2
    always_comb begin : rs1_data_EXU
        if(second_stage_hazard_rs1 | load_use_hazard_rs1) begin
            if(second_stage_hazard_rs1) begin
                FORWARD_rs1_data_EXU = MEM_i_ALU_ALUout;
            end
            else begin
                FORWARD_rs1_data_EXU = MEM_o_rdata;
            end
        end
        else if(third_stage_hazard_rs1) begin
            FORWARD_rs1_data_EXU = WB_o_rs1_data;
        end
        else FORWARD_rs1_data_EXU =  `ysyx_23060136_false;
    end


    always_comb begin : rs2_data_EXU
        if(second_stage_hazard_rs2 | load_use_hazard_rs2) begin
            if(second_stage_hazard_rs2) begin
                FORWARD_rs2_data_EXU = MEM_i_ALU_ALUout;
            end
            else begin
                FORWARD_rs2_data_EXU = MEM_o_rdata;
            end
        end
        else if(third_stage_hazard_rs2) begin
            FORWARD_rs2_data_EXU = WB_o_rs2_data;
        end
        else FORWARD_rs2_data_EXU =  `ysyx_23060136_false;
    end


    always_comb begin : csr_rs_data_EXU
        if(second_stage_hazard_csr_1 | load_use_hazard_csr_1) begin
            if(second_stage_hazard_csr_1) begin
                FORWARD_csr_rs_data_EXU = MEM_i_ALU_CSR_out;
            end
            else begin
                FORWARD_csr_rs_data_EXU = MEM_o_rdata;
            end
        end
        else if(second_stage_hazard_csr_2 | load_use_hazard_csr_2) begin
            FORWARD_csr_rs_data_EXU = `ysyx_23060136_ecall_v;
        end
        else if(third_stage_hazard_rs1 | third_stage_hazard_rs2) begin
            if(third_stage_hazard_rs1) begin
                FORWARD_csr_rs_data_EXU = WB_o_csr_rs_data_1;
            end
            else begin
                FORWARD_csr_rs_data_EXU = WB_o_csr_rs_data_2;
            end
        end
        else FORWARD_csr_rs_data_EXU =  `ysyx_23060136_false;
    end


    // forward data for IDU_EXU_REG
    // ===========================================================================

    always_comb begin : rs1_data_SEG
        if(first_stage_hazard && (second_stage_hazard_rs1  | third_stage_hazard_rs1 | load_use_hazard_rs1)) begin
            if(second_stage_hazard_rs1 | load_use_hazard_rs1) begin
                if(second_stage_hazard_rs1) begin
                    FORWARD_rs1_data_SEG = MEM_i_ALU_ALUout;
                end
                else begin
                    FORWARD_rs1_data_SEG = MEM_o_rdata;
                end
            end
            else begin
                FORWARD_rs1_data_SEG = WB_o_rs1_data;
            end
        end
        else if(fourth_stage_hazard_rs1) begin
            FORWARD_rs1_data_SEG = WB_o_rs1_data;
        end
        else FORWARD_rs1_data_SEG =  `ysyx_23060136_false;
    end


    always_comb begin : rs2_data_SEG
        if(first_stage_hazard && (second_stage_hazard_rs2  | third_stage_hazard_rs2 | load_use_hazard_rs2)) begin
            if(second_stage_hazard_rs2 | load_use_hazard_rs2) begin
                if(second_stage_hazard_rs2) begin
                    FORWARD_rs2_data_SEG = MEM_i_ALU_ALUout;
                end
                else begin
                    FORWARD_rs2_data_SEG = MEM_o_rdata;
                end
            end
            else begin
                FORWARD_rs2_data_SEG = WB_o_rs2_data;
            end
        end
        else if(fourth_stage_hazard_rs2) begin
            FORWARD_rs2_data_SEG = WB_o_rs2_data;
        end
        else FORWARD_rs2_data_SEG =  `ysyx_23060136_false;
    end


    always_comb begin : csr_rs_data_SEG
        if(first_stage_hazard & (second_stage_hazard_csr_1  | third_stage_hazard_csr_1 | load_use_hazard_csr_1 | second_stage_hazard_csr_2  | third_stage_hazard_csr_2 | load_use_hazard_csr_2)) begin
            if(second_stage_hazard_csr_1 | load_use_hazard_csr_1) begin
                if(second_stage_hazard_csr_1) begin
                    FORWARD_csr_rs_data_SEG = MEM_i_ALU_CSR_out;
                end
                else begin
                    FORWARD_csr_rs_data_SEG = MEM_o_rdata;
                end
            end
            else if(second_stage_hazard_csr_2 | load_use_hazard_csr_2) begin
                FORWARD_csr_rs_data_SEG = `ysyx_23060136_ecall_v;
            end
            else begin
                if(third_stage_hazard_csr_1) begin
                    FORWARD_csr_rs_data_SEG = WB_o_csr_rs_data_1;
                end
                else begin
                    FORWARD_csr_rs_data_SEG = WB_o_csr_rs_data_2;
                end
            end
        end
        else if(fourth_stage_hazard_csr_1 | fourth_stage_hazard_csr_1) begin
            if(fourth_stage_hazard_csr_1) begin
                FORWARD_csr_rs_data_SEG = WB_o_csr_rs_data_1;
            end
            else begin
                FORWARD_csr_rs_data_SEG = WB_o_csr_rs_data_2;
            end
        end
        else FORWARD_csr_rs_data_SEG =  `ysyx_23060136_false;
    end

endmodule



 
