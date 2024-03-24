/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-16 10:34:01 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-24 11:16:36
 */

#include <am.h>
#include <klib-macros.h>

void __am_timer_init();
void __am_timer_rtc(AM_TIMER_RTC_T *);
void __am_timer_uptime(AM_TIMER_UPTIME_T *);
void __am_uart_rx(AM_UART_RX_T *);

static void __am_timer_config(AM_TIMER_CONFIG_T *cfg) { cfg->present = true; cfg->has_rtc = true; }
static void __am_uart_config (AM_UART_CONFIG_T*cfg)   { cfg->present = true;  }
static void __am_input_config(AM_INPUT_CONFIG_T *cfg) { cfg->present = false; }


typedef void (*handler_t)(void *buf);
static void *lut[128] = {
  [AM_TIMER_CONFIG] = __am_timer_config,
  [AM_TIMER_RTC   ] = __am_timer_rtc,
  [AM_TIMER_UPTIME] = __am_timer_uptime,
  [AM_UART_CONFIG]  = __am_uart_config,
  [AM_UART_RX]      = __am_uart_rx,
  [AM_INPUT_CONFIG] = __am_input_config
};

static void fail(void *buf) { panic("access nonexist register"); }

bool ioe_init() {
  for (int i = 0; i < LENGTH(lut); i++)
    if (!lut[i]) lut[i] = fail;
  __am_timer_init();
  return true;
}

void ioe_read (int reg, void *buf) { ((handler_t)lut[reg])(buf); }
void ioe_write(int reg, void *buf) { ((handler_t)lut[reg])(buf); }


