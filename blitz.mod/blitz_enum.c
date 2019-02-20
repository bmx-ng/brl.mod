
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

static BBString * bbAppend(BBString * x, BBString * y) {
	int n = x != &bbEmptyString;
	int len=x->length+y->length + n;
    BBString *t=bbStringNew(len);
    memcpy( t->buf,x->buf,x->length*sizeof(BBChar) );
	if (n) {
		t->buf[x->length] = '|';
	}
    memcpy( t->buf+x->length+n,y->buf,y->length*sizeof(BBChar) );
	return t;
}

#define ENUM_TO_STRING(type,chr)\
BBString * bbEnumToString_##chr(BBEnum * bbEnum, type ordinal) {\
	type * value = (type*)bbEnum->values;\
	int flags = bbEnum->flags;\
	BBString * val = &bbEmptyString;\
	for (int i = 0; i < bbEnum->length; i++) {\
		if (flags) {\
			type v = *value++;\
			if (v == ordinal || (v & ordinal && v == (v & ordinal))) {\
				val = bbAppend(val, bbEnum->names[i]);\
			}\
		} else {\
			if (*value++ == ordinal) {\
				return bbEnum->names[i];\
			}\
		}\
	}\
	return val;\
}

ENUM_TO_STRING(BBBYTE,b)
ENUM_TO_STRING(BBSHORT,s)
ENUM_TO_STRING(BBINT,i)
ENUM_TO_STRING(BBUINT,u)
ENUM_TO_STRING(BBLONG,l)
ENUM_TO_STRING(BBULONG,y)
ENUM_TO_STRING(BBSIZET,t)
