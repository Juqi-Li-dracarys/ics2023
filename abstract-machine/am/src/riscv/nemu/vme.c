#include <am.h>
#include <nemu.h>
#include <klib.h>
#include <riscv/riscv.h>

static AddrSpace kas = {};
static void* (*pgalloc_usr)(int) = NULL;
static void (*pgfree_usr)(void*) = NULL;
static int vme_enable = 0;

static Area segments[] = {      // Kernel memory mappings
  NEMU_PADDR_SPACE
};

// 虚拟内存空间
#define USER_SPACE RANGE(0x40000000, 0x80000000)

static inline void set_satp(void *pdir) {
  uintptr_t mode = 1ul << (__riscv_xlen - 1);
  asm volatile("csrw satp, %0" : : "r"(mode | ((uintptr_t)pdir >> 12)));
}

static inline uintptr_t get_satp() {
  uintptr_t satp;
  asm volatile("csrr %0, satp" : "=r"(satp));
  return satp << 12;
}

bool vme_init(void* (*pgalloc_f)(int), void (*pgfree_f)(void*)) {
  pgalloc_usr = pgalloc_f;
  pgfree_usr = pgfree_f;
  kas.ptr = pgalloc_f(PGSIZE);

  int i;
  // 分页
  for (i = 0; i < LENGTH(segments); i ++) {
    void *va = segments[i].start;
    for (; va < segments[i].end; va += PGSIZE) {
      map(&kas, va, va, 0);
    }
  }
  // 设置一级页表基地址
  set_satp(kas.ptr);
  vme_enable = 1;

  return true;
}

void protect(AddrSpace *as) {
  PTE *updir = (PTE*)(pgalloc_usr(PGSIZE));
  as->ptr = updir;
  as->area = USER_SPACE;
  as->pgsize = PGSIZE;
  // map kernel space
  memcpy(updir, kas.ptr, PGSIZE);
}

void unprotect(AddrSpace *as) {
}

void __am_get_cur_as(Context *c) {
  c->pdir = (vme_enable ? (void *)get_satp() : NULL);
}

void __am_switch(Context *c) {
  if (vme_enable && c->pdir != NULL) {
    set_satp(c->pdir);
  }
}

// 确定映射关系
void map(AddrSpace *as, void *va, void *pa, int prot) {
  // just give priority and type a shit
  // 各个地址提取
  uintptr_t PPN = PA_PPN((uintptr_t)pa);
  uintptr_t VPN_1 = VA_VPN_1((uintptr_t)va);
  uintptr_t VPN_2 = VA_VPN_2((uintptr_t)va);
  // 基地址
  PTE *VPN_1_BASE = as->ptr;
  PTE *VPN_2_BASE = NULL;
  // 一级页表页表项的地址为空，则创建页表项
  if (!(VPN_1_BASE[VPN_1])) { 
    // 设置二级页表的基地址, 指向一个物理页面，专门存储页表
    VPN_1_BASE[VPN_1] = (PTE)pgalloc_usr(PGSIZE);
  }
  // 第二页表基地址和目标地址
  VPN_2_BASE = (PTE *)(VPN_1_BASE[VPN_1]);
  // 将物理页号填写到二级页表的页表项中，低 12 位是标志位
  VPN_2_BASE[VPN_2] = (PPN << 12) | 0xF;
  return;
}


// 创建用户进程
Context *ucontext(AddrSpace *as, Area kstack, void *entry) {
  // 内核栈顶部存放 context
  Context *c = (Context *)(kstack.end) - 1;
  c->mepc = (uintptr_t)entry;
  c->mstatus =  0x1800 | (1 << MPIE_OFFSET);
  return c;
}
