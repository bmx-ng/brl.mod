
#include "blitz.h"

struct BBString_19{BBClass_String* clas;BBUINT hash;int length;BBChar buf[19];};
// 'Unknown Enum name: '
static struct BBString_19 _illegal_enum_name={
	&bbStringClass,
	0,
	19,
	{85,110,107,110,111,119,110,32,69,110,117,109,32,110,97,109,101
	,58,32}
};

BBArray * bbEnumValues(BBEnum * bbEnum) {
	BBArray * values = &bbEmptyArray;

	int size = 0;
	char t = bbEnum->type[0];
	switch( t ) {
		case 'b':size=sizeof(BBBYTE);break;
		case 's':size=sizeof(BBSHORT);break;
		case 'i':size=sizeof(BBINT);break;
		case 'u':size=sizeof(BBUINT);break;
		case 'l':size=sizeof(BBLONG);break;
		case 'y':size=sizeof(BBULONG);break;
		case 't':size=sizeof(BBSIZET);break;
		case 'v':size=sizeof(BBLONGINT);break;
		case 'e':size=sizeof(BBULONGINT);break;
		default:
			printf( "ERROR! bbEnumValues: unrecognized type tag!\n" );
			return &bbEmptyArray;
	}

	values = bbArrayNew1DStruct(bbEnum->atype, bbEnum->length, size, 0);

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
BBString* bbEnumToString_##chr(BBEnum* bbEnum, type ordinal) {\
    type* values = (type*)bbEnum->values;\
    BBString* out = &bbEmptyString;\
    if (!bbEnum->flags) {\
        for (int i = 0; i < bbEnum->length; ++i) {\
            if (values[i] == ordinal) {\
                return bbEnum->names[i];\
            }\
        }\
        return out;\
    }\
    type remaining = ordinal;\
    int zero_emitted = 0;\
    for (int i = 0; i < bbEnum->length; ++i) {\
        type v = values[i];\
        if (v == 0) {\
            if (!zero_emitted && ordinal == 0) {\
                out = bbAppend(out, bbEnum->names[i]);\
                zero_emitted = 1;\
            }\
            continue;\
        }\
        if ((remaining & v) == v) {\
            out = bbAppend(out, bbEnum->names[i]);\
            remaining &= ~v;\
        }\
    }\
    return out;\
}\

ENUM_TO_STRING(BBBYTE,b)
ENUM_TO_STRING(BBSHORT,s)
ENUM_TO_STRING(BBINT,i)
ENUM_TO_STRING(BBUINT,u)
ENUM_TO_STRING(BBLONG,l)
ENUM_TO_STRING(BBULONG,y)
ENUM_TO_STRING(BBSIZET,t)
ENUM_TO_STRING(BBLONGINT,v)
ENUM_TO_STRING(BBULONGINT,e)

#define TRY_ENUM_CONVERT(type,chr)\
int bbEnumTryConvert_##chr(BBEnum * bbEnum, type ordinalValue, type * ordinalResult) {\
	type * value = (type*)bbEnum->values;\
	int i;\
	if (bbEnum->flags) {\
		if (ordinalValue == 0) {\
			for (i = 0; i < bbEnum->length; i++) {\
				if (*value++ == 0) {\
					return 1;\
				}\
			}\
			return 0;\
		}\
		type val = ordinalValue;\
		for (i = 0; i < bbEnum->length; i++) {\
			val ^= *value++;\
		}\
		if (val == 0) {\
			*ordinalResult = ordinalValue;\
			return 1;\
		}\
	} else {\
		if (ordinalValue < *value || ordinalValue > ((type*)bbEnum->values)[bbEnum->length - 1]) {\
			return 0;\
		}\
		for (i = 0; i < bbEnum->length; i++) {\
			if (*value++ == ordinalValue) {\
				*ordinalResult = ordinalValue;\
				return 1;\
			}\
		}\
	}\
	return 0;\
}

TRY_ENUM_CONVERT(BBBYTE,b)
TRY_ENUM_CONVERT(BBSHORT,s)
TRY_ENUM_CONVERT(BBINT,i)
TRY_ENUM_CONVERT(BBUINT,u)
TRY_ENUM_CONVERT(BBLONG,l)
TRY_ENUM_CONVERT(BBULONG,y)
TRY_ENUM_CONVERT(BBSIZET,t)
TRY_ENUM_CONVERT(BBLONGINT,v)
TRY_ENUM_CONVERT(BBULONGINT,e)

#ifndef NDEBUG

#define ENUM_CAST(type,chr)\
type bbEnumCast_##chr(BBEnum * bbEnum, type ordinalValue) {\
	type result;\
	if (!bbEnumTryConvert_##chr(bbEnum, ordinalValue, &result)) {\
		brl_blitz_InvalidEnumError();\
	}\
	return result;\
}

ENUM_CAST(BBBYTE,b)
ENUM_CAST(BBSHORT,s)
ENUM_CAST(BBINT,i)
ENUM_CAST(BBUINT,u)
ENUM_CAST(BBLONG,l)
ENUM_CAST(BBULONG,y)
ENUM_CAST(BBSIZET,t)
ENUM_CAST(BBLONGINT,v)
ENUM_CAST(BBULONGINT,e)

#endif

// throws if not found
#define ENUM_FROM_STRING(type,chr)\
type bbEnumFromString_##chr(BBEnum* bbEnum, BBString* name) {\
    if (!bbEnum->flags) {\
        type* value = (type*)bbEnum->values;\
        for (int i = 0; i < bbEnum->length; ++i, ++value) {\
            if (bbStringIdentifierEqualsNoCase(bbEnum->names[i], name)) {\
                return *value;\
            }\
        }\
        brl_blitz_IllegalArgumentError(bbStringConcat((BBString *)&_illegal_enum_name, name));\
        return 0;\
    }\
    const BBChar* buf = name->buf;\
    const int n = name->length;\
    if (n == 0) {\
        brl_blitz_IllegalArgumentError(bbStringConcat((BBString *)&_illegal_enum_name, name));\
        return 0;\
    }\
    type result = 0;\
    int seg_start = 0;\
    type* values = (type*)bbEnum->values;\
    for (int i = 0; i <= n; ++i) {\
        const int at_end = (i == n);\
        const int is_delim = (!at_end && buf[i] == (BBChar)'|');\
        if (at_end || is_delim) {\
            const int seg_len = i - seg_start;\
            if (seg_len <= 0) {\
                brl_blitz_IllegalArgumentError(bbStringConcat((BBString *)&_illegal_enum_name, name));\
                return 0;\
            }\
            int matched = 0;\
            for (int j = 0; j < bbEnum->length; ++j) {\
                if (bbStringIdentifierEqualsNoCaseChars(bbEnum->names[j], (BBChar*)(buf + seg_start), seg_len)) {\
                    result |= values[j];\
                    matched = 1;\
                    break;\
                }\
            }\
            if (!matched) {\
                brl_blitz_IllegalArgumentError(bbStringConcat((BBString *)&_illegal_enum_name, name));\
                return 0;\
            }\
            seg_start = i + 1;\
        }\
    }\
    return result;\
}

ENUM_FROM_STRING(BBBYTE,b)
ENUM_FROM_STRING(BBSHORT,s)
ENUM_FROM_STRING(BBINT,i)
ENUM_FROM_STRING(BBUINT,u)
ENUM_FROM_STRING(BBLONG,l)
ENUM_FROM_STRING(BBULONG,y)
ENUM_FROM_STRING(BBSIZET,t)
ENUM_FROM_STRING(BBLONGINT,v)
ENUM_FROM_STRING(BBULONGINT,e)

struct enum_info_node {
	struct avl_root link;
	BBEnum * bbEnum;
};

static struct avl_root *enum_info_root = 0;

static int enum_info_node_compare(const void *x, const void *y) {

        struct enum_info_node * node_x = (struct enum_info_node *)x;
        struct enum_info_node * node_y = (struct enum_info_node *)y;

		return strcmp(node_x->bbEnum->name, node_y->bbEnum->name);
}

void bbEnumRegister( BBEnum *p, BBDebugScope *s ) {
	bbObjectRegisterEnum(s);

	struct enum_info_node * node = (struct enum_info_node *)malloc(sizeof(struct enum_info_node));
	node->bbEnum = p;
	
	struct enum_info_node * old_node = (struct enum_info_node *)avl_map(&node->link, enum_info_node_compare, &enum_info_root);
	if (&node->link != &old_node->link) {
		// this object already exists here...
		// delete the new node, since we don't need it
		// note : should never happen as enums should only ever be registered once.
		free(node);
	}
}

BBEnum * bbEnumGetInfo( char * name ) {

	char * n = name;

	// if name starts with '/', skip it
	if (n[0] == '/') {
		n++;
	}

	// create something to look up
	struct enum_info_node node;
	BBEnum bbEnum;
	bbEnum.name = n;
	node.bbEnum = &bbEnum;
	
	struct enum_info_node * found = (struct enum_info_node *)tree_search((struct tree_root_np *)&node, enum_info_node_compare, (struct tree_root_np *)enum_info_root);

	if (found) {
		return found->bbEnum;
	}
	
	return 0;
}

void bbEnumsInit() {
	bbStringHash(&_illegal_enum_name);
}
