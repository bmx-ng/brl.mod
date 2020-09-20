
#include "blitz.h"

#include <stdio.h>

BBString*	bbAppDir=BBNULLSTRING;
BBString*	bbAppFile=BBNULLSTRING;
BBString*	bbAppTitle=BBNULLSTRING;
BBString*	bbLaunchDir=BBNULLSTRING;
BBArray*	bbAppArgs=BBNULLARRAY;

void **bbGCStackTop;

char * bbArgv0 = NULL;

void bbEnd(){
	exit(0);
}

void bbOnEnd( void (*f)() ){
	atexit( f );
}

void bbWriteStdout( BBString *t ){
	char *p=bbStringToUTF8String( t );
	fprintf( stdout,"%s",p );
	fflush( stdout );
	bbMemFree(p);
}

void bbWriteStderr( BBString *t ){
	char *p=bbStringToUTF8String( t );
	fprintf( stderr,"%s",p );
	fflush( stderr );
	bbMemFree(p);
}

BBString *bbReadStdin(){

#define BUF_SIZE 256
	int sz=0;
	char *str=0;
	BBString *t;
	for(;;){
		int t_sz;
		char buf[BUF_SIZE],*p;
		fgets( buf,BUF_SIZE,stdin );
		buf[BUF_SIZE-1]=0;
		if( p=strchr( buf,'\n' ) ){
			t_sz=p-buf;
			if( t_sz && isspace(buf[t_sz-1]) ) --t_sz;
		}else{
			t_sz=strlen( buf );
		}
		str=(char*)bbMemExtend( str,sz,sz+t_sz );
		bbMemCopy( str+sz,buf,t_sz );
		sz+=t_sz;
		if( t_sz<BUF_SIZE-1 ) break;
	}
	if( sz ) t=bbStringFromBytes( str,sz );
	else t=&bbEmptyString;
	bbMemFree( str );
	return t;
}

#if __APPLE__

#include <CoreFoundation/CoreFoundation.h>

#include <mach/mach_time.h>

#include <limits.h>
#include <unistd.h>
#include <pthread.h>

static pthread_t _mainThread;

static void startup(){
	_mainThread=pthread_self();
}

void bbDelay( int millis ){
	if (millis<0) return;
	usleep( millis*1000 );
}

#if __STDC_VERSION__ >= 199901L
extern void bbUDelay( int microseconds );
#else
void bbUDelay( int microseconds ) {
	if (microseconds <0) return
	usleep( microseconds );
}
#endif

int bbMilliSecs(){
	static mach_timebase_info_data_t info;

	if (info.denom == 0) {
		mach_timebase_info(&info);
	}

	return (int)((mach_absolute_time() * info.numer) / ((1000 * 1000) * info.denom));
}


int bbIsMainThread(){
	return pthread_self()==_mainThread;
}

#elif _WIN32

#include <direct.h>

#include <windows.h>

int _bbusew;	//internal 'use unicode' flag

static DWORD _mainThread;

static void startup(){
	_mainThread=GetCurrentThreadId();
}

void bbDelay( int millis ){
	if (millis<0) return;
	Sleep( millis );
}

int bbMilliSecs(){
	return timeGetTime();
}

void bbUDelay( int microseconds ) {
	__int64 time1 = 0;
	__int64 time2 = 0;
	__int64 freq = 0;

	QueryPerformanceCounter((LARGE_INTEGER *) &time1);
	QueryPerformanceFrequency(&freq);

	do {
		Sleep(0);
		QueryPerformanceCounter((LARGE_INTEGER *) &time2);
	} while(time2-time1 < microseconds*freq/1000000);
}

int bbIsMainThread(){
	return GetCurrentThreadId()==_mainThread;
}

void bbGetAppFileDir(wchar_t * buf) {
	int e = 0;
	for(int i=0;buf[i];++i ){
		if( buf[i]=='\\' ) buf[i]='/';
		if( buf[i]=='/' ) e=i;
	}

	bbAppFile=bbStringFromWString( buf );

	if( e ){
		if( buf[e-1]==':' ) ++e;
		bbAppDir=bbStringFromShorts( buf,e );
	}else{
		bbAppDir=&bbEmptyString;
	}
}

HICON bbAppIcon(HINSTANCE hInstance) {
	return LoadIcon(hInstance, "APP_ICON");
}

#elif __linux

#include <unistd.h>
#include <pthread.h>
#include <limits.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/sysinfo.h>

static int base_time;
static pthread_t _mainThread;

static void startup(){
	struct sysinfo info;
	
	_mainThread=pthread_self();

	sysinfo( &info );
	base_time=bbMilliSecs()-info.uptime*1000;
}

//***** ThreadSafe! *****
void bbDelay( int millis ){
	int i,e;
	
	if( millis<0 ) return;

	e=bbMilliSecs()+millis;
	
	for( i=0;;++i ){
		int t=e-bbMilliSecs();
		if( t<=0 ){
			if( !i ) usleep( 0 );	//always sleep at least once.
			break;
		}
		usleep( t*1000 );
	}
}

#if __STDC_VERSION__ >= 199901L
extern void bbUDelay( int microseconds );
#else
void bbUDelay( int microseconds ) {
	if (microseconds <0) return
	usleep( microseconds );
}
#endif

//***** ThreadSafe! *****
int bbMilliSecs(){
	int t;
	struct timeval tv;
	gettimeofday(&tv,0);
	t=tv.tv_sec*1000;
	t+=tv.tv_usec/1000;
	return t-base_time;
}

int bbIsMainThread(){
	return pthread_self()==_mainThread;
}

#elif __EMSCRIPTEN__

#include <unistd.h>
//#include <pthread.h>
#include <limits.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/sysinfo.h>

static int base_time;
//static pthread_t _mainThread;

static void startup(){
	struct sysinfo info;
	
	//_mainThread=pthread_self();

	// TODO : appears as "undefined" when linking... need this for millisecs support.
	//sysinfo( &info );
	base_time=bbMilliSecs()-info.uptime*1000;
}

//***** ThreadSafe! *****
void bbDelay( int millis ){
	int i,e;
	
	if( millis<0 ) return;

	e=bbMilliSecs()+millis;
	
	for( i=0;;++i ){
		int t=e-bbMilliSecs();
		if( t<=0 ){
			if( !i ) usleep( 0 );	//always sleep at least once.
			break;
		}
		usleep( t*1000 );
	}
}

//***** ThreadSafe! *****
int bbMilliSecs(){
	int t;
	struct timeval tv;
	gettimeofday(&tv,0);
	t=tv.tv_sec*1000;
	t+=tv.tv_usec/1000;
	return t-base_time;
}

int bbIsMainThread(){
	return 1;
//	return pthread_self()==_mainThread;
}

#elif __SWITCH__

#include <unistd.h>
//#include <pthread.h>
#include <limits.h>
#include <signal.h>
#include <sys/time.h>
//#include <sys/sysinfo.h>
#include <switch.h>

static int base_time;
//static pthread_t _mainThread;

static void startup(){
//	struct sysinfo info;
	
	//_mainThread=pthread_self();

	// TODO : appears as "undefined" when linking... need this for millisecs support.
	//sysinfo( &info );
	base_time=0;//bbMilliSecs()-info.uptime*1000;
}

//***** ThreadSafe! *****
void bbDelay( int millis ){
	int i,e;
	
	if( millis<0 ) return;

	e=bbMilliSecs()+millis;
	
	for( i=0;;++i ){
		int t=e-bbMilliSecs();
		if( t<=0 ){
			if( !i ) usleep( 0 );	//always sleep at least once.
			break;
		}
		usleep( t*1000 );
	}
}

//***** ThreadSafe! *****
int bbMilliSecs(){
	int t;
	struct timeval tv;
	gettimeofday(&tv,0);
	t=tv.tv_sec*1000;
	t+=tv.tv_usec/1000;
	return t-base_time;
}

int bbIsMainThread(){
	return 1;
//	return pthread_self()==_mainThread;
}

#elif __HAIKU__

#include <unistd.h>
#include <pthread.h>
#include <limits.h>
#include <signal.h>
#include <sys/time.h>
#include <kernel/OS.h>

static int base_time;
static pthread_t _mainThread;

static void startup(){
	
	_mainThread=pthread_self();

	bigtime_t uptime = system_time();
	base_time=bbMilliSecs()-uptime/1000;
}

//***** ThreadSafe! *****
void bbDelay( int millis ){
	int i,e;
	
	if( millis<0 ) return;

	e=bbMilliSecs()+millis;
	
	for( i=0;;++i ){
		int t=e-bbMilliSecs();
		if( t<=0 ){
			if( !i ) usleep( 0 );	//always sleep at least once.
			break;
		}
		usleep( t*1000 );
	}
}

#if __STDC_VERSION__ >= 199901L
extern void bbUDelay( int microseconds );
#else
void bbUDelay( int microseconds ) {
	if (microseconds <0) return
	usleep( microseconds );
}
#endif

//***** ThreadSafe! *****
int bbMilliSecs(){
	int t;
	struct timeval tv;
	gettimeofday(&tv,0);
	t=tv.tv_sec*1000;
	t+=tv.tv_usec/1000;
	return t-base_time;
}

int bbIsMainThread(){
	return pthread_self()==_mainThread;
}

#endif


void bbStartup( int argc,char *argv[],void *dummy1,void *dummy2 ){

	int i,k;
	BBString **p;
	
	bbArgv0 = argv[0];
	
	//Start up GC and create bbAppFile, bbAppDir and bbLaunchDir
	
#if _WIN32

	char *ebp;
	OSVERSIONINFO os={ sizeof(os) };
	
	//asm( "movl %%ebp,%0;":"=r"(ebp) );//::"%ebp" );
	
	//bbGCStackTop=ebp+28;
	
	bbGCStartup();
	bbThreadStartup();

	if( GetVersionEx( &os ) ){
		if( os.dwPlatformId==VER_PLATFORM_WIN32_NT ){
			_bbusew=1;
		}
	}
	
	if( _bbusew ){
		int e=0;
		wchar_t buf[MAX_PATH];
		
		_wgetcwd( buf,MAX_PATH );
		for( i=0;buf[i];++i ){
			if( buf[i]=='\\' ) buf[i]='/';
		}
		bbLaunchDir=bbStringFromWString( buf );

		GetModuleFileNameW( GetModuleHandleW(0),buf,MAX_PATH );
		bbGetAppFileDir(buf);
		BBChar * p = bbStringToWString(bbAppDir);
		_wchdir( p );
		bbMemFree(p);
		
	}else{
		int e=0;
		char buf[MAX_PATH];

		_getcwd( buf,MAX_PATH );
		for( i=0;buf[i];++i ){
			if( buf[i]=='\\' ) buf[i]='/';
		}
		bbLaunchDir=bbStringFromCString( buf );
		
		GetModuleFileNameA( GetModuleHandleA(0),buf,MAX_PATH );
		for( i=0;buf[i];++i ){
			if( buf[i]=='\\' ) buf[i]='/';
			if( buf[i]=='/' ) e=i;
		}
		bbAppFile=bbStringFromCString( buf );

		if( e ){
			if( buf[e-1]==':' ) ++e;
			bbAppDir=bbStringFromBytes( buf,e );
		}else{
			bbAppDir=&bbEmptyString;
		}

		char *p=bbStringToCString( bbAppDir );
		_chdir( p );
		bbMemFree(p);
	}

#elif __linux

	char *ebp;
	char buf[PATH_MAX];
	char lnk[PATH_MAX];
	pid_t pid;
	
	// asm( "movl %%ebp,%0;":"=r"(ebp) );//::"%ebp" );
	
	bbGCStackTop=ebp+28;
	
	bbThreadPreStartup();
	bbGCStartup();
	bbThreadStartup();
	
	getcwd( buf,PATH_MAX );
	bbLaunchDir=bbStringFromUTF8String( buf );
	
	pid=getpid();
	sprintf( lnk,"/proc/%i/exe",pid );
	i=readlink( lnk,buf,PATH_MAX );
	if( i>0 ){
		char *p;
		buf[i]=0;
		bbAppFile=bbStringFromUTF8String( buf );
		p=strrchr( buf,'/' );
		if( p ){
			*p=0;
			bbAppDir=bbStringFromUTF8String( buf );
		}else{
			bbAppDir=&bbEmptyString;
		}
	}else{
		bbAppFile=&bbEmptyString;
		bbAppDir=&bbEmptyString;
	}
	
	char *d=bbStringToUTF8String( bbAppDir );
	chdir( d );
	bbMemFree(d);
	
#elif __APPLE__
	
	CFURLRef url;
	char buf[PATH_MAX],*e;
	
//#if BB_ARGP
//	bbGCStackTop=bbArgp(0);
//#else
	bbGCStackTop=&argc;
//#endif

	bbGCStartup();
	bbThreadStartup();
	
	getcwd( buf,PATH_MAX );
	bbLaunchDir=bbStringFromUTF8String( buf );
	
	url=CFBundleCopyExecutableURL( CFBundleGetMainBundle() );
	CFURLGetFileSystemRepresentation( url,true,(UInt8*)buf,PATH_MAX );
	CFRelease( url );
	
	bbAppFile=bbStringFromUTF8String( buf );

	if( e=strstr( buf,".app/Contents/MacOS/" ) ){
		*e=0;
	}
	if( e=strrchr( buf,'/' ) ){
		*e=0;
		bbAppDir=bbStringFromUTF8String( buf );
	}else{
		bbAppDir=&bbEmptyString;
	}
	
	char *d=bbStringToCString( bbAppDir );
	chdir( d );
	bbMemFree(d);

#elif __SWITCH__

//	bbThreadStartup();
	bbGCStartup();

#elif __HAIKU__

	#include <kernel/image.h>

	bbThreadPreStartup();
	bbGCStartup();
	bbThreadStartup();

	char buf[MAXPATHLEN];

	getcwd( buf,MAXPATHLEN );
	bbLaunchDir=bbStringFromUTF8String( buf );
	
	image_info info;
	int cookie = 0;
	get_next_image_info(B_CURRENT_TEAM, &cookie, &info);
	
	snprintf(buf, PATH_MAX, "%s", info.name);
	char *e;
	bbAppFile=bbStringFromUTF8String( buf );
	e=strrchr( buf,'/' );
	if( e ){
		*e=0;
		bbAppDir=bbStringFromUTF8String( buf );
	}else{
		bbAppDir=&bbEmptyString;
	}

	char *d=bbStringToUTF8String( bbAppDir );
	chdir( d );
	bbMemFree(d);

#endif

	BBINCREFS( bbLaunchDir );
	BBINCREFS( bbAppDir );
	BBINCREFS( bbAppFile );

	bbAppTitle=bbStringFromCString( "BlitzMax Application" );
	BBINCREFS( bbAppTitle );

	bbAppArgs=bbArrayNew1D( "$",argc );
	BBINCREFS( bbAppArgs );

	p=(BBString**)BBARRAYDATA( bbAppArgs,1 );
	
	for( k=0;k<argc;++k ){
		BBString *arg=bbStringFromCString( argv[k] );
		BBINCREFS( arg );
		*p++=arg;
	}
	
	startup();
}

#if _WIN32
void bbLibStartup(wchar_t * buf){

	bbGCStartup();
	bbThreadStartup();

	bbGetAppFileDir(buf);

	startup();
}
#endif
