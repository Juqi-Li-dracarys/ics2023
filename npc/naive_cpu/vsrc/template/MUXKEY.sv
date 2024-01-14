/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-12 17:19:22 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 01:42:45
 */

/*
  module mux21(a,b,s,y);
    input   a,b,s;
    output  y;

    // 通过MuxKey实现如下always代码
    // always @(*) begin
    //  case (s)
    //    1'b0: y = a;
    //    1'b1: y = b;
    //  endcase
    // end
    
    MuxKey #(2, 1, 1) i0 (y, s, {
      1'b0, a,
      1'b1, b
    });
  endmodule
*/

// 不带默认值的选择器模板
// 键值对的数量 NR_KEY,
// 键值的位宽   KEY_LEN
// 数据的位宽   DATA_LEN

module MuxKey #(parameter NR_KEY = 2, KEY_LEN = 1, DATA_LEN = 1) (
    output [DATA_LEN-1 : 0] out,
    input [KEY_LEN-1 : 0] key,
    input [NR_KEY*(KEY_LEN + DATA_LEN)-1:0] lut
);

    MuxKeyInternal #(NR_KEY, KEY_LEN, DATA_LEN, 0) i0 (out, key, {DATA_LEN{1'b0}}, lut);

endmodule


