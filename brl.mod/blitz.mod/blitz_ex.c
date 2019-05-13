
#include "blitz.h"


#define EX_GROW 10

typedef struct BBExEnv{
	jmp_buf buf;
	BBObject * ex;
}BBExEnv;

typedef struct BBExStack{
	BBExEnv *ex_base,*ex_sp,*ex_end;
}BBExStack;

#ifdef _WIN32

#include <windows.h>

static DWORD exKey(){
	static int done;
	static DWORD key;
	if( !done ){
		key=TlsAlloc();
		done=1;
	}
	return key;
}

BBExStack *getExStack(){
	return (BBExStack*)TlsGetValue( exKey() );
}

void setExStack( BBExStack *st ){
	TlsSetValue( exKey(),st );
}

#else

#include <pthread.h>

static pthread_key_t exKey(){
	static int done;
	static pthread_key_t key;
	if( !done ){
		pthread_key_create( &key,0 );
		done=1;
	}
	return key;
}

BBExStack *getExStack(){
	return (BBExStack*)pthread_getspecific( exKey() );
}

void setExStack( BBExStack *st ){
	pthread_setspecific( exKey(),st );
}

#endif

static BBExStack *exStack(){
	BBExStack *st=getExStack();
	if( !st ){
		st=(BBExStack*)bbMemAlloc( sizeof( BBExStack ) );
		memset( st,0,sizeof( BBExStack ) );
		setExStack( st );
	}
	return st;
}

static void freeExStack( BBExStack *st ){
	bbMemFree( st->ex_base );
	bbMemFree( st );
	setExStack( 0 );
}

BBObject* bbExObject() {
	BBExStack *st=getExStack();
	if (st) {
		BBObject * ex = st->ex_sp->ex;
		if (st->ex_sp==st->ex_base) {
			freeExStack(st);
		}
		return ex;
	} else {
		return &bbNullObject;
	}
}

jmp_buf *bbExEnter(){
	BBExStack *st=exStack();

	if( st->ex_sp==st->ex_end ){
		int len=st->ex_sp-st->ex_base,new_len=len+EX_GROW;
		st->ex_base=(BBExEnv*)bbMemExtend( st->ex_base,len*sizeof(BBExEnv),new_len*sizeof(BBExEnv) );
		st->ex_end=st->ex_base+new_len;
		st->ex_sp=st->ex_base+len;
	}

	return &((st->ex_sp++)->buf);
}

void bbExThrow( BBObject *p ){
	BBExStack *st=getExStack();

	if( !st ) bbOnDebugUnhandledEx( p );
	
	--st->ex_sp;
	st->ex_sp->ex = p;
	longjmp(st->ex_sp->buf, 1);
}

void bbExLeave(){
	BBExStack *st=getExStack();
	
	//invariant...leaving a Try!
	//assert( st && st->ex_sp!=st->ex_base );
	
	if( --st->ex_sp==st->ex_base ){
		freeExStack( st );
	}
}

void bbExThrowCString( const char *p ){
	bbExThrow( (BBObject*)bbStringFromCString( p ) );
}
