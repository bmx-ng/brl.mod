
#ifndef BLITZ_APP_H
#define BLITZ_APP_H

#include "blitz_types.h"

#ifdef __cplusplus
extern "C"{
#endif

/*
struct BBAppController{
	int (*shouldTerminate)();
};
*/

extern BBString*	bbAppDir;
extern BBString*	bbAppFile;
extern BBString*	bbAppTitle;
extern BBString*	bbLaunchDir;
extern BBArray*	bbAppArgs;

extern void**		bbGCStackTop;

extern char * bbArgv0;

void		bbEnd();
void		bbOnEnd( void(*f)() );

BBString*	bbReadStdin();
void		bbWriteStdout( BBString *t );
void		bbWriteStderr( BBString *t );

void		bbDelay( int ms );
int		bbMilliSecs();
int		bbIsMainThread();
#if __STDC_VERSION__ >= 199901L
#ifndef _WIN32
#include <unistd.h>
inline void bbUDelay( int microseconds ) {
	if( microseconds<0 ) return;
	usleep( microseconds );
}
#else
void bbUDelay( int microseconds );
#endif
#else
void bbUDelay( int microseconds );
#endif

void		bbStartup( int argc,char *argv[],void *dummy1,void *dummy2 );

#ifdef _WIN32
HICON bbAppIcon(HINSTANCE hInstance);
#endif

#ifdef __cplusplus
}
#endif

#endif
