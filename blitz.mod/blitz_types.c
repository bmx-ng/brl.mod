
#include "blitz.h"

const char *bbVoidTypeTag="?";
const char *bbByteTypeTag="b";
const char *bbShortTypeTag="s";
const char *bbIntTypeTag="i";
const char *bbLongTypeTag="l";
const char *bbFloatTypeTag="f";
const char *bbDoubleTypeTag="d";
const char *bbStringTypeTag="$";
const char *bbObjectTypeTag=":Object";
const char *bbBytePtrTypeTag="*b";

BBINT bbConvertToInt( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'l':return data->l;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToInt( data->t );
	}
	return 0;
}

BBLONG bbConvertToLong( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'l':return data->l;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToLong( data->t );
	}
	return 0;
}

BBFLOAT bbConvertToFloat( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'l':return data->l;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToFloat( data->t );
	}
	return 0;
}

BBDOUBLE bbConvertToDouble( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'l':return data->l;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToFloat( data->t );
	}
	return 0;
}

BBSTRING bbConvertToString( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return bbStringFromInt( data->b );
	case 's':return bbStringFromInt( data->s );
	case 'i':return bbStringFromInt( data->i );
	case 'l':return bbStringFromLong( data->l );
	case 'f':return bbStringFromFloat( data->f );
	case 'd':return bbStringFromFloat( data->d );
	case '$':return data->t;
	}
	return &bbEmptyString;
}
