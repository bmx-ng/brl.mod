
#include "blitz.h"

#include <stdarg.h>

static void bbArrayFree( BBObject *o );

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"Array",
	BBDEBUGDECL_END
};

BBClass bbArrayClass={
	&bbObjectClass, //extends
	bbArrayFree,	//free
	&debugScope,	//DebugScope
	0,			//instance_size
	0,			//ctor
	0,			//dtor
	
	bbObjectToString,
	bbObjectCompare,
	bbObjectSendMessage,
	0,          //interface
	0,          //extra
	0,          //obj_size
	0,          //instance_count
	offsetof(BBArray, type), //fields_offset
	
	bbArraySort,
	bbArrayDimensions
};

BBArray bbEmptyArray={
	&bbArrayClass,	//clas
	//BBGC_MANYREFS,	//refs
	"",			//type
	0,			//dims
	0,			//size
	0,			//data_size
	0,			//data_start
	0			//scales[0]
};

//***** Note: Only used by ref counting GC.
static void bbArrayFree( BBObject *o ){
	if (bbCountInstances) {
		bbAtomicAdd(&bbArrayClass.instance_count, -1);
	}
}

static int arrayCellSize(const char * type, unsigned short data_size, int * flags) {
	int size = 4;
	
	switch( type[0] ){
		case 'b':size=1;break;
		case 's':size=2;break;
		case 'l':size=8;break;
		case 'y':size=8;break;
		case 'd':size=8;break;
		case '*':size=sizeof(void*);break;
		case ':':size=sizeof(void*);*flags=0;break;
		case '$':size=sizeof(void*);*flags=0;break;
		case '[':size=sizeof(void*);*flags=0;break;
		case '(':size=sizeof(void*);break;
		case 'z':size=sizeof(BBSIZET);break;
		#ifdef _WIN32
		case 'w':size=sizeof(WPARAM);break;
		case 'x':size=sizeof(LPARAM);break;
		#endif
		#ifdef __x86_64__
		case 'h':size=sizeof(BBFLOAT64);break;
		case 'j':size=sizeof(BBINT128);break;
		case 'k':size=sizeof(BBFLOAT128);break;
		case 'm':size=sizeof(BBDOUBLE128);break;
		#endif
		case '@':size=data_size;*flags=0;break; // structs
		case '/':size=data_size;break; // enums
	}

	return size;
}

static BBArray *allocateArray( const char *type,int dims,int *lens, unsigned short data_size ){
	int k,*len;
	int size=4;
	int length=1;
	int flags=BBGC_ATOMIC;
	BBArray *arr;
	
	len=lens;
	for( k=0;k<dims;++k ){
		int n=*len++;
		if( n<=0 ) return &bbEmptyArray;
		length*=n;
	}
	
	size = arrayCellSize(type, data_size, &flags);
	int base_size = size;
	size*=length;

	arr=(BBArray*)bbGCAllocObject( BBARRAYSIZE(size,dims),&bbArrayClass,flags );

	arr->type=type;
	arr->dims=dims;
	arr->size=size;
	arr->data_size = base_size;
	arr->data_start = (offsetof(BBArray, scales) + dims * sizeof(int)+0x0f) & ~0x0f; // 16-byte aligned
	
	len=lens;
	for( k=0;k<dims;++k ) arr->scales[k]=*len++;
	for( k=dims-2;k>=0;--k ) arr->scales[k]*=arr->scales[k+1];
		
	return arr;
}

static void *arrayInitializer( BBArray *arr ){
	switch( arr->type[0] ){
	case ':':return &bbNullObject;
	case '$':return &bbEmptyString;
	case '[':return &bbEmptyArray;
	case '(':return &brl_blitz_NullFunctionError;
	}
	return 0;
}

static void initializeArray( BBArray *arr, BBArrayStructInit structInit ){
	void *init,**p;
	
	if( !arr->size ) return;
	
	init=arrayInitializer( arr );
	p=(void**)(BBARRAYDATA( arr,arr->dims ));

	if( init ){
		int k;
		for( k=arr->scales[0];k>0;--k ) *p++=init;
	}else{
		memset( p,0,arr->size );
		if (structInit) {
			int k;
			char * s = (char*)p;
			for( k=arr->scales[0];k>0;--k ) {
				structInit(s);
				s += arr->data_size;
			}
		}
	}
}

BBArray *bbArrayNew( const char *type,int dims,... ){

	int lens[256];

	va_list lengths;
	
	va_start(lengths, dims);
	
	int i;
	for (i = 0; i < dims; i++) {
		lens[i] = va_arg(lengths, int);
	}
	va_end(lengths);

	BBArray *arr=allocateArray( type,dims, lens, 0 );
	
	initializeArray( arr, 0 );
	
	return arr;
}

BBArray *bbArrayNewStruct( const char *type, unsigned short data_size, BBArrayStructInit init, int dims, ... ){

	int lens[256];

	va_list lengths;
	
	va_start(lengths, dims);
	
	int i;
	for (i = 0; i < dims; i++) {
		lens[i] = va_arg(lengths, int);
	}
	va_end(lengths);

	BBArray *arr=allocateArray( type,dims, lens, data_size );
	
	initializeArray( arr, init );
	
	return arr;
}

BBArray *bbArrayNewEx( const char *type,int dims,int *lens ){

	BBArray *arr=allocateArray( type,dims,lens,0 );
	
	initializeArray( arr, 0 );
	
	return arr;
}

BBArray *bbArrayNew1D( const char *type,int length ){

	BBArray *arr=allocateArray( type,1,&length, 0 );
	
	initializeArray( arr, 0 );
	
	return arr;
}

BBArray *bbArrayNew1DStruct( const char *type,int length, unsigned short data_size, BBArrayStructInit init ){

	BBArray *arr=allocateArray( type,1,&length, data_size );
	
	initializeArray( arr, init );
	
	return arr;
}

BBArray *bbArraySlice( const char *type,BBArray *inarr,int beg,int end ){
	return bbArraySliceStruct(type, inarr, beg, end, 0, 0);
}

BBArray *bbArraySliceStruct( const char *type,BBArray *inarr,int beg,int end, unsigned short data_size, BBArrayStructInit structInit ){
	char *p;
	void *init;
	BBArray *arr;
	int n,k,el_size;
	int length=end-beg;

	if( length<=0 ) return &bbEmptyArray;
	
	arr=allocateArray( type,1,&length,data_size );

	el_size=arr->size/length;
	
	init=arrayInitializer( arr );
	p=(char*)BBARRAYDATA( arr,1 );
	
	n=-beg;
	if( n>0 ){
		if( beg+n>end ) n=end-beg;
		if( init ){
			void **dst=(void**)p;
			for( k=0;k<n;++k ) *dst++=init;
			p=(char*)dst;
		}else{
			memset( p,0,n*el_size );
			if (structInit) {
				char * s = (char*)p;
				for( k=0;k<n;++k ) {
					structInit(s);
					s += arr->data_size;
				}
			}
			p+=n*el_size;
		}
		beg+=n;
		if( beg==end ) return arr;
	}
	n=inarr->scales[0]-beg;
	if( n>0 ){
		if( beg+n>end ) n=end-beg;

		memcpy( p,(char*)BBARRAYDATA(inarr,inarr->dims)+beg*el_size,n*el_size );
		p+=n*el_size;

		beg+=n;
		if( beg==end ) return arr;
	}
	n=end-beg;
	if( n>0 ){
		if( init ){
			void **dst=(void**)p;
			for( k=0;k<n;++k ) *dst++=init;
		}else{
			memset( p,0,n*el_size );
			if (structInit) {
				char * s = (char*)p;
				for( k=0;k<n;++k ) {
					structInit(s);
					s += arr->data_size;
				}
			}
		}
	}
	return arr;
}

void bbArrayCopy(BBArray * srcArr, int srcPos, BBArray * dstArr, int dstPos, int length) {

	if (srcPos < 0 || dstPos < 0 || length <= 0) {
		return;
	}
	
	if (strcmp(srcArr->type, dstArr->type)) {
		brl_blitz_RuntimeError(bbStringFromCString("Incompatible array element types for copy"));
	}
	
	if (srcPos + length > srcArr->scales[0]) {
		brl_blitz_ArrayBoundsError();
	}

	if (dstPos + length > dstArr->scales[0]) {
		brl_blitz_ArrayBoundsError();
	}
	
	int flags = 0;
	int size = arrayCellSize(srcArr->type, srcArr->data_size, &flags);
	
	char * src = (char*)BBARRAYDATA(srcArr, 1) + srcPos * size;
	char * dst = (char*)BBARRAYDATA(dstArr, 1) + dstPos * size;
	
	memmove(dst, src, length * size);
}

BBArray *bbArrayConcat( const char *type,BBArray *x,BBArray *y ){

	BBArray *arr;
	char *data;
	int length=x->scales[0]+y->scales[0];
	
	if( length<=0 ) return &bbEmptyArray;
	
	int data_size = x->data_size != 0 ? x->data_size : y->data_size;

	// both arrays are empty?
	if (data_size == 0) return &bbEmptyArray;

	if (x->data_size > 0 && y->data_size > 0 && x->data_size != y->data_size) {
		brl_blitz_RuntimeError(bbStringFromCString("Incompatible array element types for concatenation"));
	}

	arr=allocateArray( type,1,&length, data_size );
	
	data=(char*)BBARRAYDATA( arr,1 );
	
	memcpy( data,BBARRAYDATA( x,1 ),x->size );
	memcpy( data+x->size,BBARRAYDATA( y,1 ),y->size );
	
	return arr;
}

BBArray *bbArrayFromData( const char *type,int length,void *data ){

	int k;
	BBArray *arr;

	if( length<=0 ) return &bbEmptyArray;
	
	arr=allocateArray( type,1,&length,0 );

	memcpy( BBARRAYDATA( arr,1 ),data,arr->size );

	return arr;
}

BBArray *bbArrayFromDataStruct( const char *type,int length,void *data, unsigned short data_size ){

	int k;
	BBArray *arr;

	if( length<=0 ) return &bbEmptyArray;
	
	arr=allocateArray( type,1,&length, data_size );

	memcpy( BBARRAYDATA( arr,1 ),data,arr->size );

	return arr;
}

BBArray *bbArrayDimensions( BBArray *arr ){
	int *p,i,n;
	BBArray *dims;

	if( !arr->scales[0] ) return &bbEmptyArray;
	
	n=arr->dims;
	dims=bbArrayNew1D( "i",n );
	p=(int*)BBARRAYDATA( dims,1 );

	for( i=0;i<n-1;++i ){
		p[i]=arr->scales[i]/arr->scales[i+1];
	}
	p[i]=arr->scales[i];
	
	return dims;
}

void * bbArrayIndex( BBArray * arr, int offset, int index) {
	if (index < 0 || index >= arr->scales[0]) brl_blitz_ArrayBoundsError();
	return BBARRAYDATA(arr, offset);
}

BBArray *bbArrayCastFromObject( BBObject *o,const char *type ){
	BBArray *arr=(BBArray*)o;
	if( arr==&bbEmptyArray ) return arr;
	if( arr->clas!=&bbArrayClass ) return &bbEmptyArray;
	if( arr->type[0]==':' && type[0]==':' ) return arr;
	if( strcmp( arr->type,type ) ) return &bbEmptyArray;
	return arr;
}

#define SWAP(X,Y) {t=*(X);*(X)=*(Y);*(Y)=t;}
#define QSORTARRAY( TYPE,IDENT )\
static void IDENT( TYPE *lo,TYPE *hi ){\
	TYPE t;\
	TYPE *i;\
	TYPE *x;\
	TYPE *y;\
	if( hi<=lo ) return;\
	if( lo+1==hi ){\
		if( LESSTHAN(hi,lo) ) SWAP(lo,hi);\
		return;\
	}\
	i=(hi-lo)/2+lo;\
	if( LESSTHAN(i,lo) ) SWAP(i,lo);\
	if( LESSTHAN(hi,i) ){\
		SWAP(i,hi);\
		if( LESSTHAN(i,lo) ) SWAP(i,lo);\
	}\
	x=lo+1;\
	y=hi-1;\
	do{\
		while( LESSTHAN(x,i) ) ++x;\
		while( LESSTHAN(i,y) ) --y;\
		if( x>y ) break;\
		if( x<y ){\
			SWAP(x,y);\
			if( i==x ) i=y;\
			else if( i==y ) i=x;\
		}\
		++x;\
		--y;\
	}while( x<=y );\
	IDENT(lo,y);\
	IDENT(x,hi);\
}

#undef LESSTHAN
#define LESSTHAN(X,Y) (*(X)<*(Y))
QSORTARRAY( unsigned char,_qsort_b )
QSORTARRAY( unsigned short,_qsort_s )
QSORTARRAY( int,qsort_i )
QSORTARRAY( unsigned int,qsort_u )
QSORTARRAY( BBInt64,qsort_l );
QSORTARRAY( BBUInt64,qsort_y );
QSORTARRAY( float,qsort_f );
QSORTARRAY( double,qsort_d );
QSORTARRAY( BBSIZET,qsort_z );
#ifdef _WIN32
QSORTARRAY( WPARAM,qsort_w );
QSORTARRAY( LPARAM,qsort_x );
#endif
#undef LESSTHAN
#define LESSTHAN(X,Y) ((*X)->clas->Compare(*(X),*(Y))<0)
QSORTARRAY( BBObject*,qsort_obj );
#undef LESSTHAN
#define LESSTHAN(X,Y) (*(X)>*(Y))
QSORTARRAY( unsigned char,qsort_b_d )
QSORTARRAY( unsigned short,qsort_s_d )
QSORTARRAY( int,qsort_i_d )
QSORTARRAY( unsigned int,qsort_u_d )
QSORTARRAY( BBInt64,qsort_l_d );
QSORTARRAY( BBUInt64,qsort_y_d );
QSORTARRAY( float,qsort_f_d );
QSORTARRAY( double,qsort_d_d );
QSORTARRAY( BBSIZET,qsort_z_d );
#ifdef _WIN32
QSORTARRAY( WPARAM,qsort_w_d );
QSORTARRAY( LPARAM,qsort_x_d );
#endif
#undef LESSTHAN
#define LESSTHAN(X,Y) ((*X)->clas->Compare(*(X),*(Y))>0)
QSORTARRAY( BBObject*,qsort_obj_d );

void bbArraySort( BBArray *arr,int ascending ){
	int n;
	void *p;
	n=arr->scales[0]-1;
	if( n<=0 ) return;
	p=BBARRAYDATA(arr,arr->dims);
	if( ascending ){
		switch( arr->type[0] ){
		case 'b':_qsort_b( (unsigned char*)p,(unsigned char*)p+n );break;
		case 's':_qsort_s( (unsigned short*)p,(unsigned short*)p+n );break;
		case 'i':qsort_i( (int*)p,(int*)p+n );break;
		case 'u':qsort_u( (unsigned int*)p,(unsigned int*)p+n );break;
		case 'l':qsort_l( (BBInt64*)p,(BBInt64*)p+n );break;
		case 'y':qsort_y( (BBUInt64*)p,(BBUInt64*)p+n );break;
		case 'f':qsort_f( (float*)p,(float*)p+n );break;
		case 'd':qsort_d( (double*)p,(double*)p+n );break;
		case '$':case ':':qsort_obj( (BBObject**)p,(BBObject**)p+n );break;
		case 'z':qsort_z( (BBSIZET*)p,(BBSIZET*)p+n );break;
#ifdef _WIN32
		case 'w':qsort_w( (WPARAM*)p,(WPARAM*)p+n );break;
		case 'x':qsort_x( (LPARAM*)p,(LPARAM*)p+n );break;
#endif
		}
	}else{
		switch( arr->type[0] ){
		case 'b':qsort_b_d( (unsigned char*)p,(unsigned char*)p+n );break;
		case 's':qsort_s_d( (unsigned short*)p,(unsigned short*)p+n );break;
		case 'i':qsort_i_d( (int*)p,(int*)p+n );break;
		case 'u':qsort_u_d( (unsigned int*)p,(unsigned int*)p+n );break;
		case 'l':qsort_l_d( (BBInt64*)p,(BBInt64*)p+n );break;
		case 'y':qsort_y_d( (BBUInt64*)p,(BBUInt64*)p+n );break;
		case 'f':qsort_f_d( (float*)p,(float*)p+n );break;
		case 'd':qsort_d_d( (double*)p,(double*)p+n );break;
		case '$':case ':':qsort_obj_d( (BBObject**)p,(BBObject**)p+n );break;
		case 'z':qsort_z_d( (BBSIZET*)p,(BBSIZET*)p+n );break;
#ifdef _WIN32
		case 'w':qsort_w_d( (WPARAM*)p,(WPARAM*)p+n );break;
		case 'x':qsort_x_d( (LPARAM*)p,(LPARAM*)p+n );break;
#endif
		}
	}
}

int bbObjectIsEmptyArray(BBObject * o) {
	return (BBArray*)o == &bbEmptyArray;
}
