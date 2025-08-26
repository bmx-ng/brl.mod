
#ifndef BLITZ_ATSTART_H
#define BLITZ_ATSTART_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*bb_startup_fn)(void);

int  bbAtstart(bb_startup_fn fn, int priority); /* returns 1 on success */
void bbRunAtstart(void); /* run once, highest priority first */

#ifdef __cplusplus
}
#endif

#endif
