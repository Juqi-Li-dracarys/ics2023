#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <NDL.h>
#include <BMP.h>


uint32_t pix[128 * 128] = {0x00FFFFFF};

int main() {
  NDL_Init(0);
  int w,h;
  printf("reading picture...\n");
  void *bmp = BMP_Load("/share/pictures/projectn.bmp", &w, &h);
  assert(bmp);
  printf("opening canvas...\n");
  NDL_OpenCanvas(&w, &h);
  NDL_DrawRect(pix, 0, 0, w, h);
  free(bmp);
  NDL_Quit();
  printf("Test ends! Spinning...\n");
  while (1);
  return 0;
}
