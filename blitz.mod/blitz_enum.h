
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

void bbEnumRegister(BBEnum * bbEnum, BBDebugScope *p);
BBEnum * bbEnumGetInfo( char * name );

#ifdef __cplusplus
}
#endif

#endif
