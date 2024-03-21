/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-03-21 17:34:36 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-03-21 19:06:18
 */

#include <am.h>
#include <ysyxsoc.h>
#include <klib.h>

// 一级加载
void fsbt() {
    // copy ssbt's code to sdram
    
    // jump to sdram to excute ssbt
    ssbt();
}

