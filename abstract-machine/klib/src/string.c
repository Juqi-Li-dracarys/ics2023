#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  size_t size = 0;
  while(*s != '\0'){
    size++;
    s++;
  }
  return size;
}

char *strcpy(char *dst, const char *src) {
  char *original_dst = dst; 
  while (*src != '\0') {
    *dst = *src;
    dst++;
    src++;
  }
  *dst = '\0';
  return original_dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
  char *original_dst = dst;  
  while (n > 0 && *src != '\0') {
    *dst = *src;
    dst++;
    src++;
    n--;
  }
  while (n > 0) {
    *dst = '\0';
    dst++;
    n--;
  }
  return original_dst; 
}

char *strcat(char *dst, const char *src) {
  char *original_dst = dst;
  while (*dst != '\0') {
    dst++;
  }
  while (*src != '\0') {
    *dst = *src;
    dst++;
    src++;
  }
  *dst = '\0'; 
  return original_dst;  
}

int strcmp(const char *s1, const char *s2)
{
  while (*s1 != '\0' && *s2 != '\0') {
    if (*s1 < *s2) {
      return -1;
    }
    else if (*s1 > *s2) {
      return 1;
    }
    s1++;
    s2++;
  }

  if (*s1 == '\0' && *s2 == '\0') {
    return 0;
  }
  else if (*s1 == '\0') {
    return -1;
  }
  else {
    return 1; 
  }
}

int strncmp(const char *s1, const char *s2, size_t n) {
  while (n > 0 && *s1 != '\0' && *s2 != '\0') {
    if (*s1 < *s2) {
      return -1;
    } 
    else if (*s1 > *s2) {
      return 1;
    }
    s1++;
    s2++;
    n--;
  }

  if (n == 0 || (*s1 == '\0' && *s2 == '\0')) {
    return 0;  // 两个字符串相等或比较了 n 个字符
  } 
  else if (*s1 == '\0') {
    return -1; // s1 较短
  } 
  else {
    return 1;  // s2 较短
  }
}

void *memset(void *s, int c, size_t n) {
  uint8_t *p = (uint8_t *)s;  
  for (size_t i = 0; i < n; i++) {
    *p = (uint8_t)c;  
    p++;
  }
  return s; 
}

void *memmove(void *dst, const void *src, size_t n) {
  uint8_t *p_dst = (uint8_t*)dst; 
  uint8_t *p_src = (uint8_t *)src; 
  // 如果目标区域与源区域有重叠，从后往前复制
  if (p_dst > p_src && p_dst < p_src + n) {
    p_dst += n;
    p_src += n;
    while (n > 0) {
      p_dst--;
      p_src--;
      *p_dst = *p_src;
      n--;
    }
  } 
  else {
    // 否则从前往后复制
    while (n > 0) {
      *p_dst = *p_src;
      p_dst++;
      p_src++;
      n--;
    }
  }
  return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
  uint8_t *dst = (uint8_t *)out;
  uint8_t *src = (uint8_t *)in; 
  for (size_t i = 0; i < n; i++) {
    dst[i] = src[i];
  }
  return out; 
}

int memcmp(const void *s1, const void *s2, size_t n) {
  uint8_t *p1 = (uint8_t *)s1; 
  uint8_t *p2 = (uint8_t *)s2; 
  for (size_t i = 0; i < n; i++) {
    if (p1[i] < p2[i]) {
      return -1;
    } 
    else if (p1[i] > p2[i]) {
      return 1;
    }
  }
  return 0;  // 两个内存区域相等
}

#endif
