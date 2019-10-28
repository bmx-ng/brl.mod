
#ifndef BLITZ_MEMORY_H
#define BLITZ_MEMORY_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

void*	bbMemAlloc( size_t );
void		bbMemFree( void *mem );
void*	bbMemExtend( void *mem,size_t size,size_t new_size );

void		bbMemClear( void *dst,size_t size );
void		bbMemCopy( void *dst,const void *src,size_t size );
void		bbMemMove( void *dst,const void *src,size_t size );

#ifdef _WIN32
#include <malloc.h>
#define bbStackAlloc _malloca
#else
#include <alloca.h>
#define bbStackAlloc alloca
#endif

#ifdef __cplusplus
}
#endif

#endif
