
#include "blitz.h"

#include "bdwgc/libatomic_ops/src/atomic_ops.h"

#include "blitz_unicode.h"

#define XXH_IMPLEMENTATION
#define XXH_STATIC_LINKING_ONLY

#include "hash/xxhash.h"

static void bbStringFree( BBObject *o );

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"String",
	{
		{
			BBDEBUGDECL_END,
			"",
			"",
			.var_address=(void*)0,
			(void (*)(void**))0
		}
	}
};

struct BBClass_String bbStringClass={
	&bbObjectClass, //super
	bbStringFree,   //free
	&debugScope,	//DebugScope
	0,				//instance_size
	0,				//ctor
	0,				//dtor

	(BBString*(*)(BBObject*))bbStringToString,
	(int(*)(BBObject*,BBObject*))bbStringCompare,
	bbObjectSendMessage,
	(unsigned int(*)(BBObject*))bbStringHash,
	(int(*)(BBObject*,BBObject*))bbStringEquals,
	0,              //interface
	0,              //extra
	0,
	0,          //instance_count
	offsetof(BBString, hash), //fields_offset
	
	bbStringFind,
	bbStringFindLast,
	bbStringTrim,
	bbStringReplace,
	
	bbStringToLower,
	bbStringToUpper,
	
	bbStringToInt,
	bbStringToLong,
	bbStringToFloat,
	bbStringToDouble,
	bbStringToCString,
	bbStringToWString,

	bbStringFromInt,
	bbStringFromLong,
	bbStringFromFloat,
	bbStringFromDouble,
	bbStringFromCString,
	bbStringFromWString,
	
	bbStringFromBytes,
	bbStringFromShorts,

	bbStringStartsWith,
	bbStringEndsWith,
	bbStringContains,
	
	bbStringSplit,
	bbStringJoin,
	
	bbStringFromUTF8String,
	bbStringToUTF8String,
	bbStringFromUTF8Bytes,
	
	bbStringToSizet,
	bbStringFromSizet,

	bbStringToUInt,
	bbStringFromUInt,
	bbStringToULong,
	bbStringFromULong,
	
#ifdef _WIN32
	bbStringToWParam,
	bbStringFromWParam,
	bbStringToLParam,
	bbStringFromLParam,
#endif

	bbStringToUTF8StringBuffer,
	bbStringToUTF8StringLen,

	bbStringToUTF32String,
	bbStringFromUTF32String,
	bbStringFromUTF32Bytes,
	bbStringToWStringBuffer,

	bbStringToLongInt,
	bbStringFromLongInt,
	bbStringToULongInt,
	bbStringFromULongInt
};

BBString bbEmptyString={
	(BBClass*)&bbStringClass, //clas
	0, 				// hash
	0				//length
};

static int wstrlen( const BBChar *p ){
	const BBChar *t=p;
	while( *t ) ++t;
	return t-p;
}

static size_t utf32strlen( const BBUINT *p ){
	const BBUINT *t=p;
	while( *t ) ++t;
	return (size_t)(t-p);
}

static int charsEqual( unsigned short *a,unsigned short *b,int n ){
	while( n-- ){
		if (*a!=*b) return 0;
		a++;b++;
	}
	return 1;
}

#if defined (__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
extern int bbStringEquals( BBString *x,BBString *y);
extern int bbObjectIsEmptyString(BBObject * o);
extern BBUINT bbStringHash( BBString * x );
#else
BBUINT bbStringHash( BBString * x ) {
	if (x->hash) return x->hash;
	BBULONG h = XXH3_64bits(x->buf, x->length * sizeof(BBChar));
	x->hash = (BBUINT)(h ^ (h >> 32));
	return x->hash;
}

int bbStringEquals( BBString *x,BBString *y ){
	if (x->clas != &bbStringClass || y->clas != &bbStringClass) return 0; // only strings with strings

	if (x == y) return 1;
	if (x->length != y->length) return 0;
	
	if (x->hash && y->hash && x->hash != y->hash) return 0;

	return memcmp(x->buf, y->buf, x->length * sizeof(BBChar)) == 0;
}

int bbObjectIsEmptyString(BBObject * o) {
	return (BBString*)o == &bbEmptyString;
}
#endif

//***** Note: Not called in THREADED mode.
static void bbStringFree( BBObject *o ){
	if (bbCountInstances && !bbCountInstanceTotals) {
		bbAtomicAdd((int*)&bbStringClass.instance_count, -1);
	}
}

BBString *bbStringNew( int len ){
	BBString *str;
	if( !len ) return &bbEmptyString;
	str=(BBString*)bbGCAllocObject( sizeof(BBString)+len*sizeof(BBChar),(BBClass*)&bbStringClass,BBGC_ATOMIC );
	str->hash=0;
	str->length=len;
	return str;
}

BBString *bbStringFromChar( int c ){
	BBString *str=bbStringNew(1);
	str->buf[0]=c;
	return str;
}

BBString *bbStringFromInt( int n ){
	char buf[64];

	sprintf(buf, "%d", n);

	return bbStringFromBytes( (unsigned char*)buf, strlen(buf) );
}

BBString *bbStringFromUInt( unsigned int n ){
	char buf[64];

	sprintf(buf, "%u", n);

	return bbStringFromBytes( (unsigned char*)buf, strlen(buf) );
}

BBString *bbStringFromLong( BBInt64 n ){
	char buf[64];

	sprintf(buf, "%lld", n);

	return bbStringFromBytes( (unsigned char*)buf,strlen(buf) );
}

BBString *bbStringFromULong( BBUInt64 n ){
	char buf[64];

	sprintf(buf, "%llu", n);

	return bbStringFromBytes( (unsigned char*)buf, strlen(buf) );
}

BBString *bbStringFromSizet( BBSIZET n ){
	char buf[64];
	
#if UINTPTR_MAX == 0xffffffff
	sprintf(buf, "%u", n);
#else
	sprintf(buf, "%llu", n);
#endif

	return bbStringFromBytes( (unsigned char*)buf, strlen(buf) );
}

BBString *bbStringFromLongInt( BBLONGINT n ){
	char buf[64];

	sprintf(buf, "%ld", n);

	return bbStringFromBytes( (unsigned char*)buf,strlen(buf) );
}

BBString *bbStringFromULongInt( BBULONGINT n ){
	char buf[64];

	sprintf(buf, "%lu", n);

	return bbStringFromBytes( (unsigned char*)buf,strlen(buf) );
}

BBString *bbStringFromFloat( float n, int fixed ){
	char buf[64];
	if( fixed ) {
		sprintf( buf,"%.9f",n );
	} else {
		sprintf( buf,"%#.9g",n );
	}
	return bbStringFromCString(buf);
}

BBString *bbStringFromDouble( double n, int fixed ){
	char buf[64];
	if( fixed ) {
		sprintf( buf,"%.17f",n );
	} else {
		sprintf( buf,"%#.17g",n );
	}
	return bbStringFromCString(buf);
}

BBString *bbStringFromBytes( const unsigned char *p,int n ){
	int k;
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	for( k=0;k<n;++k ) str->buf[k]=p[k];
	return str;
}

BBString *bbStringFromShorts( const unsigned short *p,int n ){
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	bbMemCopy( str->buf,p,n*sizeof(short) );
	return str;
}

BBString *bbStringFromInts( const int *p,int n ){
	int k;
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	for( k=0;k<n;++k ) str->buf[k]=p[k];
	return str;
}

BBString *bbStringFromUInts( const unsigned int *p,int n ){
	int k;
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	for( k=0;k<n;++k ) str->buf[k]=p[k];
	return str;
}

BBString *bbStringFromArray( BBArray *arr ){
	int n;
	void *p;
	if( arr->dims!=1 ) return &bbEmptyString;
	n=arr->scales[0];
	p=BBARRAYDATA(arr,arr->dims);
	switch( arr->type[0] ){
	case 'b':return bbStringFromBytes( (unsigned char*)p,n );
	case 's':return bbStringFromShorts( p,n );
	case 'i':return bbStringFromInts( p,n );
	}
	return &bbEmptyString;
}

BBString *bbStringFromCString( const char *p ){
	return p ? bbStringFromBytes( (unsigned char*)p,strlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromWString( const BBChar *p ){
	return p ? bbStringFromShorts( p,wstrlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromUTF8String( const unsigned char *p ){
	return p ? bbStringFromUTF8Bytes( p,strlen((char*)p) ) : &bbEmptyString;
}

#define REPLACEMENT_CHAR 0xFFFD

BBString *bbStringFromUTF8Bytes(const unsigned char *p, int n) {
    if (!p || n <= 0) return &bbEmptyString;

    // Allocate worst-case: one output code unit per input byte.
    unsigned short *buffer = (unsigned short*)malloc(n * sizeof(unsigned short));
    if (!buffer) return &bbEmptyString; // Allocation failed

    unsigned short *dest = buffer;
    const unsigned char *end = p + n;

    while (p < end) {
        unsigned int codepoint;
        unsigned char byte = *p++;

        if (byte < 0x80) {
            // 1-byte (ASCII)
            *dest++ = byte;
        } else if (byte < 0xC0) {
            // Unexpected continuation byte; insert replacement.
            *dest++ = REPLACEMENT_CHAR;
        } else if (byte < 0xE0) {
            // 2-byte sequence: 110xxxxx 10xxxxxx
            if (p >= end) {
                *dest++ = REPLACEMENT_CHAR;
                break;
            }
            unsigned char byte2 = *p++;
            if ((byte2 & 0xC0) != 0x80) {
                *dest++ = REPLACEMENT_CHAR;
                continue;
            }
            codepoint = ((byte & 0x1F) << 6) | (byte2 & 0x3F);
            if (codepoint < 0x80) { // Overlong encoding
                *dest++ = REPLACEMENT_CHAR;
            } else {
                *dest++ = (unsigned short)codepoint;
            }
        } else if (byte < 0xF0) {
            // 3-byte sequence: 1110xxxx 10xxxxxx 10xxxxxx
            if (p + 1 >= end) {
                *dest++ = REPLACEMENT_CHAR;
                break;
            }
            unsigned char byte2 = *p++;
            unsigned char byte3 = *p++;
            if ((byte2 & 0xC0) != 0x80 || (byte3 & 0xC0) != 0x80) {
                *dest++ = REPLACEMENT_CHAR;
                continue;
            }
            codepoint = ((byte & 0x0F) << 12) |
                        ((byte2 & 0x3F) << 6) |
                        (byte3 & 0x3F);
            // Reject overlong sequences and surrogate halves.
            if (codepoint < 0x800 || (codepoint >= 0xD800 && codepoint <= 0xDFFF)) {
                *dest++ = REPLACEMENT_CHAR;
            } else {
                *dest++ = (unsigned short)codepoint;
            }
        } else if (byte < 0xF8) {
            // 4-byte sequence: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
            if (p + 2 >= end) {
                *dest++ = REPLACEMENT_CHAR;
                break;
            }
            unsigned char byte2 = *p++;
            unsigned char byte3 = *p++;
            unsigned char byte4 = *p++;
            if ((byte2 & 0xC0) != 0x80 ||
                (byte3 & 0xC0) != 0x80 ||
                (byte4 & 0xC0) != 0x80) {
                *dest++ = REPLACEMENT_CHAR;
                continue;
            }
            codepoint = ((byte & 0x07) << 18) |
                        ((byte2 & 0x3F) << 12) |
                        ((byte3 & 0x3F) << 6) |
                        (byte4 & 0x3F);
            // Ensure codepoint is within valid range.
            if (codepoint < 0x10000 || codepoint > 0x10FFFF) {
                *dest++ = REPLACEMENT_CHAR;
            } else {
                // Convert to surrogate pair.
                codepoint -= 0x10000;
                unsigned short highSurrogate = 0xD800 | ((codepoint >> 10) & 0x3FF);
                unsigned short lowSurrogate  = 0xDC00 | (codepoint & 0x3FF);
                *dest++ = highSurrogate;
                *dest++ = lowSurrogate;
            }
        } else {
            // Bytes above 0xF7 are invalid in modern UTF-8.
            *dest++ = REPLACEMENT_CHAR;
        }
    }

    BBString *str = bbStringFromShorts(buffer, dest - buffer);
    free(buffer);
    return str;
}

BBString *bbStringToString( BBString *t ){
	return t;
}

int bbStringCompare( BBString *x,BBString *y ){
	int k,n,sz;
	if (x->clas != (BBClass*)&bbStringClass || y->clas != (BBClass*)&bbStringClass) return -1; // only compare strings with strings

	sz=x->length<y->length ? x->length : y->length;
	for( k=0;k<sz;++k ) if( (n=x->buf[k]-y->buf[k]) ) return n;
	return x->length-y->length;
}

int bbStringStartsWith( BBString *x,BBString *y ){
	BBChar *p,*q;
	int k,sz=y->length;
	if( x->length<sz ) return 0;
	p=x->buf;
	q=y->buf;
	for( k=0;k<sz;++k ) if( *p++!=*q++ ) return 0;
	return 1;
}

int bbStringEndsWith( BBString *x,BBString *y ){
	BBChar *p,*q;
	int k,sz=y->length;
	if( x->length<sz ) return 0;
	p=x->buf+x->length-sz;
	q=y->buf;
	for( k=0;k<sz;++k ) if( *p++!=*q++ ) return 0;
	return 1;
}

int bbStringContains( BBString *x,BBString *y ){
	return bbStringFind( x,y,0 )!=-1;
}

BBString *bbStringConcat( BBString *x,BBString *y ){
    int len=x->length+y->length;
    BBString *t=bbStringNew(len);
    memcpy( t->buf,x->buf,x->length*sizeof(BBChar) );
    memcpy( t->buf+x->length,y->buf,y->length*sizeof(BBChar) );
    return t;
}

BBString *bbStringSlice( BBString *in,int beg,int end ){
	BBChar *p;
	BBString *out;
	int k,n,len,inlen;
	
	len=end-beg;
	if( len<=0 ) return &bbEmptyString;

	out=bbStringNew( len );
	
	p=out->buf;
	inlen=in->length;

	if( (n=-beg)>0 ){
		if( beg+n>end ) n=end-beg;
		for( k=0;k<n;++k ) *p++=' ';
		if( (beg+=n)==end ) return out;
	}
	if( (n=inlen-beg)>0 ){
		BBChar *q=in->buf+beg;
		if( beg+n>end ) n=end-beg;
		for( k=0;k<n;++k ) *p++=*q++;
		if( (beg+=n)==end ) return out;
	}
	if( (n=end-beg)>0 ){
		for( k=0;k<n;++k ) *p++=' ';
	}
	return out;
}

BBString *bbStringTrim( BBString *str ){
	int b=0,e=str->length;
	while( b<e && str->buf[b]<=' ' ) ++b;
	if( b==e ) return &bbEmptyString;
	while( str->buf[e-1]<=' ' ) --e;
	if( e-b==str->length ) return str;
	return bbStringFromShorts( str->buf+b,e-b );
}

BBString *bbStringReplace( BBString *str,BBString *sub,BBString *rep ){
	int i,d,n,j,p;
	if( !sub->length ) return str;
	i=0;n=0;
	while( (i=bbStringFind(str,sub,i))!=-1 ) {i+=sub->length;n++;}
	if (!n) return str;
	d=rep->length-sub->length;
	BBString *t=bbStringNew( str->length+d*n );
	i=0;p=0;
	while( (j=bbStringFind(str,sub,i))!=-1 )
	{
		n=j-i;if (n) {memcpy( t->buf+p,str->buf+i,n*sizeof(BBChar) );p+=n;}
		n=rep->length;memcpy( t->buf+p,rep->buf,n*sizeof(BBChar) );p+=n;
		i=j+sub->length;		
	}
	n=str->length-i;
	if (n) memcpy( t->buf+p,str->buf+i,n*sizeof(BBChar) );
	return t;
}

int bbStringAsc( BBString *t ){
	return t->length ? t->buf[0] : -1;
}

int bbStringFind( BBString *x,BBString *y,int i ){
	if( i<0 ) i=0;
	while( i+y->length<=x->length ){
		if( charsEqual( x->buf+i,y->buf,y->length ) ) return i;
		++i;
	}
	return -1;
}

int bbStringFindLast( BBString *x,BBString *y,int i ){
	bbassert( i>=0 );
	i=x->length-i;
	if (i+y->length>x->length) i=x->length-y->length;
	while (i>=0)
	{
		if( charsEqual( x->buf+i,y->buf,y->length ) ) return i;
		--i;
	}
	return -1;
}

int bbStringToInt( BBString *t ){
	int i=0,neg=0,n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg=(t->buf[i]=='-')) ) ++i;
	if( i==t->length ) return 0;

	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

unsigned int bbStringToUInt( BBString *t ){
	int i=0,neg=0;
	unsigned n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg = t->buf[i]=='-') ) ++i;
	if( i==t->length ) return 0;

	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

BBInt64 bbStringToLong( BBString *t ){
	int i=0,neg=0;
	BBInt64 n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg=(t->buf[i]=='-')) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	//*r=neg ? -n : n;
	return neg ? -n : n;
}

BBUInt64 bbStringToULong( BBString *t ){
	int i=0,neg=0;
	BBUInt64 n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg = t->buf[i]=='-') ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

BBSIZET bbStringToSizet( BBString *t ){
	int i=0,neg=0;
	BBSIZET n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg=(t->buf[i]=='-')) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	//*r=neg ? -n : n;
	return neg ? -n : n;
}

BBLONGINT bbStringToLongInt( BBString *t ){
	int i=0,neg=0;
	BBLONGINT n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg=(t->buf[i]=='-')) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	//*r=neg ? -n : n;
	return neg ? -n : n;
}

BBULONGINT bbStringToULongInt( BBString *t ){
	int i=0,neg=0;
	BBULONGINT n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg = t->buf[i]=='-') ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

float bbStringToFloat( BBString *t ){
	char *p=(char*)bbStringToCString( t );
	float n=atof( p );
	bbMemFree( p );
	return n;
}

double bbStringToDouble( BBString *t ){
	char *p=(char*)bbStringToCString( t );
	double n=atof( p );
	bbMemFree( p );
	return n;
}

#ifdef _WIN32
WPARAM bbStringToWParam( BBString *t ){
	int i=0,neg=0;
	WPARAM n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg = t->buf[i]=='-') ) ++i;
	if( i==t->length ) return 0;

	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

BBString *bbStringFromWParam( WPARAM n ){
	char buf[64];

#ifdef __x86_64__
	sprintf(buf, "%llu", n);
#else
	sprintf(buf, "%u", n);
#endif

	return bbStringFromBytes( (unsigned char*)buf, strlen(buf) );
}

LPARAM bbStringToLParam( BBString *t ){
	int i=0,neg=0;
	LPARAM n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( (neg=(t->buf[i]=='-')) ) ++i;
	if( i==t->length ) return 0;

	if( t->buf[i]=='%' ){
		for( ++i;i<t->length;++i ){
			int c=t->buf[i];
			if( c!='0' && c!='1' ) break;
			n=n*2+(c-'0');
		}
	}else if( t->buf[i]=='$' ){
		for( ++i;i<t->length;++i ){
			int c=toupper(t->buf[i]);
			if( !isxdigit(c) ) break;
			if( c>='A' ) c-=('A'-'0'-10);
			n=n*16+(c-'0');
		}
	}else{
		for( ;i<t->length;++i ){
			int c=t->buf[i];
			if( !isdigit(c) ) break;
			n=n*10+(c-'0');
		}
	}
	return neg ? -n : n;
}

BBString *bbStringFromLParam( LPARAM n ){
	char buf[64];

#ifdef __x86_64__
	sprintf(buf, "%lld", n);
#else
	sprintf(buf, "%d", n);
#endif

	return bbStringFromBytes( (unsigned char*)buf, strlen(buf) );
}


#endif




BBString *bbStringToLower( BBString *str ){
	int k;
	BBString *t;
	int n = 0;
	
	while (n < str->length) {
        int c = str->buf[n];
        if (c < 192) {
            // ASCII character
            if (c >= 'A' && c <= 'Z') {
                // Found an uppercase ASCII character
                break;
            }
        } else {
            // Unicode character
            // Check if the character is an uppercase Unicode character
            int lo = 0, hi = (3828 / 4) - 1; // sizeof(bbToLowerData) = 3828
            int is_upper = 0;
            while (lo <= hi) {
                int mid = (lo + hi) / 2;
                int upper = bbToLowerData[mid * 2];
                if (c < upper) {
                    hi = mid - 1;
                } else if (c > upper) {
                    lo = mid + 1;
                } else {
                    // Found an uppercase Unicode character
                    is_upper = 1;
                    break;
                }
            }
            if (is_upper) {
                break;
            }
        }
        ++n;
    }
	
	if (n == str->length) {
		return str;
	}
	
	t=bbStringNew( str->length );

	if (n > 0) {
		memcpy(t->buf, str->buf, n * sizeof(BBChar));
	}
	
	for( k=n;k<str->length;++k ){
		int c=str->buf[k];
		if( c<192 ){
			c=(c>='A' && c<='Z') ? (c|32) : c;
		}else{
			int lo=0,hi=3828/4-1; // sizeof(bbToLowerData)=3828
			while( lo<=hi ){
				int mid=(lo+hi)/2;
				if( c<bbToLowerData[mid*2] ){
					hi=mid-1;
				}else if( c>bbToLowerData[mid*2] ){
					lo=mid+1;
				}else{
					c=bbToLowerData[mid*2+1];
					break;
				}
			}
		}
		t->buf[k]=c;
	}
	return t;
}

BBString *bbStringToUpper( BBString *str ){
	int k;
	BBString *t;
	int n = 0;
	
	while (n < str->length) {
        int c = str->buf[n];
        if (c < 181) {
            // ASCII character
            if (c >= 'a' && c <= 'z') {
                // Found a lowercase ASCII character
                break;
            }
        } else {
            // Unicode character
            // Check if the character is a lowercase Unicode character
            int lo = 0, hi = (3860 / 4) - 1; // sizeof(bbToUpperData) = 3860
            int is_lower = 0;
            while (lo <= hi) {
                int mid = (lo + hi) / 2;
                int lower = bbToUpperData[mid * 2];
                if (c < lower) {
                    hi = mid - 1;
                } else if (c > lower) {
                    lo = mid + 1;
                } else {
                    // Found a lowercase Unicode character
                    is_lower = 1;
                    break;
                }
            }
            if (is_lower) {
                break;
            }
        }
        ++n;
    }
	
	if (n == str->length) {
		return str;
	}
	
	t=bbStringNew( str->length );

	if (n > 0) {
		memcpy(t->buf, str->buf, n * sizeof(BBChar));
	}

	for( k=n;k<str->length;++k ){
		int c=str->buf[k];
		if( c<181 ){
			c=(c>='a' && c<='z') ? (c&~32) : c;
		}else{
			int lo=0,hi= 3860/4-1; //  sizeof(bbToUpperData)= 3860
			while( lo<=hi ){
				int mid=(lo+hi)/2;
				if( c<bbToUpperData[mid*2] ){
					hi=mid-1;
				}else if( c>bbToUpperData[mid*2] ){
					lo=mid+1;
				}else{
					c=bbToUpperData[mid*2+1];
					break;
				}
			}
		}
		t->buf[k]=c;
	}
	return t;
}

unsigned char *bbStringToCString( BBString *str ){
	unsigned char *p;
	int k,sz=str->length;
	p=(unsigned char*)bbMemAlloc( sz+1 );
	for( k=0;k<sz;++k ) p[k]=str->buf[k];
	p[sz]=0;
	return p;
}

BBChar *bbStringToWString( BBString *str ){
	BBChar *p;
	size_t sz=str->length + 1;
	p=(BBChar*)bbMemAlloc( sz * sizeof(BBChar) );
	return bbStringToWStringBuffer(str, p, &sz);
}

BBChar *bbStringToWStringBuffer( BBString *str, BBChar * buf, size_t * length ){
	size_t capacity = *length;
	if (capacity == 0) {
		return buf; // nothing to do
	}

	size_t maxcpy = capacity - 1; // leave space for null terminator
	size_t n = (size_t)str->length; // max number of characters we can copy

	if (n > maxcpy) {
		n = maxcpy; // truncate as needed
	}

	if (n) {
		memcpy(buf, str->buf, n * sizeof(BBChar));
	}
	buf[n] = 0;
	*length = n;
	return buf;
}

unsigned char *bbStringToUTF8String( BBString *str ){
	int len=str->length;
	size_t buflen = len * 4 + 1;
	unsigned char *buf=(unsigned char*)bbMemAlloc( buflen );
	return bbStringToUTF8StringBuffer(str, buf, &buflen);
}

unsigned char *bbStringToUTF8StringLen( BBString *str, size_t * length ){
	int len=str->length;
	size_t buflen = len * 4 + 1;
	unsigned char *buf=(unsigned char*)bbMemAlloc( buflen );
	bbStringToUTF8StringBuffer(str, buf, &buflen);
	if (length != NULL) {
		*length = buflen;
	}
	return buf;
}

unsigned char *bbStringToUTF8StringBuffer( BBString *str, unsigned char * buf, size_t * length ){
	int i=0,len=str->length;
	size_t buflen = *length;
	unsigned char *q=buf;
	unsigned short *p=str->buf;
	while (i < len) {
		unsigned int c=*p++;
		if(0xd800 <= c && c <= 0xdbff && i < len - 1) {
			/* surrogate pair */
			unsigned int c2 = *p;
			if(0xdc00 <= c2 && c2 <= 0xdfff) {
				/* valid second surrogate */
				c = ((c - 0xd800) << 10) + (c2 - 0xdc00) + 0x10000;
				++p;
				++i;
			}
		}
		size_t n = q - buf;
		if( c<0x80 ){
			if (buflen <= n+1) break;
			*q++=c;
		}else if( c<0x800 ){
			if (buflen <= n+2) break;
			*q++=0xc0|(c>>6);
			*q++=0x80|(c&0x3f);
		}else if(c < 0x10000) { 
			if (buflen <= n+3) break;
			*q++=0xe0|(c>>12);
			*q++=0x80|((c>>6)&0x3f);
			*q++=0x80|(c&0x3f);
		}else if(c <= 0x10ffff) {
			if (buflen <= n+4) break;
			*q++ = 0xf0|(c>>18);
			*q++ = 0x80|((c>>12)&0x3f);
			*q++ = 0x80|((c>>6)&0x3f);
			*q++ = 0x80|((c&0x3f));
		}else{
			bbExThrowCString( "Unicode character out of UTF-8 range" );
		}
		++i;
	}
	*q=0;
	*length = q - buf;
	return buf;
}

BBArray *bbStringSplit( BBString *str,BBString *sep ){
	int i,i2,n;
	BBString **p,*bit;
	BBArray *bits;

	if( sep->length ){
		i=0;n=1;
		while( (i2=bbStringFind( str,sep,i ))!=-1 ){
			++n;
			i=i2+sep->length;
		}
		
		bits=bbArrayNew1D( "$",n );
		p=(BBString**)BBARRAYDATA( bits,1 );
	
		i=0;
		while( n-- ){
			i2=bbStringFind( str,sep,i );
			if( i2==-1 ) i2=str->length;
			bit=bbStringSlice( str,i,i2 );
			//BBINCREFS( bit );
			*p++=bit;
			i=i2+sep->length;
		}
		return bits;
	}
		
	i=0;n=0;
	for(;;){
		while( i!=str->length && str->buf[i]<33 ) ++i;
		if( i++==str->length ) break;
		while( i!=str->length && str->buf[i]>32 ) ++i;
		++n;
	}
	if( !n ) return &bbEmptyArray;
	
	bits=bbArrayNew1D( "$",n );
	p=(BBString**)BBARRAYDATA( bits,1 );
	
	i=0;
	while( n-- ){
		while( str->buf[i]<33 ) ++i;
		i2=i++;
		while( i!=str->length && str->buf[i]>32 ) ++i;
		bit=bbStringSlice( str,i2,i );
		//BBINCREFS( bit );
		*p++=bit;
	}
	return bits;
}

BBString *bbStringJoin( BBString *sep,BBArray *bits ){
	int i,sz=0;
	int n_bits=bits->scales[0];
	BBString **p,*str;
	BBChar *t;
	
	if( bits==&bbEmptyArray ){
		return &bbEmptyString;
	}
	
	p=(BBString**)BBARRAYDATA( bits,1 );
	for( i=0;i<n_bits;++i ){
		BBString *bit=*p++;
		sz+=bit->length;
	}

	sz+=(n_bits-1)*sep->length;
	str=bbStringNew( sz );
	t=str->buf;
	
	p=(BBString**)BBARRAYDATA( bits,1 );
	for( i=0;i<n_bits;++i ){
		if( i ){
			memcpy( t,sep->buf,sep->length*sizeof(BBChar) );
			t+=sep->length;
		}
		BBString *bit=*p++;
		memcpy( t,bit->buf,bit->length*sizeof(BBChar) );
		t+=bit->length;
	}
	
	return str;
}
#ifndef __ANDROID__
#ifndef __EMSCRIPTEN__
static void mktmp( void *p ){
	static AO_t i;
	static void *bufs[32];
	int n=AO_fetch_and_add1( &i ) & 31;
	bbMemFree( bufs[n] );
	bufs[n]=p;
}
#else
static void mktmp( void *p ){
	static int i;
	static void *bufs[32];
	int n=++i & 31;
	bbMemFree( bufs[n] );
	bufs[n]=p;
}
#endif
#else
static void mktmp( void *p ){
	static int i;
	static void *bufs[32];
	int n= __sync_fetch_and_add( &i, 1 ) & 31;
	bbMemFree( bufs[n] );
	bufs[n]=p;
}
#endif
char *bbTmpCString( BBString *str ){
	printf("Use of bbTmpCString is deprecated\n");fflush(stdout);
	char *p=(char*)bbStringToCString( str );
	mktmp( p );
	return p;
}

BBChar *bbTmpWString( BBString *str ){
	printf("Use of bbTmpWString is deprecated\n");fflush(stdout);
	BBChar *p=bbStringToWString( str );
	mktmp( p );
	return p;
}

char *bbTmpUTF8String( BBString *str ){
	printf("Use of bbTmpUTF8String is deprecated\n");fflush(stdout);
	char *p=(char*)bbStringToUTF8String( str );
	mktmp( p );
	return p;
}

BBUINT* bbStringToUTF32String( BBString *str ) {
	if (!str || str == &bbEmptyString) {
		BBUINT *buf = (BBUINT*)bbMemAlloc(sizeof(BBUINT));
		*buf = 0;
		return buf;
	}

	size_t len=(size_t)str->length;

	size_t cap = len + 1;
	if (cap > SIZE_MAX / sizeof(BBUINT)) {  // overflow guard
        return NULL;
    }

	BBUINT *buf = (BBUINT*)bbMemAlloc(cap * sizeof(BBUINT));
    if (!buf) {
		return NULL;
	}

	const BBChar *p = str->buf;
	BBUINT *bp = buf;
	for (size_t i = 0; i < len; ++i) {
		BBChar c = p[i];

		// Non-surrogate fast path
        if (c < 0xD800u || c > 0xDFFFu) {
            *bp++ = (BBUINT)c;
            continue;
        }

		// Surrogates
        if ((c & 0xFC00u) == 0xD800u) { // high surrogate
            if (i + 1 >= len) {
                bbMemFree(buf);
                bbExThrowCString("Failed to create UTF32. Invalid surrogate pair (truncated).");
            }
            BBChar c2 = p[i + 1];
            if ((c2 & 0xFC00u) != 0xDC00u) {
                bbMemFree(buf);
                bbExThrowCString("Failed to create UTF32. Invalid surrogate pair.");
            }
            // Decode pair
            BBUINT cp = (((BBUINT)c - 0xD800u) << 10) | ((BBUINT)c2 - 0xDC00u);
            cp += 0x10000u;
            *bp++ = cp;
            ++i; // consumed the low surrogate
        } else {
            // Lone low surrogate
            bbMemFree(buf);
            bbExThrowCString("Failed to create UTF32. Lone low surrogate.");
        }
	}
	*bp = 0;
	return buf;
}

BBString* bbStringFromUTF32String( const BBUINT *p ) {
	return p ? bbStringFromUTF32Bytes(p, utf32strlen(p)) : &bbEmptyString;
}

BBString* bbStringFromUTF32Bytes( const BBUINT *p, size_t n ) {
	if( !p || n == 0 ) return &bbEmptyString;

	BBChar * d=(BBChar*)malloc( n * sizeof(BBChar) * 2 );
	BBChar * q=d;

	BBUINT* bp = p;

	int i = 0;
	while (i++ < n) {
		BBUINT c = *bp++;
		if (c <= 0xffffu) {
			if (c >= 0xd800u && c <= 0xdfffu) {
				*q++ = 0xfffd;
			} else {
          		*q++ = c;
			}
		} else if (c > 0x0010ffffu) {
			*q++ = 0xfffd;
		} else {
			c -= 0x0010000u;
        	*q++ = (BBChar)((c >> 10) + 0xd800);
        	*q++ = (BBChar)((c & 0x3ffu) + 0xdc00);
		}
	}
	BBString * str=bbStringFromShorts( d,q-d );
	free( d );
	return str;
}

static inline unsigned int ascii_is_upper(unsigned int c) {
    return (unsigned int)(c - 'A') <= 25u;
}

static inline unsigned int ascii_lower(unsigned int c) {
    return c + ascii_is_upper(c) * 32u;
}

// Case-insensitive comparison for string identifiers (ASCII only)
int bbStringIdentifierEqualsNoCase(BBString *x, BBString *y) {
	return bbStringIdentifierEqualsNoCaseChars(x, y->buf, y->length);
}

// Case-insensitive comparison for string identifiers (ASCII only)
int bbStringIdentifierEqualsNoCaseChars(BBString *x, BBChar * y, int ylen) {
    if (x->clas != (BBClass *)&bbStringClass)
        return 0;

    if (x->length != ylen)
        return 0;

    const BBChar *xb = x->buf;
    const BBChar *yb = y;
    int n = x->length;

    for (int i = 0; i < n; ++i) {
		unsigned int xc = (unsigned int)xb[i];
        unsigned int yc = (unsigned int)yb[i];

        xc = ascii_lower(xc);
        yc = ascii_lower(yc);

        if (xc != yc) return 0;
    }
    return 1;
}

BBString * bbStringFromBytesAsHex( const unsigned char * bytes, int length, int upperCase ) {

	static const char hexDigitsLower[] = "0123456789abcdef";
	static const char hexDigitsUpper[] = "0123456789ABCDEF";

	if (length <= 0 || bytes == NULL) {
		return &bbEmptyString;
	}

	const char * hexDigits = upperCase ? hexDigitsUpper : hexDigitsLower;

	BBString * str = bbStringNew(length * 2);
	BBChar * buf = str->buf;

	for (int i = 0; i < length; ++i) {
		unsigned char byte = bytes[i];
		buf[i * 2]     = (BBChar)hexDigits[(byte >> 4) & 0x0F];
		buf[i * 2 + 1] = (BBChar)hexDigits[byte & 0x0F];
	}

	return str;
}

unsigned short bbFoldChar(unsigned short c) {
    // ASCII
    if (c <= 0x7A) {
        if (c >= 'A' && c <= 'Z') {
			return (unsigned short)(c | 32);
		}
        return c;
    }
    return bbFoldCharLUT(c);
}

int bbStringCompareCase( BBString *x,BBString *y, int caseSensitive ) {
	if (caseSensitive != 0) {
		return bbStringCompare(x, y);
	}

	const int nx = x->length;
    const int ny = y->length;
    const BBChar *sx = x->buf;
    const BBChar *sy = y->buf;

    int n = nx < ny ? nx : ny;
    for (int i = 0; i < n; ++i) {
        unsigned short ax = (unsigned short)sx[i];
        unsigned short ay = (unsigned short)sy[i];

		if (ax == ay) {
			continue;
		}
        unsigned short cx = bbFoldChar(ax);
        unsigned short cy = bbFoldChar(ay);
        if (cx != cy) {
            return (int)cx - (int)cy;
        }
    }
	// shorter string is less
    return nx - ny;
}

int bbStringEqualsCase( BBString *x,BBString *y, int caseSensitive ) {
	if (caseSensitive != 0) {
		return bbStringEquals(x, y);
	}

	const int n = x->length;
	if (n != y->length) {
		return 0;
	}

	const BBChar *sx = x->buf;
	const BBChar *sy = y->buf;

	for (int i = 0; i < n; ++i) {
		unsigned short ax = (unsigned short)sx[i];
        unsigned short ay = (unsigned short)sy[i];

		if (ax == ay) {
			continue;
		}
		unsigned short cx = bbFoldChar(ax);
		unsigned short cy = bbFoldChar(ay);
		if (cx != cy) {
			return 0;
		}
	}
	return 1;
}

static inline unsigned short fold_ascii(unsigned short c) {
    if (c >= 'A' && c <= 'Z') {
		return (unsigned short)(c | 32);
	}
    return c;
}

static inline unsigned short fold16(unsigned short c) {
    // ASCII fast path
    if (c <= 0x7F) {
		return fold_ascii(c);
	}
    return bbFoldCharLUT(c);
}

BBUINT bbStringHashCase( BBString *str, int caseSensitive ) {
    int n = str->length;

	if (caseSensitive != 0 || n == 0) {
		return bbStringHash(str);
	}
	
    const BBChar *s = str->buf;

    // Use stack buffer for small strings
	if (n <= 512) {
		unsigned short tmp[512];

		int i = 0;

		// Unroll by 8, ASCII-first. Bail out if any non-ASCII is seen.
		for (; i + 8 <= n; i += 8) {
			unsigned short c0 = (unsigned short)s[i + 0];
			unsigned short c1 = (unsigned short)s[i + 1];
			unsigned short c2 = (unsigned short)s[i + 2];
			unsigned short c3 = (unsigned short)s[i + 3];
			unsigned short c4 = (unsigned short)s[i + 4];
			unsigned short c5 = (unsigned short)s[i + 5];
			unsigned short c6 = (unsigned short)s[i + 6];
			unsigned short c7 = (unsigned short)s[i + 7];

			// Single ASCII test for the whole block
			if ((c0 | c1 | c2 | c3 | c4 | c5 | c6 | c7) > 0x7F) {
				break;
			}

			tmp[i + 0] = fold_ascii(c0);
			tmp[i + 1] = fold_ascii(c1);
			tmp[i + 2] = fold_ascii(c2);
			tmp[i + 3] = fold_ascii(c3);
			tmp[i + 4] = fold_ascii(c4);
			tmp[i + 5] = fold_ascii(c5);
			tmp[i + 6] = fold_ascii(c6);
			tmp[i + 7] = fold_ascii(c7);
		}

		// Finish remaining chars in ASCII mode until we hit a non-ASCII (or end)
		for (; i < n; ++i) {
			unsigned short c = (unsigned short)s[i];
			if (c > 0x7F) {
				break;
			}
			tmp[i] = fold_ascii(c);
		}

		if (i == n) {
			// All ASCII
			return (BBUINT)XXH3_64bits(tmp, (size_t)n * sizeof(tmp[0]));
		}

		// Rare path: non-ASCII encountered
		for (; i < n; ++i) {
			tmp[i] = fold16((unsigned short)s[i]);
		}

		return (BBUINT)XXH3_64bits(tmp, (size_t)n * sizeof(tmp[0]));
	} else {
		// Chunk processing for large strings
		const int CHUNK = 512;
		unsigned short buf[CHUNK];

		XXH3_state_t state;
		XXH3_64bits_reset(&state);

		int i = 0;
		while (i < n) {
			int m = n - i;
			if (m > CHUNK) {
				m = CHUNK;
			}

			for (int j = 0; j < m; ++j) {
				unsigned short c = (unsigned short)s[i + j];
				buf[j] = fold16(c);
			}

			XXH3_64bits_update(&state, buf, (size_t)m * sizeof(buf[0]));
			i += m;
		}

		return (BBUINT)XXH3_64bits_digest(&state);
	}
}

static inline int u32_dec_len(uint32_t x){
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

static inline int u64_dec_len( uint64_t x ){
    if( x <= 0xFFFFFFFFull ){
        return u32_dec_len((uint32_t)x);
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

static const char DIGIT_TABLE[200] =
    "00010203040506070809"
    "10111213141516171819"
    "20212223242526272829"
    "30313233343536373839"
    "40414243444546474849"
    "50515253545556575859"
    "60616263646566676869"
    "70717273747576777879"
    "80818283848586878889"
    "90919293949596979899";

static inline BBChar* write_u32_dec_backwards(BBChar *end, uint32_t x){
    // writes digits into [..end) backwards and returns new start pointer
    while (x >= 100){
        uint32_t q = x / 100;
        uint32_t r = x - q * 100;
        end -= 2;
        end[0] = (BBChar)DIGIT_TABLE[r*2 + 0];
        end[1] = (BBChar)DIGIT_TABLE[r*2 + 1];
        x = q;
    }
    if (x < 10){
        *--end = (BBChar)('0' + x);
    }else{
        end -= 2;
        end[0] = (BBChar)DIGIT_TABLE[x*2 + 0];
        end[1] = (BBChar)DIGIT_TABLE[x*2 + 1];
    }
    return end;
}

static inline BBChar* write_u64_dec_backwards( BBChar *end, uint64_t x ){
    if( x <= 0xFFFFFFFFull ){
        return write_u32_dec_backwards(end, (uint32_t)x);
    }
    while( x >= 100ull ){
        uint64_t q = x / 100ull;
        uint64_t r = x - q * 100ull;
        end -= 2;
        end[0] = (BBChar)DIGIT_TABLE[r*2 + 0];
        end[1] = (BBChar)DIGIT_TABLE[r*2 + 1];
        x = q;
    }
    if( x < 10ull ){
        *--end = (BBChar)('0' + (int)x);
    }else{
        end -= 2;
        end[0] = (BBChar)DIGIT_TABLE[x*2 + 0];
        end[1] = (BBChar)DIGIT_TABLE[x*2 + 1];
    }
    return end;
}

#define BB_DEFINE_JOIN_SIGNED(NAME, ELEM_T, MAG_U_T, WIDE_S_T, DEC_LEN_FN, WRITE_BACK_FN) \
BBString *NAME( BBString *sep, BBArray *bits ){ \
    int i, sz = 0; \
    int n_bits = bits->scales[0]; \
    ELEM_T *p; \
    BBString *str; \
    BBChar *t; \
    if( bits==&bbEmptyArray || n_bits==0 ) return &bbEmptyString; \
    p = (ELEM_T*)BBARRAYDATA( bits, 1 ); \
    for( i=0; i<n_bits; ++i ){ \
        ELEM_T v = p[i]; \
        if( v==0 ){ sz += 1; continue; } \
        if( v < 0 ){ sz += 1; /* '-' */ \
            MAG_U_T mag = (MAG_U_T)(-(WIDE_S_T)v); \
            sz += DEC_LEN_FN( mag ); \
        }else{ \
            MAG_U_T mag = (MAG_U_T)v; \
            sz += DEC_LEN_FN( mag ); \
        } \
    } \
    sz += (n_bits-1) * sep->length; \
    str = bbStringNew( sz ); \
    t = str->buf; \
    p = (ELEM_T*)BBARRAYDATA( bits, 1 ); \
    for( i=0; i<n_bits; ++i ){ \
        ELEM_T v = p[i]; \
        if( i ){ memcpy( t, sep->buf, sep->length * sizeof(BBChar) ); t += sep->length; } \
        if( v==0 ){ *t++ = (BBChar)'0'; continue; } \
        MAG_U_T mag; \
        if( v < 0 ){ *t++ = (BBChar)'-'; mag = (MAG_U_T)(-(WIDE_S_T)v); } \
        else{ mag = (MAG_U_T)v; } \
        int dlen = DEC_LEN_FN( mag ); \
        BBChar *end = t + dlen; \
        (void)WRITE_BACK_FN( end, mag ); \
        t = end; \
    } \
    return str; \
}

BB_DEFINE_JOIN_SIGNED(bbStringJoinInts,  BBINT,  uint32_t, int64_t,  u32_dec_len, write_u32_dec_backwards)
BB_DEFINE_JOIN_SIGNED(bbStringJoinLongs, BBLONG, uint64_t, int64_t,  u64_dec_len, write_u64_dec_backwards)

BBString *bbStringJoinLongInts( BBString *sep, BBArray *bits ){
    if( sizeof(BBLONGINT) == 8 ){
        return bbStringJoinLongs(sep, bits);
    }else{
        return bbStringJoinInts(sep, bits);
    }
}

#define BB_DEFINE_JOIN_UNSIGNED(NAME, ELEM_T, MAG_U_T, DEC_LEN_FN, WRITE_BACK_FN) \
BBString *NAME( BBString *sep, BBArray *bits ){ \
    int i, sz = 0; \
    int n_bits = bits->scales[0]; \
    ELEM_T *p; \
    BBString *str; \
    BBChar *t; \
    if( bits==&bbEmptyArray || n_bits==0 ) return &bbEmptyString; \
    p = (ELEM_T*)BBARRAYDATA( bits, 1 ); \
    for( i=0; i<n_bits; ++i ){ \
        MAG_U_T v = (MAG_U_T)p[i]; \
        sz += DEC_LEN_FN( v ); \
    } \
    sz += (n_bits-1) * sep->length; \
    str = bbStringNew( sz ); \
    t = str->buf; \
    p = (ELEM_T*)BBARRAYDATA( bits, 1 ); \
    for( i=0; i<n_bits; ++i ){ \
        MAG_U_T v = (MAG_U_T)p[i]; \
        if( i ){ memcpy( t, sep->buf, sep->length * sizeof(BBChar) ); t += sep->length; } \
        int dlen = DEC_LEN_FN( v ); \
        BBChar *end = t + dlen; \
        (void)WRITE_BACK_FN( end, v ); \
        t = end; \
    } \
    return str; \
}

BB_DEFINE_JOIN_UNSIGNED(bbStringJoinBytes,  BBBYTE,  uint32_t, u32_dec_len, write_u32_dec_backwards)
BB_DEFINE_JOIN_UNSIGNED(bbStringJoinShorts, BBSHORT, uint32_t, u32_dec_len, write_u32_dec_backwards)
BB_DEFINE_JOIN_UNSIGNED(bbStringJoinUInts,  BBUINT,  uint32_t, u32_dec_len, write_u32_dec_backwards)
BB_DEFINE_JOIN_UNSIGNED(bbStringJoinULongs, BBULONG, uint64_t, u64_dec_len, write_u64_dec_backwards)

BBString *bbStringJoinSizets( BBString *sep, BBArray *bits ){
    if( sizeof(BBSIZET) == 8 ){
        return bbStringJoinULongs(sep, bits);
    }else{
        return bbStringJoinUInts(sep, bits);
    }
}

BBString *bbStringJoinULongInts( BBString *sep, BBArray *bits ){
    if( sizeof(BBULONGINT) == 8 ){
        return bbStringJoinULongs(sep, bits);
    }else{
        return bbStringJoinUInts(sep, bits);
    }
}
