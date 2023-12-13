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
// 好奇的鼠鼠会想：这和 NEMU 加载 AM 的程序有啥区别？
// 区别在于 AM 对 ELF 文件进行 objdump，再转化为 bin
// 之后 copy 到 memory, 接下来取指执行
// 而这里我们要直接对 ELF 解析
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

