/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-21 17:28:20 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-21 17:56:00
 */


#include <am.h>
#include <ysyxsoc.h>
#include <klib.h>

// 二级加载
void ssbt() {
    // copy user's code

    // jump to the entry
    _trm_init();
}

