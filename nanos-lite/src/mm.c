#include <memory.h>

static void *pf = NULL;

void* new_page(size_t nr_page) {
  // 记录初始地址
  char *old_pf = (char *)pf;
  pf = (void *)(old_pf + nr_page * PGSIZE);
  return (void *)old_pf;
}

#ifdef HAS_VME
// 我们保证AM通过回调函数调用 pg_alloc()
// 时申请的空间总是页面大小的整数倍
static void* pg_alloc(int n) {
  int page_num = n / PGSIZE;
  assert(page_num * PGSIZE == n);
  void *p = new_page(page_num);
  memset(p, 0, n);
  return p;
}
#endif

void free_page(void *p) {
  panic("not implement yet");
}

/* The brk() system call handler. */
int mm_brk(uintptr_t brk) {
  return 0;
}

void init_mm() {
  pf = (void *)ROUNDUP(heap.start, PGSIZE);
  Log("free physical pages starting from %p", pf);

#ifdef HAS_VME
  vme_init(pg_alloc, free_page);
#endif
}
