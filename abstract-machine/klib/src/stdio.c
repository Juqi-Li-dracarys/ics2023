#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

// printf sprintf 的最大输入不能超过该容量
// 注意，不要开太大，小心爆栈
#define str_buffer_size 1500

const char hex_chars[] = "0123456789abcdef";

uint16_t int2str(char *str, int num, int max_size) {
  uint16_t offset = 0;
  char temp[100] = {0}; 
  int tempOffset = 0;
  // 正负判断
  if (num < 0 && offset < max_size) {
    str[offset++] = '-';
  }
  uint32_t abs_num = (uint32_t)abs(num);
  // 低位提取
  do {
    temp[tempOffset++] = '0' + (abs_num % 10);
    abs_num /= 10;
  } 
  while (abs_num > 0 && tempOffset < 100);

  while (tempOffset > 0 && offset < max_size) {
    str[offset++] = temp[--tempOffset];
  }
  return offset;
}

uint16_t str2str(char *des_str, char *src, int max_size) {
  uint16_t offset = 0;
  while (src != NULL && *src != '\0' && offset < max_size) {
    des_str[offset++] = *src;
    src++;
  }
  return offset;
}

uint16_t ch2str(char *des_str, char c, int max_size) {
  if(max_size > 0) {
    *des_str = c;
    return 1;
  }
  else return 0;
}

uint16_t ptr2str(char *des_str, uintptr_t num, int max_size) { 
  char temp [10] = {0};
  uint16_t offset = 0;
  temp[0] = '0';
  temp[1] = 'x';
  for (int i = 7; i >= 0; --i) {
      int hexValue = (num >> (i * 4)) & 0xF;
      temp[2 + (7 - i)] = hex_chars[hexValue];
  }
  while(offset < 10 && offset < max_size) {
    des_str[offset] = temp[offset];
    offset++;
  }
  return offset;
}

int printf(const char *fmt, ...) {
  char temp [str_buffer_size] = {0};
  va_list ap;
  va_start(ap, fmt);
  int size = vsprintf(temp, fmt, ap);
  va_end(ap);
  for(int i = 0; i < size; i++) {
    putch(temp[i]);
  }
  return size;
}

int sprintf(char *out, const char *fmt, ...) {
  int out_size = 0;
  va_list ap;
  va_start(ap, fmt);
  out_size = vsprintf(out, fmt, ap);
  va_end(ap);
  return out_size;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  return vsnprintf(out, str_buffer_size, fmt, ap);
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  int out_size = 0;
  va_list ap;
  va_start(ap, fmt);
  out_size = vsnprintf(out, n, fmt, ap);
  va_end(ap);
  return out_size;
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  int size_str = 0;
  int size_in = 0;
  while(fmt != NULL && *fmt != '\0' && size_str < n - 1) {
    // 未成功匹配到%，则直接复制粘贴
    if(*fmt != '%') {
      *out = *fmt;
      out++, fmt++;
      size_str++;
    }
    else {
  // 匹配到 %, 则读取后一个字符
      switch(*(fmt + 1)) {
        case 'd': size_in = int2str(out, va_arg(ap, int), n - size_str - 1); fmt += 2; out += size_in; size_str += size_in; break;
        case 's': size_in = str2str(out, va_arg(ap, char *), n - size_str - 1); fmt += 2; out += size_in; size_str += size_in; break;
        case 'c': size_in = ch2str(out, (char)va_arg(ap, int), n - size_str - 1); fmt += 2; out += size_in; size_str += size_in; break;
        case 'p': size_in = ptr2str(out, (uintptr_t)va_arg(ap, void *), n - size_str - 1); fmt += 2; out += size_in; size_str += size_in; break;
        default: *out = *fmt; out++; fmt++; size_str++; break;
      }
    }
  }
  // 自动追加
  *out = '\0';
  return size_str;
}

// Hit bad trap
void panic_test(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  if(va_arg(ap, int) != -2147483648) {
    halt(1);
  }
  va_end(ap);
}

// unknown bug
// snprintf(buf, 15, "%d\n", -2147483648);
// printf("%s", buf);
// printf("%d\n", -2147483648);

#endif
