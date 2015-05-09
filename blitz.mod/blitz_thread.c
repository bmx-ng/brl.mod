
#include "blitz.h"

#include "bdwgc/libatomic_ops/src/atomic_ops.h"

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

int bbThreadAllocData(){
	if( threadDataId<31 ) return ++threadDataId;
	return 0;
}

void bbThreadSetData( int index,BBObject *data ){
	bbThreadGetCurrent()->data[index]=data;
}

BBObject *bbThreadGetData( int index ){
	BBObject *data=bbThreadGetCurrent()->data[index];
	return data ? data : &bbNullObject;
}

//***** Windows threads *****
#ifdef _WIN32

static DWORD curThreadTls;

static DWORD WINAPI threadProc( void *p ){
	BBThread *thread=p;
	
	TlsSetValue( curThreadTls,thread );
	
	DWORD ret=(DWORD)thread->proc( thread->data[0] );
	
	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
	
	return ret;
}

void bbThreadStartup(){

	if( bb_mutex_init( &_bbLock )<0 ) exit(-1);

	curThreadTls=TlsAlloc();

	BBThread *thread=GC_MALLOC( sizeof( BBThread ) );
	
	thread->proc=0;
	memset( thread->data,0,sizeof(thread->data) );
	thread->detached=0;
	thread->stackTop=bbGCStackTop;
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
	BBThread *thread=GC_MALLOC( sizeof( BBThread ) );
	
	thread->proc=proc;
	memset( thread->data,0,sizeof(thread->data) );
	thread->data[0]=data;
	thread->detached=0;
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
		BBObject *p;
		if( GetExitCodeThread( thread->handle,(DWORD*)&p ) ){
			thread->detached=1;
			return p;
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

BBThread *_bbThreadLockThreads(){
	BBThread *curThread=bbThreadGetCurrent();
	BBThread *t;
	for( t=threads;t;t=t->succ ){
		if( t!=curThread ){
			SuspendThread( t->handle );
		}
	}
	return threads;
}

void _bbThreadUnlockThreads(){
	BBThread *curThread=bbThreadGetCurrent();
	BBThread *t;
	for( t=threads;t;t=t->succ ){
		if( t!=curThread ){
			ResumeThread( t->handle );
		}
	}
}

//***** POSIX threads *****
#else

#include <unistd.h>
#include <signal.h>

#if __linux
#define MUTEX_RECURSIVE 1
#elif __APPLE__
#define MUTEX_RECURSIVE 2
#endif

pthread_mutexattr_t _bb_mutexattr;

static BBThread *threads;
static pthread_key_t curThreadTls;

static void suspendSigHandler( int sig ){//,siginfo_t *info,ucontext_t *ctx ){
	BBThread *thread=pthread_getspecific( curThreadTls );
	
#ifdef DEBUG_THREADS
	printf( "In suspendSigHandler! thread=%p locked_sp=%p\n",thread,thread->locked_sp );fflush( stdout );
#endif
	
	bb_sem_post( &thread->acksema );
	
	//wait for resume - apparently very naughty!
	bb_sem_wait( &thread->runsema );

#ifdef DEBUG_THREADS	
	printf( "Got resume!\n" );fflush( stdout );
#endif
}

void bbThreadStartup(){

	if( pthread_mutexattr_init( &_bb_mutexattr )<0 ) exit(-1);
	if( pthread_mutexattr_settype( &_bb_mutexattr,MUTEX_RECURSIVE )<0 ) exit(-1);
	
	if( pthread_key_create( &curThreadTls,0 )<0 ) exit(-1);

	if( bb_mutex_init( &_bbLock )<0 ) exit(-1);
	
	struct sigaction act;
	memset( &act,0,sizeof(act) );
	act.sa_handler=suspendSigHandler;
	act.sa_flags=SA_RESTART;
		
	if( sigaction( SIGUSR2,&act,0 )<0 ) exit(-1);
		
	BBThread *thread=GC_MALLOC( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->proc=0;
	thread->detached=0;
	thread->suspended=0;
	thread->handle=pthread_self();
	if( !bb_sem_init( &thread->runsema,0 ) ) exit(-1);
	if( !bb_sem_init( &thread->acksema,0 ) ) exit(-1);

	thread->stackTop=bbGCStackTop;
	pthread_setspecific( curThreadTls,thread );
	
	thread->succ=threads;
	threads=thread;
	mainThread=thread;
}

static void *threadProc( void *p ){
	BBThread *thread=p;
	
	pthread_setspecific( curThreadTls,thread );
	
	BB_LOCK
	addThread( thread );
	BB_UNLOCK
	
	bb_sem_post( &thread->acksema );
	bb_sem_wait( &thread->runsema );
	
#ifdef DEBUG_THREADS
	printf( "Thread %p added, stackTop=%p\n",thread,thread->stackTop );fflush( stdout );
#endif
	
	void *ret=thread->proc( thread->data[0] );
	
	BB_LOCK
	removeThread( thread );
	BB_UNLOCK
	
	bb_sem_destroy( &thread->runsema );
	bb_sem_destroy( &thread->acksema );
	
#ifdef DEBUG_THREADS
	printf( "Thread %p removed\n",thread );fflush( stdout );
#endif
	
	return ret;
}

BBThread *bbThreadCreate( BBThreadProc proc,BBObject *data ){
	BBThread *thread=GC_MALLOC( sizeof( BBThread ) );
	memset( thread->data,0,sizeof(thread->data) );
	
	thread->proc=proc;
	thread->data[0]=data;
	thread->detached=0;
	thread->suspended=1;
	if( bb_sem_init( &thread->runsema,0 ) ){
		if( bb_sem_init( &thread->acksema,0 ) ){
			if( pthread_create( &thread->handle,0,threadProc,thread )>=0 ){
				bb_sem_wait( &thread->acksema );
				_bbNeedsLock=1;
				return thread;
			}
			bb_sem_destroy( &thread->acksema );
		}
		bb_sem_destroy( &thread->runsema );
	}
	GC_FREE( thread );
	return 0;
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

int bbThreadSuspend( BBThread *thread ){
	BB_LOCK
	
	int n=thread->suspended++;
	
	if( n==0 ){
		pthread_kill( thread->handle,SIGUSR2 );
		bb_sem_wait( &thread->acksema );
	}

	BB_UNLOCK
	
	return n;
}

int bbThreadResume( BBThread *thread ){
	BB_LOCK
	
	int n=thread->suspended--;
	
	if( n==1 ){
		bb_sem_post( &thread->runsema );
	}
	
	BB_UNLOCK
	
	return n;
}

BBThread *_bbThreadLockThreads(){
	BBThread *curThread=bbThreadGetCurrent();
	BBThread *t;
	for( t=threads;t;t=t->succ ){
		if( t!=curThread ){
			if( !t->suspended++ ){
				pthread_kill( t->handle,SIGUSR2 );
				bb_sem_wait( &t->acksema );
			}
		}
	}
	return threads;
}

void _bbThreadUnlockThreads(){
	BBThread *curThread=bbThreadGetCurrent();
	BBThread *t;
	for( t=threads;t;t=t->succ ){
		if( t!=curThread ){
			if( !--t->suspended ){
				bb_sem_post( &t->runsema );
			}
		}
	}
}

#endif

//***** Atomic ops *****

int bbAtomicCAS( volatile int *addr,int old,int new_val ){
	return AO_int_compare_and_swap(addr, old, new_val);
}

int bbAtomicAdd( volatile int *p,int incr ){
	return AO_fetch_and_add((AO_t*)p, incr);
}

#endif // __EMSCRIPTEN__
