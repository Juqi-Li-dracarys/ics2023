/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-09 14:09:47 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-23 15:41:21
 */

/*
``2024.3.22 添加了对 RT-thread 段的支持
*/

ENTRY(_start)

/* Map of SoC memory */
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
    KEEP(*(_fsbt))
    _fsbt_end = .;
  } > REGION_FSBT  AT> flash
  
  /* 二级加载*/
  .ssbt :{
    _ssbt_start = .;
    KEEP(*(_ssbt))
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
    *(.rela*)
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
    /* section information for finsh shell */
    __fsymtab_start = .;
    KEEP(*(FSymTab))
    __fsymtab_end = .;
    . = ALIGN(8);
    __vsymtab_start = .;
    KEEP(*(VSymTab))
    __vsymtab_end = .;
    . = ALIGN(8);
    /* section information for initial. */
    . = ALIGN(8);
    __rt_init_start = .;
    KEEP(*(SORT(.rti_fn*)))
    __rt_init_end = .;
    . = ALIGN(8);
    __rt_utest_tc_tab_start = .;
    KEEP(*(UtestTcTab))
    __rt_utest_tc_tab_end = .;
    . = ALIGN(8);
    __am_apps_data_start = .;
    *(__am_apps.data*)
    *(__am_apps.sdata*)
    __am_apps_data_end = .;
    . = ALIGN(8);
  /* end of this section */
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
    /* section information for apps-bss. */
    . = ALIGN(8);
    __am_apps_bss_start = .;
    *(__am_apps.bss*)
    *(__am_apps.sbss*)
    *(__am_apps.scommon*)
    __am_apps_bss_end = .;
    /* end of this section */
    . = ALIGN(8);
  _bss_end = .;
  } > REGION_BSS  AT> flash

  /*堆放入 sdram*/
   _heap_start = ALIGN(4);

  /*栈放入 sram*/
  _stack_top = ORIGIN(sram);
  _stack_pointer = _stack_top + LENGTH(sram);
}


