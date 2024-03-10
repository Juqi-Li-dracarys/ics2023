/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-02-21 15:56:01 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-04 16:41:05
 */


`define  true     'b1
`define  false    'b0

`define  PC_RST   32'h80000000
`define  NOP      32'h00000013

 // AXI machine state
`define  idle     'h0
`define  busy     'h1
`define  done     'h2

// csr idx 
`define  mstatus  'h0 
`define  mtvec    'h1
`define  mepc     'h2
`define  mcause   'h3

// arbiter/xbar state machine
`define  state_0     'h0
`define  state_1     'h1
`define  state_2     'h2
`define  state_3     'h3
`define  state_4     'h4
`define  state_5     'h5
`define  state_6     'h6

// SRAM地址
`define SRAM_MBASE `h8000_0000
`define SRAM_MSIZE `h0800_0000

// 串口地址
`define SERIAL_MBASE `ha00003f8
`define SERIAL_MSIZE `h00000008





