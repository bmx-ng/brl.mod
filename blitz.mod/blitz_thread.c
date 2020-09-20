
#include "blitz.h"

#include "bdwgc/libatomic_ops/src/atomic_ops.h"

#ifdef __APPLE__
#include <libkern/OSAtomic.h>
#endif

//#define DEBUG_THREADS

#ifndef __EMSCRIPTEN__

//***** Common *****

int _bbNeedsLock;
bb_mutex_t _bbLock;

static int threadDataId;

static BBThread *threads;
static BBThread *deadThreads;

static BBThread *mainThread;

static void flushDeadThreads(){
	BBThread **p=&deadThreads,*t;
	while( t=*p ){
		if( t->detached ){
			*p=t->succ;
#ifdef _WIN32
			CloseHandle( t->handle );
#endif
			GC_FREE( t );
		}else{
			p=&t->succ;
		}
	}
}

static void addThread( BBThread *thread ){
	flushDeadThreads();
	thread->succ=threads;
	threads=thread;
}

static void removeThread( BBThread *thread ){
	BBThread **p=&threads,*t;
	while( t=*p ){
		if( t==thread ){
			*p=t->succ;
			if( t->detached ){
#ifdef _WIN32
				CloseHandle( t->handle );
#endif
				GC_FREE( t );
			}else{
				t->succ=deadThreads;
				deadThreads=t;
			}
			break;
		}else{
			p=&t->succ;
		}
	}
}

static void * bbRegisterGCThread(struct GC_stack_base * sb, void * arg) {
    GC_register_my_thread(sb);
    return NULL; 
}

int bbThreadAllocData(){
	if( threadDataId<31 ) return ++threadDataId;
	return 0;
}

void bbThreadSetData( int index,BBObject *data ){
	bbThreadGetCurrent()->data[index]=data;
}

BBObject *bbThreadGetData( int index ){
	BBObject * data = bbThreadGetCurrent()->data[index];
	return data ? data : &bbNullObject;
}

//***** Windows threads *****
#ifdef _WIN32

static DWORD curThreadTls;

static DWORD WINAPI threadProc( void *p ){
	BBThread *thread=p;
	
	TlsSetValue( curThreadTls,thread );
	
	BBObject * result = thread->proc( thread->data[0] );
	thread->result = result;

	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
	
	return 0;
}

void bbThreadPreStartup(){
}

void bbThreadStartup(){

	if( bb_mutex_init( &_bbLock )<0 ) exit(-1);

	curThreadTls=TlsAlloc();

	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	
	thread->proc=0;
	memset( thread->data,0,sizeof(thread->data) );
	thread->detached=0;
	thread->id=GetCurrentThreadId();
	if( !DuplicateHandle( GetCurrentProcess(),GetCurrentThread(),GetCurrentProcess(),&thread->handle,0,FALSE,DUPLICATE_SAME_ACCESS ) ){
		exit( -1 );
	}

	TlsSetValue( curThreadTls,thread );
	
	thread->succ=threads;
	threads=thread;
	mainThread=thread;
}

BBThread *bbThreadCreate( BBThreadProc proc,BBObject *data ){
	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	
	thread->proc=proc;
	memset( thread->data,0,sizeof(thread->data) );
	thread->data[0]=data;
	thread->detached=0;
	thread->result = &bbNullObject;
	thread->handle=CreateThread( 0,0,threadProc,thread,CREATE_SUSPENDED,&thread->id );

	BB_LOCK
	addThread( thread );
	BB_UNLOCK

	_bbNeedsLock=1;
	
	return thread;
}

void bbThreadDetach( BBThread *thread ){
	thread->detached=1;
}

BBObject *bbThreadWait( BBThread *thread ){
	if( WaitForSingleObject( thread->handle,INFINITE )==WAIT_OBJECT_0 ){
		DWORD res;
		if( GetExitCodeThread( thread->handle, &res ) ){
			thread->detached=1;
			return thread->result;
		}else{
			printf( "ERROR! bbThreadWait: GetExitCodeThread failed!\n" );
		}
	}else{
		printf( "ERROR! bbThreadWait: WaitForSingleObject failed!\n" );
	}
	printf( "LastError=%i\n",GetLastError() );
	
	return &bbNullObject;
}

BBThread *bbThreadGetMain(){
	return mainThread;
}

BBThread *bbThreadGetCurrent(){
	return TlsGetValue( curThreadTls );
}

int bbThreadSuspend( BBThread *thread ){
	return SuspendThread( thread->handle );
}

int bbThreadResume( BBThread *thread ){
	return ResumeThread( thread->handle );
}

BBThread *bbThreadRegister( DWORD id ) {

	GC_call_with_stack_base(bbRegisterGCThread, NULL);

	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->handle = 0;
	thread->proc=0;
	thread->data[0]=0;
	thread->detached=0;
	thread->id = id;
	
	TlsSetValue( curThreadTls,thread );

	BB_LOCK
	addThread( thread );
	BB_UNLOCK
	
	return thread;
}

void bbThreadUnregister( BBThread * thread ) {

	GC_unregister_my_thread();

	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
}

#elif __SWITCH__

static __thread BBThread * bbThread;

void bbThreadPreStartup(){
}

void bbThreadStartup() {

	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	
	thread->proc=0;
	thread->detached=0;
	thread->handle=thrd_current();

	bbThread = thread;

	thread->succ=threads;
	threads=thread;
	mainThread=thread;
}

static BBObject * threadProc( void *p ){

	GC_call_with_stack_base(bbRegisterGCThread, NULL);

	BBThread *thread = p;
	
	bbThread = thread;
	
	BB_LOCK
	addThread( thread );
	BB_UNLOCK
	
#ifdef DEBUG_THREADS
	printf( "Thread %p added\n",thread );fflush( stdout );
#endif
	
	BBObject * ret=thread->proc( thread->data[0] );
	
	GC_unregister_my_thread();
	
	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
	
#ifdef DEBUG_THREADS
	printf( "Thread %p removed\n",thread );fflush( stdout );
#endif
	
	return ret;
}

BBThread * bbThreadCreate( BBThreadProc proc,BBObject *data ) {
	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->proc=proc;
	thread->data[0]=data;
	thread->detached=0;
	if( thrd_create( &thread->handle,threadProc,thread ) == thrd_success ){
		_bbNeedsLock=1;
		return thread;
	}
	GC_FREE( thread );
	return 0;
}

void bbThreadDetach( BBThread *thread ) {
	thread->detached=1;
//	thrd_detach( thread->handle );
}

BBObject * bbThreadWait( BBThread *thread ) {
	BBObject *p=0;
	thread->detached=1;
	thrd_join( thread->handle,&p );
	return p;
}

BBThread * bbThreadGetMain() {
	return mainThread;
}

BBThread * bbThreadGetCurrent() {
	return bbThread;
}

int bbThreadResume( BBThread *thread ) {
	return 0;
}

//***** POSIX threads *****
#else

#include <unistd.h>
#include <signal.h>

#if __linux
#define MUTEX_RECURSIVE 1
#elif __APPLE__
#define MUTEX_RECURSIVE 2
#elif __SWITCH__
#define MUTEX_RECURSIVE 1
#elif __HAIKU__
#define MUTEX_RECURSIVE 3
#endif

pthread_mutexattr_t _bb_mutexattr;

static BBThread *threads;
static pthread_key_t curThreadTls;

void bbThreadPreStartup(){
	if( pthread_mutexattr_init( &_bb_mutexattr )<0 ) exit(-1);
	if( pthread_mutexattr_settype( &_bb_mutexattr,MUTEX_RECURSIVE )<0 ) exit(-1);
}

void bbThreadStartup(){

	if( pthread_key_create( &curThreadTls,0 )<0 ) exit(-1);

	if( bb_mutex_init( &_bbLock )<0 ) exit(-1);
		
	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->proc=0;
	thread->detached=0;
	thread->handle=pthread_self();

	pthread_setspecific( curThreadTls,thread );
	
	thread->succ=threads;
	threads=thread;
	mainThread=thread;
}

static void *threadProc( void *p ){

	GC_call_with_stack_base(bbRegisterGCThread, NULL);

	BBThread *thread=p;
	
	pthread_setspecific( curThreadTls,thread );
	
	BB_LOCK
	addThread( thread );
	BB_UNLOCK
	
#ifdef DEBUG_THREADS
	printf( "Thread %p added\n",thread );fflush( stdout );
#endif
	
	void *ret=thread->proc( thread->data[0] );
	
	GC_unregister_my_thread();
	
	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
	
#ifdef DEBUG_THREADS
	printf( "Thread %p removed\n",thread );fflush( stdout );
#endif
	
	return ret;
}

BBThread *bbThreadCreate( BBThreadProc proc,BBObject *data ){
	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->proc=proc;
	thread->data[0]=data;
	thread->detached=0;
	if( pthread_create( &thread->handle,0,threadProc,thread )==0 ){
		_bbNeedsLock=1;
		return thread;
	}
	GC_FREE( thread );
	return 0;
}

BBThread *bbThreadRegister( void * thd ) {

	GC_call_with_stack_base(bbRegisterGCThread, NULL);

	BBThread *thread=GC_MALLOC_UNCOLLECTABLE( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->handle = thd;
	thread->proc=0;
	thread->data[0]=0;
	thread->detached=0;
	
	pthread_setspecific( curThreadTls,thread );

	BB_LOCK
	addThread( thread );
	BB_UNLOCK
	
	return thread;
}

void bbThreadUnregister( BBThread * thread ) {

	GC_unregister_my_thread();

	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
}

void bbThreadDetach( BBThread *thread ){
	thread->detached=1;
	pthread_detach( thread->handle );
}

BBObject *bbThreadWait( BBThread *thread ){
	BBObject *p=0;
	thread->detached=1;
	pthread_join( thread->handle,&p );
	return p;
}

BBThread *bbThreadGetMain(){
	return mainThread;
}

BBThread *bbThreadGetCurrent(){
	return pthread_getspecific( curThreadTls );
}

int bbThreadResume( BBThread *thread ){
	return 0;
}
#endif

//***** Atomic ops *****
int bbAtomicCAS( volatile int *addr,int old,int new_val ){
#if !defined(__ANDROID__) && !defined(_WIN32)
#	ifndef __APPLE__
		return __sync_bool_compare_and_swap(addr, old, new_val);
#	else
		return OSAtomicCompareAndSwap32(old, new_val, addr);
#	endif
#else
	return __sync_bool_compare_and_swap(addr, old, new_val);
#endif
}

int bbAtomicAdd( volatile int *p,int incr ){
#if !defined(__ANDROID__) && !defined(_WIN32)
#	ifndef __APPLE__
		return __sync_fetch_and_add(p, incr);
#	else
		return OSAtomicAdd32(incr, p);
#	endif
#else
	return __sync_fetch_and_add(p, incr);
#endif
}

#endif // __EMSCRIPTEN__
