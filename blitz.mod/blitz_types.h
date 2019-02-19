
#ifndef BLITZ_TYPES_H
#define BLITZ_TYPES_H

#ifdef __cplusplus
extern "C"{
#endif

#ifdef _MSC_VER
	typedef __int64 BBInt64;
	typedef unsigned __int64 BBUInt64;
#else
	typedef long long BBInt64;
	typedef unsigned long long BBUInt64;
#endif

typedef unsigned short	BBChar;

typedef struct BBClass	BBClass;
typedef struct BBObject	BBObject;
typedef struct BBString	BBString;
typedef struct BBArray	BBArray;
typedef struct BBInterfaceTable BBInterfaceTable;
typedef struct BBInterface BBInterface;
typedef struct BBInterfaceOffsets BBInterfaceOffsets;
typedef struct BBEnum BBEnum;

typedef unsigned char	BBBYTE;
typedef unsigned short	BBSHORT;
typedef signed int		BBINT;
typedef unsigned int	BBUINT;
typedef BBInt64			BBLONG;
typedef BBUInt64		BBULONG;
typedef float			BBFLOAT;
typedef double			BBDOUBLE;
typedef size_t			BBSIZET;
typedef BBClass*		BBCLASS;
typedef BBObject*		BBOBJECT;
typedef BBString*		BBSTRING;
typedef BBArray*		BBARRAY;
typedef BBInterfaceTable*	BBINTERFACETABLE;
typedef BBInterface*	BBINTERFACE;
typedef BBInterfaceOffsets * BBINTERFACEOFFSETS;

#ifdef __x86_64__
#include <immintrin.h>
typedef __m64			BBFLOAT64;
typedef __m128i			BBINT128;
typedef __m128			BBFLOAT128;
typedef __m128d			BBDOUBLE128;
#endif

extern const char *bbVoidTypeTag;	//"?"
extern const char *bbByteTypeTag;	//"b"
extern const char *bbShortTypeTag;	//"s"
extern const char *bbIntTypeTag;	//"i"
extern const char *bbUIntTypeTag;	//"u"
extern const char *bbLongTypeTag;	//"l"
extern const char *bbULongTypeTag;	//"y"
extern const char *bbSizetTypeTag;	//"z"
extern const char *bbFloatTypeTag;	//"f"
extern const char *bbDoubleTypeTag;	//"d"
extern const char *bbStringTypeTag;	//"$"
extern const char *bbObjectTypeTag;	//":Object"
extern const char *bbBytePtrTypeTag;//"*b"
extern const char *bbEnumTypeTag;   //"/"

struct bbDataDef { 
	char * type; 
	union {
		BBBYTE b;
		BBSHORT s;
		BBINT i;
		BBUINT u;
		BBLONG l;
		BBULONG y;
		BBSIZET z;
		BBFLOAT f;
		BBDOUBLE d;
		BBSTRING t;
	};
};

BBINT bbConvertToInt( struct bbDataDef * data );
BBUINT bbConvertToUInt( struct bbDataDef * data );
BBLONG bbConvertToLong( struct bbDataDef * data );
BBULONG bbConvertToULong( struct bbDataDef * data );
BBFLOAT bbConvertToFloat( struct bbDataDef * data );
BBDOUBLE bbConvertToDouble( struct bbDataDef * data );
BBSTRING bbConvertToString( struct bbDataDef * data );
BBSIZET bbConvertToSizet( struct bbDataDef * data );

#ifdef __cplusplus
}
#endif

#endif
