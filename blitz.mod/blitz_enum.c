
#include "blitz.h"



BBArray * bbEnumValues(BBEnum * bbEnum) {
	BBArray * values = &bbEmptyArray;

	int size = 4;
	char t = bbEnum->type[0];
	switch( t ) {
		case 'b':size=1;break;
		case 's':size=2;break;
		case 'l':size=8;break;
		case 'y':size=8;break;
		case 'z':size=sizeof(BBSIZET);break;
	}

	values = bbArrayNew1DStruct(bbEnum->atype, bbEnum->length, size);

	char * p = BBARRAYDATA(values, 0);

	memcpy(p, bbEnum->values, size * bbEnum->length);
	
	return values;
}

BBString * bbEnumToString_b(BBEnum * bbEnum, BBBYTE ordinal) {
	BBBYTE * value = (BBBYTE*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}

BBString * bbEnumToString_s(BBEnum * bbEnum, BBSHORT ordinal) {
	BBSHORT * value = (BBSHORT*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}

BBString * bbEnumToString_i(BBEnum * bbEnum, BBINT ordinal) {
	BBINT * value = (BBINT*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}

BBString * bbEnumToString_u(BBEnum * bbEnum, BBUINT ordinal) {
	BBUINT * value = (BBUINT*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}

BBString * bbEnumToString_l(BBEnum * bbEnum, BBLONG ordinal) {
	BBLONG * value = (BBLONG*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}

BBString * bbEnumToString_y(BBEnum * bbEnum, BBULONG ordinal) {
	BBULONG * value = (BBULONG*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}

BBString * bbEnumToString_t(BBEnum * bbEnum, BBSIZET ordinal) {
	BBSIZET * value = (BBSIZET*)bbEnum->values;
	for (int i = 0; i < bbEnum->length; i++) {
		if (*value++ == ordinal)
			return bbEnum->names[i];
	}
	return &bbEmptyString;
}
