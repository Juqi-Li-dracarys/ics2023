#include <stdio.h>

int main() {
    FILE *fp = fopen("/share/files/test", "r");
    int times = 0;
    char buf [10] = {0};
    while (!feof(fp) && times < 20)
    {
        fscanf(fp, "%s\n", buf);
        printf("[%d]  eof:%d  %s\n", times, feof(fp), buf);
        times++;
    }
    return 0;
    
}