
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
	bbStringHash,

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
	0x776eddfb6bfd9195, // hash
	0				//length
};

static int wstrlen( const BBChar *p ){
	const BBChar *t=p;
	while( *t ) ++t;
	return t-p;
}

static int utf32strlen( const BBUINT *p ){
	const BBUINT *t=p;
	while( *t ) ++t;
	return t-p;
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
extern BBULONG bbStringHash( BBString * x );
#else
BBULONG bbStringHash( BBString * x ) {
	if (x->hash > 0) return x->hash;
	x->hash = XXH3_64bits(x->buf, x->length * sizeof(BBChar));
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
	if (bbCountInstances) {
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

BBString *bbStringFromFloat( float n ){
	char buf[64];
	sprintf( buf,"%#.9g",n );
	return bbStringFromCString(buf);
}

BBString *bbStringFromDouble( double n ){
	char buf[64];
	sprintf( buf,"%#.17lg",n );
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
	if (x->length == y->length && x->hash) {
		if (!y->hash) bbStringHash(y);
		if (x->hash == y->hash) return 0;
	}
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
	size_t sz = str->length + 1 < *length ? str->length + 1 : *length;
	BBChar * p = buf;
	memcpy(p,str->buf,sz*sizeof(BBChar));
	p[sz-1]=0;
	return p;
}

unsigned char *bbStringToUTF8String( BBString *str ){
	int len=str->length;
	size_t buflen = len * 4 + 1;
	unsigned char *buf=(unsigned char*)bbMemAlloc( buflen );
	return bbStringToUTF8StringBuffer(str, buf, &buflen);
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
	int len=str->length;
	int n = 0;
	size_t buflen = len * 4 + 4;
	BBUINT *buf=(BBUINT*)bbMemAlloc( buflen );

	BBChar *p=str->buf;
	BBUINT *bp = buf;
	while( *p ) {
		n++;
		BBChar c = *p++;
		if (!((c - 0xd800u) < 2048u)) {
			*bp++ = c;
		} else {
			if (((c & 0xfffffc00) == 0xd800) && n < len && ((*p & 0xfffffc00) == 0xdc00)) {
				*bp++ = (c << 10) + (*p++) - 0x35fdc00;
			} else {
				bbMemFree( buf );
				bbExThrowCString( "Failed to create UTF32. Invalid surrogate pair." );
			}
		}
	}
	*bp = 0;
	return buf;
}

BBString* bbStringFromUTF32String( const BBUINT *p ) {
	return p ? bbStringFromUTF32Bytes(p, utf32strlen(p)) : &bbEmptyString;
}

BBString* bbStringFromUTF32Bytes( const BBUINT *p, int n ) {
	if( !p || n <= 0 ) return &bbEmptyString;
	
	int len = n * 2;
	unsigned short * d=(unsigned short*)malloc( n * sizeof(BBChar) * 2 );
	unsigned short * q=d;

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