/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-06-10 20:05:34 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-10 23:28:33
 */


 `include "ysyx_23060136_DEFINES.sv"
 
 // 00(strong not take) -> 01(not take) -> 10(take) -> 11(strong take)

 // BHT and mini-decoder
 // ===========================================================================
 module ysyx_23060136_IFU_BHT(
    input                                             clk               ,
    input                                             rst               ,
    input                                             FORWARD_stallIF   ,

    input     [  `ysyx_23060136_INST_W-1:0]           IFU_o_inst        ,
    input     [  `ysyx_23060136_BITS_W-1:0]           IFU_o_pc          ,

    // pc from BRANCH module
    input     [  `ysyx_23060136_BITS_W -1:0]          BHT_pc            ,
    // correct/wrong predict
    input                                             BHT_pre_true      ,
    input                                             BHT_pre_false     ,
    input                                             BRANCH_PCSrc      ,
    
    // predict result
    output    logic                                   BHT_pre_take          ,
    output                                            BHT_flushIF           ,
    output                                            BHT_PCSrc             ,
    output    [`ysyx_23060136_BITS_W - 1 : 0]         BHT_branch_target     

 );


    logic  [1 : 0]  BHT_bits_counter [`ysyx_23060136_BHT_size-1 : 0];

    
    // amend the predict result of BHT
    integer i;
    always_ff @(posedge clk) begin : BHT_update
        if(rst) begin
            for(i = 0; i < `ysyx_23060136_BHT_size; i = i + 1) begin
                BHT_bits_counter[i] <=  `ysyx_23060136_false;
            end
        end
        else if(BHT_pre_false & !FORWARD_stallIF) begin
            BHT_bits_counter[BHT_pc[8 : 0]] <= BRANCH_PCSrc ? BHT_bits_counter[BHT_pc[8 : 0]] + 2'b1 : 
                                                              BHT_bits_counter[BHT_pc[8 : 0]] - 2'b1 ;
        end
        else if(BHT_pre_true & !FORWARD_stallIF) begin
            if(BHT_bits_counter[BHT_pc[8 : 0]][1]) begin
                BHT_bits_counter[BHT_pc[8 : 0]] <= 2'b11;
            end
            else begin
                BHT_bits_counter[BHT_pc[8 : 0]] <= 2'b00;
            end
        end
    end

    // ===========================================================================
    // mini-decode
    wire  [6 : 0]  opcode      =   IFU_o_inst[6 : 0] ;
    wire  opcode_1_0_11  = (opcode[1 : 0] == 2'b11) ;
    wire  opcode_4_2_000 = (opcode[4 : 2] == 3'b000);
    wire  opcode_4_2_011 = (opcode[4 : 2] == 3'b011);
    wire  opcode_6_5_11  = (opcode[6 : 5] == 2'b11) ;

    wire  [`ysyx_23060136_BITS_W - 1 : 0]  imm_B  =  {{52{IFU_o_inst[31]}}, IFU_o_inst[7], IFU_o_inst[30 : 25], IFU_o_inst[11 : 8], 1'b0};
    wire  [`ysyx_23060136_BITS_W - 1 : 0]  imm_J  =  {{44{IFU_o_inst[31]}}, IFU_o_inst[19 : 12], IFU_o_inst[20], IFU_o_inst[30 : 21], 1'b0};


    // Branch
    wire  rv64_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11;

    // jump without condition
    wire  rv64_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11;


    // predict result
    always_comb begin : result
        BHT_pre_take =  `ysyx_23060136_false;
        if(rv64_jal) begin
            BHT_pre_take =  `ysyx_23060136_true;
        end
        else if(rv64_branch) begin
            if(BHT_bits_counter[IFU_o_pc[8 : 0]][1]) begin
                BHT_pre_take =  `ysyx_23060136_true;
            end
            else begin
                BHT_pre_take =  `ysyx_23060136_false;
            end
        end
    end

     assign  BHT_flushIF        =   BHT_pre_take;
     assign  BHT_PCSrc          =   BHT_pre_take;
     assign  BHT_branch_target  =   IFU_o_pc  +  (rv64_branch ? imm_B : imm_J);


 endmodule





