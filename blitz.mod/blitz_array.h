
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

extern		BBClass bbArrayClass;
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

void bbArrayCopy(BBArray * srcArr, int srcPos, BBArray * dstArr, int dstPos, int length);

int bbObjectIsEmptyArray(BBObject * o);

#ifdef __cplusplus
}
#endif

#endif


