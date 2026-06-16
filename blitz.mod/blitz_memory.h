
#ifndef BLITZ_MEMORY_H
#define BLITZ_MEMORY_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

void *bbMemAllocCollectable(size_t size);
void bbMemFreeCollectable( void *mem );
void *bbMemExtendCollectable( void *mem,size_t size,size_t new_size );
void*	bbMemAlloc( size_t );
void		bbMemFree( void *mem );
void*	bbMemExtend( void *mem,size_t size,size_t new_size );

void		bbMemClear( void *dst,size_t size );
void		bbMemCopy( void *dst,const void *src,size_t size );
void		bbMemMove( void *dst,const void *src,size_t size );

void bbMemDump(void * mem, int size);


#if defined(__MINGW32__) || defined(__MINGW64__)
#define BB_TARGET_MINGW
#endif

#if defined(_MSC_VER)
#ifndef __clang__
#define BB_TARGET_MSVC
#endif
#endif

#if defined(__clang__)
#define BB_TARGET_CLANG
#endif

#if defined(__GNUC__)
#define BB_TARGET_GNU
#endif

#ifdef __cplusplus
#define bbAlignOf(T) static_cast<size_t>(alignof(T))
#elif defined(BB_TARGET_MSVC)
#define bbAlignOf(T) (size_t)__alignof(T)
#elif defined(BB_TARGET_GNU)
#define bbAlignOf(T) (size_t)__alignof__(T)
#elif defined(BB_TARGET_CLANG)
#define bbAlignOf(T) (size_t)__alignof__(T)
#else
#define bbAlignOf(T) ((size_t)&((struct { char c; T d; } *)0)->d)
#endif

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
