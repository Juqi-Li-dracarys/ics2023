/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-09 14:09:47 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-21 21:31:02
 */

ENTRY(_start)

/*定义内存空间*/
/* ysyxsoc.h 中也有定义*/
MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 256M
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  sdram : ORIGIN = 0xa0000000, LENGTH = 128M
}

REGION_ALIAS("REGION_FSBT",   flash);
REGION_ALIAS("REGION_SSBT",   sdram);
REGION_ALIAS("REGION_TEXT",   sdram);
REGION_ALIAS("REGION_RODATA", sdram);
REGION_ALIAS("REGION_DATA",   sdram);
REGION_ALIAS("REGION_BSS",    sdram);

SECTIONS {
  /* 链接的起始位置 */
  . = ORIGIN(flash);
  
  /* 一级加载*/
  .fsbt :{
    _fsbt_start = .;
    *(entry)
    *(_fsbt)
    _fsbt_end = .;
  } > REGION_FSBT  AT> flash
  
  /* 二级加载*/
  .ssbt :{
    _ssbt_start = .;
    *(_ssbt)
     _ssbt_end = .;
  } > REGION_SSBT  AT> flash

 /* 二级加载*/
  _ssbt_load_start = LOADADDR(.ssbt);
  _ssbt_size = _ssbt_end - _ssbt_start;

  .text : {
    _code_start = .;
    _text_start = .;
    _stext = .;
    *(.text*)
     etext = .;
    _etext = .;
  } > REGION_TEXT  AT> flash

  
  .rodata : {
    _rodata_start = .;
    *(.rodata*)
    *(.srodata*)
    rodata_end = .;
    _rodata_end = .;
  } > REGION_RODATA AT> flash

  .data : {
     _data_start = .;
    *(.data*)
    *(.sdata*)
      edata = .;
     _edata = .;
     _data_end = .;
  } > REGION_DATA  AT> flash


  /*VMA*/
  _code_load_start = LOADADDR(.text);
  _code_size = _bss_start - _text_start;

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  _bss_end = .;
  } > REGION_BSS  AT> flash

   _heap_start = ALIGN(4);

  /*堆栈全部放入 sram*/
  _stack_top = ORIGIN(sram);
  . = _stack_top + 0x2000;
  _stack_pointer = .;
}
