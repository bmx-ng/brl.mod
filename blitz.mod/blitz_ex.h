
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

jmp_buf*	bbExEnter();
void		bbExThrow( BBObject *p );
void		bbExThrowCString( const char *p );
void		bbExLeave();
BBObject*   bbExObject();

BBObject* bbExCatchAndReenter();
BBObject* bbExCatch();

//void	_bbExEnter( void *_cpu_state );
//void*	_bbExThrow( void *_cpu_state,void *p );

#ifdef __cplusplus
}
#endif

#endif
