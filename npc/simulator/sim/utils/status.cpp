/*
 * @Author: Juqi Li @ NJU 
 * @Date: 2024-01-17 21:47:12 
 * @Last Modified by: Juqi Li @ NJU
 * @Last Modified time: 2024-01-17 22:01:17
 */

#include <common.h>
#include <sim.h>
#include <debug.h>

bool is_exit_status_bad() {
    bool good = (sim_state.state == SIM_END && sim_state.halt_ret == 0) ||
    (sim_state.state == SIM_QUIT);
    if(good) 
        printf(ANSI_FG_GREEN "simulator exit!\n" ANSI_NONE);
    else
        printf(ANSI_FG_RED "simulator exit!\n" ANSI_NONE);
    return !good;
}

