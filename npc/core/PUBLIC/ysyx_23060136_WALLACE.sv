/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-05-02 09:50:14 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-05-02 16:04:39
 */

 
 `include "ysyx_23060136_DEFINES.sv"


// Due to product adding for 33 times, we request 33 bits Wallace tree
// SUM = \sum_{k=0}^{k=32} a_k (a_k = bool)
// ===========================================================================
module ysyx_23060136_WALLACE #(parameter wallece_width = 33)
(
    input              [  wallece_width-1:0]         src_in                     ,
    input              [  wallece_width-3:0]         cin                        ,
    output             [  wallece_width-3:0]         cout_group                 ,
    output                                           cout,s                      
);


wire                   [wallece_width-3:0]           c                          ;

// ===========================================================================
wire                   [  10:0]                      first_s                             ;
ysyx_23060136_CSA csa_1_1  (.in(src_in[32:30]), .cout(c[ 0]), .s(first_s[ 0]) )          ;
ysyx_23060136_CSA csa_1_2  (.in(src_in[29:27]), .cout(c[ 1]), .s(first_s[ 1]) )          ;
ysyx_23060136_CSA csa_1_3  (.in(src_in[26:24]), .cout(c[ 2]), .s(first_s[ 2]) )          ;
ysyx_23060136_CSA csa_1_4  (.in(src_in[23:21]), .cout(c[ 3]), .s(first_s[ 3]) )          ;
ysyx_23060136_CSA csa_1_5  (.in(src_in[20:18]), .cout(c[ 4]), .s(first_s[ 4]) )          ;
ysyx_23060136_CSA csa_1_6  (.in(src_in[17:15]), .cout(c[ 5]), .s(first_s[ 5]) )          ;
ysyx_23060136_CSA csa_1_7  (.in(src_in[14:12]), .cout(c[ 6]), .s(first_s[ 6]) )          ;
ysyx_23060136_CSA csa_1_8  (.in(src_in[11: 9]), .cout(c[ 7]), .s(first_s[ 7]) )          ;
ysyx_23060136_CSA csa_1_9  (.in(src_in[ 8: 6]), .cout(c[ 8]), .s(first_s[ 8]) )          ;
ysyx_23060136_CSA csa_1_10 (.in(src_in[ 5: 3]), .cout(c[ 9]), .s(first_s[ 9]) )          ;
ysyx_23060136_CSA csa_1_11 (.in(src_in[ 2: 0]), .cout(c[10]), .s(first_s[10]) )          ;


// ===========================================================================
wire                  [   6:0]                      second_s                             ;
ysyx_23060136_CSA csa_2_1  (.in(first_s[2:0]), .cout(c[11]), .s(second_s[ 0]) )          ;
ysyx_23060136_CSA csa_2_2  (.in(first_s[5:3]), .cout(c[12]), .s(second_s[ 1]) )          ;
ysyx_23060136_CSA csa_2_3  (.in(first_s[8:6]), .cout(c[13]), .s(second_s[ 2]) )          ;
ysyx_23060136_CSA csa_2_4  (.in({first_s[10:9],cin[0]}), .cout(c[14]), .s(second_s[ 3]) );
ysyx_23060136_CSA csa_2_5  (.in(cin[3:1]), .cout(c[15]), .s(second_s[ 4]) )              ;
ysyx_23060136_CSA csa_2_6  (.in(cin[6:4]), .cout(c[16]), .s(second_s[ 5]) )              ;
ysyx_23060136_CSA csa_2_7  (.in(cin[9:7]), .cout(c[17]), .s(second_s[ 6]) )              ;


// ===========================================================================
wire                   [   4:0]                    third_s                                ;
ysyx_23060136_CSA csa_3_1  (.in(second_s[2:0]), .cout(c[18]), .s(third_s[ 0]) )           ;
ysyx_23060136_CSA csa_3_2  (.in(second_s[5:3]), .cout(c[19]), .s(third_s[ 1]) )           ;
ysyx_23060136_CSA csa_3_3  (.in({second_s[6],cin[11:10]}), .cout(c[20]), .s(third_s[ 2]) );
ysyx_23060136_CSA csa_3_4  (.in(cin[14:12]), .cout(c[21]), .s(third_s[ 3]) )              ;
ysyx_23060136_CSA csa_3_5  (.in(cin[17:15]), .cout(c[22]), .s(third_s[ 4]) )              ;


// ===========================================================================
wire                   [   2:0]                     fourth_s                              ;
ysyx_23060136_CSA csa_4_1  (.in(third_s[2:0]), .cout(c[23]), .s(fourth_s[ 0]) )           ;
ysyx_23060136_CSA csa_4_2  (.in({third_s[4:3],cin[18]}), .cout(c[24]), .s(fourth_s[ 1]) ) ;
ysyx_23060136_CSA csa_4_3  (.in(cin[21:19]), .cout(c[25]), .s(fourth_s[ 2]) )             ;


// ===========================================================================
wire                   [   1:0]                     fifth_s                               ;
ysyx_23060136_CSA csa_5_1  (.in(fourth_s[2:0]), .cout(c[26]), .s(fifth_s[ 0]) )           ;
ysyx_23060136_CSA csa_5_2  (.in(cin[24:22]), .cout(c[27]), .s(fifth_s[ 1]) )              ;


// ===========================================================================
wire                   [   1:0]                     sixth_s                               ;
ysyx_23060136_CSA csa_6_1  (.in({fifth_s[1:0],cin[25]}), .cout(c[28]), .s(sixth_s[ 0]) )  ;
ysyx_23060136_CSA csa_6_2  (.in({cin[27:26],1'b0}), .cout(c[29]), .s(sixth_s[ 1]) )       ;


// ===========================================================================
wire                                                seventh_s                             ;
ysyx_23060136_CSA csa_7_1  (.in({sixth_s[1:0],cin[28]}), .cout(c[30]), .s(seventh_s) )    ;


// ===========================================================================
ysyx_23060136_CSA csa_8_1  (.in({seventh_s,cin[30:29]}), .cout(cout), .s(s) );


// ===========================================================================
assign cout_group = c;


endmodule


