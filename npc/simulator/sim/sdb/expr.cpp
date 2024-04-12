
/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */

#include <regex.h>
#include <common.h>
#include <debug.h>

enum {
  TK_NOTYPE = 256, TK_EQ,

  /* TODO: Add more token types */
  //TK_PTR is pointer "*"
  //TK_NEG is negtive number "-"
  TK_DEC_NUM, TK_HEX_NUM, TK_REG,
  TK_NEQ, TK_AND, TK_PTR, TK_NEG

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
  {"\\-", '-'},         // distract
  {"\\*", '*'},         // multiply
  {"\\/", '/'},         // divide or pointer
  {"\\(", '('}, 
  {"\\)", ')'},
  {"0[X,x][a-f,A-F,0-9]+", TK_HEX_NUM},          // hex number should be placed behind the dec
  {"[0-9]+", TK_DEC_NUM},                        // decimal number
  {"\\$[\\$,a,t,r,g,s][a,p,0-9]{1,2}", TK_REG},  // reg value
  {"!=", TK_NEQ},                                // not equal
  {"&&", TK_AND}                                 // logic and
};

//#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))
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
  char str[4096];
} Token;

static Token tokens[4096] __attribute__((used)) = {}; // Array to store tokens
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
            if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '+';
            strcpy(tokens[nr_token].str, "+");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case '-': {
            if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '-';
            strcpy(tokens[nr_token].str, "-");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case '*': {
            if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '*';
            strcpy(tokens[nr_token].str, "*");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case '/': {
            if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '/';
            strcpy(tokens[nr_token].str, "/");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case '(': {
            if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = '(';
            strcpy(tokens[nr_token].str, "(");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case ')': {
           if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = ')';
            strcpy(tokens[nr_token].str, ")");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case TK_EQ: {
           if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = TK_EQ;
            strcpy(tokens[nr_token].str, "==");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case TK_NEQ: {
           if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = TK_NEQ;
            strcpy(tokens[nr_token].str, "!=");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case TK_AND: {
           if(nr_token == 4096) {
              printf("Token exceed.\n");
              return false;
            }
            tokens[nr_token].type = TK_AND;
            strcpy(tokens[nr_token].str, "&&");
            *(tokens[nr_token].str + substr_len) = '\0';
            nr_token++;
            break;
          }

          case TK_HEX_NUM: {
            if (nr_token == 4096)
            {
              printf("Token exceed.");
              return false;
            }
            tokens[nr_token].type = TK_HEX_NUM;
            if(substr_len < 4096) {
                strncpy(tokens[nr_token].str, e + position - substr_len, substr_len);
                *(tokens[nr_token].str + substr_len) = '\0';
              }
            else {
              printf("Token str exceed.");
              return false;
            }
            nr_token++;
            break;
          } 

          case TK_DEC_NUM: {
            if (nr_token == 4096)
            {
              printf("Token exceed.");
              return false;
            }
            tokens[nr_token].type = TK_DEC_NUM;
            if(substr_len < 4096) {
              strncpy(tokens[nr_token].str, e + position - substr_len, substr_len);
              *(tokens[nr_token].str + substr_len) = '\0';
            }
            else {
              printf("Token str exceed.");
              return false;
            }
            nr_token++;
            break;
          } 

          case TK_REG: {
            if (nr_token == 4096)
            {
              printf("Token exceed.");
              return false;
            }
            tokens[nr_token].type = TK_REG;
            if(substr_len < 4096) {
              strncpy(tokens[nr_token].str, e + position - substr_len, substr_len);
              *(tokens[nr_token].str + substr_len) = '\0';
            }
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

/*The function is designed to judge whether the expr is surrounded by a matched pair of parentheses.
* p is the begin token index of the expr
* q is the end token index of the expr
*/
bool check_parentheses(int p, int q) {
  // the whole expression is not surrounded by a matched
  // pair of parentheses
  if (tokens[p].type != '(' || tokens[q].type != ')')
    return false;
  else {
    int flag = 0;
    for(int i = p + 1; i <= q - 1; i++) {
      if (tokens[i].type == '(')
        flag++;
      else if(tokens[i].type == ')') {
        flag--;
        if (flag < 0) {return false;} // Match error
      }
    }
    if (flag == 0)
      return true;
    else 
      return false;
  }
}

/*The function is designed to find the priority of op
*/

int findOpPriority(int type) {

  if (type == TK_AND) return 0;
  if (type == TK_EQ || type == TK_NEQ) return 1;
  if (type == '+' || type == '-') return 2;
  if (type == '*' || type == '/') return 3;

  return -1; // Didn't find TYPE
}

/*The function is designed to find the main op index of expr
* p is the begin token index of the expr
* q is the end token index of the expr
*/
int find_main_op(int p, int q) {
  int index_record = 0; // the record of index
  int priority_record = 3;// the record of lowest priorty
  int parentheses_flag = 0;// the flag of parentheses
  for(int i = p; i <= q; i++) {
    switch(tokens[i].type) {
      case '(':  {parentheses_flag++; break;}
      case ')':  {if (parentheses_flag > 0) parentheses_flag--; else printf("Error: find_main_op Illegal expression!\n"); break;}
      case '+': {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }
      case '-': {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }
      case '*': {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }
      case '/': {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }
      case TK_EQ: {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }

      case TK_NEQ: {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }

      case TK_AND: {
        if (parentheses_flag != 0)
          break;
        else {
          if (findOpPriority(tokens[i].type) <= priority_record) {
            index_record = i;
            priority_record = findOpPriority(tokens[i].type);
          }
          break;
        }
      }
      default: ; // Not op, do not anything
    }
  }
  return index_record;
}

/*The function is designed to dereference ptr for num times
*/
word_t ptr_dereference(word_t ptr, int num) {
  word_t result = ptr;
  for(int i = num; i > 0; i--) {
    result = paddr_read(result, 4);
  }
  return result;
}

/*The function is designed to claculate the value of expr
* p is the begin token index of the expr
* q is the end token index of the expr
*/
word_t eval(int p, int q) {

  if (p > q) {
    /* Bad expression */
    printf("Error: eval() occures bad expression.\n");
    assert(0);
  }

  else if (p == q) {
    /* Single token.
     * For now this token might be a decimal/hex/reg
     * Return the value of the number.
     */
    word_t result;

    switch (tokens[p].type) {
      case TK_DEC_NUM: {
        sscanf(tokens[p].str, "%lu", &result);
        return result;
      }
      case TK_HEX_NUM: {
        sscanf(tokens[p].str, "%lx", &result);
        return result;
      }
      case TK_REG: {
        bool success;
        char reg_name [5] = {0}; 
        sscanf((tokens[p].str + 1), "%s", reg_name);
        result = isa_reg_str2val(reg_name, &success);
        if (success == 1)
          return result;
        else {
          printf("Reg value fault");
          assert(0);
        } 
      }
      default: assert(0);
    }
  }

  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  }

  else {
    int op_index = find_main_op(p, q);
    if (op_index > 0) {
      switch (tokens[op_index].type) {
        case '+': return (eval(p, op_index - 1) + eval(op_index + 1, q));
        case '-': return (eval(p, op_index - 1) - eval(op_index + 1, q));
        case '*': return (eval(p, op_index - 1) * eval(op_index + 1, q));
        case '/': return (eval(p, op_index - 1) / eval(op_index + 1, q));
        case TK_EQ: return (eval(p, op_index - 1) == eval(op_index + 1, q));
        case TK_NEQ: return (eval(p, op_index - 1) != eval(op_index + 1, q));
        case TK_AND: return (eval(p, op_index - 1) && eval(op_index + 1, q));
        default: assert(0); 
      }
    }

    else if(tokens[p].type == TK_NEG) {
        /* For now this token is a negtive
        *  Return the value of the number.
        *  正常情况下，一个负号的后面只可能为数字，括号，负号, ptr*
        */
      int i;
      int num = 1;
      // Continuing '-'
      for(i = p + 1; i < nr_token; i++) {
        if(tokens[i].type != TK_NEG)
          break;
        num++;
      }
      if (tokens[i].type != '(') {
        if (num%2 != 0) return (~(eval(i, i)) + 1);
        else return eval(i, i);
      }
      // still have '('
      else {
        for(int j = i + 1; j < nr_token; j++) {
          if (check_parentheses(i, j) == true) {
            if (num%2 != 0) return (~(eval(i + 1, j - 1)) + 1);
            else return eval(i + 1, j - 1);
          }
        }
        printf("( is not balance! Error 1!\n"); assert(0);
      }
    }

    else if(tokens[p].type == TK_PTR) {
        /* For now this token is a ptr number
        *  Return the value of the number.
        *  正常情况下，一个负号的后面只可能为数字，括号，负号
        */
      int i;
      int num = 1;
      // Continuing '*'
      for(i = p + 1; i < nr_token; i++) {
        if(tokens[i].type != TK_PTR)
          break;
        num++;
      }
      if (tokens[i].type != '(') {
        return ptr_dereference(eval(i, i), num);
      }
      // still have '('
      else {
        for(int j = i + 1; j < nr_token; j++) {
          if (check_parentheses(i, j) == true) {
            return ptr_dereference(eval(i + 1, j - 1), num);
          }
        }
        printf("( is not balance! Error 2!\n"); assert(0);
      }
    }
    else {printf("Unkown type of token. Critical error!\n"); assert(0);}
  }
}

/* The function to evaluate the expression
*/
word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }
  /* TODO: Insert codes to evaluate the expression. */
  /*
    负号可能出现在第一个位置，或其前面不是数字和右括号
    指针解引用可能出现在第一个位置，或其前面不是数字和右括号
  */
  for (int i = 0; i < nr_token; i++) {
    if (tokens[i].type == '-' && 
    (i == 0 || (tokens[i - 1].type != ')' && 
    tokens[i - 1].type != TK_DEC_NUM && 
    tokens[i - 1].type != TK_REG && 
    tokens[i - 1].type != TK_HEX_NUM))) {
      tokens[i].type = TK_NEG;
    }
    
    if (tokens[i].type == '*' && 
    (i == 0 || (tokens[i - 1].type != ')' && 
    tokens[i - 1].type != TK_DEC_NUM && 
    tokens[i - 1].type != TK_REG && 
    tokens[i - 1].type != TK_HEX_NUM))) {
      tokens[i].type = TK_PTR;
    }
  }

  *success = true; // Maketoken success
  return eval(0, nr_token - 1);
}
