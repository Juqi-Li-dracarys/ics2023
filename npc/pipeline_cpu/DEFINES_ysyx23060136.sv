/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 15:56:01 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-02-21 16:54:07
 */


`define  true     'b1
`define  false    'b0

`define  PC_RST   32'h80000000
`define  NOP      32'h00000013

`define  idle     'h0
`define  busy     'h1
`define  done     'h2

 // csr idx 
`define  mstatus  'h0 
`define  mtvec    'h1
`define  mepc     'h2
`define  mcause   'h3


