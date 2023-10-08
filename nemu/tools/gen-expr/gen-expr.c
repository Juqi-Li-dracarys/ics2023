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
static char buf[65536] = {}; // to store the expr for nemu
static char buf_c[65536] = {}; // to store the expr for gcc
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  int result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static int buf_index = 0; // buf index for nemu
static int buf_index_c = 0; // buf index for c
static int n_input = 0;   // size of new input for nemu
static int n_input_c = 0;   // size of new input for c
static int ran = 0; //rand num

#define choose(x) (rand() % x) // generate random num
#define gen(c)    n_input = sprintf(buf + buf_index,"%c",c); n_input_c = sprintf(buf_c + buf_index_c,"%c",c); buf_index = (buf_index >= 65530 ? 65530 : buf_index + n_input); buf_index_c = (buf_index_c >= 65530 ? 65530 : buf_index_c + n_input_c); // print one char in the buf
#define gen_num   ran = rand() % 10; n_input = sprintf(buf + buf_index,"%u",ran); n_input_c = sprintf(buf_c + buf_index_c,"%uu",ran); buf_index = (buf_index >= 65530 ? 65530 : buf_index + n_input); buf_index_c = (buf_index_c >= 65530 ? 65530 : buf_index_c + n_input_c); // print one num in the buf
#define gen_num_c(r)   n_input = sprintf(buf + buf_index,"%u",r); n_input_c = sprintf(buf_c + buf_index_c,"%uu",r); buf_index = (buf_index >= 65530 ? 65530 : buf_index + n_input); buf_index_c = (buf_index_c >= 65530 ? 65530 : buf_index_c + n_input_c);
// generate random op
void gen_rand_op(void) {
  switch (choose(3)) {
    case 0: gen('+'); break;
    case 1: gen('-'); break;
    default: gen('*'); break;
  }
}

// generate random op
void gen_space(void) {
  for(int i = rand() % 4; i > 0; i--) {
    gen(' ');
  }
}

// generate expr for nemu and GCC
static void gen_rand_expr() {
  // To avoid the segmental fault
  switch (buf_index < 20 ? choose(6) : 0) {
    case 0: {gen_space(); gen_num(buf_index); gen_space(); break;}
    case 1: {gen('('); gen_rand_expr(); gen(')'); break;}
    case 2: { // To aviod /0
      gen_rand_expr(); gen_space(); gen('/'); gen_space(); 
      gen('('); gen('('); gen_rand_expr();gen(')');
      gen('*'); gen_num_c(2);gen('+'); 
      gen_num_c(1);gen(')');break;
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
  for (i = 0; i < loop; i ++) {
    // generate expr once
    buf_index = 0;
    buf_index_c = 0;
    gen_rand_expr();
    // generate code.c
    sprintf(code_buf, code_format, buf_c);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    uint32_t result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);
    // generate input
    printf("%u %s\n", result, buf);
  }
  return 0;
}
