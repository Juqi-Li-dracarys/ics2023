
#include <elf.h>
#include <common.h>
#include <../include/cpu/decode.h>

#ifdef CONFIG_FTRACE

typedef struct ftrace_f {
    uint32_t addr;    // function address
    char name [30];   // function name
    uint16_t size;    // function size
} ftrace_fun; 

FILE *elf_fp = NULL;
ftrace_fun ftrace_table [500] = {0};
uint32_t ftrace_table_size = 0;

// Success return 1, else return 0
uint8_t init_ftrace(char *elf_addr) {

    Elf32_Ehdr ehdr = {0};          // ELF头
    Elf32_Shdr shdr [500] = {0};    // 节头表
    Elf32_Sym sym_table [500]= {0}; // 符号表
    size_t read_size;
    if ((elf_fp = fopen(elf_addr, "rb")) == NULL) {
        puts("读取ELF文件失败, ftrace 未启动.");
        return 0;
    }
    else {
        char magic_buf[6] = {0};
        fseek(elf_fp, 0, SEEK_SET);
        read_size = fread(magic_buf, 1, 5, elf_fp);
        //魔数检查
        if (magic_buf[0] != 0x7f || magic_buf[1] != 'E' || magic_buf[2] != 'L' || magic_buf[3] != 'F') {
            puts("文件类型错误, ftrace 未启动.");
            return 0;
        }
        if (magic_buf[4] != 0x01) {
            puts("警告: ELF文件非32位系统生成.");
        }       
    }
    fseek(elf_fp, 0, SEEK_SET);
    // 读取ELF头
    read_size = fread(&ehdr, sizeof(Elf32_Ehdr), 1, elf_fp);
    // 跳转到节头表, 并全部读取
    fseek(elf_fp, ehdr.e_shoff, SEEK_SET);
    read_size = fread(&shdr, ehdr.e_shentsize, ehdr.e_shnum, elf_fp);
    // 跳转到shstrtab, 并全部读取
    char shstr_table [5000] = {0};
    fseek(elf_fp, shdr[ehdr.e_shstrndx].sh_offset, SEEK_SET);
    read_size = fread(&shstr_table, 1, shdr[ehdr.e_shstrndx].sh_size, elf_fp);
    // 查找 strtab, 并跳转读取
    uint32_t index;
    for(index = ehdr.e_shnum - 1; index >= 0; index--) {
        if(strcmp(".strtab", &shstr_table[shdr[index].sh_name]) == 0) {
            break;
        }
    }
    char str_table [5000] = {0};
    fseek(elf_fp, shdr[index].sh_offset, SEEK_SET);
    read_size = fread(&str_table, 1, shdr[index].sh_size, elf_fp);
    // 查找 symtab, 并跳转读取
    for(index = ehdr.e_shnum - 1; index >= 0; index--) {
        if(strcmp(".symtab", &shstr_table[shdr[index].sh_name]) == 0) {
            break;
        }
    }
    fseek(elf_fp, shdr[index].sh_offset, SEEK_SET);
    int sym_num = shdr[index].sh_size / sizeof(Elf32_Sym);
    read_size = fread(&sym_table, sizeof(Elf32_Sym), sym_num, elf_fp);
    index = 0;
    // Parse symbol table
    for(int i = 0; i < sym_num; i++) {
        if(ELF32_ST_TYPE(sym_table[i].st_info) == STT_FUNC) {
            ftrace_table[index].addr = sym_table[i].st_value;
            ftrace_table[index].size = sym_table[i].st_size;
            strcpy(ftrace_table[index].name, &str_table[sym_table[i].st_name]);
            index++;
        }
    }
    ftrace_table_size = index;
    if(read_size == 0) return 0;
    else return 1;
}

void disp_ftrace(void) {
    puts("ftrace table:");
    for(int i = 0; i < ftrace_table_size; i++) {
        printf("name:%-30s\taddr:0x%08x\t\t\tsize:%-5d\n", ftrace_table[i].name, ftrace_table[i].addr, ftrace_table[i].size);
    }
    return;
}

void write_ftrace(Decode *ptr) {
    log_write("fuck: 0x%08x\n", ptr->pc);
}

#endif