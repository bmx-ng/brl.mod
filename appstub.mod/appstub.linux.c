
#include <brl.mod/blitz.mod/blitz.h>

#include <signal.h>
#include <sys/uio.h>
#include <unistd.h>

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

#ifndef __EMSCRIPTEN__
size_t bmx_process_vm_readv(size_t dataSize, void * pointer, void * buffer) {

	struct iovec local;
	struct iovec remote;
	pid_t pid = getpid();
	
	local.iov_base = buffer;
	local.iov_len = dataSize;
	
	remote.iov_base = pointer;
	remote.iov_len = dataSize;
	
	size_t result = process_vm_readv(pid, &local, 1, &remote, 1, 0);
	
	return result;
}
#endif