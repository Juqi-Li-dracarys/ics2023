module adder (
    input cin,                    
    input [3:0] data_a,
    input [3:0] data_b, 
    output cout,             
    output zero,              
    output overflow,        
    output [3:0] addout
);
    assign {cout,addout} = data_a + data_b + {3'b000, cin};
    assign overflow = (data_a[3]==data_b[3]) && (data_a[3]!=addout[3]);
    assign zero = (addout == 4'b0);

endmodule
