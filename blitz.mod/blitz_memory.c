
#include "blitz.h"

#define SIZEALIGN 16
#define ALIGNMASK (SIZEALIGN-1)

/* use malloc/free() in Debug mode, otherwise use the GC heap */
void *bbMemAlloc( size_t size ){
	void *p;
#ifdef BMX_DEBUG
	p=malloc( size );
#else
	p=GC_MALLOC_ATOMIC_UNCOLLECTABLE( size );
	#ifdef BBCC_ALLOCCOUNT
	++bbGCAllocCount;
	#endif
#endif
	return p;
	
}

void bbMemFree( void *p ){
#ifdef BMX_DEBUG
	if ( p ) free(p);
#else
	if( p ) GC_free( p );
#endif
}

void *bbMemExtend( void *mem,size_t size,size_t new_size ){
	void *p;
	p=bbMemAlloc( new_size );
	if (mem) {
		bbMemCopy( p,mem,size );
		bbMemFree( mem );
	}
	return p;
}

void bbMemClear( void *dst,size_t size ){
	memset( dst,0,size );
}

void bbMemCopy( void *dst,const void *src,size_t size ){
	memcpy( dst,src,size );
}

void bbMemMove( void *dst,const void *src,size_t size ){
	memmove( dst,src,size );
}

void bbMemDump(void * mem, int size) {
    unsigned int i;
    const unsigned char * const px = (unsigned char*)mem;
    for (i = 0; i < size; ++i) {
        if( i % (sizeof(int) * 8) == 0){
            printf("\n%08x ", i);
        }
        else if( i % 4 == 0){
            printf(" ");
        }
        printf("%02x", px[i]);
    }

    printf("\n");
}
