#include <stdio.h>
#include <fixedptc.h>
#include <stdlib.h>
#include <assert.h>

int main() {
    fixedpt A = fixedpt_rconst(-411.98);
    fixedpt B = fixedpt_rconst(30.07);
    int C = -7;
    fixedpt D = 0;
    assert(fixedpt_toint(A) == -412);
    assert(fixedpt_toint(B) == 30);

    D = fixedpt_muli(A, C);
    assert(fixedpt_toint(D) == 2883);
    assert(fixedpt_toint(fixedpt_floor(D)) == 2883);
    assert(fixedpt_toint(fixedpt_ceil(D)) == 2884);
    assert(fixedpt_toint(fixedpt_abs(fixedpt_floor(D))) == 2883);

    D = fixedpt_mul(A, B);
    assert(fixedpt_toint(D) == -12389);
    assert(fixedpt_toint(fixedpt_floor(D)) == -12389);
    assert(fixedpt_toint(fixedpt_ceil(D)) == -12388);
    assert(fixedpt_toint(fixedpt_abs(fixedpt_ceil(D))) == 12388);

    D = fixedpt_divi(A, C);
    assert(fixedpt_toint(D) == 58);
    assert(fixedpt_toint(fixedpt_floor(D)) == 58);
    assert(fixedpt_toint(fixedpt_ceil(D)) == 59);
    assert(fixedpt_toint(fixedpt_abs(fixedpt_floor(D))) == 58);

    D = fixedpt_div(A, B);
    assert(fixedpt_toint(D) == -14);
    assert(fixedpt_toint(fixedpt_floor(D)) == -14);
    assert(fixedpt_toint(fixedpt_ceil(D)) == -13);
    assert(fixedpt_toint(fixedpt_abs(fixedpt_ceil(D))) == 13);

    printf("PASS\n");
    return 0;
}