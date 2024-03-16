/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-16 10:33:54 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-16 10:44:12
 */


#include <am.h>
#include <ysyxsoc.h>

void __am_timer_init() {
    
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
//   uint64_t us_lower = (uint64_t)inl(RTC_ADDR);
//   uint64_t us_higher = (uint64_t)inl(RTC_ADDR + 4);
//   uptime->us = us_lower | (us_higher << 32);
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}