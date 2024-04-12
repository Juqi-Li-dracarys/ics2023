/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-11 23:41:53 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-18 08:22:44
 */

// header of all tracer for other module

#include <common.h>

// Watching point
typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */
  char expr [128]; // To store the expr
  word_t result; // To store the latest result of expr
} WP;

void init_wp_pool();
void init_wp_pool();
WP* new_wp();
void print_wp(void);
void delete_wp(unsigned int index);
void set_bp(word_t _pc_addr);
void delete_bp(void);
bool check_wp(void);
bool check_bp(word_t pc);


// Itrace
typedef struct buffer
{
  char log_buf[80];
  bool use_state;
  struct buffer *next;
} 
ring_buffer;

extern ring_buffer *ring_head;

ring_buffer *init_ring_buffer(void);
void print_ring_buffer(ring_buffer *head);
void destroy_ring_buffer(ring_buffer *head);
ring_buffer *write_ring_buffer(ring_buffer *head, char *log_str);


// Ftrace
void ftrace_table_d(void);
void ftrace_log_d(void);
void ftrace_process(inst_log *ptr);
void ftrace_log_d(void);

