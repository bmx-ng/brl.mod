
#include "blitz.h"

#define SIZEALIGN 16
#define ALIGNMASK (SIZEALIGN-1)

void *bbMemAllocCollectable(size_t size) {
    void * p = GC_malloc_atomic(size);
    return p;
}

void bbMemFreeCollectable(void *p) {
    GC_free(p);
}

void *bbMemExtendCollectable( void *mem,size_t size,size_t new_size ){
    void *p = bbMemAllocCollectable(new_size);
    if (mem) {
        bbMemCopy(p, mem, size);
        bbMemFreeCollectable(mem);
    }
    return p;
}

void *bbMemAlloc(size_t size) {
    size_t totalSize = size + SIZEALIGN - 1 + sizeof(void*);
    void *p = malloc(totalSize);
    if (!p) {
        GC_gcollect();
        p = malloc(totalSize);
        if (!p) return NULL;
    }
    
    uintptr_t rawAddr = (uintptr_t)p + sizeof(void*);
    uintptr_t alignedAddr = (rawAddr + SIZEALIGN - 1) & ~(uintptr_t)ALIGNMASK;
    
    // Store the original pointer just before the aligned memory.
    ((void**)alignedAddr)[-1] = p;
    return (void*)alignedAddr;
}

void bbMemFree(void *p) {
    if (p) {
        // Get the original pointer stored before the aligned block and free it.
        void *original = ((void**)p)[-1];
        free(original);
    }
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
