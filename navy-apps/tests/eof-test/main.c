#include <stdio.h>

int main() {
    FILE *fp = fopen("/share/files/test", "r");
    int times = 0;
    char buf [10] = {0};
    while (!feof(fp)) {
        int str_in = fscanf(fp, "%s\n", buf);
        printf("[%d]  eof:%d  offset:%d  size:%d  str:%s", times, feof(fp), ftell(fp), str_in, buf);
        times++;
    }
    return 0;  
}