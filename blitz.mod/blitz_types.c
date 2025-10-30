
#include "blitz.h"

const char *bbVoidTypeTag="?";
const char *bbByteTypeTag="b";
const char *bbShortTypeTag="s";
const char *bbIntTypeTag="i";
const char *bbUIntTypeTag="u";
const char *bbLongTypeTag="l";
const char *bbULongTypeTag="y";
const char *bbSizetTypeTag="z";
const char *bbLongIntTypeTag="v";
const char *bbULongIntTypeTag="e";
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
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToInt( data->t );
	}
	return 0;
}

BBUINT bbConvertToUInt( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToUInt( data->t );
	}
	return 0;
}

BBLONG bbConvertToLong( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToLong( data->t );
	}
	return 0;
}

BBULONG bbConvertToULong( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToULong( data->t );
	}
	return 0;
}

BBFLOAT bbConvertToFloat( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
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
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
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
	case 'u':return bbStringFromUInt( data->u );
	case 'l':return bbStringFromLong( data->l );
	case 'y':return bbStringFromULong( data->y );
	case 'z':return bbStringFromSizet( data->z );
	case 'v':return bbStringFromLongInt( data->v );
	case 'e':return bbStringFromULongInt( data->e );
	case 'f':return bbStringFromFloat( data->f, 0 );
	case 'd':return bbStringFromFloat( data->d, 0 );
	case '$':return data->t;
	}
	return &bbEmptyString;
}

BBSIZET bbConvertToSizet( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToSizet( data->t );
	}
	return 0;
}

BBLONGINT bbConvertToLongInt( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToLongInt( data->t );
	}
	return 0;
}

BBULONGINT bbConvertToULongInt( struct bbDataDef * data ){
	switch( data->type[0] ){
	case 'b':return data->b;
	case 's':return data->s;
	case 'i':return data->i;
	case 'u':return data->u;
	case 'l':return data->l;
	case 'y':return data->y;
	case 'z':return data->z;
	case 'v':return data->v;
	case 'e':return data->e;
	case 'f':return data->f;
	case 'd':return data->d;
	case '$':return bbStringToULongInt( data->t );
	}
	return 0;
}
