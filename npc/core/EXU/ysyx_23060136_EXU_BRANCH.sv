/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-06-11 11:03:39 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-06-11 12:23:00
 */



 `include "ysyx_23060136_DEFINES.sv"
 

// Branch control and BHT crtl
// ===========================================================================
module ysyx_23060136_EXU_BRANCH (
        // data
        input                                                     clk                         ,
        input                                                     rst                         ,
        input                                                     FORWARD_stallEX2            ,
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_pc                     ,
        // data from hazard in EXU1
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_rs1_data        ,
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_HAZARD_csr_rs_data     ,
        input              [  `ysyx_23060136_BITS_W -1:0]         EXU2_imm                    ,
        input                                                     EXU2_ALU_Less               ,
        input                                                     EXU2_ALU_Zero               ,

        // predict of BHT
        input                                                     EXU2_pre_take               ,
        input                                                     EXU2_Btype                  ,

        // jump/branch types isn't equal to jump signal
        input                                                     EXU2_jump                   ,
        input                                                     EXU2_pc_plus_imm            ,
        input                                                     EXU2_rs1_plus_imm           ,
        input                                                     EXU2_csr_plus_imm           ,
        // signal is 0 means jump directly
        input                                                     EXU2_cmp_eq                 ,
        input                                                     EXU2_cmp_neq                ,
        input                                                     EXU2_cmp_ge                 ,
        input                                                     EXU2_cmp_lt                 ,

        // BHT predict error, request to update
        output             [  `ysyx_23060136_BITS_W -1:0]         BHT_pc                      ,
        output                                                    BHT_pre_true                ,
        output                                                    BHT_pre_false               ,

        // jump target for IFU
        output             [  `ysyx_23060136_BITS_W -1:0]         branch_target               ,
        // jump signal
        output                                                    PCSrc                       ,
        // 控制冒险
        output                                                    BRANCH_flushIF              ,
        output                                                    BRANCH_flushID              ,
        output                                                    BRANCH_flushEX1             
    );

    wire   [`ysyx_23060136_BITS_W -1 : 0]  adder_da  =  ({`ysyx_23060136_BITS_W {EXU2_pc_plus_imm}}  & EXU2_pc)                 |
                                                        ({`ysyx_23060136_BITS_W {EXU2_rs1_plus_imm}} & EXU2_HAZARD_rs1_data)    |
                                                        ({`ysyx_23060136_BITS_W {EXU2_csr_plus_imm}} & EXU2_HAZARD_csr_rs_data) ;

    
                                                        
    assign   branch_target     =  !should_jump ? (BHT_pc + 'h04) : (adder_da + EXU2_imm);

    // judge whether to jump
    wire     should_jump       =  EXU2_jump & ~((EXU2_cmp_eq & ~EXU2_ALU_Zero) | (EXU2_cmp_neq & EXU2_ALU_Zero)   |
                                                (EXU2_cmp_ge & EXU2_ALU_Less)  | (EXU2_cmp_lt  & ~EXU2_ALU_Less)) ;

                                                
    // predict wrong, so flush the whole pipeline
    assign   PCSrc             =  (BHT_pre_false) | (should_jump & !EXU2_Btype);
                                            
    assign   BRANCH_flushID    =  PCSrc;
    assign   BRANCH_flushIF    =  PCSrc;
    assign   BRANCH_flushEX1   =  PCSrc;


    assign   BHT_pc            =  EXU2_pc;
    // wrong predict
    assign   BHT_pre_false     =  EXU2_Btype & ((should_jump & !EXU2_pre_take)  | (!should_jump & EXU2_pre_take));
    assign   BHT_pre_true      =  EXU2_Btype & ((should_jump & EXU2_pre_take)   | (!should_jump & !EXU2_pre_take));


    `ifdef bench_counter

        logic     [`ysyx_23060136_BITS_W-1 : 0]       pre_true_counter;
        logic     [`ysyx_23060136_BITS_W-1 : 0]       pre_false_counter;
        
        // DIP-C in verilog
        import "DPI-C" function void set_pre_true_counter(input logic [`ysyx_23060136_BITS_W-1 : 0] a []);
        import "DPI-C" function void set_pre_false_counter(input logic [`ysyx_23060136_BITS_W-1 : 0] a []);

        // set the ptr to register
        initial begin
            set_pre_true_counter(pre_true_counter);
            set_pre_false_counter(pre_false_counter);
        end

        always_ff @(posedge clk) begin : icache_counter_update
            if(rst) begin
                pre_true_counter  <=  `ysyx_23060136_false;
                pre_false_counter <=  `ysyx_23060136_false;
            end
            else if(!FORWARD_stallEX2 & BHT_pre_true) begin
                pre_true_counter  <=  pre_true_counter + 'h1;
            end
            else if(!FORWARD_stallEX2 & BHT_pre_false) begin
                pre_false_counter  <=  pre_false_counter + 'h1;
            end
        end   
                                                      
`endif


endmodule


