
#include <brl.mod/blitz.mod/blitz.h>

#include <dispatch/dispatch.h>


dispatch_semaphore_t threads_CreateSemaphore( int count ){
	return dispatch_semaphore_create(count);
}

void threads_CloseSemaphore(dispatch_semaphore_t sem ){
	dispatch_release(sem);
}

void threads_WaitSemaphore( dispatch_semaphore_t sem ){
	dispatch_semaphore_wait( sem, DISPATCH_TIME_FOREVER );
}

void threads_PostSemaphore( dispatch_semaphore_t sem ){
	dispatch_semaphore_signal( sem );
}

int threads_TimedWaitSemaphore( dispatch_semaphore_t sem, int millisecs ){
	return dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)millisecs * 1000000));
}
