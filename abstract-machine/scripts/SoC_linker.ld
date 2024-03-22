/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-09 14:09:47 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-22 01:05:55
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

 /* 二级加载 VMA*/
  _ssbt_load_start = LOADADDR(.ssbt);
  _ssbt_size = _text_start - _ssbt_start;

  .text : {
    _text_start = .;
    _stext = .;
    *(.text*)
     etext = .;
    _etext = .;
  } > REGION_TEXT  AT> flash

  /* text VMA*/
  _text_load_start = LOADADDR(.text);
  _text_size = _rodata_start - _text_start;

  .rodata : {
    _rodata_start = .;
    *(.rodata*)
    *(.srodata*)
    rodata_end = .;
    _rodata_end = .;
  } > REGION_RODATA AT> flash

  /*data VMA*/
  _rodata_load_start = LOADADDR(.rodata);
  _rodata_size = _data_start - _rodata_start;

  .data : {
     _data_start = .;
    *(.data*)
    *(.sdata*)
      edata = .;
     _edata = .;
     _data_end = .;
  } > REGION_DATA  AT> flash

  /*data VMA*/
  _data_load_start = LOADADDR(.data);
  _data_size = _bss_start - _data_start;

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  _bss_end = .;
  } > REGION_BSS  AT> flash

  /*堆放入 sdram*/
   _heap_start = ALIGN(4);

  /*栈放入 sram*/
  _stack_top = ORIGIN(sram);
  _stack_pointer = _stack_top + 0x2000;
}
