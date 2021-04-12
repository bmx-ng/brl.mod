
#ifndef BLITZ_EX_H
#define BLITZ_EX_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#if __APPLE__
#if __i386__
#define BB_ARGP 1
void*	bbArgp( int offset );
#endif
#endif

#ifdef __MINGW64__
typedef intptr_t BBExJmpBuf[5];
#else
typedef jmp_buf BBExJmpBuf;
#endif

// bbExTry can't be a function due to how setjmp works, so a macro it is
#ifdef __MINGW64__
#define bbExTry \
	BBExJmpBuf* buf = bbExEnter(); \
	int jmp_status = 0; \
	if(__builtin_setjmp(*buf)) jmp_status = bbExStatus(); \
	switch(jmp_status)
#elif __APPLE__
#define bbExTry \
	BBExJmpBuf* buf = bbExEnter(); \
	switch(_setjmp(*buf))
#else
#define bbExTry \
	BBExJmpBuf* buf = bbExEnter(); \
	switch(setjmp(*buf))
#endif
BBExJmpBuf* bbExEnter();
void        bbExThrow( BBObject *p );
void        bbExThrowCString( const char *p );
void        bbExLeave();
int         bbExStatus();
BBObject*   bbExCatchAndReenter();
BBObject*   bbExCatch();

//void	_bbExEnter( void *_cpu_state );
//void*	_bbExThrow( void *_cpu_state,void *p );

#ifdef __cplusplus
}
#endif

#endif
