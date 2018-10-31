
#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>

#include <brl.mod/systemdefault.mod/system.h>

#define MAX_TIMERS 16

void brl_timerdefault__TimerFired( BBObject *bbTimer );
PHANDLE brl_timerdefault_TDefaultTimer__GetHandle(BBObject *bbTimer);

static PHANDLE timers[MAX_TIMERS];
static int n_timers;

static void timerSyncOp( BBObject *bbTimer,PHANDLE timer ){
	int i;
	for( i=0;i<n_timers && timer!=timers[i];++i ) {}
	if( i<n_timers ) brl_timerdefault__TimerFired( bbTimer );
}

static void __stdcall timerProc( PVOID user, BOOLEAN t ){
	bbSystemPostSyncOp( timerSyncOp,(BBObject*)user,(size_t)brl_timerdefault_TDefaultTimer__GetHandle((BBObject*)user) );
}

void * bbTimerStart( float hertz,BBObject *bbTimer ){
	PHANDLE timer;
	
	if( n_timers==MAX_TIMERS ) return 0;
	
	if ( !CreateTimerQueueTimer(&timer, NULL, timerProc, (PVOID)bbTimer, 0, 1000.0/hertz, 0 ) ) return 0;
	
	BBRETAIN( bbTimer );
	
	timers[n_timers++]=timer;
	return (void*)timer;
}

void bbTimerStop( void* t,BBObject *bbTimer ){
	int i;
	
	PHANDLE timer=(PHANDLE)t;
	for( i=0;i<n_timers && timer!=timers[i];++i ) {}
	if( i==n_timers ) return;

	timers[i]=timers[--n_timers];
	DeleteTimerQueueTimer(NULL, timer, NULL);

	BBRELEASE( bbTimer );
}
