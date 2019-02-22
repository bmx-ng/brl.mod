
//Oh the fun...no multiple timers in Linux (!) so we have to roll our own...
//
#include <brl.mod/blitz.mod/blitz.h>

#include <pthread.h>

typedef struct BBTimer{
	pthread_t thread;
	int status;
	int puts;
	int gets;
	int start;
	int period;
	BBObject *bbTimer;
}BBTimer;

extern int bbMilliSecs();
extern void bbDelay( int millis );

extern void brl_timerdefault__TimerFired( BBObject *bbTimer );

static void timerSyncOp( BBObject *user,size_t ret ){
	BBTimer *timer=(BBTimer*)ret;

	++timer->gets;	

	switch( timer->status ){
	case 1:
		brl_timerdefault__TimerFired( timer->bbTimer );
		break;
	case 2:
		if( timer->puts==timer->gets ){
			BBRELEASE( timer->bbTimer );
			free( timer );
		}
		break;
	}
}

static void *timerProc( void *data ){
	BBTimer *timer=(BBTimer*)data;
	
	int time=timer->start;
	
	while( timer->status==1 ){
		time+=timer->period;

		bbDelay( time-bbMilliSecs() );

		++timer->puts;
		bbSystemPostSyncOp( timerSyncOp,&bbNullObject,(size_t)timer );
	}

	bbSystemPostSyncOp( timerSyncOp,&bbNullObject,(size_t)timer );
}

BBTimer *bbTimerStart( float hertz,BBObject *bbTimer ){
	BBTimer *timer;
	int start=bbMilliSecs();
	
	timer=(BBTimer*)malloc( sizeof( BBTimer ) );
	
	timer->status=1;
	timer->puts=1;
	timer->gets=0;
	timer->start=start;
	timer->period=1000.0f/hertz;
	timer->bbTimer=bbTimer;
	
	if( pthread_create( &timer->thread,0,(void*(*)(void*))timerProc,timer )<0 ){
		free( timer );
		return 0;
	}
	
	BBRETAIN( timer->bbTimer );
	
	return timer;
}

void bbTimerStop( BBTimer *timer,BBObject *bbTimer ){
	timer->status=2;
}
