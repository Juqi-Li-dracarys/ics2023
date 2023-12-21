#include <fs.h>
#include "syscall.h"
#include <common.h>
#include <time.h>

/* 
  注意目录下 syscall.h 和 files.h 是两个
  软链接文件，不要往这两个文件写任何代码！
  F**K ME！！
*/

// enable strace here
// #define STRACE 1

#define MAX_NUM 100

typedef struct node {
  uintptr_t type;
  uintptr_t arg_ret[4];
  struct node *next;
} s_node;

#ifdef STRACE
static s_node *head = NULL;
static uintptr_t size = 0;
#endif

static void add_strace(uintptr_t type, uintptr_t arg0, uintptr_t arg1, uintptr_t arg2, uintptr_t ret) {
#ifdef STRACE
  if(size < MAX_NUM) {
    s_node *new = (s_node *)malloc(sizeof(s_node));
    new->type = type;
    new->arg_ret[0] = arg0;
    new->arg_ret[1] = arg1;
    new->arg_ret[2] = arg2;
    new->arg_ret[3] = ret;
    new->next = head;
    head = new;
    size++;
  }
#endif
  return;
}

// 分配在 NEMU 中的内存没必要 free, 打印即可
static void disp_strace(void) {
#ifdef STRACE
  s_node *temp = head;
  uintptr_t i = 0;
  printf("STRACE:\n");
  while(temp != NULL) {
    printf("[%d]: type: %d, arg0:%p, arg1:%p, arg2:%p, ret:%p\n", size - i, temp->type, temp->arg_ret[0], temp->arg_ret[1], temp->arg_ret[2], temp->arg_ret[3]);
    i++;
    temp = temp->next;
  }
#endif
  return;
}

static uintptr_t sys_yield() {
  // call yield from AM_CTE
  yield();
  return 0;
}

static void sys_exit(uintptr_t status) {
  // nemu halt here
  printf("\nsystem halt in EXIT CODE: %p\n", status);
  halt(status);
}

static uintptr_t sys_open(const char *path, int flags, uintptr_t mode) {
  return fs_open(path, flags, mode);
}

static uintptr_t sys_lseek(uintptr_t fd, uintptr_t offset, uintptr_t whence) {
  return lseek(fd, offset, whence);
}

static uintptr_t sys_write(uintptr_t fd, char *buf, uintptr_t count) {
  return fs_write(fd, (void *)buf, count);
}

static uintptr_t sys_read(uintptr_t fd, char *buf, uintptr_t count) {
  return fs_read(fd, (void *)buf, count);
}

static uintptr_t sys_close(uintptr_t fd) {
  return fs_close(fd);
}

// 堆区处理
static uintptr_t sys_brk(uintptr_t *ptr, uintptr_t increment) {
  *ptr = *ptr + increment;
  return *ptr;
}

// 系统时间获取(非 RTC 时间)
static uintptr_t sys_gettimeofday(timeval *tv, timezone *tz) {
  if(io_read(AM_TIMER_CONFIG).present == true && tv != NULL) {
    uint64_t us = io_read(AM_TIMER_UPTIME).us;
    tv->tv_usec = (long)(us % 1000000);
    tv->tv_sec = (long)(us / 1000000);
    return 0;
  }
  else return -1;
}

// 处理各种系统调用号
void do_syscall(Context *c) {
  uintptr_t gpr2_temp = c->GPR2;
  switch (c->GPR1) {
    case SYS_yield:        c->GPRx = sys_yield(); add_strace(SYS_yield, 0, 0, 0, c->GPRx); break;
    case SYS_exit:         disp_strace(); sys_exit(c->GPR2); break;
    case SYS_write:        c->GPRx = sys_write(c->GPR2, (char *)(c->GPR3), c->GPR4);             add_strace(SYS_write, gpr2_temp, c->GPR3, c->GPR4, c->GPRx); break;
    case SYS_read:         c->GPRx = sys_read(c->GPR2, (char *)(c->GPR3), c->GPR4);              add_strace(SYS_read, gpr2_temp, c->GPR3, c->GPR4, c->GPRx); break;
    case SYS_open:         c->GPRx = sys_open((const char *)c->GPR2, 0, 0);                      add_strace(SYS_open, gpr2_temp, 0, 0, c->GPRx); break;
    case SYS_lseek:        c->GPRx = sys_lseek(c->GPR2, c->GPR3, c->GPR4);                       add_strace(SYS_lseek, gpr2_temp, c->GPR3, c->GPR4, c->GPRx); break;
    case SYS_close:        c->GPRx = sys_close(c->GPR2);                                         add_strace(SYS_close, gpr2_temp, 0, 0, c->GPRx); break;
    case SYS_brk:          c->GPRx = sys_brk((uintptr_t *)(c->GPR2), c->GPR3);                   add_strace(SYS_brk, gpr2_temp,c->GPR3, 0, c->GPRx); break;
    case SYS_gettimeofday: c->GPRx = sys_gettimeofday((timeval *)c->GPR2, (timezone *)c->GPR3);  add_strace(SYS_gettimeofday, gpr2_temp, c->GPR3, 0, c->GPRx); break;
    default:               panic("Unhandled syscall ID = %d", c->GPR1);
  }
}



