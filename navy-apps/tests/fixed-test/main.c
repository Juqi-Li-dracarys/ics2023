#include <stdio.h>
#include <fixedptc.h>
#include <stdlib.h>
#include <assert.h>

int main() {
    fixedpt A = fixedpt_rconst(3.3);
    fixedpt B = fixedpt_rconst(3);
    int C = -3;
    fixedpt D = 0;

    D = fixedpt_muli(A, C);
    printf("%d\n", fixedpt_toint(D));
    assert(fixedpt_toint(D) == -9);
    assert(fixedpt_toint(fixedpt_floor(D)) == -10);
    assert(fixedpt_toint(fixedpt_ceil(D)) == -9);

    printf("PASS\n");
    return 0;
}