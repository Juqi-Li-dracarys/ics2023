/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-13 18:06:14 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 19:55:44
 */


// Main memory write and read

/*
    010 时为 4 字节读写
    001 时为 2 字节读带符号扩展, 写不考虑符号
    000 时为 1 字节读带符号, 写不考虑符号
    101 时为 2 字节读无符号扩展
    100 时为 1 字节读无符号扩展
*/

module DATA_MEM (
    input                      clk,
    input                      rst,
    input                      WrEn,
    input        [2 : 0]       MemOp,
    input        [31 : 0]      addr,
    input        [31 : 0]      DataIn,
    output  reg  [31 : 0]      DataOut
);

    import "DPI-C" function int  vaddr_read (input int addrs, input int len);
    import "DPI-C" function void vaddr_write(input int addrs, input int len, input int data);
    
    always_comb begin
        unique case(MemOp)
            3'b010: begin
                DataOut = vaddr_read(addr, 32'h4);
            end
            3'b001: begin
                DataOut = vaddr_read(addr, 32'h2);
                DataOut = DataOut | {{16{DataOut[15]}}, {16{1'b0}}};
            end
            3'b000: begin
                DataOut = vaddr_read(addr, 32'h1);
                DataOut = DataOut | {{24{DataOut[7]}}, {8{1'b0}}};
            end
            3'b101: begin
                DataOut = vaddr_read(addr, 32'h2);
            end
            3'b100: begin
                DataOut = vaddr_read(addr, 32'h1);
            end
            // should not reach here
            default: begin
                DataOut = 32'b0;
            end      
        endcase
    end

    // 下一个周期写入数据
    always_ff @(posedge clk) begin
        if(WrEn && !rst) begin
            unique case(MemOp)
                3'b010: begin
                    vaddr_write(addr, 32'h4, DataIn);
                end
                3'b001: begin
                    vaddr_write(addr, 32'h2, DataIn);
                end
                3'b000: begin
                    vaddr_write(addr, 32'h1, DataIn);
                end
                // should not reach here
                default: begin
                    vaddr_write(addr, 32'h0, DataIn);
                end      
            endcase
        end
    end

endmodule


