/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-11 23:44:45 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-04-02 15:27:29
 */

// source code for wp bp

#include "sdb.h"
#include <cpu/decode.h>
#include <trace.h>

#define NR_WP 32

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

// Break point of PC
static word_t pc_addr = 0;
static word_t pc_break = 0;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

/* move WP from free_ to head
*/
WP* new_wp() {
  if (free_ == NULL) {
    printf("No free watchpoint.");
    assert(0);
  }
  else {
    WP *temp = free_;
    free_ = free_->next;
    temp->next = head;
    head = temp;
  }
  return head;
}

/* move WP from head to free_
*/
void free_wp(WP *wp) {
  if(head == NULL) {
    printf("Not find the watching point.\n");
    return;
  }
  if(wp == head) {
    head = head -> next;
    wp->next = free_;
    free_ = wp;
  }
  else {
    WP *temp = head;
    while(temp->next != wp) {
      if(temp->next == NULL) {
        printf("Not find the watching point.\n");
        return;
      }
      temp = temp->next;
    }
    temp->next = wp->next;
    wp->next = free_;
    free_ = wp;
  }
}

/* print the value of all active watching point
*/
void print_wp(void) {
  WP *temp = head;
  while(temp != NULL) {
    printf("Watching point %d: expr: %s, latest value: 0x%016lx\n", temp->NO, temp->expr, temp->result);
    temp = temp->next;
  }
}

/* delete the certain watching point
*/
void delete_wp(unsigned int index) {
  free_wp(wp_pool + index);
  return ;
}

/* delete all watching point
*  if the value one active point change thn return 1
*  else return 0  
*/
bool check_wp(void) {
  WP *temp = head;
  word_t new_value;
  bool flag = false;
  while(temp != NULL) {
    bool success;
    new_value = expr(temp->expr, &success);
    if (temp->result != new_value) {
      flag = true;
      printf("After complish the follow action, Watching point %d value change: \nexpr: %s  value: 0x%016lx  ->  0x%016lx\n", temp->NO, temp->expr, temp->result, new_value);
      temp->result = new_value;
    }
    temp = temp->next;
  }
  return flag;
}

/* Set and update the breakpoint of PC
*/
void set_bp(word_t pc_add) {
  pc_break = true;
  pc_addr = pc_add;
  printf("Set up/Update the break point @PC = 0x%016lx\n", pc_addr);
  return;
}

/* check the breakpoint of PC
*  if the value one active point change thn return 1
*  else return 0  
*/
bool check_bp(Decode * s) {
  if(pc_break == true && pc_addr == s->pc) {
    printf("Got the break point @PC = 0x%016lx, and complish the follow action: \n", s->pc);
    return true;
  }
  else {
    return false;
  }
}

/* Delete the breakpoint of PC
*/
void delete_bp(void) {
  pc_break = false;
  printf("Delete the break point @PC = 0x%016lx\n", pc_addr);
  return;
}