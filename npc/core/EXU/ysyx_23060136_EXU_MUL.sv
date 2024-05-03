/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-04-08 12:09:07 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-08 12:53:28
 */


 `include "ysyx_23060136_DEFINES.sv"


// 64-Bit multiply
// ===========================================================================
module ysyx_23060136_EXU_MUL (
    input                                                 clk           ,          
    input                                                 rst	        ,          
    input                                                 mul_valid	    ,                           
    input                                                 mulw	        ,                   
    input            [1 : 0]                              mul_signed    ,          
    input            [  `ysyx_23060136_BITS_W-1:0 ]       multiplicand  ,                
    input            [  `ysyx_23060136_BITS_W-1:0 ]       multiplier	, 

    output    logic                                       mul_ready	    ,                                                                    
    output    logic                                       mul_out_valid ,                                                          
    output    logic  [  `ysyx_23060136_BITS_W-1:0 ]       result_hi	    ,                                                             
    output    logic  [  `ysyx_23060136_BITS_W-1:0 ]       result_lo	                                                                                                                                   
);


`ifdef USE_WALLACE

    // convert all 64 bits input into 66 bits signed type
    wire                   [  65:0]         mul_a                      ;
    wire                   [  65:0]         mul_b                      ;

    assign      mul_a      [31 : 0]  =      multiplicand [31 : 0]      ;
    assign      mul_b      [31 : 0]  =      multiplier   [31 : 0]      ;

    assign      mul_a      [63 : 32] =      mulw ? (mul_signed[1] ? {32{multiplicand[31]}} : 32'b0) : multiplicand[63:32];
    assign      mul_b      [63 : 32] =      mulw ? (mul_signed[0] ? {32{multiplier  [31]}} : 32'b0) : multiplier  [63:32];

    assign      mul_a      [65 : 64] =      (mul_signed[1]) ? (mulw ? {2{multiplicand[31]}} : {2{multiplicand[63]}}) :  2'b0;
    assign      mul_b      [65 : 64] =      (mul_signed[0]) ? (mulw ? {2{multiplier  [31]}} : {2{multiplier  [63]}}) :  2'b0;


    // ===========================================================================
    // partial product
    wire [131 : 0] P [32 : 0];

    // carry
    wire [32 : 0] c;

    // generate product
    ysyx_23060136_PP  part_product00 ({mul_b[1:0],1'b0}, {{66{mul_a[65]}},mul_a}           , P[00], c[ 0]);
    ysyx_23060136_PP  part_product01 (mul_b[ 3: 1]     , {{64{mul_a[65]}},mul_a,{ 2{1'b0}}}, P[01], c[ 1]);
    ysyx_23060136_PP  part_product02 (mul_b[ 5: 3]     , {{62{mul_a[65]}},mul_a,{ 4{1'b0}}}, P[02], c[ 2]);
    ysyx_23060136_PP  part_product03 (mul_b[ 7: 5]     , {{60{mul_a[65]}},mul_a,{ 6{1'b0}}}, P[03], c[ 3]);
    ysyx_23060136_PP  part_product04 (mul_b[ 9: 7]     , {{58{mul_a[65]}},mul_a,{ 8{1'b0}}}, P[04], c[ 4]);
    ysyx_23060136_PP  part_product05 (mul_b[11: 9]     , {{56{mul_a[65]}},mul_a,{10{1'b0}}}, P[05], c[ 5]);
    ysyx_23060136_PP  part_product06 (mul_b[13:11]     , {{54{mul_a[65]}},mul_a,{12{1'b0}}}, P[06], c[ 6]);
    ysyx_23060136_PP  part_product07 (mul_b[15:13]     , {{52{mul_a[65]}},mul_a,{14{1'b0}}}, P[07], c[ 7]);
    ysyx_23060136_PP  part_product08 (mul_b[17:15]     , {{50{mul_a[65]}},mul_a,{16{1'b0}}}, P[08], c[ 8]);
    ysyx_23060136_PP  part_product09 (mul_b[19:17]     , {{48{mul_a[65]}},mul_a,{18{1'b0}}}, P[09], c[ 9]);
    ysyx_23060136_PP  part_product10 (mul_b[21:19]     , {{46{mul_a[65]}},mul_a,{20{1'b0}}}, P[10], c[10]);
    ysyx_23060136_PP  part_product11 (mul_b[23:21]     , {{44{mul_a[65]}},mul_a,{22{1'b0}}}, P[11], c[11]);
    ysyx_23060136_PP  part_product12 (mul_b[25:23]     , {{42{mul_a[65]}},mul_a,{24{1'b0}}}, P[12], c[12]);
    ysyx_23060136_PP  part_product13 (mul_b[27:25]     , {{40{mul_a[65]}},mul_a,{26{1'b0}}}, P[13], c[13]);
    ysyx_23060136_PP  part_product14 (mul_b[29:27]     , {{38{mul_a[65]}},mul_a,{28{1'b0}}}, P[14], c[14]);
    ysyx_23060136_PP  part_product15 (mul_b[31:29]     , {{36{mul_a[65]}},mul_a,{30{1'b0}}}, P[15], c[15]);
    ysyx_23060136_PP  part_product16 (mul_b[33:31]     , {{34{mul_a[65]}},mul_a,{32{1'b0}}}, P[16], c[16]);
    ysyx_23060136_PP  part_product17 (mul_b[35:33]     , {{32{mul_a[65]}},mul_a,{34{1'b0}}}, P[17], c[17]);
    ysyx_23060136_PP  part_product18 (mul_b[37:35]     , {{30{mul_a[65]}},mul_a,{36{1'b0}}}, P[18], c[18]);
    ysyx_23060136_PP  part_product19 (mul_b[39:37]     , {{28{mul_a[65]}},mul_a,{38{1'b0}}}, P[19], c[19]);
    ysyx_23060136_PP  part_product20 (mul_b[41:39]     , {{26{mul_a[65]}},mul_a,{40{1'b0}}}, P[20], c[20]);
    ysyx_23060136_PP  part_product21 (mul_b[43:41]     , {{24{mul_a[65]}},mul_a,{42{1'b0}}}, P[21], c[21]);
    ysyx_23060136_PP  part_product22 (mul_b[45:43]     , {{22{mul_a[65]}},mul_a,{44{1'b0}}}, P[22], c[22]);
    ysyx_23060136_PP  part_product23 (mul_b[47:45]     , {{20{mul_a[65]}},mul_a,{46{1'b0}}}, P[23], c[23]);
    ysyx_23060136_PP  part_product24 (mul_b[49:47]     , {{18{mul_a[65]}},mul_a,{48{1'b0}}}, P[24], c[24]);
    ysyx_23060136_PP  part_product25 (mul_b[51:49]     , {{16{mul_a[65]}},mul_a,{50{1'b0}}}, P[25], c[25]);
    ysyx_23060136_PP  part_product26 (mul_b[53:51]     , {{14{mul_a[65]}},mul_a,{52{1'b0}}}, P[26], c[26]);
    ysyx_23060136_PP  part_product27 (mul_b[55:53]     , {{12{mul_a[65]}},mul_a,{54{1'b0}}}, P[27], c[27]);
    ysyx_23060136_PP  part_product28 (mul_b[57:55]     , {{10{mul_a[65]}},mul_a,{56{1'b0}}}, P[28], c[28]);
    ysyx_23060136_PP  part_product29 (mul_b[59:57]     , {{ 8{mul_a[65]}},mul_a,{58{1'b0}}}, P[29], c[29]);
    ysyx_23060136_PP  part_product30 (mul_b[61:59]     , {{ 6{mul_a[65]}},mul_a,{60{1'b0}}}, P[30], c[30]);
    ysyx_23060136_PP  part_product31 (mul_b[63:61]     , {{ 4{mul_a[65]}},mul_a,{62{1'b0}}}, P[31], c[31]);
    ysyx_23060136_PP  part_product32 (mul_b[65:63]     , {{ 2{mul_a[65]}},mul_a,{64{1'b0}}}, P[32], c[32]);

    // seg reg
    reg      [131 : 0]       P_seg_reg     [32 : 0]     ;
    reg      [32 : 0]        c_seg_reg                  ;
    reg                      mul_pipe1_valid            ;

    integer l;
    always_ff @(posedge clk) begin
        if(rst) begin
            for(l = 0; l < 33; l = l + 1) begin
                P_seg_reg[l] <= 132'b0;
            end
            c_seg_reg <= 33'b0;
            mul_pipe1_valid  <= `ysyx_23060136_false;
        end
        else if(mul_valid && mul_ready) begin
            for(l = 0; l < 33;l = l + 1) begin
                P_seg_reg[l] <= P[l];
            end
            c_seg_reg <= c;
            mul_pipe1_valid  <= `ysyx_23060136_true;
        end
        else begin
            mul_pipe1_valid  <= `ysyx_23060136_false;
        end
    end


    // ===========================================================================
    // switch
    wire [32:0] walloc_din [131:0];

    genvar i;
    generate
        for(i = 0; i <= 131; i = i+1) begin
            assign walloc_din [i] = {P_seg_reg[00][i],P_seg_reg[01][i],P_seg_reg[02][i],P_seg_reg[03][i],
                                     P_seg_reg[04][i],P_seg_reg[05][i],P_seg_reg[06][i],P_seg_reg[07][i],
                                     P_seg_reg[08][i],P_seg_reg[09][i],P_seg_reg[10][i],P_seg_reg[11][i],
                                     P_seg_reg[12][i],P_seg_reg[13][i],P_seg_reg[14][i],P_seg_reg[15][i],
                                     P_seg_reg[16][i],P_seg_reg[17][i],P_seg_reg[18][i],P_seg_reg[19][i],
                                     P_seg_reg[20][i],P_seg_reg[21][i],P_seg_reg[22][i],P_seg_reg[23][i],
                                     P_seg_reg[24][i],P_seg_reg[25][i],P_seg_reg[26][i],P_seg_reg[27][i],
                                     P_seg_reg[28][i],P_seg_reg[29][i],P_seg_reg[30][i],P_seg_reg[31][i],P_seg_reg[32][i]};
        end
    endgenerate

    // ===========================================================================
    // tree output and carry
    wire [130  :0]  walloc_c                ;
    wire [131 : 0]  walloc_s                ;
    // carry output of each tree
    wire [30 : 0]   walloc_cgroup [1 : 131] ;


    ysyx_23060136_WALLACE walloc_tree0   (walloc_din[0],c_seg_reg[30:0],walloc_cgroup[01],walloc_c[0],walloc_s[0] );
    ysyx_23060136_WALLACE walloc_tree01  (walloc_din[ 01],walloc_cgroup[01],walloc_cgroup[02],walloc_c[ 01],walloc_s[ 01] );
    ysyx_23060136_WALLACE walloc_tree02  (walloc_din[ 02],walloc_cgroup[02],walloc_cgroup[03],walloc_c[ 02],walloc_s[ 02] );
    ysyx_23060136_WALLACE walloc_tree03  (walloc_din[ 03],walloc_cgroup[03],walloc_cgroup[04],walloc_c[ 03],walloc_s[ 03] );
    ysyx_23060136_WALLACE walloc_tree04  (walloc_din[ 04],walloc_cgroup[04],walloc_cgroup[05],walloc_c[ 04],walloc_s[ 04] );
    ysyx_23060136_WALLACE walloc_tree05  (walloc_din[ 05],walloc_cgroup[05],walloc_cgroup[06],walloc_c[ 05],walloc_s[ 05] );
    ysyx_23060136_WALLACE walloc_tree06  (walloc_din[ 06],walloc_cgroup[06],walloc_cgroup[07],walloc_c[ 06],walloc_s[ 06] );
    ysyx_23060136_WALLACE walloc_tree07  (walloc_din[ 07],walloc_cgroup[07],walloc_cgroup[08],walloc_c[ 07],walloc_s[ 07] );
    ysyx_23060136_WALLACE walloc_tree08  (walloc_din[ 08],walloc_cgroup[08],walloc_cgroup[09],walloc_c[ 08],walloc_s[ 08] );
    ysyx_23060136_WALLACE walloc_tree09  (walloc_din[ 09],walloc_cgroup[09],walloc_cgroup[10],walloc_c[ 09],walloc_s[ 09] );
    ysyx_23060136_WALLACE walloc_tree10  (walloc_din[ 10],walloc_cgroup[10],walloc_cgroup[11],walloc_c[ 10],walloc_s[ 10] );
    ysyx_23060136_WALLACE walloc_tree11  (walloc_din[ 11],walloc_cgroup[11],walloc_cgroup[12],walloc_c[ 11],walloc_s[ 11] );
    ysyx_23060136_WALLACE walloc_tree12  (walloc_din[ 12],walloc_cgroup[12],walloc_cgroup[13],walloc_c[ 12],walloc_s[ 12] );
    ysyx_23060136_WALLACE walloc_tree13  (walloc_din[ 13],walloc_cgroup[13],walloc_cgroup[14],walloc_c[ 13],walloc_s[ 13] );
    ysyx_23060136_WALLACE walloc_tree14  (walloc_din[ 14],walloc_cgroup[14],walloc_cgroup[15],walloc_c[ 14],walloc_s[ 14] );
    ysyx_23060136_WALLACE walloc_tree15  (walloc_din[ 15],walloc_cgroup[15],walloc_cgroup[16],walloc_c[ 15],walloc_s[ 15] );
    ysyx_23060136_WALLACE walloc_tree16  (walloc_din[ 16],walloc_cgroup[16],walloc_cgroup[17],walloc_c[ 16],walloc_s[ 16] );
    ysyx_23060136_WALLACE walloc_tree17  (walloc_din[ 17],walloc_cgroup[17],walloc_cgroup[18],walloc_c[ 17],walloc_s[ 17] );
    ysyx_23060136_WALLACE walloc_tree18  (walloc_din[ 18],walloc_cgroup[18],walloc_cgroup[19],walloc_c[ 18],walloc_s[ 18] );
    ysyx_23060136_WALLACE walloc_tree19  (walloc_din[ 19],walloc_cgroup[19],walloc_cgroup[20],walloc_c[ 19],walloc_s[ 19] );
    ysyx_23060136_WALLACE walloc_tree20  (walloc_din[ 20],walloc_cgroup[20],walloc_cgroup[21],walloc_c[ 20],walloc_s[ 20] );
    ysyx_23060136_WALLACE walloc_tree21  (walloc_din[ 21],walloc_cgroup[21],walloc_cgroup[22],walloc_c[ 21],walloc_s[ 21] );
    ysyx_23060136_WALLACE walloc_tree22  (walloc_din[ 22],walloc_cgroup[22],walloc_cgroup[23],walloc_c[ 22],walloc_s[ 22] );
    ysyx_23060136_WALLACE walloc_tree23  (walloc_din[ 23],walloc_cgroup[23],walloc_cgroup[24],walloc_c[ 23],walloc_s[ 23] );
    ysyx_23060136_WALLACE walloc_tree24  (walloc_din[ 24],walloc_cgroup[24],walloc_cgroup[25],walloc_c[ 24],walloc_s[ 24] );
    ysyx_23060136_WALLACE walloc_tree25  (walloc_din[ 25],walloc_cgroup[25],walloc_cgroup[26],walloc_c[ 25],walloc_s[ 25] );
    ysyx_23060136_WALLACE walloc_tree26  (walloc_din[ 26],walloc_cgroup[26],walloc_cgroup[27],walloc_c[ 26],walloc_s[ 26] );
    ysyx_23060136_WALLACE walloc_tree27  (walloc_din[ 27],walloc_cgroup[27],walloc_cgroup[28],walloc_c[ 27],walloc_s[ 27] );
    ysyx_23060136_WALLACE walloc_tree28  (walloc_din[ 28],walloc_cgroup[28],walloc_cgroup[29],walloc_c[ 28],walloc_s[ 28] );
    ysyx_23060136_WALLACE walloc_tree29  (walloc_din[ 29],walloc_cgroup[29],walloc_cgroup[30],walloc_c[ 29],walloc_s[ 29] );
    ysyx_23060136_WALLACE walloc_tree30  (walloc_din[ 30],walloc_cgroup[30],walloc_cgroup[31],walloc_c[ 30],walloc_s[ 30] );
    ysyx_23060136_WALLACE walloc_tree31  (walloc_din[ 31],walloc_cgroup[31],walloc_cgroup[32],walloc_c[ 31],walloc_s[ 31] );
    ysyx_23060136_WALLACE walloc_tree32  (walloc_din[ 32],walloc_cgroup[32],walloc_cgroup[33],walloc_c[ 32],walloc_s[ 32] );
    ysyx_23060136_WALLACE walloc_tree33  (walloc_din[ 33],walloc_cgroup[33],walloc_cgroup[34],walloc_c[ 33],walloc_s[ 33] );
    ysyx_23060136_WALLACE walloc_tree34  (walloc_din[ 34],walloc_cgroup[34],walloc_cgroup[35],walloc_c[ 34],walloc_s[ 34] );
    ysyx_23060136_WALLACE walloc_tree35  (walloc_din[ 35],walloc_cgroup[35],walloc_cgroup[36],walloc_c[ 35],walloc_s[ 35] );
    ysyx_23060136_WALLACE walloc_tree36  (walloc_din[ 36],walloc_cgroup[36],walloc_cgroup[37],walloc_c[ 36],walloc_s[ 36] );
    ysyx_23060136_WALLACE walloc_tree37  (walloc_din[ 37],walloc_cgroup[37],walloc_cgroup[38],walloc_c[ 37],walloc_s[ 37] );
    ysyx_23060136_WALLACE walloc_tree38  (walloc_din[ 38],walloc_cgroup[38],walloc_cgroup[39],walloc_c[ 38],walloc_s[ 38] );
    ysyx_23060136_WALLACE walloc_tree39  (walloc_din[ 39],walloc_cgroup[39],walloc_cgroup[40],walloc_c[ 39],walloc_s[ 39] );
    ysyx_23060136_WALLACE walloc_tree40  (walloc_din[ 40],walloc_cgroup[40],walloc_cgroup[41],walloc_c[ 40],walloc_s[ 40] );
    ysyx_23060136_WALLACE walloc_tree41  (walloc_din[ 41],walloc_cgroup[41],walloc_cgroup[42],walloc_c[ 41],walloc_s[ 41] );
    ysyx_23060136_WALLACE walloc_tree42  (walloc_din[ 42],walloc_cgroup[42],walloc_cgroup[43],walloc_c[ 42],walloc_s[ 42] );
    ysyx_23060136_WALLACE walloc_tree43  (walloc_din[ 43],walloc_cgroup[43],walloc_cgroup[44],walloc_c[ 43],walloc_s[ 43] );
    ysyx_23060136_WALLACE walloc_tree44  (walloc_din[ 44],walloc_cgroup[44],walloc_cgroup[45],walloc_c[ 44],walloc_s[ 44] );
    ysyx_23060136_WALLACE walloc_tree45  (walloc_din[ 45],walloc_cgroup[45],walloc_cgroup[46],walloc_c[ 45],walloc_s[ 45] );
    ysyx_23060136_WALLACE walloc_tree46  (walloc_din[ 46],walloc_cgroup[46],walloc_cgroup[47],walloc_c[ 46],walloc_s[ 46] );
    ysyx_23060136_WALLACE walloc_tree47  (walloc_din[ 47],walloc_cgroup[47],walloc_cgroup[48],walloc_c[ 47],walloc_s[ 47] );
    ysyx_23060136_WALLACE walloc_tree48  (walloc_din[ 48],walloc_cgroup[48],walloc_cgroup[49],walloc_c[ 48],walloc_s[ 48] );
    ysyx_23060136_WALLACE walloc_tree49  (walloc_din[ 49],walloc_cgroup[49],walloc_cgroup[50],walloc_c[ 49],walloc_s[ 49] );
    ysyx_23060136_WALLACE walloc_tree50  (walloc_din[ 50],walloc_cgroup[50],walloc_cgroup[51],walloc_c[ 50],walloc_s[ 50] );
    ysyx_23060136_WALLACE walloc_tree51  (walloc_din[ 51],walloc_cgroup[51],walloc_cgroup[52],walloc_c[ 51],walloc_s[ 51] );
    ysyx_23060136_WALLACE walloc_tree52  (walloc_din[ 52],walloc_cgroup[52],walloc_cgroup[53],walloc_c[ 52],walloc_s[ 52] );
    ysyx_23060136_WALLACE walloc_tree53  (walloc_din[ 53],walloc_cgroup[53],walloc_cgroup[54],walloc_c[ 53],walloc_s[ 53] );
    ysyx_23060136_WALLACE walloc_tree54  (walloc_din[ 54],walloc_cgroup[54],walloc_cgroup[55],walloc_c[ 54],walloc_s[ 54] );
    ysyx_23060136_WALLACE walloc_tree55  (walloc_din[ 55],walloc_cgroup[55],walloc_cgroup[56],walloc_c[ 55],walloc_s[ 55] );
    ysyx_23060136_WALLACE walloc_tree56  (walloc_din[ 56],walloc_cgroup[56],walloc_cgroup[57],walloc_c[ 56],walloc_s[ 56] );
    ysyx_23060136_WALLACE walloc_tree57  (walloc_din[ 57],walloc_cgroup[57],walloc_cgroup[58],walloc_c[ 57],walloc_s[ 57] );
    ysyx_23060136_WALLACE walloc_tree58  (walloc_din[ 58],walloc_cgroup[58],walloc_cgroup[59],walloc_c[ 58],walloc_s[ 58] );
    ysyx_23060136_WALLACE walloc_tree59  (walloc_din[ 59],walloc_cgroup[59],walloc_cgroup[60],walloc_c[ 59],walloc_s[ 59] );
    ysyx_23060136_WALLACE walloc_tree60  (walloc_din[ 60],walloc_cgroup[60],walloc_cgroup[61],walloc_c[ 60],walloc_s[ 60] );
    ysyx_23060136_WALLACE walloc_tree61  (walloc_din[ 61],walloc_cgroup[61],walloc_cgroup[62],walloc_c[ 61],walloc_s[ 61] );
    ysyx_23060136_WALLACE walloc_tree62  (walloc_din[ 62],walloc_cgroup[62],walloc_cgroup[63],walloc_c[ 62],walloc_s[ 62] );
    ysyx_23060136_WALLACE walloc_tree63  (walloc_din[ 63],walloc_cgroup[63],walloc_cgroup[64],walloc_c[ 63],walloc_s[ 63] );
    ysyx_23060136_WALLACE walloc_tree64  (walloc_din[ 64],walloc_cgroup[64],walloc_cgroup[65],walloc_c[ 64],walloc_s[ 64] );
    ysyx_23060136_WALLACE walloc_tree65  (walloc_din[ 65],walloc_cgroup[65],walloc_cgroup[66],walloc_c[ 65],walloc_s[ 65] );
    ysyx_23060136_WALLACE walloc_tree66  (walloc_din[ 66],walloc_cgroup[66],walloc_cgroup[67],walloc_c[ 66],walloc_s[ 66] );
    ysyx_23060136_WALLACE walloc_tree67  (walloc_din[ 67],walloc_cgroup[67],walloc_cgroup[68],walloc_c[ 67],walloc_s[ 67] );
    ysyx_23060136_WALLACE walloc_tree68  (walloc_din[ 68],walloc_cgroup[68],walloc_cgroup[69],walloc_c[ 68],walloc_s[ 68] );
    ysyx_23060136_WALLACE walloc_tree69  (walloc_din[ 69],walloc_cgroup[69],walloc_cgroup[70],walloc_c[ 69],walloc_s[ 69] );
    ysyx_23060136_WALLACE walloc_tree70  (walloc_din[ 70],walloc_cgroup[70],walloc_cgroup[71],walloc_c[ 70],walloc_s[ 70] );
    ysyx_23060136_WALLACE walloc_tree71  (walloc_din[ 71],walloc_cgroup[71],walloc_cgroup[72],walloc_c[ 71],walloc_s[ 71] );
    ysyx_23060136_WALLACE walloc_tree72  (walloc_din[ 72],walloc_cgroup[72],walloc_cgroup[73],walloc_c[ 72],walloc_s[ 72] );
    ysyx_23060136_WALLACE walloc_tree73  (walloc_din[ 73],walloc_cgroup[73],walloc_cgroup[74],walloc_c[ 73],walloc_s[ 73] );
    ysyx_23060136_WALLACE walloc_tree74  (walloc_din[ 74],walloc_cgroup[74],walloc_cgroup[75],walloc_c[ 74],walloc_s[ 74] );
    ysyx_23060136_WALLACE walloc_tree75  (walloc_din[ 75],walloc_cgroup[75],walloc_cgroup[76],walloc_c[ 75],walloc_s[ 75] );
    ysyx_23060136_WALLACE walloc_tree76  (walloc_din[ 76],walloc_cgroup[76],walloc_cgroup[77],walloc_c[ 76],walloc_s[ 76] );
    ysyx_23060136_WALLACE walloc_tree77  (walloc_din[ 77],walloc_cgroup[77],walloc_cgroup[78],walloc_c[ 77],walloc_s[ 77] );
    ysyx_23060136_WALLACE walloc_tree78  (walloc_din[ 78],walloc_cgroup[78],walloc_cgroup[79],walloc_c[ 78],walloc_s[ 78] );
    ysyx_23060136_WALLACE walloc_tree79  (walloc_din[ 79],walloc_cgroup[79],walloc_cgroup[80],walloc_c[ 79],walloc_s[ 79] );
    ysyx_23060136_WALLACE walloc_tree80  (walloc_din[ 80],walloc_cgroup[80],walloc_cgroup[81],walloc_c[ 80],walloc_s[ 80] );
    ysyx_23060136_WALLACE walloc_tree81  (walloc_din[ 81],walloc_cgroup[81],walloc_cgroup[82],walloc_c[ 81],walloc_s[ 81] );
    ysyx_23060136_WALLACE walloc_tree82  (walloc_din[ 82],walloc_cgroup[82],walloc_cgroup[83],walloc_c[ 82],walloc_s[ 82] );
    ysyx_23060136_WALLACE walloc_tree83  (walloc_din[ 83],walloc_cgroup[83],walloc_cgroup[84],walloc_c[ 83],walloc_s[ 83] );
    ysyx_23060136_WALLACE walloc_tree84  (walloc_din[ 84],walloc_cgroup[84],walloc_cgroup[85],walloc_c[ 84],walloc_s[ 84] );
    ysyx_23060136_WALLACE walloc_tree85  (walloc_din[ 85],walloc_cgroup[85],walloc_cgroup[86],walloc_c[ 85],walloc_s[ 85] );
    ysyx_23060136_WALLACE walloc_tree86  (walloc_din[ 86],walloc_cgroup[86],walloc_cgroup[87],walloc_c[ 86],walloc_s[ 86] );
    ysyx_23060136_WALLACE walloc_tree87  (walloc_din[ 87],walloc_cgroup[87],walloc_cgroup[88],walloc_c[ 87],walloc_s[ 87] );
    ysyx_23060136_WALLACE walloc_tree88  (walloc_din[ 88],walloc_cgroup[88],walloc_cgroup[89],walloc_c[ 88],walloc_s[ 88] );
    ysyx_23060136_WALLACE walloc_tree89  (walloc_din[ 89],walloc_cgroup[89],walloc_cgroup[90],walloc_c[ 89],walloc_s[ 89] );
    ysyx_23060136_WALLACE walloc_tree90  (walloc_din[ 90],walloc_cgroup[90],walloc_cgroup[91],walloc_c[ 90],walloc_s[ 90] );
    ysyx_23060136_WALLACE walloc_tree91  (walloc_din[ 91],walloc_cgroup[91],walloc_cgroup[92],walloc_c[ 91],walloc_s[ 91] );
    ysyx_23060136_WALLACE walloc_tree92  (walloc_din[ 92],walloc_cgroup[92],walloc_cgroup[93],walloc_c[ 92],walloc_s[ 92] );
    ysyx_23060136_WALLACE walloc_tree93  (walloc_din[ 93],walloc_cgroup[93],walloc_cgroup[94],walloc_c[ 93],walloc_s[ 93] );
    ysyx_23060136_WALLACE walloc_tree94  (walloc_din[ 94],walloc_cgroup[94],walloc_cgroup[95],walloc_c[ 94],walloc_s[ 94] );
    ysyx_23060136_WALLACE walloc_tree95  (walloc_din[ 95],walloc_cgroup[95],walloc_cgroup[96],walloc_c[ 95],walloc_s[ 95] );
    ysyx_23060136_WALLACE walloc_tree96  (walloc_din[ 96],walloc_cgroup[96],walloc_cgroup[97],walloc_c[ 96],walloc_s[ 96] );
    ysyx_23060136_WALLACE walloc_tree97  (walloc_din[ 97],walloc_cgroup[97],walloc_cgroup[98],walloc_c[ 97],walloc_s[ 97] );
    ysyx_23060136_WALLACE walloc_tree98  (walloc_din[ 98],walloc_cgroup[98],walloc_cgroup[99],walloc_c[ 98],walloc_s[ 98] );
    ysyx_23060136_WALLACE walloc_tree99  (walloc_din[ 99],walloc_cgroup[99],walloc_cgroup[100],walloc_c[ 99],walloc_s[ 99] );

    ysyx_23060136_WALLACE walloc_tree100  (walloc_din[100],walloc_cgroup[100],walloc_cgroup[101],walloc_c[100],walloc_s[100] );
    ysyx_23060136_WALLACE walloc_tree101  (walloc_din[101],walloc_cgroup[101],walloc_cgroup[102],walloc_c[101],walloc_s[101] );
    ysyx_23060136_WALLACE walloc_tree102  (walloc_din[102],walloc_cgroup[102],walloc_cgroup[103],walloc_c[102],walloc_s[102] );
    ysyx_23060136_WALLACE walloc_tree103  (walloc_din[103],walloc_cgroup[103],walloc_cgroup[104],walloc_c[103],walloc_s[103] );
    ysyx_23060136_WALLACE walloc_tree104  (walloc_din[104],walloc_cgroup[104],walloc_cgroup[105],walloc_c[104],walloc_s[104] );
    ysyx_23060136_WALLACE walloc_tree105  (walloc_din[105],walloc_cgroup[105],walloc_cgroup[106],walloc_c[105],walloc_s[105] );
    ysyx_23060136_WALLACE walloc_tree106  (walloc_din[106],walloc_cgroup[106],walloc_cgroup[107],walloc_c[106],walloc_s[106] );
    ysyx_23060136_WALLACE walloc_tree107  (walloc_din[107],walloc_cgroup[107],walloc_cgroup[108],walloc_c[107],walloc_s[107] );
    ysyx_23060136_WALLACE walloc_tree108  (walloc_din[108],walloc_cgroup[108],walloc_cgroup[109],walloc_c[108],walloc_s[108] );
    ysyx_23060136_WALLACE walloc_tree109  (walloc_din[109],walloc_cgroup[109],walloc_cgroup[110],walloc_c[109],walloc_s[109] );
    ysyx_23060136_WALLACE walloc_tree110  (walloc_din[110],walloc_cgroup[110],walloc_cgroup[111],walloc_c[110],walloc_s[110] );
    ysyx_23060136_WALLACE walloc_tree111  (walloc_din[111],walloc_cgroup[111],walloc_cgroup[112],walloc_c[111],walloc_s[111] );
    ysyx_23060136_WALLACE walloc_tree112  (walloc_din[112],walloc_cgroup[112],walloc_cgroup[113],walloc_c[112],walloc_s[112] );
    ysyx_23060136_WALLACE walloc_tree113  (walloc_din[113],walloc_cgroup[113],walloc_cgroup[114],walloc_c[113],walloc_s[113] );
    ysyx_23060136_WALLACE walloc_tree114  (walloc_din[114],walloc_cgroup[114],walloc_cgroup[115],walloc_c[114],walloc_s[114] );
    ysyx_23060136_WALLACE walloc_tree115  (walloc_din[115],walloc_cgroup[115],walloc_cgroup[116],walloc_c[115],walloc_s[115] );
    ysyx_23060136_WALLACE walloc_tree116  (walloc_din[116],walloc_cgroup[116],walloc_cgroup[117],walloc_c[116],walloc_s[116] );
    ysyx_23060136_WALLACE walloc_tree117  (walloc_din[117],walloc_cgroup[117],walloc_cgroup[118],walloc_c[117],walloc_s[117] );
    ysyx_23060136_WALLACE walloc_tree118  (walloc_din[118],walloc_cgroup[118],walloc_cgroup[119],walloc_c[118],walloc_s[118] );
    ysyx_23060136_WALLACE walloc_tree119  (walloc_din[119],walloc_cgroup[119],walloc_cgroup[120],walloc_c[119],walloc_s[119] );
    ysyx_23060136_WALLACE walloc_tree120  (walloc_din[120],walloc_cgroup[120],walloc_cgroup[121],walloc_c[120],walloc_s[120] );
    ysyx_23060136_WALLACE walloc_tree121  (walloc_din[121],walloc_cgroup[121],walloc_cgroup[122],walloc_c[121],walloc_s[121] );
    ysyx_23060136_WALLACE walloc_tree122  (walloc_din[122],walloc_cgroup[122],walloc_cgroup[123],walloc_c[122],walloc_s[122] );
    ysyx_23060136_WALLACE walloc_tree123  (walloc_din[123],walloc_cgroup[123],walloc_cgroup[124],walloc_c[123],walloc_s[123] );
    ysyx_23060136_WALLACE walloc_tree124  (walloc_din[124],walloc_cgroup[124],walloc_cgroup[125],walloc_c[124],walloc_s[124] );
    ysyx_23060136_WALLACE walloc_tree125  (walloc_din[125],walloc_cgroup[125],walloc_cgroup[126],walloc_c[125],walloc_s[125] );
    ysyx_23060136_WALLACE walloc_tree126  (walloc_din[126],walloc_cgroup[126],walloc_cgroup[127],walloc_c[126],walloc_s[126] );
    ysyx_23060136_WALLACE walloc_tree127  (walloc_din[127],walloc_cgroup[127],walloc_cgroup[128],walloc_c[127],walloc_s[127] );
    ysyx_23060136_WALLACE walloc_tree128  (walloc_din[128],walloc_cgroup[128],walloc_cgroup[129],walloc_c[128],walloc_s[128] );
    ysyx_23060136_WALLACE walloc_tree129  (walloc_din[129],walloc_cgroup[129],walloc_cgroup[130],walloc_c[129],walloc_s[129] );
    ysyx_23060136_WALLACE walloc_tree130  (walloc_din[130],walloc_cgroup[130],walloc_cgroup[131],walloc_c[130],walloc_s[130] );
    ysyx_23060136_WALLACE walloc_tree131  (walloc_din[131],walloc_cgroup[131], , ,walloc_s[131] );


    reg                    [ 130:0]         walloc_c_reg               ;
    reg                    [ 131:0]         walloc_s_reg               ;
    reg                                     c31_reg                    ;
    reg                                     c32_reg                    ;
    reg                                     mul_pipe2_valid            ;

    always_ff @(posedge clk) begin
        if(rst) begin
            walloc_c_reg    <= 131'b0;
            walloc_s_reg    <= 132'b0;
            c31_reg         <= 1'b0;
            c32_reg         <= 1'b0;
            mul_pipe2_valid <= `ysyx_23060136_false;
        end
        else if(mul_pipe1_valid) begin
            walloc_c_reg    <= walloc_c;
            walloc_s_reg    <= walloc_s;
            c31_reg         <= c_seg_reg[31];
            c32_reg         <= c_seg_reg[32];
            mul_pipe2_valid <= `ysyx_23060136_true;
        end
        else begin
            mul_pipe2_valid <= `ysyx_23060136_false;
        end
    end

    // ===========================================================================
    // final adder

    wire    [131 : 0]   result          =  walloc_s_reg + {walloc_c_reg, c31_reg} + {{131{1'b0}}, c32_reg};                                                    ;

    assign              result_hi       = result[127 : 64] ;
    assign              result_lo       = result[63  : 0]  ;

    assign              mul_ready       = ~(mul_pipe1_valid || mul_pipe2_valid);
    assign              mul_out_valid   =  mul_pipe2_valid                     ;                 


// signal cycle multiply
`else

    logic                             state;
    logic                             next_state;
    // use the counter to simulate the laytency of real multiplyer
    logic          [1 : 0]            cyc_counter;

    wire                              state_idle    =  (state == `ysyx_23060136_idle)   ;
    wire                              state_ready   =  (state == `ysyx_23060136_ready)  ;


// ===========================================================================
// function  interface
    wire            [127 : 0]         MUL_dword_u   =  $unsigned(multiplicand) * $unsigned(multiplier);
    wire            [127 : 0]         MUL_dword_s   =  $signed(multiplicand)   * $signed(multiplier);
    wire            [127 : 0]         MUL_dword_su  =  $signed(multiplicand)   * $unsigned(multiplier);
    // 
    wire            [31 : 0]          MUL_word      =  {$unsigned(multiplicand[31 : 0]) * $unsigned(multiplier[31 : 0])};    


    wire            [  `ysyx_23060136_BITS_W-1:0 ] MUL_result_hi =  {64{mul_signed == 2'b00}} &  MUL_dword_u[127 : 64]   | 
                                                                    {64{mul_signed == 2'b10}} &  MUL_dword_su[127 : 64]  |
                                                                    {64{mul_signed == 2'b11}} &  MUL_dword_s[127 : 64]   ;

    wire            [  `ysyx_23060136_BITS_W-1:0 ] MUL_result_lo =  (({64{mulw}})  & ({{32{MUL_word[31]}}, MUL_word}))   |
                                                                    ({64{!mulw}}   &
                                                                    ({64{mul_signed == 2'b00}} &  MUL_dword_u [63 : 0]    | 
                                                                     {64{mul_signed == 2'b10}} &  MUL_dword_su[63 : 0]    |
                                                                     {64{mul_signed == 2'b11}} &  MUL_dword_s [63 : 0]))  ;

// ===========================================================================

    always_comb begin : next_state_update
        unique case(state)
        `ysyx_23060136_idle: begin
            if(mul_valid & mul_ready) begin
                next_state = `ysyx_23060136_ready;
            end
            else begin
                next_state = `ysyx_23060136_idle;
            end
        end
        `ysyx_23060136_ready: begin
            if(&cyc_counter) begin
                next_state = `ysyx_23060136_idle;
            end
            else begin
                next_state = `ysyx_23060136_ready;
            end
        end
        default: next_state = `ysyx_23060136_idle;
        endcase
    end

    always_ff @(posedge clk) begin : state_update
        if(rst) begin
            state <=  `ysyx_23060136_idle;
        end
        else begin
            state <=   next_state;
        end
    end

    always_ff @(posedge clk) begin : counter_update
        if(rst || (state_idle & next_state == `ysyx_23060136_ready)) begin
            cyc_counter <= `ysyx_23060136_false;
        end
        else if(state_ready)begin
            cyc_counter <= cyc_counter + 1;
        end
    end

    always_ff @(posedge clk) begin : mul_ready_update
        if(rst) begin
            mul_ready     <= `ysyx_23060136_true;
            mul_out_valid <= `ysyx_23060136_false;
        end
        else if((state_idle & next_state == `ysyx_23060136_ready)) begin
            mul_ready     <= `ysyx_23060136_false;
            mul_out_valid <= `ysyx_23060136_false;
        end
        else if(&cyc_counter) begin
            mul_ready     <= `ysyx_23060136_true;
            mul_out_valid <= `ysyx_23060136_true;
        end
    end

    always_ff @(posedge clk) begin : mul_result_update
        if(rst) begin
            result_hi  <= `ysyx_23060136_false;
            result_lo  <= `ysyx_23060136_false;
        end
        else if(state_idle & next_state == `ysyx_23060136_ready)begin
            result_hi  <= MUL_result_hi;
            result_lo  <= MUL_result_lo;
        end
    end


`endif


endmodule

