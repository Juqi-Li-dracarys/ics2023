/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 15:56:01 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-08 00:11:24
 */

`define  FLASH_BASE     'h30000000
`define  FLASH_END      'h3fffffff
 
`define  true     'b1
`define  false    'b0

`define  PC_RST    32'h30000000
`define  NOP       32'h00000013

// AXI-lite machine state
`define  idle     'h0
`define  busy     'h1
// only for writing
`define  done     'h2

// csr idx 
`define  mstatus  'h0 
`define  mtvec    'h1
`define  mepc     'h2
`define  mcause   'h3


// arbiter state machine(read)
`define  idle     'h0
`define  ready    'h1
`define  waiting  'h2
`define  over     'h3

// arbiter handling guests
`define  G_IFU    'h0
`define  G_MEM    'd1
 
// response signal
`define  OKAY     'b00
`define  EXOKAY   'b01
`define  SLVERR   'b10
`define  DECERR   'b11

`define  DEBUG    `b1





