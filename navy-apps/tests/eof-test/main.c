#include <stdio.h>

// ISA=native 不会出错
// 目前问题定位在 libos 和 libc
// 即两个 syscall
int main() {
    FILE *fp = fopen("/share/files/test", "r");
    int times = 0;
    char buf [10] = {0};
    while (!feof(fp) && times < 20)
    {
        // fscanf(fp, "%s\n", buf);       
        fread(buf, 7, 1, fp);
        printf("[%d]  eof:%d  %s", times, feof(fp), buf);
        times++;
    }
    return 0;
    
}