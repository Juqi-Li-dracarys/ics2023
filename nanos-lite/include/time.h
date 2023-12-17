#ifndef _TIME_H_
#define _TIME_H_

#include <common.h>

#ifndef __kernel_long_t
typedef uint64_t 	__kernel_long_t;
#endif

#ifndef __kernel_suseconds_t
typedef __kernel_long_t		__kernel_suseconds_t;
#endif

#ifndef __kernel_old_time_t
typedef __kernel_long_t	 	__kernel_old_time_t;
#endif

#ifndef timeval
typedef struct eval {
	__kernel_old_time_t	    tv_sec;		/* seconds */
	__kernel_suseconds_t	tv_usec;	/* microseconds */
} timeval;
#endif

#ifndef timezone
typedef struct zone {
	int	tz_minuteswest; /* minutes west of Greenwich */
	int	tz_dsttime;	    /* type of dst correction */
} timezone;
#endif

#endif
