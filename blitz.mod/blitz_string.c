
#include "blitz.h"

#include "bdwgc/libatomic_ops/src/atomic_ops.h"

#include "blitz_unicode.h"

#define XXH_IMPLEMENTATION
#define XXH_STATIC_LINKING_ONLY

#include "hash/xxh3.h"

static void bbStringFree( BBObject *o );

static BBDebugScope debugScope={
	BBDEBUGSCOPE_USERTYPE,
	"String",
	BBDEBUGDECL_END
};

BBClass bbStringClass={
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
	bbStringHash
};

BBString bbEmptyString={
	&bbStringClass, //clas
	0x776eddfb6bfd9195, // hash
	0				//length
};

static int wstrlen( const BBChar *p ){
	const BBChar *t=p;
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

//***** Note: Not called in THREADED mode.
static void bbStringFree( BBObject *o ){
	if (bbCountInstances) {
		bbAtomicAdd(&bbStringClass.instance_count, -1);
	}
}

BBString *bbStringNew( int len ){
	int flags;
	BBString *str;
	if( !len ) return &bbEmptyString;
	str=(BBString*)bbGCAllocObject( sizeof(BBString)+len*sizeof(BBChar),&bbStringClass,BBGC_ATOMIC );
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

	return bbStringFromBytes( buf, strlen(buf) );
}

BBString *bbStringFromUInt( unsigned int n ){
	char buf[64];

	sprintf(buf, "%u", n);

	return bbStringFromBytes( buf, strlen(buf) );
}

BBString *bbStringFromLong( BBInt64 n ){
	char buf[64];

	sprintf(buf, "%lld", n);

	return bbStringFromBytes( buf,strlen(buf) );
}

BBString *bbStringFromULong( BBUInt64 n ){
	char buf[64];

	sprintf(buf, "%llu", n);

	return bbStringFromBytes( buf, strlen(buf) );
}

BBString *bbStringFromSizet( BBSIZET n ){
	char buf[64];
	
#if UINTPTR_MAX == 0xffffffff
	sprintf(buf, "%u", n);
#else
	sprintf(buf, "%llu", n);
#endif

	return bbStringFromBytes( buf, strlen(buf) );
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

BBString *bbStringFromBytes( const char *p,int n ){
	int k;
	BBString *str;
	if( !n ) return &bbEmptyString;
	str=bbStringNew( n );
	for( k=0;k<n;++k ) str->buf[k]=(unsigned char)p[k];
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
	case 'b':return bbStringFromBytes( p,n );
	case 's':return bbStringFromShorts( p,n );
	case 'i':return bbStringFromInts( p,n );
	}
	return &bbEmptyString;
}

BBString *bbStringFromCString( const char *p ){
	return p ? bbStringFromBytes( p,strlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromWString( const BBChar *p ){
	return p ? bbStringFromShorts( p,wstrlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromUTF8String( const char *p ){
	return p ? bbStringFromUTF8Bytes( p,strlen(p) ) : &bbEmptyString;
}

BBString *bbStringFromUTF8Bytes( const char *p,int n ){
	int c;
	short *d,*q;
	BBString *str;

	if( !p || n <= 0 ) return &bbEmptyString;
	
	d=(short*)malloc( n*2 );
	q=d;
	
	while( n-- && (c=*p++ & 0xff)){
		if( c<0x80 ){
			*q++=c;
		}else{
			if (!n--) continue;
			int d=*p++ & 0x3f;
			if( c<0xe0 ){
				*q++=((c&31)<<6) | d;
			}else{
				if (!n--) continue;
				int e=*p++ & 0x3f;
				if( c<0xf0 ){
					*q++=((c&15)<<12) | (d<<6) | e;
				}else{
					if (!n--) continue;
					int f=*p++ & 0x3f;
					int v=((c&7)<<18) | (d<<12) | (e<<6) | f;
					if( v & 0xffff0000 ) {
						v -= 0x10000;
						d = ((v >> 10) & 0x7ff) + 0xd800;
						e = (v & 0x3ff) + 0xdc00;
						*q++=d;
						*q++=e;
					}else{
						*q++=v;
					}
				}
			}
		}
	}
	str=bbStringFromShorts( d,q-d );
	free( d );
	return str;
}

BBString *bbStringToString( BBString *t ){
	return t;
}

int bbStringCompare( BBString *x,BBString *y ){
	int k,n,sz;
	sz=x->length<y->length ? x->length : y->length;
	for( k=0;k<sz;++k ) if( n=x->buf[k]-y->buf[k] ) return n;
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
	else if( neg=(t->buf[i]=='-') ) ++i;
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
	int i=0;
	unsigned n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( t->buf[i]=='-' ) ++i;
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
	return n;
}

BBInt64 bbStringToLong( BBString *t ){
	int i=0,neg=0;
	BBInt64 n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( neg=(t->buf[i]=='-') ) ++i;
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
	int i=0;
	BBUInt64 n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( t->buf[i]=='-' ) ++i;
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
	return n;
}

BBSIZET bbStringToSizet( BBString *t ){
	int i=0,neg=0;
	BBSIZET n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ){ return 0; }
	
	if( t->buf[i]=='+' ) ++i;
	else if( neg=(t->buf[i]=='-') ) ++i;
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
	return n;
}

float bbStringToFloat( BBString *t ){
	char *p=bbStringToCString( t );
	float n=atof( p );
	bbMemFree( p );
	return n;
}

double bbStringToDouble( BBString *t ){
	char *p=bbStringToCString( t );
	double n=atof( p );
	bbMemFree( p );
	return n;
}

#ifdef _WIN32
WPARAM bbStringToWParam( BBString *t ){
	int i=0;
	WPARAM n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( t->buf[i]=='-' ) ++i;
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
	return n;
}

BBString *bbStringFromWParam( WPARAM n ){
	char buf[64];

#ifdef __x86_64__
	sprintf(buf, "%llu", n);
#else
	sprintf(buf, "%u", n);
#endif

	return bbStringFromBytes( buf, strlen(buf) );
}

LPARAM bbStringToLParam( BBString *t ){
	int i=0,neg=0;
	LPARAM n=0;
	
	while( i<t->length && isspace(t->buf[i]) ) ++i;
	if( i==t->length ) return 0;
	
	if( t->buf[i]=='+' ) ++i;
	else if( neg=(t->buf[i]=='-') ) ++i;
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

	return bbStringFromBytes( buf, strlen(buf) );
}


#endif




BBString *bbStringToLower( BBString *str ){
	int k;
	BBString *t;
	int n = 0;
	
	while (n < str->length) {
		int c=str->buf[n];
		// ascii upper or other unicode char
		if (c >= 192 || (c>='A' && c<='Z')) {
			break;
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
		int c=str->buf[n];
		// ascii lower or other unicode char
		if (c >= 181 || (c>='a' && c<='z')) {
			break;
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

char *bbStringToCString( BBString *str ){
	char *p;
	int k,sz=str->length;
	p=(char*)bbMemAlloc( sz+1 );
	for( k=0;k<sz;++k ) p[k]=str->buf[k];
	p[sz]=0;
	return p;
}

BBChar *bbStringToWString( BBString *str ){
	BBChar *p;
	int k,sz=str->length;
	p=(BBChar*)bbMemAlloc( (sz+1)*sizeof(BBChar) );
	memcpy(p,str->buf,sz*sizeof(BBChar));
	p[sz]=0;
	return p;
}

char *bbStringToUTF8String( BBString *str ){
	int i=0,len=str->length;
	size_t buflen = len * 4 + 1;
	char *buf=(char*)bbMemAlloc( buflen );
	return bbStringToUTF8StringBuffer(str, buf, &buflen);
}

char *bbStringToUTF8StringBuffer( BBString *str, char * buf, size_t * length ){
	int i=0,len=str->length;
	size_t buflen = *length;
	char *q=buf;
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
		int n = q - buf;
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
	char *p=bbStringToCString( str );
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
	char *p=bbStringToUTF8String( str );
	mktmp( p );
	return p;
}

#if __STDC_VERSION__ >= 199901L
extern int bbStringEquals( BBString *x,BBString *y);
extern int bbObjectIsEmptyString(BBObject * o);
extern BBULONG bbStringHash( BBString * x );
#else
int bbStringEquals( BBString *x,BBString *y ){
	if (x->length-y->length != 0) return 0;
	if (x->hash != 0 && x->hash == y->hash) return 1;
	BBChar * bx = x->buf;
	BBChar * by = y->buf;
	int k = x->length;
	while( k-- ) if ( *bx++ - *by++ != 0 ) return 0;
	return 1;
}

int bbObjectIsEmptyString(BBObject * o) {
	return (BBString*)o == &bbEmptyString;
}

BBULONG bbStringHash( BBString * x ) {
	if (x->hash > 0) return x->hash;
	x->hash = XXH3_64bits(x->buf, x->length * sizeof(BBChar));
	return x->hash;
}

#endif
