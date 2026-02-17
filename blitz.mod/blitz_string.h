
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
	BBUINT hash;
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
	unsigned int (*HashCode)( BBObject *o );
	int 		(*Equals)( BBObject *x,BBObject *y );

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
	BBString* (*bbStringFromFloat)( float n, int fixed );
	BBString* (*bbStringFromDouble)( double n, int fixed );
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
	unsigned char* (*bbStringToUTF8StringLen)( BBString *str, size_t * length );

	BBUINT* (*bbStringToUTF32String)( BBString *str );
	BBString* (*bbStringFromUTF32String)( const BBUINT *p );
	BBString* (*bbStringFromUTF32Bytes)( const BBUINT *p, size_t n );
	BBChar* (*bbStringToWStringBuffer)( BBString *str, BBChar * buf, size_t * length );

	BBLONGINT (*bbStringToLongInt)( BBString *t );
	BBString* (*bbStringFromLongInt)( BBLONGINT n );
	BBULONGINT (*bbStringToULongInt)( BBString *t );
	BBString* (*bbStringFromULongInt)( BBULONGINT n );

	int (*bbStringToDoubleEx)( BBString *str, double *val, int start, int end, BBULONG format, BBString *sep );
	int (*bbStringToFloatEx)( BBString *str, float *val, int start, int end, BBULONG format, BBString *sep );
	int (*bbStringToIntEx)( BBString *str, int *val, int start, int end, BBULONG format, int base );
	int (*bbStringToUIntEx)( BBString *str, unsigned int *val, int start, int end, BBULONG format, int base );
	int (*bbStringToLongEx)( BBString *str, BBInt64 *val, int start, int end, BBULONG format, int base );
	int (*bbStringToULongEx)( BBString *str, BBUInt64 *val, int start, int end, BBULONG format, int base );
	int (*bbStringToSizeTEx)( BBString *str, BBSIZET *val, int start, int end, BBULONG format, int base );
	int (*bbStringToLongIntEx)( BBString *str, BBLONGINT *val, int start, int end, BBULONG format, int base );
	int (*bbStringToULongIntEx)( BBString *str, BBULONGINT *val, int start, int end, BBULONG format, int base );

	BBString* (*bbStringFromBytesAsHex)( const unsigned char *p, int n, int uppercase );
	int (*bbStringCompareCase)( BBString *x,BBString *y, int caseSensitive );
	BBUINT (*bbStringHashCase)( BBString *str, int caseSensitive );

	BBString* (*bbStringJoinInts)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinLongs)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinLongInts)( BBString *sep, BBArray *bits );

	BBString* (*bbStringJoinBytes)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinShorts)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinUInts)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinULongs)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinSizets)( BBString *sep, BBArray *bits );
	BBString* (*bbStringJoinULongInts)( BBString *sep, BBArray *bits );

	BBString* (*bbStringJoinFloats)( BBString *sep, BBArray *bits, int fixed );
	BBString* (*bbStringJoinDoubles)( BBString *sep, BBArray *bits, int fixed );
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
BBString*bbStringFromFloat( float n, int fixed );
BBString*	bbStringFromDouble( double n, int fixed );
BBString*	bbStringFromBytes( const unsigned char *p,int n );
BBString*	bbStringFromShorts( const unsigned short *p,int n );
BBString*	bbStringFromInts( const int *p,int n );
BBString*	bbStringFromUInts( const unsigned int *p,int n );
BBString*bbStringFromArray( BBArray *arr );
BBString*	bbStringFromCString( const char *p );
BBString*bbStringFromWString( const BBChar *p );
BBString*bbStringFromUTF8String( const unsigned char *p );
BBString *bbStringFromUTF8Bytes( const unsigned char *p,int n );
BBString*	bbStringFromLongInt( BBLONGINT n );
BBString*	bbStringFromULongInt( BBULONGINT n );

BBString*	bbStringToString( BBString *t );
int		bbStringCompare( BBString *x,BBString *y );
int		bbStringStartsWith( BBString *x,BBString *y );
int		bbStringEndsWith( BBString *x,BBString *y );
int		bbStringContains( BBString *x,BBString *y );
int		bbStringCompareCase( BBString *x,BBString *y, int caseSensitive );
int		bbStringEqualsCase( BBString *x,BBString *y, int caseSensitive );
BBUINT bbStringHashCase( BBString *str, int caseSensitive );

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
BBLONGINT bbStringToLongInt( BBString *str );
BBULONGINT bbStringToULongInt( BBString *str );

int	bbStringToDoubleEx( BBString *str, double *val, int start, int end, BBULONG format, BBString *sep );
int	bbStringToFloatEx( BBString *str, float *val, int start, int end, BBULONG format, BBString *sep );
int	bbStringToIntEx( BBString *str, int *val, int start, int end, BBULONG format, int base );
int	bbStringToUIntEx( BBString *str, unsigned int *val, int start, int end, BBULONG format, int base );
int	bbStringToLongEx( BBString *str, BBInt64 *val, int start, int end, BBULONG format, int base );
int	bbStringToULongEx( BBString *str, BBUInt64 *val, int start, int end, BBULONG format, int base );
int	bbStringToSizeTEx( BBString *str, BBSIZET *val, int start, int end, BBULONG format, int base );
int	bbStringToLongIntEx( BBString *str, BBLONGINT *val, int start, int end, BBULONG format, int base );
int	bbStringToULongIntEx( BBString *str, BBULONGINT *val, int start, int end, BBULONG format, int base );

int bbStrToDoubleEx( BBChar *buf, int length, double * val, int startPos, int endPos, BBULONG format, BBString* sep );
int bbStrToFloatEx( BBChar *buf, int length, float * val, int startPos, int endPos, BBULONG format, BBString* sep );

BBUINT* bbStringToUTF32String( BBString *str );
BBString* bbStringFromUTF32String( const BBUINT *p );
BBString* bbStringFromUTF32Bytes( const BBUINT *p, size_t n );

#ifdef _WIN32
WPARAM  bbStringToWParam( BBString *str );
LPARAM  bbStringToLParam( BBString *str );
BBString* bbStringFromWParam( WPARAM n );
BBString* bbStringFromLParam( LPARAM n );
#endif

BBArray*	bbStringSplit( BBString *str,BBString *sep );
BBString*	bbStringJoin( BBString *sep,BBArray *bits );

BBString* bbStringJoinInts( BBString *sep, BBArray *bits );
BBString* bbStringJoinLongs( BBString *sep, BBArray *bits );
BBString* bbStringJoinLongInts( BBString *sep, BBArray *bits );

BBString* bbStringJoinBytes( BBString *sep, BBArray *bits );
BBString* bbStringJoinShorts( BBString *sep, BBArray *bits );
BBString* bbStringJoinUInts( BBString *sep, BBArray *bits );
BBString* bbStringJoinULongs( BBString *sep, BBArray *bits );
BBString* bbStringJoinSizets( BBString *sep, BBArray *bits );
BBString* bbStringJoinULongInts( BBString *sep, BBArray *bits );

BBString *bbStringJoinFloats( BBString *sep, BBArray *bits, int fixed );
BBString *bbStringJoinDoubles( BBString *sep, BBArray *bits, int fixed );

char*	bbTmpCString( BBString *str );
BBChar*	bbTmpWString( BBString *str );
char*	bbTmpUTF8String( BBString *str );

extern const char bbDigitTable[200];

#if defined (__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
inline BBUINT bbStringHash( BBString * x ) {
	if (x->hash) return x->hash;
	BBULONG h = XXH3_64bits(x->buf, x->length * sizeof(BBChar));
	x->hash = (BBUINT)(h ^ (h >> 32));
	return x->hash;
}

inline int bbStringEquals( BBString *x,BBString *y ){
	if (x->clas != (BBClass *)&bbStringClass || y->clas != (BBClass *)&bbStringClass) return 0; // only strings with strings
	
	if (x == y) return 1;
	if (x->length != y->length) return 0;
	
	if (x->hash && y->hash && x->hash != y->hash) return 0;

	return memcmp(x->buf, y->buf, x->length * sizeof(BBChar)) == 0;
}

inline int bbObjectIsEmptyString(BBObject * o) {
	return (BBString*)o == &bbEmptyString;
}

inline int bbU32DecLen(uint32_t x){
    if (x >= 1000000000u) return 10;
    if (x >= 100000000u)  return 9;
    if (x >= 10000000u)   return 8;
    if (x >= 1000000u)    return 7;
    if (x >= 100000u)     return 6;
    if (x >= 10000u)      return 5;
    if (x >= 1000u)       return 4;
    if (x >= 100u)        return 3;
    if (x >= 10u)         return 2;
    return 1;
}

inline BBChar* bbWriteU32DecBackwards(BBChar *end, uint32_t x){
    // writes digits into [..end) backwards and returns new start pointer
    while (x >= 100){
        uint32_t q = x / 100;
        uint32_t r = x - q * 100;
        end -= 2;
        end[0] = (BBChar)bbDigitTable[r*2 + 0];
        end[1] = (BBChar)bbDigitTable[r*2 + 1];
        x = q;
    }
    if (x < 10){
        *--end = (BBChar)('0' + x);
    }else{
        end -= 2;
        end[0] = (BBChar)bbDigitTable[x*2 + 0];
        end[1] = (BBChar)bbDigitTable[x*2 + 1];
    }
    return end;
}

inline int bbU64DecLen( uint64_t x ){
    if( x <= 0xFFFFFFFFull ){
        return bbU32DecLen((uint32_t)x);
    }
    if( x >= 10000000000000000000ull ) return 20;
    if( x >= 1000000000000000000ull )  return 19;
    if( x >= 100000000000000000ull )   return 18;
    if( x >= 10000000000000000ull )    return 17;
    if( x >= 1000000000000000ull )     return 16;
    if( x >= 100000000000000ull )      return 15;
    if( x >= 10000000000000ull )       return 14;
    if( x >= 1000000000000ull )        return 13;
    if( x >= 100000000000ull )         return 12;
    if( x >= 10000000000ull )          return 11;
    return 10;
}

inline BBChar* bbWriteU64DecBackwards( BBChar *end, uint64_t x ){
    if( x <= 0xFFFFFFFFull ){
        return bbWriteU32DecBackwards(end, (uint32_t)x);
    }
    while( x >= 100ull ){
        uint64_t q = x / 100ull;
        uint64_t r = x - q * 100ull;
        end -= 2;
        end[0] = (BBChar)bbDigitTable[r*2 + 0];
        end[1] = (BBChar)bbDigitTable[r*2 + 1];
        x = q;
    }
    if( x < 10ull ){
        *--end = (BBChar)('0' + (int)x);
    }else{
        end -= 2;
        end[0] = (BBChar)bbDigitTable[x*2 + 0];
        end[1] = (BBChar)bbDigitTable[x*2 + 1];
    }
    return end;
}
#else
int bbStringEquals( BBString *x,BBString *y );
int bbObjectIsEmptyString(BBObject * o);
BBULONG bbStringHash( BBString * x );

int bbU32DecLen(uint32_t x);
BBChar* bbWriteU32DecBackwards(BBChar *end, uint32_t x);
int bbU64DecLen( uint64_t x );
BBChar* bbWriteU64DecBackwards( BBChar *end, uint64_t x );
#endif

unsigned char *bbStringToUTF8StringBuffer( BBString *str, unsigned char * buf, size_t * length );
unsigned char *bbStringToUTF8StringLen( BBString *str, size_t * length );
BBChar *bbStringToWStringBuffer( BBString *str, BBChar * buf, size_t * length );

int bbStringIdentifierEqualsNoCase(BBString *x, BBString *y);
int bbStringIdentifierEqualsNoCaseChars(BBString *x, BBChar * y, int ylen);

BBString *bbStringFromBytesAsHex( const unsigned char * bytes, int length, int upperCase );
unsigned short bbFoldChar(unsigned short c);

int d2s_buffered_expand_n(double v, char *buf);
int f2s_buffered_expand_n(float v, char *buf);

#ifdef __cplusplus
}
#endif

#endif
