/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {}; // to store the expr
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  int result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static int buf_index = 0; // buf index
static int n_input = 0;   // size of new input
#define choose(x) (rand() % x) // generate random num
#define gen(c,i) n_input = sprintf(buf + i,"%c",c); i = (i >= 65530 ? 65530 : i + n_input); // print one char in the buf
#define gen_num(i) n_input = sprintf(buf + i,"%d",rand() % 10); i = (i >= 65530 ? 65530 : i + n_input); // print one num in the buf

// generate random op
void gen_rand_op(void) {
  switch (choose(3)) {
    case 0: gen('+',buf_index); break;
    case 1: gen('-',buf_index); break;
    default: gen('*',buf_index); break;
  }
}

// generate random op
void gen_space(void) {
  for(int i = rand() % 4; i > 0; i--) {
    gen(' ',buf_index)
  }
}

// generate expr once
static void gen_rand_expr() {
  // To avoid the segmental fault
  switch (buf_index < 20 ? choose(6) : 0) {
    case 0: {gen_space(); gen_num(buf_index); gen_space(); break;}
    case 1: {gen('(',buf_index); gen_rand_expr(); gen(')',buf_index); break;}
    case 2: { // To aviod /0
      gen_rand_expr(); gen_space(); gen('/',buf_index); gen_space(); 
      gen('(',buf_index); gen_rand_expr();gen('*',buf_index); gen('2',buf_index);
      gen('+',buf_index); gen('1',buf_index);gen(')',buf_index);break;
    }
    default: {gen_rand_expr(); gen_space(); gen_rand_op(); gen_space(); gen_rand_expr(); break;}
  }
  return ;
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  buf_index = 0;
  for (i = 0; i < loop; i ++) {
    // generate expr once
    buf_index = 0;
    gen_rand_expr();
    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf(" result:%d \n", result);
  }
  return 0;
}
