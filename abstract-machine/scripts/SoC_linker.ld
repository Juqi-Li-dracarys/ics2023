/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-09 14:09:47 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-09 17:31:13
 */

ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }


/*定义内存空间*/
/* ysyxsoc.h 中也有定义*/
MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 128M
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
}

REGION_ALIAS("REGION_TEXT", flash);
REGION_ALIAS("REGION_RODATA", flash);
REGION_ALIAS("REGION_DATA", sram);
REGION_ALIAS("REGION_BSS", sram);

SECTIONS {
  /* 链接的起始位置 */
  . = ORIGIN(flash);
  .text : {
    _stext = .;
    *(entry)
    *(.text*)
     etext = .;
    _etext = .;
  } > REGION_TEXT  AT> flash :text

  .rodata : {
    _rodata_start = .;
    *(.rodata*)
    *(.srodata*)
    rodata_end = .;
    _rodata_end = .;
  } > REGION_RODATA AT> flash

  .data : {
   /*VMA*/
     _data_start = .;
    *(.data*)
    *(.sdata*)
      edata = .;
     _edata = .;
     _data_end = .;
  } > REGION_DATA  AT> flash :data

  
  /*LMA*/
  _data_load_start = LOADADDR(.data);
  _data_size = _bss_start - _data_start;

  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  _bss_end = .;
  } > REGION_BSS  AT> flash

  /*stack and heap in sram*/
  _stack_top = ALIGN(4);
  . = _stack_top + 0x1000;
  _stack_pointer = .;
   end = .;
  _end = .;
  _heap_start = ALIGN(4);
}
