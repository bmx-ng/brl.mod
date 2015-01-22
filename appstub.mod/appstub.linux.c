
#include <brl.mod/blitz.mod/blitz.h>

#include <signal.h>

int __bb_brl_appstub_appstub();

#ifndef __ANDROID__
int main( int argc,char *argv[] ){
#else
int SDL_main( int argc,char *argv[] ){
#endif

	signal( SIGPIPE,SIG_IGN );
	
	bbStartup( argc,argv,0,0 );
	
	__bb_brl_appstub_appstub();

	return 0;
}
