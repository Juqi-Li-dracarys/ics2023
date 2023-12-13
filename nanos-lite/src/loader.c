#include <proc.h>
#include <elf.h>

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
#endif

extern uint8_t ramdisk_start;
extern uint8_t ramdisk_end;

// 解读 elf 文件内容，将程序指令拷贝到正确位置的
// 好奇的鼠鼠会想：这和 NEMU 加载 AM 的程序的过程有啥区别？
// 区别在于 AM 对 elf 文件进行 objcopy 转化为 bin
// 之后 copy 到 memory, 接下来取指执行, 而这里我们要直接对 ELF 解析

// 想我这样的蠢鼠鼠还会思考，程序从可执行文件加载包含数据加载和代码加载等
// 为啥我看加载到 NEMU 的过程只是把 elf 文件粗暴地拷贝过去，而没有解析代码和数据呢？
// 我们能不能在这里用对 NEMU 的骚操作来完成 loader ？
// 答案是不能
// 那是因为 elf 用的 ld 链接器，其链接后的格式被精心处理过了，
// 也因为它加载到了 0x80000000, 内存的开端，细品....

static uintptr_t loader(PCB *pcb, const char *filename) {
  TODO();
  return 0;
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  // 过调用这个函数指针，实际上执行了加载文件的代码
  ((void(*)())entry) ();
}

