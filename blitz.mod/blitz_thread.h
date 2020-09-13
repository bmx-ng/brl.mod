
#ifndef BLITZ_THREAD_H
#define BLITZ_THREAD_H

#ifdef __cplusplus
extern "C"{
#endif

#ifdef _WIN32

#include <windows.h>
typedef CRITICAL_SECTION bb_mutex_t;
#define bb_mutex_init(MUTPTR) (InitializeCriticalSection(MUTPTR),1)
#define bb_mutex_destroy(MUTPTR) DeleteCriticalSection(MUTPTR)
#define bb_mutex_lock(MUTPTR) EnterCriticalSection(MUTPTR)
#define bb_mutex_unlock(MUTPTR) LeaveCriticalSection(MUTPTR)
#define bb_mutex_trylock(MUTPTR) (TryEnterCriticalSection(MUTPTR)!=0)

/*
typedef HANDLE bb_mutex_t;
#define bb_mutex_init(MUTPTR) ((*(MUTPTR)=CreateMutex(0,0,0))!=0)
#define bb_mutex_destroy(MUTPTR) CloseHandle(*(MUTPTR))
#define bb_mutex_lock(MUTPTR) WaitForSingleObject(*(MUTPTR),INFINITE)
#define bb_mutex_unlock(MUTPTR) ReleaseMutex(*(MUTPTR))
#define bb_mutex_trylock(MUTPTR) (WaitForSingleObject(*(MUTPTR),0 )==WAIT_OBJECT_0) 
*/

typedef HANDLE bb_sem_t;
#define bb_sem_init(SEMPTR,COUNT) ((*(SEMPTR)=CreateSemaphore(0,(COUNT),0x7fffffff,0))!=0)
#define bb_sem_destroy(SEMPTR) CloseHandle(*(SEMPTR))
#define bb_sem_wait(SEMPTR) WaitForSingleObject(*(SEMPTR),INFINITE)
#define bb_sem_post(SEMPTR) ReleaseSemaphore(*(SEMPTR),1,0)
#define bb_sem_timed_wait(SEMPTR, MILLIS) WaitForSingleObject(*(SEMPTR),MILLIS)

#elif __SWITCH__
#include<switch/kernel/mutex.h>
#include<switch/kernel/semaphore.h>
#include <threads.h>

typedef mtx_t bb_mutex_t;
#define bb_mutex_init(MUTPTR) (mtx_init(MUTPTR,mtx_recursive),1)
#define bb_mutex_destroy(MUTPTR)
#define bb_mutex_lock(MUTPTR) mtx_lock(MUTPTR)
#define bb_mutex_unlock(MUTPTR) mtx_unlock(MUTPTR)
#define bb_mutex_trylock(MUTPTR) (mtx_trylock(MUTPTR)!=0)

typedef Semaphore bb_sem_t;
#define bb_sem_init(SEMPTR,COUNT) (semaphoreInit( (SEMPTR), (COUNT) ), 1)
#define bb_sem_destroy(SEMPTR)
#define bb_sem_wait(SEMPTR) semaphoreWait( (SEMPTR) )
#define bb_sem_post(SEMPTR) semaphoreSignal( (SEMPTR) )

#else

#include <pthread.h>
typedef pthread_mutex_t bb_mutex_t;
extern pthread_mutexattr_t _bb_mutexattr;
#define bb_mutex_init(MUTPTR) (pthread_mutex_init((MUTPTR),&_bb_mutexattr)>=0)
#define bb_mutex_destroy(MUTPTR) pthread_mutex_destroy(MUTPTR)
#define bb_mutex_lock(MUTPTR) pthread_mutex_lock(MUTPTR)
#define bb_mutex_unlock(MUTPTR) pthread_mutex_unlock(MUTPTR)
#define bb_mutex_trylock(MUTPTR) (pthread_mutex_trylock(MUTPTR)==0)

#endif

#ifdef __linux

#include <semaphore.h>
typedef sem_t bb_sem_t;
#define bb_sem_init(SEMPTR,COUNT) (sem_init((SEMPTR),0,(COUNT))>=0)
#define bb_sem_destroy sem_destroy
#define bb_sem_wait sem_wait
#define bb_sem_post sem_post
#define bb_sem_timed_wait sem_timedwait

#elif __HAIKU__
#include <semaphore.h>
typedef sem_t bb_sem_t;
#define bb_sem_init(SEMPTR,COUNT) (sem_init((SEMPTR),0,(COUNT))>=0)
#define bb_sem_destroy sem_destroy
#define bb_sem_wait sem_wait
#define bb_sem_post sem_post
#define bb_sem_timed_wait sem_timedwait

#endif

#ifdef _WIN32
#define BB_THREADREGS 7	//via GetThreadContext()
#elif __ppc__
#define BB_THREADREGS 19	//via bbGCRootRegs()
#else
#define BB_THREADREGS 4	//vid bbGCRootRegs()
#endif

#include "blitz_types.h"

typedef BBObject *(*BBThreadProc)( BBObject* );

typedef struct BBThread BBThread;

struct BBThread{
	BBThread *succ;
	BBThreadProc proc;
	void *data[32];
	int detached;
	int locked_regs[BB_THREADREGS];
#ifdef _WIN32
	BBObject * result;
	HANDLE handle;
	DWORD id;
#elif __SWITCH__
	thrd_t handle;
#else
	pthread_t handle;
#endif
};

void bbThreadPreStartup();
void			bbThreadStartup();

BBThread*		bbThreadCreate( BBThreadProc entry,BBObject *data );
void			bbThreadDetach( BBThread *thread );
BBObject*		bbThreadWait( BBThread *thread );

BBThread*		bbThreadGetMain();
BBThread*		bbThreadGetCurrent();

int			bbThreadResume( BBThread *thread );

int			bbThreadAllocData();
void			bbThreadSetData( int index,BBObject *data );
BBObject*		bbThreadGetData( int index );

int			bbAtomicCAS( volatile int *target,int oldVal,int newVal );
int			bbAtomicAdd( volatile int *target,int incr );

#ifdef _WIN32
BBThread *bbThreadRegister( DWORD id );
#else
BBThread *bbThreadRegister( void * thd );
#endif
void bbThreadUnregister( BBThread * thread );


//Internal locks...
extern int _bbNeedsLock;
extern bb_mutex_t _bbLock;

#define BB_LOCK if( _bbNeedsLock ){ bb_mutex_lock( &_bbLock ); }
#define BB_UNLOCK if( _bbNeedsLock ){ bb_mutex_unlock( &_bbLock ); }

#ifdef __cplusplus
}
#endif

#endif
