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

#include "sdb.h"

#define NR_WP 32

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */
  char expr [128]; // To store the expr
  uint32_t result; // To store the latest result of expr
} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

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
  if(wp == head) {
    head = head -> next;
    wp->next = free_;
    free_ = wp;
  }
  else {
    WP *temp = head;
    while(temp->next != wp) {
      temp = temp->next;
      if(temp->next != NULL) assert(0);
    }
    temp->next = wp->next;
    wp->next = free_;
    free_ = wp;
  }
}
