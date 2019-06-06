
#ifndef BLITZ_ENUM_H
#define BLITZ_ENUM_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

struct BBEnum {
	const char * name;
	char * type; // the numeric type
	char * atype; // array type
	int flags; // 1 if a flags enum
	int length; // number of values
	void * values;
	BBString * names[1]; // array of names
};

BBArray * bbEnumValues(BBEnum * bbEnum);
BBString * bbEnumToString_b(BBEnum * bbEnum, BBBYTE ordinal);
BBString * bbEnumToString_s(BBEnum * bbEnum, BBSHORT ordinal);
BBString * bbEnumToString_i(BBEnum * bbEnum, BBINT ordinal);
BBString * bbEnumToString_u(BBEnum * bbEnum, BBUINT ordinal);
BBString * bbEnumToString_l(BBEnum * bbEnum, BBLONG ordinal);
BBString * bbEnumToString_y(BBEnum * bbEnum, BBULONG ordinal);
BBString * bbEnumToString_t(BBEnum * bbEnum, BBSIZET ordinal);

int bbEnumTryConvert_b(BBEnum * bbEnum, BBBYTE ordinalValue, BBBYTE * ordinalResult);
int bbEnumTryConvert_s(BBEnum * bbEnum, BBSHORT ordinalValue, BBSHORT * ordinalResult);
int bbEnumTryConvert_i(BBEnum * bbEnum, BBINT ordinalValue, BBINT * ordinalResult);
int bbEnumTryConvert_u(BBEnum * bbEnum, BBUINT ordinalValue, BBUINT * ordinalResult);
int bbEnumTryConvert_l(BBEnum * bbEnum, BBLONG ordinalValue, BBLONG * ordinalResult);
int bbEnumTryConvert_y(BBEnum * bbEnum, BBULONG ordinalValue, BBULONG * ordinalResult);
int bbEnumTryConvert_t(BBEnum * bbEnum, BBSIZET ordinalValue, BBSIZET * ordinalResult);

#ifndef NDEBUG

BBBYTE bbEnumCast_b(BBEnum * bbEnum, BBBYTE ordinalValue);
BBSHORT bbEnumCast_s(BBEnum * bbEnum, BBSHORT ordinalValue);
BBINT bbEnumCast_i(BBEnum * bbEnum, BBINT ordinalValue);
BBUINT bbEnumCast_u(BBEnum * bbEnum, BBUINT ordinalValue);
BBLONG bbEnumCast_l(BBEnum * bbEnum, BBLONG ordinalValue);
BBULONG bbEnumCast_y(BBEnum * bbEnum, BBULONG ordinalValue);
BBSIZET bbEnumCast_t(BBEnum * bbEnum, BBSIZET ordinalValue);

#endif

void bbEnumRegister(BBEnum * bbEnum, BBDebugScope *p);
BBEnum * bbEnumGetInfo( char * name );

#ifdef __cplusplus
}
#endif

#endif
