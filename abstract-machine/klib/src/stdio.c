#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

// num 为 int，将其保存到 str 所指字符串中，返回 str 的偏移量
uint16_t int2str(char *str, int num) {
  uint16_t offset = 0;
  char temp[20] = {0}; 
  int tempOffset = 0;

  // 正负判断
  if (num < 0) {
    str[offset++] = '-';
  }
  uint32_t abs_num = (uint32_t)abs(num);
  // 低位提取
  do {
    temp[tempOffset++] = '0' + (abs_num % 10);
    abs_num /= 10;
  } 
  while (abs_num > 0 && tempOffset <= 20);

  while (tempOffset > 0) {
    str[offset++] = temp[--tempOffset];
  }
  return offset;
}

// num 为 str，将其保存到 str 所指字符串中，返回 str 的偏移量
uint16_t str2str(char *des_str, char *src) {
  uint16_t offset = 0;
  while (*src != '\0') {
    des_str[offset++] = *src;
    src++;
  }
  return offset;
}

int printf(const char *fmt, ...) {
  char temp [100] = {0};
  va_list ap;
  va_start(ap, fmt);
  int size = vsprintf(temp, fmt, ap);
  va_end(ap);
  for(int i = 0; i < size; i++) {
    putch(temp[i]);
  }
  return size;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  int size_str = 0;
  int size_in = 0;
  while(*fmt != '\0') {
    // 未成功匹配到%，则直接复制粘贴
    if(*fmt != '%') {
      *out = *fmt;
      out++, fmt++;
      size_str++;
    }
    else {
  // 匹配到 %, 则读取后一个字符
      switch(*(fmt + 1)) {
        case 'd': size_in = int2str(out, va_arg(ap, int)); fmt += 2; out += size_in; size_str += size_in; break;
        case 's': size_in = str2str(out, va_arg(ap, char *)); fmt += 2; out += size_in; size_str += size_in; break;
        default: *out = *fmt; out++; fmt++; size_str++; break;
      }
    }
  }
  *out = '\0';
  return size_str;
}

int sprintf(char *out, const char *fmt, ...) {
  int out_size = 0;
  va_list ap;
  va_start(ap, fmt);
  out_size = vsprintf(out, fmt, ap);
  va_end(ap);
  return out_size;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

// Hit good trap
void panic_test_ok(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  if(va_arg(ap, int) != -2147483648) {
    halt(1);
  }
  va_end(ap);
}

// Hit bad trap
void panic_test(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  if(va_arg(ap, int) != 2147483648) {
    halt(1);
  }
  va_end(ap);
}

#endif
