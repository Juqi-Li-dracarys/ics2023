
#include <elf.h>
#include <common.h>
#include <../include/cpu/decode.h>
#include <../include/utils.h>

typedef struct ftrace_f {
    uint32_t addr;    // function address
    char name [30];   // function name
    uint32_t size;    // function size
} ftrace_fun; 

typedef struct ftrace_s {
    uint32_t fun_table_index;
    uint32_t fun_stack_index;
} ftrace_stack; 

FILE *elf_fp = NULL;
ftrace_fun ftrace_table [500] = {0};   // record fun
uint32_t ftrace_table_size = 0;
ftrace_stack fun_stack [500] = {0};    // fun stack
int32_t stack_top = -1;                // 栈顶指针
uint32_t stack_cum = 0;                // 累计入栈函数个数
char flog [1000][100] = {0};            // 调用返回记录
uint32_t flog_indx = 0;

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

void stack_push(uint32_t fun_index) {
    if(fun_index >= ftrace_table_size || stack_top >= 499) {
        return ;
    }
    stack_top++;
    fun_stack[stack_top].fun_table_index = fun_index;
    fun_stack[stack_top].fun_stack_index = stack_cum;
    stack_cum++;
    return;
}

void stack_get(ftrace_stack* temp) {
    if(stack_top <= -1) {
        return;
    }
    temp->fun_stack_index = fun_stack[stack_top].fun_stack_index;
    temp->fun_table_index = fun_stack[stack_top].fun_table_index;
    return;
}

void stack_pull(ftrace_stack* temp) {
    stack_get(temp);
    stack_top--;
    return;
}

// 获取当前函数在ftrace_table中的编号
int32_t get_fun_index(vaddr_t pc) {
    for(int i = 0; i < ftrace_table_size; i++) {
        if(pc >= ftrace_table[i].addr && pc < ftrace_table[i].addr + ftrace_table[i].size) {
            return i;
        }
    }
    //未找到相关函数
    return -1;
}

void ftrace_process(Decode *ptr) {
    // 下一条指令的所在函数序号
    int32_t ftab_index = get_fun_index(ptr->dnpc);
    // 不在函数中
    if(ftab_index == -1) {
        return;
    }
    else {
        ftrace_stack temp;
        // 非空栈
        if(stack_top > -1) {
            stack_get(&temp);
            // 与栈顶函数一致，非跳转
            if(temp.fun_table_index == ftab_index) {
            #ifdef CONFIG_FTRACE_COND
                log_write("FTRACE: 0x%08x\t in   (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
            #endif
                return;
            }
            else {
                if(ptr->isa.inst.val == 0x00008067) {
                    stack_pull(&temp);
                #ifdef CONFIG_FTRACE_COND
                    log_write("FTRACE: 0x%08x\t ret  (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
                #endif
                    sprintf(flog[flog_indx++], "FTRACE: 0x%08x\t ret  (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
                    return;
                }
                else {
                    stack_push(ftab_index);
                    stack_get(&temp);
                #ifdef CONFIG_FTRACE_COND
                    log_write("FTRACE: 0x%08x\t call (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
                #endif
                    sprintf(flog[flog_indx++], "FTRACE: 0x%08x\t call (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
                    return;
                }
            }
        }
        // 空栈
        else {
            stack_push(ftab_index);
            stack_get(&temp);
        #ifdef CONFIG_FTRACE_COND
            log_write("FTRACE: 0x%08x\t call (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
        #endif
            sprintf(flog[flog_indx++], "FTRACE: 0x%08x\t call (stack_idx = %03u)[%s@0x%08x]\n", ptr->pc, temp.fun_stack_index, ftrace_table[temp.fun_table_index].name, ftrace_table[temp.fun_table_index].addr);
            return;
        }

    }
}

void ftrace_table_d(void) {
    puts("FTRACE table:");
    for(int i = 0; i < ftrace_table_size; i++) {
        printf("name:%-30s\taddr:0x%08x\t\t\tsize:%-5d\n", ftrace_table[i].name, ftrace_table[i].addr, ftrace_table[i].size);
    }
    return;
}

void ftrace_log_d(void) {
    puts("FTRACE log:");
    for(int i = 0; i < flog_indx; i++) {
        printf("%s", flog[i]);
    }
    return;
}
