/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2023-12-28 16:54:36 
 * @Last Modified by:   Juqi Li @ NJU 
 * @Last Modified time: 2023-12-28 16:54:36 
 */


#include <NDL.h>
#include <sdl-video.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/*
  The width and height in srcrect determine 
  the size of the copied rectangle. 
  Only the position is used in the dstrect 
  (the width and height are ignored). 
*/
void SDL_BlitSurface(SDL_Surface *src, SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect) {
  // robust check
  assert(dst && src);
  assert(src->pixels && src->pixels);
  assert(dst->format->BitsPerPixel == src->format->BitsPerPixel);
  // if(src->h > dst->h || src->w > dst->w) 
  //   printf("WARNING: copy surface may lead to segmentation fault.\n");
  if(dst->format->palette == NULL && dst->format->BitsPerPixel == 32) {
    uint32_t *ptr_s = (uint32_t *)src->pixels;
    uint32_t *ptr_d = (uint32_t *)dst->pixels;
    // 第一个复制矩形的起始点和宽高
    int starpoint_s_x = 0;
    int starpoint_s_y = 0;
    int rect_w = 0; int rect_h = 0;
    // 在（x，y）或 （0，0）粘贴
    int starpoint_d_x = (dstrect != NULL) ? dstrect->x : 0;
    int starpoint_d_y = (dstrect != NULL) ? dstrect->y : 0;
    // 复制全图
    if(srcrect == NULL) {
      starpoint_s_x = 0; starpoint_s_y = 0;
      rect_w = src->w; rect_h = src->h;
    }
    // 复制部分
    else {
      starpoint_s_x = srcrect->x; starpoint_s_y = srcrect->y;
      rect_w = srcrect->w; rect_h = srcrect->h;
    }
    // 矩形内偏移量算出实际 offset
    for(int j = 0; (j < rect_h) && (j + starpoint_s_y < src->h); j++) {
      for(int i = 0; (i < rect_w) && (i + starpoint_s_x < src->w); i++) {
        *(ptr_d + (j + starpoint_d_y) * (dst->w) + i + starpoint_d_x) = *(ptr_s + (j + starpoint_s_y) * (src->w) + i + starpoint_s_x);
      }
    }
  }
  else if(dst->format->palette != NULL && dst->format->BitsPerPixel == 8) {
    uint8_t *ptr_s = (uint8_t *)src->pixels;
    uint8_t *ptr_d = (uint8_t *)dst->pixels;
    // 第一个复制矩形的起始点和宽高
    int starpoint_s_x = 0;
    int starpoint_s_y = 0;
    int rect_w = 0; int rect_h = 0;
    // 在（x，y）或 （0，0）粘贴
    int starpoint_d_x = (dstrect != NULL) ? dstrect->x : 0;
    int starpoint_d_y = (dstrect != NULL) ? dstrect->y : 0;
    // 复制全图
    if(srcrect == NULL) {
      starpoint_s_x = 0; starpoint_s_y = 0;
      rect_w = src->w; rect_h = src->h;
    }
    // 复制部分
    else {
      starpoint_s_x = srcrect->x; starpoint_s_y = srcrect->y;
      rect_w = srcrect->w; rect_h = srcrect->h;
    }
    // 矩形内偏移量算出实际 offset
    for(int j = 0; (j < rect_h) && (j + starpoint_s_y < src->h); j++) {
      for(int i = 0; (i < rect_w) && (i + starpoint_s_x < src->w); i++) {
        *(ptr_d + (j + starpoint_d_y) * (dst->w) + i + starpoint_d_x) = *(ptr_s + (j + starpoint_s_y) * (src->w) + i + starpoint_s_x);
      }
    }
  }
  else {
   assert(0);
  }
  
  return;
}

// 对 SDL surface 填充颜色
// 不输出到屏幕上
void SDL_FillRect(SDL_Surface *dst, SDL_Rect *dstrect, uint32_t color) {
  assert(dst);
  assert(dst->pixels);
  if(dst->format->palette == NULL && dst->format->BitsPerPixel == 32) {
    uint32_t *ptr = (uint32_t *)dst->pixels;
    if(dstrect == NULL) {
      for(int i = 0; i < (dst->w) * (dst->h); i++) {
        *ptr = color;
        ptr ++;
      }
    }
    else {
      for(int j = dstrect->y; (j < dstrect->y + dstrect->h) && (j < dst->h); j++) {
        for(int i = dstrect->x; (i < dstrect->x + dstrect->w) && (i < dst->w); i++) {
          *(ptr + j * (dst->w) + i) = color;
        }
      }
    }
  }
  else if(dst->format->palette != NULL && dst->format->BitsPerPixel == 8) {
    uint8_t *ptr = (uint8_t *)dst->pixels;
    if(dstrect == NULL) {
      for(int i = 0; i < (dst->w) * (dst->h); i++) {
        *ptr = (uint8_t)color;
        ptr ++;
      }
    }
    else {
      for(int j = dstrect->y; (j < dstrect->y + dstrect->h) && (j < dst->h); j++) {
        for(int i = dstrect->x; (i < dstrect->x + dstrect->w) && (i < dst->w); i++) {
          *(ptr + j * (dst->w) + i) = (uint8_t)color;
        }
      }
    }
  }
  else {
    assert(0);
  }

  return;
}

/*

Makes sure the given area is updated on the given screen. The rectangle
must be confined within the screen boundaries (no clipping is done).

If 'x', 'y', 'w' and 'h' are all 0, SDL_UpdateRect will update the  en‐
tire screen.

*/
// 在 surface 的 (x,y) 处截取一块 w*h 的矩形，之后在画布的 (x,y) 画出相同的矩形
void SDL_UpdateRect(SDL_Surface *s, int x, int y, int w, int h) {
  assert(s);
  if(s->format->palette == NULL && s->format->BitsPerPixel == 32) {
    if((x == 0 && y == 0 && w == 0 && h == 0) || s->flags == SDL_FULLSCREEN) {
      NDL_DrawRect((uint32_t *)s->pixels, x, y, s->w, s->h);
    }
    else {
      uint32_t *rect = (uint32_t *)malloc(w * h * sizeof(uint32_t));
      uint32_t offset = 0;
      for(int j = 0; j < h && j + y < s->h; j++) {
        for(int i = 0; i < w && i + x < s->w; i++) {
          rect[offset++] = ((uint32_t *)(s->pixels))[i + x + (j + y) * (s->w)];
        }
      }
      NDL_DrawRect(rect, x, y, w, h);
      free(rect);
    }
  }
  // 加入对仙剑的支持(palatte)
  else if(s->format->palette != NULL && s->format->BitsPerPixel == 8) {
    size_t rect_height = ((x == 0 && y == 0 && w == 0 && h == 0) || s->flags == SDL_FULLSCREEN) ? s->h : h;
    size_t rect_width = ((x == 0 && y == 0 && w == 0 && h == 0) || s->flags == SDL_FULLSCREEN) ? s->w : w;
    uint32_t *rect = (uint32_t *)malloc(rect_height * rect_width * sizeof(uint32_t));
    SDL_Color rgb_color = {0};
    uint32_t offset = 0;
    for(int j = 0; j < rect_height && j + y < s->h; j++) {
      for(int i = 0; i < rect_width && i + x < s->w; i++) {
        //palette
        rgb_color = s->format->palette->colors[s->pixels[i + x + (j + y) * (s->w)]];
        // 00RRGGBB
        rect[offset++] = rgb_color.a << 24 | rgb_color.r << 16 | rgb_color.g << 8 | rgb_color.b;
      }
    }
    NDL_DrawRect((uint32_t *)rect, x, y, w, h);
    free(rect);
  }
  else assert(0);
}

// APIs below are already implemented.

static inline int maskToShift(uint32_t mask) {
  switch (mask) {
    case 0x000000ff: return 0;
    case 0x0000ff00: return 8;
    case 0x00ff0000: return 16;
    case 0xff000000: return 24;
    case 0x00000000: return 24; // hack
    default: assert(0);
  }
}

SDL_Surface* SDL_CreateRGBSurface(uint32_t flags, int width, int height, int depth,
    uint32_t Rmask, uint32_t Gmask, uint32_t Bmask, uint32_t Amask) {
  assert(depth == 8 || depth == 32);
  SDL_Surface *s = malloc(sizeof(SDL_Surface));
  assert(s);
  s->flags = flags;
  s->format = malloc(sizeof(SDL_PixelFormat));
  assert(s->format);
  if (depth == 8) {
    s->format->palette = malloc(sizeof(SDL_Palette));
    assert(s->format->palette);
    s->format->palette->colors = malloc(sizeof(SDL_Color) * 256);
    assert(s->format->palette->colors);
    memset(s->format->palette->colors, 0, sizeof(SDL_Color) * 256);
    s->format->palette->ncolors = 256;
  } else {
    s->format->palette = NULL;
    s->format->Rmask = Rmask; s->format->Rshift = maskToShift(Rmask); s->format->Rloss = 0;
    s->format->Gmask = Gmask; s->format->Gshift = maskToShift(Gmask); s->format->Gloss = 0;
    s->format->Bmask = Bmask; s->format->Bshift = maskToShift(Bmask); s->format->Bloss = 0;
    s->format->Amask = Amask; s->format->Ashift = maskToShift(Amask); s->format->Aloss = 0;
  }

  s->format->BitsPerPixel = depth;
  s->format->BytesPerPixel = depth / 8;

  s->w = width;
  s->h = height;
  s->pitch = width * depth / 8;
  assert(s->pitch == width * s->format->BytesPerPixel);

  if (!(flags & SDL_PREALLOC)) {
    s->pixels = malloc(s->pitch * height);
    assert(s->pixels);
  }

  return s;
}

SDL_Surface* SDL_CreateRGBSurfaceFrom(void *pixels, int width, int height, int depth,
    int pitch, uint32_t Rmask, uint32_t Gmask, uint32_t Bmask, uint32_t Amask) {
  SDL_Surface *s = SDL_CreateRGBSurface(SDL_PREALLOC, width, height, depth,
      Rmask, Gmask, Bmask, Amask);
  assert(pitch == s->pitch);
  s->pixels = pixels;
  return s;
}

void SDL_FreeSurface(SDL_Surface *s) {
  if (s != NULL) {
    if (s->format != NULL) {
      if (s->format->palette != NULL) {
        if (s->format->palette->colors != NULL) free(s->format->palette->colors);
        free(s->format->palette);
      }
      free(s->format);
    }
    if (s->pixels != NULL && !(s->flags & SDL_PREALLOC)) free(s->pixels);
    free(s);
  }
}

SDL_Surface* SDL_SetVideoMode(int width, int height, int bpp, uint32_t flags) {
  if (flags & SDL_HWSURFACE) NDL_OpenCanvas(&width, &height);
  return SDL_CreateRGBSurface(flags, width, height, bpp,
      DEFAULT_RMASK, DEFAULT_GMASK, DEFAULT_BMASK, DEFAULT_AMASK);
}

void SDL_SoftStretch(SDL_Surface *src, SDL_Rect *srcrect, SDL_Surface *dst, SDL_Rect *dstrect) {
  assert(src && dst);
  assert(dst->format->BitsPerPixel == src->format->BitsPerPixel);
  assert(dst->format->BitsPerPixel == 8);

  int x = (srcrect == NULL ? 0 : srcrect->x);
  int y = (srcrect == NULL ? 0 : srcrect->y);
  int w = (srcrect == NULL ? src->w : srcrect->w);
  int h = (srcrect == NULL ? src->h : srcrect->h);

  assert(dstrect);
  if(w == dstrect->w && h == dstrect->h) {
    /* The source rectangle and the destination rectangle
     * are of the same size. If that is the case, there
     * is no need to stretch, just copy. */
    SDL_Rect rect;
    rect.x = x;
    rect.y = y;
    rect.w = w;
    rect.h = h;
    SDL_BlitSurface(src, &rect, dst, dstrect);
  }
  else {
    assert(0);
  }
}

void SDL_SetPalette(SDL_Surface *s, int flags, SDL_Color *colors, int firstcolor, int ncolors) {
  assert(s);
  assert(s->format);
  assert(s->format->palette);
  assert(firstcolor == 0);

  s->format->palette->ncolors = ncolors;
  memcpy(s->format->palette->colors, colors, sizeof(SDL_Color) * ncolors);

  if(s->flags & SDL_HWSURFACE) {
    assert(ncolors == 256);
    for (int i = 0; i < ncolors; i ++) {
      uint8_t r = colors[i].r;
      uint8_t g = colors[i].g;
      uint8_t b = colors[i].b;
    }
    SDL_UpdateRect(s, 0, 0, 0, 0);
  }
}

static void ConvertPixelsARGB_ABGR(void *dst, void *src, int len) {
  int i;
  uint8_t (*pdst)[4] = dst;
  uint8_t (*psrc)[4] = src;
  union {
    uint8_t val8[4];
    uint32_t val32;
  } tmp;
  int first = len & ~0xf;
  for (i = 0; i < first; i += 16) {
#define macro(i) \
    tmp.val32 = *((uint32_t *)psrc[i]); \
    *((uint32_t *)pdst[i]) = tmp.val32; \
    pdst[i][0] = tmp.val8[2]; \
    pdst[i][2] = tmp.val8[0];

    macro(i + 0); macro(i + 1); macro(i + 2); macro(i + 3);
    macro(i + 4); macro(i + 5); macro(i + 6); macro(i + 7);
    macro(i + 8); macro(i + 9); macro(i +10); macro(i +11);
    macro(i +12); macro(i +13); macro(i +14); macro(i +15);
  }

  for (; i < len; i ++) {
    macro(i);
  }
}

SDL_Surface *SDL_ConvertSurface(SDL_Surface *src, SDL_PixelFormat *fmt, uint32_t flags) {
  assert(src->format->BitsPerPixel == 32);
  assert(src->w * src->format->BytesPerPixel == src->pitch);
  assert(src->format->BitsPerPixel == fmt->BitsPerPixel);

  SDL_Surface* ret = SDL_CreateRGBSurface(flags, src->w, src->h, fmt->BitsPerPixel,
    fmt->Rmask, fmt->Gmask, fmt->Bmask, fmt->Amask);

  assert(fmt->Gmask == src->format->Gmask);
  assert(fmt->Amask == 0 || src->format->Amask == 0 || (fmt->Amask == src->format->Amask));
  ConvertPixelsARGB_ABGR(ret->pixels, src->pixels, src->w * src->h);

  return ret;
}

uint32_t SDL_MapRGBA(SDL_PixelFormat *fmt, uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
  assert(fmt->BytesPerPixel == 4);
  uint32_t p = (r << fmt->Rshift) | (g << fmt->Gshift) | (b << fmt->Bshift);
  if (fmt->Amask) p |= (a << fmt->Ashift);
  return p;
}

int SDL_LockSurface(SDL_Surface *s) {
  return 0;
}

void SDL_UnlockSurface(SDL_Surface *s) {
}
