/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-07 10:46:52 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-07 14:06:23
 */



 `include "ysyx_23060136_DEFINES.sv"

 
// module for handling data hazard in EXU1 and calculating ALU input
// ===========================================================================
module  ysyx_23060136_EXU_HAZARD (
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU1_rs1_data               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU1_rs2_data               ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU1_csr_rs_data            ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU1_pc                     ,
        input              [  `ysyx_23060136_BITS_W-1:0]         EXU1_imm                    ,

        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs1_data_EXU1       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_rs2_data_EXU1       ,
        input              [  `ysyx_23060136_BITS_W-1:0]         FORWARD_csr_rs_data_EXU1    ,

        input                                                    FORWARD_rs1_hazard_EXU1     ,
        input                                                    FORWARD_rs2_hazard_EXU1     ,
        input                                                    FORWARD_csr_rs_hazard_EXU1  ,
        
        // EXU1 internal use
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU1_HAZARD_rs1_data        ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU1_HAZARD_rs2_data        ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU1_HAZARD_csr_rs_data     ,

        // ALU pre calculate
        input                                                    EXU1_ALU_i1_rs1             ,
        input                                                    EXU1_ALU_i1_pc              ,
        input                                                    EXU1_ALU_i2_rs2             ,
        input                                                    EXU1_ALU_i2_imm             ,
        input                                                    EXU1_ALU_i2_4               ,
        input                                                    EXU1_ALU_i2_csr             ,

        output             [  `ysyx_23060136_BITS_W-1:0]         EXU1_ALU_da                 ,
        output             [  `ysyx_23060136_BITS_W-1:0]         EXU1_ALU_db                  
    );

    // To handle with the data hazard
    assign EXU1_HAZARD_rs1_data    = FORWARD_rs1_hazard_EXU1    ? FORWARD_rs1_data_EXU1    :    EXU1_rs1_data;
    assign EXU1_HAZARD_rs2_data    = FORWARD_rs2_hazard_EXU1    ? FORWARD_rs2_data_EXU1    :    EXU1_rs2_data;
    assign EXU1_HAZARD_csr_rs_data = FORWARD_csr_rs_hazard_EXU1 ? FORWARD_csr_rs_data_EXU1 :    EXU1_csr_rs_data;
    
    
    assign EXU1_ALU_da             = ({`ysyx_23060136_BITS_W{EXU1_ALU_i1_rs1}} & (EXU1_HAZARD_rs1_data))     |
                                     ({`ysyx_23060136_BITS_W{EXU1_ALU_i1_pc}}  & (EXU1_pc))                  ;
                          
                                     
    assign EXU1_ALU_db             = ({`ysyx_23060136_BITS_W{EXU1_ALU_i2_rs2}} & (EXU1_HAZARD_rs2_data))     |
                                     ({`ysyx_23060136_BITS_W{EXU1_ALU_i2_imm}} & (EXU1_imm))                 |
                                     ({`ysyx_23060136_BITS_W{EXU1_ALU_i2_4}}   & (`ysyx_23060136_BITS_W'h4)) |
                                     ({`ysyx_23060136_BITS_W{EXU1_ALU_i2_csr}} & (EXU1_csr_rs_data))         ;

endmodule


