/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-18 09:15:52 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-18 09:24:15
 */

module Register_ysyx23060136 #(WIDTH = 1, RESET_VAL = 0) (
        input                     clk,
        input                     rst,
        input        [WIDTH-1:0]  din,
        output logic [WIDTH-1:0]  dout,
        input                     wen
    );
    always_ff @(posedge clk) begin
        if (rst)
            dout <= RESET_VAL;
        else if (wen)
            dout <= din;
    end
endmodule



// 选择器模板内部实现
module MuxKeyInternal_ysyx23060136 #(NR_KEY = 2, KEY_LEN = 1, DATA_LEN = 1, HAS_DEFAULT = 0) (
        output logic [DATA_LEN-1:0]                    out,
        input        [KEY_LEN-1:0]                     key,
        input        [DATA_LEN-1:0]                    default_out,
        input        [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
    );

    localparam PAIR_LEN = KEY_LEN + DATA_LEN;
    logic [PAIR_LEN-1:0]  pair_list [NR_KEY-1:0];
    logic [KEY_LEN-1:0]   key_list  [NR_KEY-1:0];
    logic [DATA_LEN-1:0]  data_list [NR_KEY-1:0];

    genvar n;
    generate
        for (n = 0; n < NR_KEY; n = n + 1) begin
            assign pair_list[n] = lut[PAIR_LEN*(n+1)-1 : PAIR_LEN*n];
            assign data_list[n] = pair_list[n][DATA_LEN-1:0];
            assign key_list[n]  = pair_list[n][PAIR_LEN-1:DATA_LEN];
        end
    endgenerate

    logic [DATA_LEN-1 : 0] lut_out;
    logic                  hit;
    integer                i;
    always_comb begin
        lut_out = 0;
        hit = 0;
        for (i = 0; i < NR_KEY; i = i + 1) begin
            lut_out = lut_out | ({DATA_LEN{key == key_list[i]}} & data_list[i]);
            hit = hit | (key == key_list[i]);
        end
        if (!HAS_DEFAULT)
            out = lut_out;
        else
            out = (hit ? lut_out : default_out);
    end
endmodule



// 不带默认值的选择器模板
module MuxKey_ysyx23060136 #(NR_KEY = 2, KEY_LEN = 1, DATA_LEN = 1) (
        output [DATA_LEN-1:0]                    out,
        input  [KEY_LEN-1:0]                     key,
        input  [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
    );
    MuxKeyInternal_ysyx23060136 #(NR_KEY, KEY_LEN, DATA_LEN, 0) i0 (out, key, {DATA_LEN{1'b0}}, lut);
endmodule



// 带默认值的选择器模板
module MuxKeyWithDefault_ysyx23060136 #(NR_KEY = 2, KEY_LEN = 1, DATA_LEN = 1) (
        output [DATA_LEN-1:0]                    out,
        input  [KEY_LEN-1:0]                     key,
        input  [DATA_LEN-1:0]                    default_out,
        input  [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
    );
    MuxKeyInternal_ysyx23060136 #(NR_KEY, KEY_LEN, DATA_LEN, 1) i0 (out, key, default_out, lut);
endmodule





