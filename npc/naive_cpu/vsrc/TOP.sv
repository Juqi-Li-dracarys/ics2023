/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 18:21:52 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-13 18:22:14
 */


module TOP #(parameter PC_RST = 32'H80000000) (
        input                                   clk, rstn,
        output [31: 0] pc_cur, inst,
        output commit_wb, uncache_read_wb
`ifdef DEBUG
        ,
        output                                  putchar,
        output                  [7 : 0]         c
`endif
);



endmodule



