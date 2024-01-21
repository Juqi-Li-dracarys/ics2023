#include <am.h>
#include <nemu.h>
#include <klib.h>

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
  for (i = 0; i < LENGTH(segments); i ++) {
    void *va = segments[i].start;
    for (; va < segments[i].end; va += PGSIZE) {
      printf("OK1\n");
      map(&kas, va, va, 0);
    }
  }
  
  printf("OK2\n");
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

void map(AddrSpace *as, void *va, void *pa, int prot) {

  // // 各个地址提取
  // uint32_t PPN = PA_PPN((uint32_t)pa);
  // uint32_t VPN_1 = VA_VPN_1((uint32_t)va);
  // uint32_t VPN_2 = VA_VPN_2((uint32_t)va);
 
  // // 一级页表的目标位置
  // PTE *VPN_1_TARGET = as->ptr + VPN_1;
  // PTE *VPN_2_BASE = NULL;
  // // 如果一级页表中的页表项的地址为空，则创建页表项
  // if (!(*VPN_1_TARGET)) { 
  //   // 设置二级页表的基地址, 指向一个物理页面，专门存储页表
  //   *VPN_1_TARGET = (PTE)pgalloc_usr(PGSIZE);
  // }
  // // 第二页表基地址和目标地址
  // VPN_2_BASE = (PTE *)(*VPN_1_TARGET);
  // PTE *VPN_2_TAGET = VPN_2_BASE + VPN_2;
  // // 将物理页号填写到二级页表的页表项中，低 12 位是标志位
  // *VPN_2_TAGET = (PPN << 12) | 0xF;




#define PTE_PPN 0xFFFFF000
  uintptr_t va_trans = (uintptr_t) va;
  uintptr_t pa_trans = (uintptr_t) pa;
 
  assert(PA_OFFSET(pa_trans) == 0);
  assert(VA_OFFSET(va_trans) == 0);
 
  //提取虚拟地址的二级页号和一级页号，以及物理地址的物理页号
  uint32_t ppn = PA_PPN(pa_trans);
  uint32_t vpn_1 = VA_VPN_1(va_trans);
  uint32_t vpn_2 = VA_VPN_2(va_trans);
 
  //获取地址空间的页表基址和一级页表的目标位置
  PTE * page_dir_base = (PTE *) as->ptr;
  PTE * page_dir_target = page_dir_base + vpn_1;
  
  //如果一级页表中的页表项的地址(二级页表的基地址)为空，创建并填写页表项
  if (*page_dir_target == 0) { 
    //通过 pgalloc_usr 分配一页物理内存，作为二级页表的基地址
    PTE * page_table_base = (PTE *) pgalloc_usr(PGSIZE);
    //将这个基地址填写到一级页表的页表项中，同时设置 PTE_V 表示这个页表项是有效的。
    *page_dir_target = ((PTE) page_table_base) | PTE_V;
    //计算在二级页表中的页表项的地址
    PTE * page_table_target = page_table_base + vpn_2;
    //将物理页号 ppn 左移 12 位，即去掉低 12 位的偏移，与权限标志 PTE_V | PTE_R | PTE_W | PTE_X 组合，填写到二级页表的页表项中。
    *page_table_target = (ppn << 12) | PTE_V | PTE_R | PTE_W | PTE_X;
  } else {
    //取得一级页表项的内容，然后 & PTE_PPN 通过按位与操作提取出页表的基地址，提取高20位，低 12 位为零
    PTE * page_table_base = (PTE *) ((*page_dir_target) & PTE_PPN);
    //通过加上 vpn_0 计算得到在二级页表中的目标项的地址
    PTE * page_table_target = page_table_base + vpn_2;
    //将物理页号 ppn 左移 12 位，即去掉低 12 位的偏移，与权限标志 PTE_V | PTE_R | PTE_W | PTE_X 组合，填写到二级页表的目标项中。
    *page_table_target = (ppn << 12) | PTE_V | PTE_R | PTE_W | PTE_X;
  }

}


// 创建用户进程
Context *ucontext(AddrSpace *as, Area kstack, void *entry) {
  // 内核栈顶部存放 context
  Context *c = (Context *)(kstack.end) - 1;
  c->mepc = (uintptr_t)entry;
  c->mstatus = 0x1800;
  return c;
}
