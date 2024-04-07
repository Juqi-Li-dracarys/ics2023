/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 10:46:52 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2024-04-07 10:46:52 
 */



 `include "ysyx_23060136_DEFINES.sv"

 
// module for handling data hazard in EXU and calculating ALU input
// ===========================================================================
module  ysyx_23060136_EXU_HAZARD (
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_rs1_data               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_rs2_data               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_csr_rs_data            ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_pc                     ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU_imm                    ,

        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_EXU       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_EXU       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_EXU    ,

        input                                                    FORWARD_rs1_hazard_EXU     ,
        input                                                    FORWARD_rs2_hazard_EXU     ,
        input                                                    FORWARD_csr_rs_hazard_EXU  ,
        
        // EXU internal use
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_rs1_data        ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_rs2_data        ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_HAZARD_csr_rs_data     ,

        // ALU pre calculate
        input                                                    EXU_ALU_i1_rs1             ,
        input                                                    EXU_ALU_i1_pc              ,
        input                                                    EXU_ALU_i2_rs2             ,
        input                                                    EXU_ALU_i2_imm             ,
        input                                                    EXU_ALU_i2_4               ,
        input                                                    EXU_ALU_i2_csr             ,

        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_da                 ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU_ALU_db                  
    );

    assign EXU_HAZARD_rs1_data    = FORWARD_rs1_hazard_EXU    ? FORWARD_rs1_data_EXU    :    EXU_rs1_data;
    assign EXU_HAZARD_rs2_data    = FORWARD_rs2_hazard_EXU    ? FORWARD_rs2_data_EXU    :    EXU_rs2_data;
    assign EXU_HAZARD_csr_rs_data = FORWARD_csr_rs_hazard_EXU ? FORWARD_csr_rs_data_EXU :    EXU_csr_rs_data;

    
    assign EXU_ALU_da             = ({`ysyx_23060136_BITS_W{EXU_ALU_i1_rs1}} & (EXU_HAZARD_rs1_data))    |
                                    ({`ysyx_23060136_BITS_W{EXU_ALU_i1_pc}}  & (EXU_pc))                 ;
                                    
    assign EXU_ALU_db             = ({`ysyx_23060136_BITS_W{EXU_ALU_i2_rs2}} & (EXU_HAZARD_rs2_data))    |
                                    ({`ysyx_23060136_BITS_W{EXU_ALU_i2_imm}} & (EXU_imm))                |
                                    ({`ysyx_23060136_BITS_W{EXU_ALU_i2_4}}   & (`ysyx_23060136_BITS_W'h4))                  |
                                    ({`ysyx_23060136_BITS_W{EXU_ALU_i2_csr}} & (EXU_csr_rs_data))        ;

endmodule


