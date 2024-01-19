/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 17:38:18 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-18 23:06:41
 */

#define CONFIG_AUDIO_CTL_MMIO 0xa0000200
#define CONFIG_DIFFTEST_REF_NAME "none"
#define CONFIG_ENGINE "interpreter"
#define CONFIG_VGA_SIZE_400x300 1
#define CONFIG_VGA_SHOW_SCREEN 1
#define CONFIG_PC_RESET_OFFSET 0x0
#define CONFIG_RTC_MMIO 0xa0000040
#define CONFIG_TARGET_NATIVE_ELF 1
#define CONFIG_HAS_AUDIO 1
#define CONFIG_MSIZE 0x8000000
#define CONFIG_CC_O2 1
#define CONFIG_DEVICE 1
#define CONFIG_HAS_KEYBOARD 1
#define CONFIG_MODE_SYSTEM 1
#define CONFIG_MEM_RANDOM 1
#define CONFIG_HAS_SERIAL 1
#define CONFIG_ISA_riscv 1
#define CONFIG_FB_ADDR 0xa1000000
#define CONFIG_HAS_VGA 1
#define CONFIG_HAS_TIMER 1
#define CONFIG_DISK_CTL_MMIO 0xa0000300
#define CONFIG_MBASE 0x80000000
#define CONFIG_TIMER_GETTIMEOFDAY 1
#define CONFIG_ENGINE_INTERPRETER 1
#define CONFIG_CC_OPT "-O2"
#define CONFIG_SERIAL_MMIO 0xa00003f8
#define CONFIG_RT_CHECK 1
#define CONFIG_I8042_DATA_MMIO 0xa0000060
#define CONFIG_SB_SIZE 0x10000
#define CONFIG_CC "gcc"
#define CONFIG_DIFFTEST_REF_PATH "none"
#define CONFIG_DISK_IMG_PATH ""
#define CONFIG_CC_GCC 1
#define CONFIG_SB_ADDR 0xa1200000
#define CONFIG_ISA "riscv32"
#define CONFIG_VGA_CTL_MMIO 0xa0000100
#define CONFIG_PMEM_GARRAY 1
#define CONFIG_FFB_ADDR 0xa2000000


#define CONFIG_RVE 1

// Trace
#define CONFIG_TRACE 1

// // Itrace
// #define CONFIG_ITRACE 1
// #define CONFIG_ITRACE_COND 1
// #define ITRACE_COND  1
// #define CONFIG_TRACE_START 0
// #define CONFIG_TRACE_END 10000

// diff test
#define CONFIG_DIFFTEST 1

// // Mtrace
// # define CONFIG_MTRACE_COND 1
// # define MTRACE_COND 1

// // watch/break point
// #define CONFIG_WBCHECK 1

// wave record
// #define WAVE_RECORD 1


