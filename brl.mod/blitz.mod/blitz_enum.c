
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

struct enum_info_node {
	struct avl_root link;
	BBEnum * bbEnum;
};

static struct avl_root *enum_info_root = 0;

static int enum_info_node_compare(const void *x, const void *y) {

        struct enum_info_node * node_x = (struct enum_info_node *)x;
        struct enum_info_node * node_y = (struct enum_info_node *)y;

        return strcmp(node_x->bbEnum->atype, node_y->bbEnum->atype);
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
	// create something to look up
	struct enum_info_node node;
	BBEnum bbEnum;
	bbEnum.atype = name;
	node.bbEnum = &bbEnum;
	
	struct enum_info_node * found = (struct enum_info_node *)tree_search(&node, enum_info_node_compare, enum_info_root);

	if (found) {
		return found->bbEnum;
	}
	
	return 0;
}