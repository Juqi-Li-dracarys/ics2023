#include <stdio.h>

// ISA=native 不会出错
// 目前问题定位在 libos 和 libc
// 即两个 syscall
int main() {
    FILE *fp = fopen("/share/files/test", "r");
    int times = 0;
    char buf [10] = {0};
    while (!feof(fp) && times < 10)
    {
        int size_in = fscanf(fp, "%s\n", buf);
        // int size_in = fread(buf, 1, 7, fp);
        printf("[%d]  eof:%d  offset:%d  size:%d  str:%s", times, feof(fp), ftell(fp), size_in, buf);
        times++;
    }
    // printf("hello world\n");
    // printf("********************\n");
    return 0;
    
}