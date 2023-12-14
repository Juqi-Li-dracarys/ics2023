#include <proc.h>
#include <elf.h>

#ifdef __LP64__
# define Elf_Ehdr Elf64_Ehdr
# define Elf_Phdr Elf64_Phdr
#else
# define Elf_Ehdr Elf32_Ehdr
# define Elf_Phdr Elf32_Phdr
#endif

#if defined(__ISA_AM_NATIVE__)
# define EXPECT_TYPE EM_X86_64
#elif defined(__riscv)
#define EXPECT_TYPE EM_RISCV
#else
# error Unsupported ISA
#endif

size_t ramdisk_read(void *buf, size_t offset, size_t len);
size_t ramdisk_write(const void *buf, size_t offset, size_t len);
size_t get_ramdisk_size();


// 好奇的鼠鼠会想：这和 NEMU 加载 AM 的程序的过程有啥区别？
// 区别在于 AM 对 elf 文件进行 objcopy 转化为 bin
// 之后 copy 到 memory, 接下来取指执行, 而这里我们要直接对 ELF 解析

// 想我这样的蠢鼠鼠还会思考，程序从可执行文件加载包含数据加载和代码加载等
// 为啥我看加载到 NEMU 的过程只是把 elf 文件粗暴地拷贝过去，而没有解析代码和数据呢？
// 我们能不能在这里用对 NEMU 的骚操作来完成 loader ？
// 答案是不能
// 那是因为 elf 用的 ld 链接器，其链接后的格式被精心处理过了，
// 也因为它加载到了 0x80000000, 内存的开端，细品....


// 解读 elf 文件内容，将程序指令和数据拷贝到正确位置
static uintptr_t loader(PCB *pcb, const char *filename) {
  // 获取ELF头表
  Elf_Ehdr ehdr = {0};
  uintptr_t entry = 0x0;
  ramdisk_read(&ehdr, 0, sizeof(Elf_Ehdr));
  if (ehdr.e_ident[0] != 0x7f || ehdr.e_ident[1] != 'E' || ehdr.e_ident[2] != 'L' || ehdr.e_ident[3] != 'F') {
      Log("error file type.");
      assert(0);
  }
  if (ehdr.e_ident[4] != 0x01) {
      Log("this file was not complied for a 32bits system.");
      assert(0);
  }
  // if(ehdr.e_machine != EXPECT_TYPE) {
  //     Log("error ISA.");
  //     assert(0);
  // }
  Log("PASS BASIC CHECK");
  entry = ehdr.e_entry;
  Log("get the entry point address: %p", entry);
  // 获取段头表
  Elf_Phdr phdr = {0};
  for(int i = 0; i < ehdr.e_phnum; i++) {
    ramdisk_read(&phdr, ehdr.e_phoff + ehdr.e_phentsize * i, sizeof(Elf_Phdr));
    if(phdr.p_type == PT_LOAD) {
      printf("LOAD: offset:%p  virtaddr:%p  filesize:%p\n", phdr.p_offset, phdr.p_vaddr, phdr.p_filesz);
      ramdisk_read((void *)phdr.p_vaddr, phdr.p_offset, phdr.p_filesz);
      memset((void *)(phdr.p_vaddr + phdr.p_filesz), 0, phdr.p_memsz - phdr.p_filesz);
    }
  }
  return entry;     
}

void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  // 过调用这个函数指针，实际上执行了加载文件的代码
  ((void(*)())entry) ();
}

