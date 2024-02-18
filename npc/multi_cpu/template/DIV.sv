/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-14 01:23:41 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-14 16:44:39
 */

/*
    M 指令：
    01 100 除法，带符号
    01 101 除法，无符号
*/

// naive way of building a div

module DIV #(parameter data_width = 32) (
    input      [data_width-1 : 0]    data_a,
    input      [data_width-1 : 0]    data_b,
    input                            div_op,
    output reg [data_width-1 : 0]    result
);

    always_comb begin
        if(div_op) begin
            // Unsigned division
            if(data_b != 32'b0)
                result = data_a / data_b;
            else
                // Handle division by zero
                result = {data_width{1'b0}};
        end 
        else begin
            if(data_b != 32'b0) 
                result = $signed(data_a) / $signed(data_b);
            else
                result = {data_width{1'b0}};
        end
    end

endmodule



