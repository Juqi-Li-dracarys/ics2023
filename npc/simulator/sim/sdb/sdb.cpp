/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 18:53:49 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-12 12:26:04
 */

#include <common.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <sdb.h>
#include <trace.h>

static int is_batch_mode = false;

extern SimState sim_state;

void init_regex();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(simulator) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}

static int cmd_q(char *args) {
  // Change the flag of nemu_state
  if(sim_state.state != SIM_ABORT && sim_state.state != SIM_END)
    sim_state.state = SIM_QUIT;
#ifdef CONFIG_ITRACE
  destroy_ring_buffer(ring_head);
#endif
  return -1;
}

// TASK1: The function that can step through the program
static int cmd_si(char *args) {

  uint64_t exe_times = 1;
  if (args == NULL) {
    /* no argument given */
     printf("Step through the program for %lu steps and complish the follow action:\n", exe_times);
     cpu_exec(exe_times); // Excute once
  }
  else {
    sscanf(args, "%lu", &exe_times);
    printf("Step through the program for %lu steps and complish the follow action:\n", exe_times);
    cpu_exec(exe_times);
  }
  return 0;
}

// TASK2: Print the information of reg or watching point or trace
static int cmd_info(char *args) {
  if (args == NULL) {
    /* no argument given */
     printf("Error: The info needs 1 args!\n");
     return 0;
  }
  else if (strcmp(args,(const char*)"r") == 0) {
    printf("The rigister value in nemu:\n");
    isa_reg_display();
  }
  else if (strcmp(args,(const char*)"w") == 0) {
    // Print the value of watching point
  #ifdef CONFIG_WBCHECK
    print_wp();
  #endif
  }
#ifdef CONFIG_ITRACE
  else if (strcmp(args,(const char*)"i-ring") == 0) {
    // Print the trace in ring buffer
    print_ring_buffer(ring_head);
  }
#endif
  else if (strcmp(args,(const char*)"f-table") == 0) {
#ifdef CONFIG_FTRACE
    // Print the ftrace table
    ftrace_table_d();
#endif
  }
  else if (strcmp(args,(const char*)"f-log") == 0) {
#ifdef CONFIG_FTRACE
    // Print the ftrace log
    ftrace_log_d();
#endif
  }
  return 0;
}

// TASK3: Print the information of memory
static int cmd_x(char *args) {
  if (args == NULL) {
    /* no argument given */
     printf("Error: The x needs 2 args!\n");
     return 0;
  }
  else {
    char *arg1 = strtok(args, " ");
    char *arg2 = strtok(NULL, " ");
    if (arg2 == NULL) {
      printf("Error: The x needs 2 args!\n");
      return 0;
    }
    // Parsing the value
    word_t index, addr;
    bool success;
    sscanf(arg1, "%lu", &index);
    addr = expr(arg2, &success);
    if(success == false) assert(0);
    puts("The information of memory is listed below:\n");
    for(uint16_t i = 0; i < index; i++) {
      printf("Address: 0x%016lx   Value: 0x%016lxx\n", addr + i, paddr_read(addr + i, 1));
    }
  }
  return 0;
}

// TASK4: Calculate the value of the expr.
static int cmd_p(char *args) {
  if (args == NULL) {
    /* no argument given */
     printf("Error: The p needs 1 args!\n");
     return 0;
  }
  else {
    bool success;
    word_t result = expr(args, &success);
    if (success == false) {
      printf("calculate fault."); 
      assert(0);
    }
    else {
      printf("Done.\nthe result of expr in hex is: 0x%016lx\nanswer in dec is %lu\n", result, result);
      return 0;
    }
  }
}

// TASK5: Excute the examination progranm for calculation
static int cmd_e(char *args) {
  bool success = 0;
  FILE *file = fopen("/home/dracacys/ics2023/nemu/tools/gen-expr/input", "r");
  if (file == NULL) {
        perror("Error opening file");
        return 1;
  }
  int lineCount = 0;
  char line[10000] = {0}; // Every line char recorder
  while (fgets(line, sizeof(line), file)) {
        lineCount++;
  }
  rewind(file);

  // read every line and store them in the result
  for (int i = 0; i < lineCount; i++) {
      if (fgets(line, sizeof(line), file)) {
          word_t answer,result;
          char str[10000];
          if (sscanf(line, "%lu %9999[^\n]", &answer, str) == 2) {
              result = expr(str, &success);  
              printf("Line: %d   Result: %lu   Answer: %lu\n", i, result, answer);
              if (result != answer || success == 0) {
                printf("Error: the answer is not correct.");
                assert(0);
              }
          }
      }
  }
  fclose(file);
  printf("Test pass.\n");
  return 0;
}


// TASK6: Set up watching point
static int cmd_w(char *args) {
  if (args == NULL) {
    /* no argument given */
     printf("Error: The w needs 1 args!\n");
     return 0;
  }
  else {
#ifdef CONFIG_WBCHECK
    bool success;
    unsigned int value = expr(args, &success);
    if(success != true) {
      return 0;
    }
    else {
      WP* ptr = new_wp();
      strcpy(ptr->expr, args);
      ptr->result = value;
      printf("Watching point %d: expr: %s, latest value: %u is created.\n", ptr->NO, ptr->expr, ptr->result);
      return 0;
    }
#endif
  }
  return 0;
}

// TASK7: Delete watching point or break point
static int cmd_d(char *args) {
#ifdef CONFIG_WBCHECK
  if (args == NULL) {
    /* no argument given */
     delete_bp();
     return 0;
  }
  else {
    unsigned int index;
    sscanf(args, "%u", &index);
    delete_wp(index);
    return 0;
  }
#endif
  return 0;
}

// TASK8: Set PC break point
static int cmd_b(char *args) {
#ifdef CONFIG_WBCHECK
  bool success;
  if (args == NULL) {
    /* no argument given */
     printf("Error: The b needs 1 args!\n");
     return 0;
  }
  else {
    set_bp(expr(args, &success));
    if(success != true) {
      printf("Wrong match in cmb_d.\n");
    }
  }
#endif
  return 0;
}

// TASK9: Excute the program in n clocks 
static int cmd_clk(char *args) {
  uint64_t exe_times = 1;
  if (args == NULL) {
    /* no argument given */
     printf("Excute the program in %lu clocks .\n", exe_times);
     cpu_exec_clk(exe_times); // Excute once
  }
  else {
    sscanf(args, "%lu", &exe_times);
    printf("Excute the program in %lu clocks .\n", exe_times);
    cpu_exec_clk(exe_times);
  }
  return 0;
}


static int cmd_help(char *args);

// The structure decide the next action in the gdb_loop, including the pointer of function
static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit SIM", cmd_q },

  /* TODO: Add more commands */
  { "si", "Excute the program in n instructions", cmd_si },
  { "info", "Print the information of reg or watching point or trace(1 ags must be given)", cmd_info },
  { "x", "Print the information of memory(2 ags must be given)", cmd_x },
  { "p", "Calculate the value of the expr", cmd_p },
  { "e", "Excute the examination progranm for calculation", cmd_e },
  { "w", "Set up watching point", cmd_w },
  { "d", "Delete watching point or break point", cmd_d },
  { "b", "Set PC break point", cmd_b },
  { "clk", "Excute the program in n clocks", cmd_clk }
};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}


void sdb_set_batch_mode() {
  is_batch_mode = true;
}


void sdb_mainloop() {

  // The default value of is_batch_mode is equal to 0
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  // Read the whole cammand once
  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");

    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     * We will parsing the remaining arguments in the function
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL; // No args
    }

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        // Function calling hanppens here, very impressive!
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
#ifdef CONFIG_WBCHECK
  init_wp_pool();
#endif
   /* Initialize the ring buffer. */
#ifdef CONFIG_ITRACE
  ring_head = init_ring_buffer();
#endif
}

