
#ifndef BLITZ_STRING_H
#define BLITZ_STRING_H

#include "blitz_types.h"

#define XXH_STATIC_LINKING_ONLY
#include "hash/xxhash.h"

#ifdef __cplusplus
extern "C"{
#endif

#define BBNULLSTRING (&bbEmptyString)

struct BBString{
	BBClass*	clas;
	BBULONG hash;
	int		length;
	BBChar	buf[];
};

struct BBClass_String{
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

	int (*bbStringFind)( BBString *x,BBString *y,int i );
	int (*bbStringFindLast)( BBString *x,BBString *y,int i );
	BBString* (*bbStringTrim)( BBString *str );
	BBString* (*bbStringReplace)( BBString *str,BBString *sub,BBString *rep );

	BBString* (*bbStringToLower)( BBString *str );
	BBString* (*bbStringToUpper)( BBString *str );

	int (*bbStringToInt)( BBString *t );
	BBInt64 (*bbStringToLong)( BBString *t );
	float (*bbStringToFloat)( BBString *t );
	double (*bbStringToDouble)( BBString *t );
	unsigned char* (*bbStringToCString)( BBString *str );
	BBChar* (*bbStringToWString)( BBString *str );

	BBString* (*bbStringFromInt)( int n );
	BBString* (*bbStringFromLong)( BBInt64 n );
	BBString* (*bbStringFromFloat)( float n );
	BBString* (*bbStringFromDouble)( double n );
	BBString* (*bbStringFromCString)( const char *p );
	BBString* (*bbStringFromWString)( const BBChar *p );

	BBString* (*bbStringFromBytes)( const unsigned char *p,int n );
	BBString* (*bbStringFromShorts)( const unsigned short *p,int n );

	int (*bbStringStartsWith)( BBString *x,BBString *y );
	int (*bbStringEndsWith)( BBString *x,BBString *y );
	int (*bbStringContains)( BBString *x,BBString *y );

	BBArray* (*bbStringSplit)( BBString *str,BBString *sep );
	BBString* (*bbStringJoin)( BBString *sep,BBArray *bits );

	BBString* (*bbStringFromUTF8String)( const unsigned char *p );
	unsigned char* (*bbStringToUTF8String)( BBString *str );
	BBString* (*bbStringFromUTF8Bytes)( const unsigned char *p,int n );

	BBSIZET (*bbStringToSizet)( BBString *t );
	BBString* (*bbStringFromSizet)( BBSIZET n );

	unsigned int (*bbStringToUInt)( BBString *t );
	BBString* (*bbStringFromUInt)( unsigned int n );
	BBUInt64 (*bbStringToULong)( BBString *t );
	BBString* (*bbStringFromULong)( BBUInt64 n );

#ifdef _WIN32
	WPARAM (*bbStringToWParam)( BBString *t );
	BBString* (*bbStringFromWParam)( WPARAM n );
	LPARAM (*bbStringToLParam)( BBString *t );
	BBString* (*bbStringFromLParam)( LPARAM n );
#endif

	unsigned char* (*bbStringToUTF8StringBuffer)( BBString *str, unsigned char * buf, size_t * length );
	BBULONG (*bbStringHash)( BBString * x );
};

extern	struct BBClass_String bbStringClass;
extern	BBString bbEmptyString;

BBString*bbStringNew( int len );
BBString*bbStringFromChar( int c );

BBString* bbStringFromInt( int n );
BBString* bbStringFromUInt( unsigned int n );
BBString*	bbStringFromLong( BBInt64 n );
BBString*	bbStringFromULong( BBUInt64 n );
BBString*	bbStringFromSizet( BBSIZET n );
BBString*bbStringFromFloat( float n );
BBString*	bbStringFromDouble( double n );
BBString*	bbStringFromBytes( const unsigned char *p,int n );
BBString*	bbStringFromShorts( const unsigned short *p,int n );
BBString*	bbStringFromInts( const int *p,int n );
BBString*	bbStringFromUInts( const unsigned int *p,int n );
BBString*bbStringFromArray( BBArray *arr );
BBString*	bbStringFromCString( const char *p );
BBString*bbStringFromWString( const BBChar *p );
BBString*bbStringFromUTF8String( const unsigned char *p );
BBString *bbStringFromUTF8Bytes( const unsigned char *p,int n );

BBString*	bbStringToString( BBString *t );
int		bbStringCompare( BBString *x,BBString *y );
int		bbStringStartsWith( BBString *x,BBString *y );
int		bbStringEndsWith( BBString *x,BBString *y );
int		bbStringContains( BBString *x,BBString *y );

BBString*bbStringConcat( BBString *x,BBString *y );

BBString*	bbStringTrim( BBString *t );
BBString*	bbStringSlice( BBString *t,int beg,int end );
BBString*	bbStringReplace( BBString *str,BBString *sub,BBString *rep );

int		bbStringAsc( BBString *t );
int		bbStringFind( BBString *x,BBString *y,int i );
int		bbStringFindLast( BBString *x,BBString *y,int i );
BBString*	bbStringToLower( BBString *str );
BBString*	bbStringToUpper( BBString *str );

int		bbStringToInt( BBString *str );
unsigned int bbStringToUInt( BBString *str );
float	bbStringToFloat( BBString *str );
double	bbStringToDouble( BBString *str );
BBInt64 bbStringToLong( BBString *str );
BBUInt64 bbStringToULong( BBString *str );
BBSIZET bbStringToSizet( BBString *str );
unsigned char* bbStringToCString( BBString *str );
BBChar*	bbStringToWString( BBString *str );
unsigned char* bbStringToUTF8String( BBString *str );

#ifdef _WIN32
WPARAM  bbStringToWParam( BBString *str );
LPARAM  bbStringToLParam( BBString *str );
BBString* bbStringFromWParam( WPARAM n );
BBString* bbStringFromLParam( LPARAM n );
#endif

BBArray*	bbStringSplit( BBString *str,BBString *sep );
BBString*	bbStringJoin( BBString *sep,BBArray *bits );

char*	bbTmpCString( BBString *str );
BBChar*	bbTmpWString( BBString *str );
char*	bbTmpUTF8String( BBString *str );

#if __STDC_VERSION__ >= 199901L
inline int bbStringEquals( BBString *x,BBString *y ){
	if (x->length-y->length != 0) return 0;
	if (x->hash != 0 && x->hash == y->hash) return 1;
	return memcmp(x->buf, y->buf, x->length * sizeof(BBChar)) == 0;
}

inline int bbObjectIsEmptyString(BBObject * o) {
	return (BBString*)o == &bbEmptyString;
}

inline BBULONG bbStringHash( BBString * x ) {
	if (x->hash > 0) return x->hash;
	x->hash = XXH3_64bits(x->buf, x->length * sizeof(BBChar));
	return x->hash;
}
#else
int bbStringEquals( BBString *x,BBString *y );
int bbObjectIsEmptyString(BBObject * o);
BBULONG bbStringHash( BBString * x );
#endif

unsigned char *bbStringToUTF8StringBuffer( BBString *str, unsigned char * buf, size_t * length );

#ifdef __cplusplus
}
#endif

#endif
