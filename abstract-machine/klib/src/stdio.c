#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  int written = 0;  // 用于记录写入字符的数量
  while (*fmt != '\0') {
    if (*fmt == '%') {
      fmt++;  // 跳过 '%'
      if (*fmt == 's') {
        const char *str = va_arg(args, const char *);
        while (*str != '\0') {
            *out++ = *str++;
            written++;
          }
      } 
      else if (*fmt == 'd') {
        int num = va_arg(args, int);
        int num_chars = sprintf(out, "%d", num);  // 递归调用 sprintf 处理整数
        out += num_chars;
        written += num_chars;
      }
    } 
    else {
      *out++ = *fmt;
      written++;
    }
    fmt++;
  }
  *out = '\0';  // 添加 NULL 终止符
  va_end(args);
  return written;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
