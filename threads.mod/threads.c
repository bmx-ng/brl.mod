
#include <brl.mod/blitz.mod/blitz.h>

//***** Threads *****
BBThread *threads_CreateThread( BBThreadProc entry,BBObject *data ){
	BBThread *thread=bbThreadCreate( entry,data );
	bbThreadResume( thread );
	return thread;
}

void threads_DetachThread( BBThread *thread ){
	bbThreadDetach( thread );
}

BBObject *threads_WaitThread( BBThread *thread ){
	return bbThreadWait( thread );
}

//***** Mutexes *****
bb_mutex_t *threads_CreateMutex(){
	bb_mutex_t *mutex=malloc( sizeof(bb_mutex_t) );
	if( bb_mutex_init( mutex ) ) return mutex;
	free( mutex );
	return 0;
}

void threads_CloseMutex( bb_mutex_t *mutex ){
	bb_mutex_destroy( mutex );
	free( mutex );
}

void threads_LockMutex( bb_mutex_t *mutex ){
	bb_mutex_lock( mutex );
}

void threads_UnlockMutex( bb_mutex_t *mutex ){
	bb_mutex_unlock( mutex );
}

int threads_TryLockMutex( bb_mutex_t *mutex ){
	return bb_mutex_trylock( mutex );
}

//***** Semaphores *****
#ifndef __APPLE__
bb_sem_t *threads_CreateSemaphore( int count ){
	bb_sem_t *sem=malloc( sizeof(bb_sem_t) );
	if( bb_sem_init( sem,count ) ) return sem;
	free( sem );
	return 0;
}

void threads_CloseSemaphore( bb_sem_t *sem ){
	bb_sem_destroy( sem );
	free( sem );
}

void threads_WaitSemaphore( bb_sem_t *sem ){
	bb_sem_wait( sem );
}

void threads_PostSemaphore( bb_sem_t *sem ){
	bb_sem_post( sem );
}
#endif
//***** CondVars *****
#ifdef _WIN32

int threads_TimedWaitSemaphore( bb_sem_t *sem, int millisecs ){

	int res = bb_sem_timed_wait( sem, millisecs );
	if (res == WAIT_TIMEOUT) {
		return 1;
	} else if (res == WAIT_FAILED) {
		return -1;
	}
	return 0;
}

typedef struct BBCond BBCond;

struct BBCond{
	int waiters;
	bb_sem_t sema;
};

BBCond *threads_CreateCond(){
	BBCond *cond=(BBCond*)malloc( sizeof( BBCond ) );
	
	cond->waiters=0;
	bb_sem_init( &cond->sema,0 );
	
	return cond;
}

void threads_CloseCond( BBCond *cond ){
	bb_sem_destroy( &cond->sema );
	free( cond );
}

void threads_WaitCond( BBCond *cond,bb_mutex_t *mutex ){
	bbAtomicAdd( &cond->waiters,1 );

	//Ok, the below is not strictly speaking 'fair'.
	//A context switch below the mutex_unlock and sem_wait could end up
	//starving this thread (I think). Possibly not a problem unless app is 
	//really thrashing, but should be fixed none-the-less. 
	//
	bb_mutex_unlock( mutex );

	bb_sem_wait( &cond->sema );

	bb_mutex_lock( mutex );
}

int threads_TimedWaitCond( BBCond *cond,bb_mutex_t *mutex, int millisecs ){
	bbAtomicAdd( &cond->waiters,1 );

	//Ok, the below is not strictly speaking 'fair'.
	//A context switch below the mutex_unlock and sem_wait could end up
	//starving this thread (I think). Possibly not a problem unless app is 
	//really thrashing, but should be fixed none-the-less. 
	//
	bb_mutex_unlock( mutex );

	int res = bb_sem_timed_wait( &cond->sema, millisecs );

	bb_mutex_lock( mutex );
	
	if (res == WAIT_TIMEOUT) {
		return 1;
	} else if (res == WAIT_FAILED) {
		return -1;
	}
	return 0;
}

void threads_SignalCond( BBCond *cond ){
	int waiters;
	while( waiters=cond->waiters ){
		if( bbAtomicCAS( &cond->waiters,waiters,waiters-1 ) ){
			bb_sem_post( &cond->sema );
			return;
		}
	}
}

void threads_BroadcastCond( BBCond *cond ){
	int waiters;
	while( waiters=cond->waiters ){
		if( bbAtomicCAS( &cond->waiters,waiters,0 ) ){
			while( waiters-- ){
				bb_sem_post( &cond->sema );
			}
			return;
		}
	}
}

#elif __SWITCH__

cnd_t *threads_CreateCond(){
	cnd_t *cond=malloc( sizeof(cnd_t) );
	if( cnd_init( cond )==thrd_success ) return cond;
	free( cond );
	return 0;
}

void threads_CloseCond( cnd_t *cond ){
	free( cond );
}

void threads_WaitCond( cnd_t *cond,bb_mutex_t *mutex ){
	cnd_wait( cond,mutex );
}

void threads_SignalCond( cnd_t *cond ){
	cnd_signal( cond );
}

void threads_BroadcastCond( cnd_t *cond ){
	cnd_broadcast( cond );
}

#else

#include <errno.h>

pthread_cond_t *threads_CreateCond(){
	pthread_cond_t *cond=malloc( sizeof( pthread_cond_t ) );
	if( pthread_cond_init( cond,0 )>=0 ) return cond;
	free( cond );
	return 0;
}

void threads_CloseCond( pthread_cond_t *cond ){
	pthread_cond_destroy( cond );
	free( cond );
}

void threads_WaitCond( pthread_cond_t *cond,bb_mutex_t *mutex ){
	pthread_cond_wait( cond,mutex );
}

void threads_SignalCond( pthread_cond_t *cond ){
	pthread_cond_signal( cond );
}

void threads_BroadcastCond( pthread_cond_t *cond ){
	pthread_cond_broadcast( cond );
}

int threads_TimedWaitCond(pthread_cond_t *cond,bb_mutex_t *mutex, int millisecs) {
	struct timespec ts;
	
	if (clock_gettime(CLOCK_REALTIME, &ts) == -1) {
		return -1;
	}
	
	ts.tv_sec += millisecs / 1000;
	ts.tv_nsec += (millisecs % 1000) * 1000000L;

	int res = pthread_cond_timedwait(cond, mutex, &ts);

	if (res == 0) {
		return 0;
	} else if (res == ETIMEDOUT) {
		return 1;
	}

	return -1;	
}

#endif

#if __linux || __HAIKU__
int threads_TimedWaitSemaphore( bb_sem_t *sem, int millisecs ){
	struct timespec ts;
	
	if (clock_gettime(CLOCK_REALTIME, &ts) == -1) {
		return -1;
	}
	
	ts.tv_sec += millisecs / 1000;
	ts.tv_nsec += (millisecs % 1000) * 1000000L;
	
	int res = sem_timedwait(sem, &ts);
	
	if (res == 0) {
		return 0;
	} else if (res == ETIMEDOUT) {
		return 1;
	}

	return -1;
}
#endif
