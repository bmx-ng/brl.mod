
#include <brl.mod/blitz.mod/blitz.h>

#include <windows.h>

//Enable exception debugging
#define BB_DEBUG_EXCEPTIONS

#ifdef BB_DEBUG_EXCEPTIONS

static LONG WINAPI unhandledExceptionFilter( EXCEPTION_POINTERS *xinfo ){
	const char *p="EXCEPTION_UNKNOWN";
	switch( xinfo->ExceptionRecord->ExceptionCode ){
	case EXCEPTION_ACCESS_VIOLATION:p="EXCEPTION_ACCESS_VIOLATION";break;
	case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:p="EXCEPTION_ARRAY_BOUNDS_EXCEEDED";break;
	case EXCEPTION_BREAKPOINT:p="EXCEPTION_BREAKPOINT";break;
	case EXCEPTION_DATATYPE_MISALIGNMENT:p="EXCEPTION_DATATYPE_MISALIGNMENT";break;
	case EXCEPTION_FLT_DENORMAL_OPERAND:p="EXCEPTION_FLT_DENORMAL_OPERAND";break;
	case EXCEPTION_FLT_DIVIDE_BY_ZERO:p="EXCEPTION_FLT_DIVIDE_BY_ZERO";break;
	case EXCEPTION_FLT_INEXACT_RESULT:p="EXCEPTION_FLT_INEXACT_RESULT";break;
	case EXCEPTION_FLT_INVALID_OPERATION:p="EXCEPTION_FLT_INVALID_OPERATION";break;
	case EXCEPTION_FLT_OVERFLOW:p="EXCEPTION_FLT_OVERFLOW";break;
	case EXCEPTION_FLT_STACK_CHECK:p="EXCEPTION_FLT_STACK_CHECK";break;
	case EXCEPTION_FLT_UNDERFLOW:p="EXCEPTION_FLT_UNDERFLOW";break;
	case EXCEPTION_ILLEGAL_INSTRUCTION:p="EXCEPTION_ILLEGAL_INSTRUCTION";break;
	case EXCEPTION_IN_PAGE_ERROR:p="EXCEPTION_IN_PAGE_ERROR";break;
	case EXCEPTION_INT_DIVIDE_BY_ZERO:p="EXCEPTION_INT_DIVIDE_BY_ZERO";break;
	case EXCEPTION_INT_OVERFLOW:p="EXCEPTION_INT_OVERFLOW";break;
	case EXCEPTION_INVALID_DISPOSITION:p="EXCEPTION_INVALID_DISPOSITION";break;
	case EXCEPTION_NONCONTINUABLE_EXCEPTION:p="EXCEPTION_NONCONTINUABLE_EXCEPTION";break;
	case EXCEPTION_PRIV_INSTRUCTION:p="EXCEPTION_PRIV_INSTRUCTION";break;
	case EXCEPTION_SINGLE_STEP:p="EXCEPTION_SINGLE_STEP";break;
	case EXCEPTION_STACK_OVERFLOW:p="EXCEPTION_STACK_OVERFLOW";break;
	}
	MessageBoxA( GetActiveWindow(),p,"Windows exception",MB_OK );
	bbOnDebugStop();
	exit( 0 );
}

#endif

void bbLibStartup(wchar_t * buf);

void __bb_brl_appstub_appstub();

int main( int argc,char *argv[] ){

#ifdef BB_DEBUG_EXCEPTIONS

	SetUnhandledExceptionFilter( unhandledExceptionFilter );

#endif

	bbStartup( argc,argv,0,0 );

	__bb_brl_appstub_appstub();

	return 0;
}

wchar_t bbLibFile[MAX_PATH];

BOOL WINAPI DllMain( HINSTANCE hinstDLL,DWORD fdwReason,LPVOID lpvReserved ){

	if( fdwReason!=DLL_PROCESS_ATTACH ) return 1;

	GetModuleFileNameW( hinstDLL,bbLibFile,MAX_PATH );

	return 1;
}

void bbLibInit() {
	bbLibStartup(bbLibFile);
	__bb_brl_appstub_appstub();
}
