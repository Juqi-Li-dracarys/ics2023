#include <proc.h>
#include <elf.h>
#include <fs.h>

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
# define EXPECT_TYPE EM_X86_64
#endif

// 好奇的鼠鼠会想：这和 NEMU 加载 AM 的程序的过程有啥区别？
// 区别在于 AM 对 elf 文件进行 objcopy 转化为 bin
// 之后 copy 到 memory, 接下来取指执行, 而这里我们要直接对 ELF 解析

// 想我这样的蠢鼠鼠还会思考，程序从可执行文件加载包含数据加载和代码加载等
// 为啥我看加载到 NEMU 的过程只是把 elf 文件粗暴地拷贝过去，而没有解析代码和数据呢？
// 我们能不能在这里用对 NEMU 的骚操作来完成 loader ？
// 答案是不能
// 那是因为 elf 用的 ld 链接器，其链接后的格式被精心处理过了，
// 也因为它加载到了 0x80000000, 内存的开端，细品....


// 解读 elf 文件内容，将单个程序的指令和数据拷贝到正确位置
static uintptr_t loader(PCB *pcb, const char *filename) {
  uintptr_t fd = 0;
  uintptr_t entry_ = 0x0;
  Elf_Ehdr ehdr = {0};
  Elf_Phdr phdr = {0};
  // can't open file
  if((fd = fs_open(filename, 0, 0)) == -1) {
    // 获取ELF头表
    ramdisk_read(&ehdr, 0, sizeof(Elf_Ehdr));
    if (ehdr.e_ident[0] != 0x7f || ehdr.e_ident[1] != 'E' || ehdr.e_ident[2] != 'L' || ehdr.e_ident[3] != 'F') {
        Log("error file type.");
        assert(0);
    }
    if(ehdr.e_machine != EXPECT_TYPE) {
        Log("error ISA: %d. desired type: %d", ehdr.e_machine, EXPECT_TYPE);
        assert(0);
    }
    Log("PASS BASIC CHECK, ISA = %s", EXPECT_TYPE == EM_RISCV ? "RISCV" : "X86_64");
    entry_ = ehdr.e_entry;
    Log("get the entry point address: %p", entry_);
    // 获取段头表
    for(int i = 0; i < ehdr.e_phnum; i++) {
      ramdisk_read(&phdr, ehdr.e_phoff + ehdr.e_phentsize * i, sizeof(Elf_Phdr));
      if(phdr.p_type == PT_LOAD) {
        Log("\nLOADING...offset:%p  virtaddr:%p  filesize:%p", phdr.p_offset, phdr.p_vaddr, phdr.p_filesz);
        ramdisk_read((void *)phdr.p_vaddr, phdr.p_offset, phdr.p_filesz);
        memset((void *)(phdr.p_vaddr + phdr.p_filesz), 0, phdr.p_memsz - phdr.p_filesz);
      }
    }
  }
  // filename exist
  else {
    // 获取ELF头表
    lseek(fd, 0, SEEK_SET);
    fs_read(fd, &ehdr, sizeof(Elf_Ehdr));
    // ramdisk_read(&ehdr, 0, sizeof(Elf_Ehdr));
    if (ehdr.e_ident[0] != 0x7f || ehdr.e_ident[1] != 'E' || ehdr.e_ident[2] != 'L' || ehdr.e_ident[3] != 'F') {
        Log("error file type.");
        assert(0);
    }
    if(ehdr.e_machine != EXPECT_TYPE) {
        Log("error ISA: %d. desired type: %d", ehdr.e_machine, EXPECT_TYPE);
        assert(0);
    }
    Log("PASS BASIC CHECK, ISA = %s", EXPECT_TYPE == EM_RISCV ? "RISCV" : "X86_64");
    entry_ = ehdr.e_entry;
    Log("get the entry point address: %p", entry_);
    // 获取段头表
    for(int i = 0; i < ehdr.e_phnum; i++) {
      lseek(fd, ehdr.e_phoff + ehdr.e_phentsize * i, SEEK_SET);
      fs_read(fd, &phdr, sizeof(Elf_Phdr));
      // ramdisk_read(&phdr, ehdr.e_phoff + ehdr.e_phentsize * i, sizeof(Elf_Phdr));
      if(phdr.p_type == PT_LOAD) {
        Log("\nLOADING...offset:%p  virtaddr:%p  filesize:%p", phdr.p_offset, phdr.p_vaddr, phdr.p_filesz);
        // ramdisk_read((void *)phdr.p_vaddr, phdr.p_offset, phdr.p_filesz);
        lseek(fd, phdr.p_offset, SEEK_SET);
        fs_read(fd, (void *)phdr.p_vaddr, phdr.p_filesz);
        memset((void *)(phdr.p_vaddr + phdr.p_filesz), 0, phdr.p_memsz - phdr.p_filesz);
      }
    }
  }
  return entry_;
}

// 批处理，单进程
void naive_uload(PCB *pcb, const char *filename) {
  uintptr_t entry = loader(pcb, filename);
  Log("Jump to entry = %p", entry);
  // 通过调用这个函数指针，实际上执行了加载文件的代码
  ((void(*)())entry) ();
}

// 创建内核线程
// 将上下文保存在 pcb.stack 中,运行时也用 PCB 栈
uintptr_t context_kload(PCB *pcb, void (*entry)(void *), void *arg) {
  Area kernels_stack;
  kernels_stack.start = pcb->stack;
  kernels_stack.end = pcb->stack + STACK_SIZE;
  pcb->cp = kcontext(kernels_stack, entry, arg);
  return (uintptr_t)entry;
}

// 创建用户进程
// 将上下文保存在 pcb.stack 中,但运行时的栈要切换到用户栈
uintptr_t context_uload(PCB *pcb, const char *filename, char *const argv[], char *const envp[]) {

  Area kernel_stack;
  uintptr_t *user_stack = (uintptr_t *)heap.end;
  kernel_stack.start = pcb->stack;
  kernel_stack.end = pcb->stack + STACK_SIZE;

  // // 函数参数压入用户栈
  // int argc = 0;
  // int envc = 0;
  // // 记录字符串在栈中地址
  // char *argv_[100] = {NULL};
  // char *envp_[100] = {NULL};

  // // Set NULL
  // user_stack--;
  // *user_stack = 0;
  
  // // create string area
  // while(argv[argc]) {
  //   size_t len = strlen(argv[argc]) + 1;
  //   // 4 字节对齐
  //   len = (len % 4 == 0) ? len : ((len / 4) + 1) * 4;
  //   user_stack = user_stack - (len / 4);
  //   strcpy((char *)user_stack, argv[argc]);
  //   // 记录字符串开头
  //   argv_[argc] = (char *)user_stack;
  //   argc++;
  // }

  // while(envp[envc]) {
  //   size_t len = strlen(envp[envc]) + 1;
  //   // 4 字节对齐
  //   len = (len % 4 == 0) ? len : ((len / 4) + 1) * 4;
  //   user_stack = user_stack - (len / 4);
  //   strcpy((char *)user_stack, envp[envc]);
  //   // 记录字符串开头
  //   envp_[envc] = (char *)user_stack;
  //   envc++;
  // }

  // // Set NULL
  // user_stack--;
  // *user_stack = 0;

  // // NULL 结尾和 argc/envc 的值
  // user_stack -= (argc + envc + 4);
  // user_stack[0] = argc;
  // for(int i = 0; i < argc; i++) {
  //   user_stack[1 + i] = (uintptr_t)argv_[i];
  // }
  //  // Set NULL
  // user_stack[1 + argc] = 0;
  // user_stack[2 + argc] = envc;

  // for(int i = 0; i < envc; i++) {
  //   user_stack[3 + argc + i] = (uintptr_t)envp_[i];
  // }

  // 上下文压入内核栈
  uintptr_t entry = loader(pcb, filename);
  pcb->cp = ucontext(NULL, kernel_stack, (void *)entry);
  pcb->cp->GPRx = (uintptr_t)user_stack;
  return (uintptr_t)entry;

}



