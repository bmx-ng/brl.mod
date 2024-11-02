
#ifndef BLITZ_ARRAY_H
#define BLITZ_ARRAY_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBNULLARRAY (&bbEmptyArray)

#define BBARRAYSIZE(q,n) (((offsetof(BBArray, scales) + n * sizeof(int)+0x0f) & ~0x0f)+(q))
//#define BBARRAYDATA(p,n) ((void*)((char*)(p)+((offsetof(BBArray, scales) + n * sizeof(int)+0x0f) & ~0x0f)))
#define BBARRAYDATA(p,n) ((void*)((char*)(p)+((BBArray*)(p))->data_start))
#define BBARRAYDATAINDEX(p,n,i) bbArrayIndex(p,n,i)

#define BBARRAYNEW1DSTRUCT_FUNC(FUNC_SUFFIX, STRUCT_TYPE, CONSTRUCTOR_FUNC, TYPE_STRING) \
BBArray *bbArrayNew1DStruct_##FUNC_SUFFIX(int length) { \
    BBArray *arr = bbAllocateArray(TYPE_STRING, 1, &length, sizeof(struct STRUCT_TYPE)); \
    if (!arr->size) return arr; \
    struct STRUCT_TYPE *p = (struct STRUCT_TYPE *)(BBARRAYDATA(arr, arr->dims)); \
    memset(p, 0, arr->size); \
    struct STRUCT_TYPE *s = p; \
    for (int k = arr->scales[0]; k > 0; --k) { \
        CONSTRUCTOR_FUNC(s); \
        s++; \
    } \
    return arr; \
}

#define BBARRAYSLICESTRUCT_FUNC(FUNC_SUFFIX, STRUCT_TYPE, CONSTRUCTOR_FUNC, TYPE_STRING) \
BBArray *bbArraySliceStruct_##FUNC_SUFFIX(BBArray *inarr, int beg, int end) { \
    int k; \
    int length = end - beg; \
    if (length <= 0) return &bbEmptyArray; \
    BBArray *arr = bbAllocateArray(TYPE_STRING, 1, &length, sizeof(struct STRUCT_TYPE)); \
    int el_size = sizeof(struct STRUCT_TYPE); \
    struct STRUCT_TYPE *p = (struct STRUCT_TYPE *)BBARRAYDATA(arr, 1); \
    int n = -beg; \
    if (n > 0) { \
        if (beg + n > end) n = end - beg; \
        memset(p, 0, n * el_size); \
        struct STRUCT_TYPE *s = p; \
        for (k = 0; k < n; ++k) { \
            CONSTRUCTOR_FUNC(s); \
            s++; \
        } \
        p += n; \
        beg += n; \
        if (beg == end) return arr; \
    } \
    n = inarr->scales[0] - beg; \
    if (n > 0) { \
        if (beg + n > end) n = end - beg; \
        memcpy(p, (struct STRUCT_TYPE *)BBARRAYDATA(inarr, inarr->dims) + beg, n * el_size); \
        p += n; \
        beg += n; \
        if (beg == end) return arr; \
    } \
    n = end - beg; \
    if (n > 0) { \
        memset(p, 0, n * el_size); \
        struct STRUCT_TYPE *s = p; \
        for (k = 0; k < n; ++k) { \
            CONSTRUCTOR_FUNC(s); \
            s++; \
        } \
    } \
    return arr; \
}

struct BBArray{
	//extends BBObject
	BBClass*        clas;

	const char*     type;       //
	unsigned int    dims;       //
	unsigned int    size;       // total size minus this header
	unsigned short  data_size;  // size of data element
	unsigned short  data_start; // start offset of data
	int    scales[1];  // [dims]
};

struct BBClass_Array{
	//extends BBGCPool
	BBClass*	super;
	void		(*free)( BBObject *o );
	
	BBDebugScope*debug_scope;

	unsigned int instance_size;

	void		(*ctor)( BBObject *o );
	void		(*dtor)( BBObject *o );
	
	BBString*	(*ToString)( BBObject *x );
	int		(*Compare)( BBObject *x,BBObject *y );
	BBObject*	(*SendMessage)( BBObject * o, BBObject *m,BBObject *s );

	BBINTERFACETABLE itable;
	void*   extra;
	unsigned int obj_size;
	unsigned int instance_count;
	unsigned int fields_offset;

	void (*bbArraySort)( BBArray *arr,int ascending );
	BBArray* (*bbArrayDimensions)( BBArray *arr );
};

extern	struct BBClass_Array bbArrayClass;
extern		BBArray bbEmptyArray;

BBArray*	bbArrayNew( const char *type,int dims,... );
BBArray*	bbArrayNew1D( const char *type,int length );
BBArray*	bbArrayNewEx( const char *type,int dims,int *lens );	//alternate version of New...

BBArray*	bbArraySlice( const char *type,BBArray *arr,int beg,int end );
BBArray*	bbArrayFromData( const char *type,int length,void *data );
BBArray*	bbArrayCastFromObject( BBObject *o,const char *type_encoding );

void		bbArraySort( BBArray *arr,int ascending );

BBArray*	bbArrayDimensions( BBArray *arr );

BBArray*	bbArrayConcat( const char *type,BBArray *x,BBArray *y );

void*	bbArrayIndex( BBArray *, int, int );

typedef void (*BBArrayStructInit)(void * ref);

BBArray*	bbArrayNew1DStruct( const char *type,int length, unsigned short data_size, BBArrayStructInit init );
BBArray*	bbArrayNewStruct( const char *type,unsigned short data_size, BBArrayStructInit init, int dims, ... );
BBArray*	bbArrayFromDataStruct( const char *type,int length,void *data, unsigned short data_size );
BBArray*	bbArraySliceStruct( const char *type,BBArray *inarr,int beg,int end, unsigned short data_size, BBArrayStructInit structInit );
BBArray*	bbArrayFromDataSize( const char *type,int length,void *data, unsigned short data_size );
BBArray*	bbArrayNew1DNoInit( const char *type,int length );

void bbArrayCopy(BBArray * srcArr, int srcPos, BBArray * dstArr, int dstPos, int length);

int bbObjectIsEmptyArray(BBObject * o);

BBArray *bbAllocateArray( const char *type,int dims,int *lens, unsigned short data_size );

#ifdef __cplusplus
}
#endif

#endif


