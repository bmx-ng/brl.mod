#include <brl.mod/blitz.mod/blitz.h>

#include <signal.h>
#include <unistd.h>
#include <switch.h>

int __bb_brl_appstub_appstub();

int main( int argc,char *argv[] ){
	
	socketInitializeDefault();
	nxlinkStdio();

	signal( SIGPIPE,SIG_IGN );
	
	bbStartup( argc,argv,0,0 );
	
	__bb_brl_appstub_appstub();

	socketExit();

	return 0;
}

