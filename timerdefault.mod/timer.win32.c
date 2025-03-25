
#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>

#include <brl.mod/systemdefault.mod/system.h>

#define MAX_TIMERS 16

void brl_timerdefault__TimerFired( BBObject *bbTimer );

static uintptr_t timers[MAX_TIMERS],n_timers;

static void timerSyncOp( BBObject *bbTimer,int timer ){
	int i;
	for( i=0;i<n_timers && timer!=timers[i];++i ) {}
	if( i<n_timers ) brl_timerdefault__TimerFired( bbTimer );
}

static void __stdcall timerProc( UINT timer,UINT msg,DWORD_PTR user,DWORD_PTR u1,DWORD_PTR u2 ){
	bbSystemPostSyncOp( timerSyncOp,(BBObject*)user,timer );
}

void * bbTimerStart( float hertz,BBObject *bbTimer ){
	uintptr_t timer;
	
	if( n_timers==MAX_TIMERS ) return 0;
	
	timer=(uintptr_t)timeSetEvent( 1000.0/hertz,0,timerProc,(DWORD_PTR)bbTimer,TIME_PERIODIC );
	if( !timer ) return 0;
	
	BBRETAIN( bbTimer );
	
	timers[n_timers++]=timer;
	return (void*)timer;
}

void bbTimerStop( void* t,BBObject *bbTimer ){
	int i;
	
	uintptr_t timer=(uintptr_t)t;
	for( i=0;i<n_timers && timer!=timers[i];++i ) {}
	if( i==n_timers ) return;

	timers[i]=timers[--n_timers];
	timeKillEvent( timer );

	BBRELEASE( bbTimer );
}
