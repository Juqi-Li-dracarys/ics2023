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

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
  TK_DEC_NUM

};

static struct rule {
  const char *regex;
  int token_type; // ASCII Code
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"==", TK_EQ},        // equal
  {"[0-9]+", TK_DEC_NUM}, // decimal number
  {"\\-", '-'},         // distract
  {"\\*", '*'},         // multiply
  {"\\/", '/'},
  {"\\(", '('}, 
  {"\\)", ')'}         
};

// #define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))
#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {}; // Array to store tokens
static int nr_token __attribute__((used))  = 0; // Num of token

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo; //Strictly, we should define len = eo - so, but here so == 0

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

        switch (rules[i].token_type) {

          case TK_NOTYPE: break;

          case '+': {
            if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '+';
            strcpy(tokens[nr_token].str, "+");
            nr_token++;
            break;
          }

          case '-': {
            if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '-';
            strcpy(tokens[nr_token].str, "-");
            nr_token++;
            break;
          }

          case '*': {
            if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '*';
            strcpy(tokens[nr_token].str, "*");
            nr_token++;
            break;
          }

          case '/': {
            if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '/';
            strcpy(tokens[nr_token].str, "/");
            nr_token++;
            break;
          }

          case '(': {
            if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '(';
            strcpy(tokens[nr_token].str, "(");
            nr_token++;
            break;
          }

          case ')': {
           if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = ')';
            strcpy(tokens[nr_token].str, ")");
            nr_token++;
            break;
          }

          case TK_EQ: {
           if(nr_token == 32) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = TK_EQ;
            strcpy(tokens[nr_token].str, "==");
            nr_token++;
            break;
          }

          case TK_DEC_NUM: {
            if (nr_token == 31)
            {
              printf("Token exceed.");
              return false;
            }
            tokens[nr_token].type = TK_DEC_NUM;
            if(substr_len < 33)
              strncpy(tokens[nr_token].str, e + position - substr_len, substr_len);
            else {
              printf("Token str exceed.");
              return false;
            }
            nr_token++;
            break;
          } 
          default: return false;
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}


word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  for(int i = 0; i < nr_token; i++){
    printf("%d ----- %s\n", tokens[i].type, tokens[i].str);
  }
  *success = true;
  return 0;
}
