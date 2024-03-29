
#include "system.h"
#include <shlobj.h>

typedef struct AsyncOp{
	BBSyncOp syncOp;
	BBObject *syncInfo;
	size_t asyncRet;
	BBAsyncOp asyncOp;
	int asyncInfo;
}AsyncOp;

// track shift key state because Windows doesn't report events when the two shift
// keys are being pressed at the same time, and then one released.
static int shiftKeyState[2];

static int _usew;

static HHOOK msghook;
static int mainThreadId;

static int mods;
static int started;

static HWND mouseHwnd;
static BBObject *mouseSource;
static int mouseVisible;

static int keyCode( WPARAM wp,LPARAM lp){
	switch( ((lp>>17)&0x80)|((lp>>16)&0x7f) ){
	case 42:return VK_LSHIFT;
	case 54:return VK_RSHIFT;
	case 29:return VK_LCONTROL;
	case 157:return VK_RCONTROL;
	case 56:return VK_LMENU;
	case 184:return VK_RMENU;
	}
	return wp;
}

static void updateMods(){
	mods=0;
	if( GetKeyState( VK_SHIFT )<0 ) mods|=MODIFIER_SHIFT;
	if( GetKeyState( VK_CONTROL )<0 ) mods|=MODIFIER_CONTROL;
	if( GetKeyState( VK_MENU )<0 ) mods|=MODIFIER_OPTION;
	if( GetKeyState( VK_LWIN )<0 || GetKeyState( VK_RWIN )<0 ) mods|=MODIFIER_SYSTEM;
}

static void bbSystemShutdown(){	
	if( !started ) return;
	timeEndPeriod( 1 );
	started=0;
}

static int isControl( HWND hwnd ){
	int style=GetWindowLong( hwnd,GWL_STYLE) & (WS_TABSTOP|WS_CHILD);
	return style==(WS_TABSTOP|WS_CHILD);
}

static void updateMouseVisibility(){
	int visible=mouseVisible || !mouseHwnd;
	int n=ShowCursor( visible );
	if( n<-1 || n>0 ) ShowCursor( !visible );
}

static void setMouseHwnd( HWND hwnd,int x,int y,BBObject *source ){
	if( hwnd==mouseHwnd ) return;

	if( hwnd && source ){
		BBRETAIN( source );
	}
	
	if( mouseHwnd ){
		POINT p;
		GetCursorPos( &p );
		ScreenToClient( mouseHwnd,&p );
		bbSystemEmitEvent( BBEVENT_MOUSELEAVE,mouseSource,0,0,p.x,p.y,&bbNullObject );
		if( mouseSource ){
			BBRELEASE( mouseSource );
		}
	}
	mouseHwnd=hwnd;
	updateMouseVisibility();
	if( mouseHwnd ){
		TRACKMOUSEEVENT tm={sizeof(tm),TME_LEAVE,hwnd,0};
		mouseSource=source;
		bbSystemEmitEvent( BBEVENT_MOUSEENTER,mouseSource,0,0,x,y,&bbNullObject );
		_TrackMouseEvent( &tm );
	}
}

static HWND focHwnd;

static void beginPanel(){
	focHwnd=GetFocus();
}

static void endPanel(){
	SetFocus( focHwnd );
}

static LRESULT CALLBACK getMessageHook( int code,WPARAM wp,LPARAM lp ){
	if( code>=0 && wp==PM_REMOVE ){
		MSG *msg=(MSG*)lp;
		if( msg->message==WM_BBRESERVED1 ){
			AsyncOp *p=(AsyncOp*)msg->lParam;
			p->syncOp( p->syncInfo,p->asyncRet );
			if( p->asyncOp ){
				BBRELEASE( p->syncInfo );
			}
			free( p );
		}
	}
	return CallNextHookEx( msghook,code,wp,lp );
}

void bbSystemEmitOSEvent( HWND hwnd,UINT msg,WPARAM wp,LPARAM lp,BBObject *source ){

	RECT rect;
	POINT point;
	int inRect,id,data=0,x=0,y=0;
	
	switch( msg ){
	case WM_KEYDOWN:case WM_SYSKEYDOWN:
		if( wp<1 || wp>255 ) return;
		id=( lp & 0x40000000 ) ? BBEVENT_KEYREPEAT : BBEVENT_KEYDOWN;
		data=keyCode( wp,lp );
		
		switch(data) {
			case VK_LSHIFT:
				shiftKeyState[0] = 1;
				break;
			case VK_RSHIFT:
				shiftKeyState[1] = 1;
				break;
		}
		
		break;
	case WM_KEYUP:case WM_SYSKEYUP:
		if( wp<1 || wp>255 ) return;
		id=BBEVENT_KEYUP;
		data=keyCode( wp,lp );

		switch(data) {
			case VK_LSHIFT:
				shiftKeyState[0] = 0;
				break;
			case VK_RSHIFT:
				shiftKeyState[1] = 0;
				break;
		}

		break;
	case WM_CHAR:case WM_SYSCHAR:
		id=BBEVENT_KEYCHAR;
		data=wp;
		break;
	case WM_LBUTTONDOWN:case WM_RBUTTONDOWN:case WM_MBUTTONDOWN:case WM_XBUTTONDOWN:
		SetCapture( hwnd );
		id=BBEVENT_MOUSEDOWN;
		switch (msg) {
			case WM_LBUTTONDOWN:
				data = 1;
				break;
			case WM_RBUTTONDOWN:
				data = 2;
				break;
			case WM_MBUTTONDOWN:
				data = 3;
				break;
			case WM_XBUTTONDOWN:
				if (GET_XBUTTON_WPARAM(wp) == XBUTTON1) {
					data = 4;
				} else {
					data = 5;
				}
		}
		x=(short)LOWORD(lp);
		y=(short)HIWORD(lp);
		break;
	case WM_LBUTTONUP:case WM_RBUTTONUP:case WM_MBUTTONUP:case WM_XBUTTONUP:
		ReleaseCapture();
		id=BBEVENT_MOUSEUP;
		switch (msg) {
			case WM_LBUTTONUP:
				data = 1;
				break;
			case WM_RBUTTONUP:
				data = 2;
				break;
			case WM_MBUTTONUP:
				data = 3;
				break;
			case WM_XBUTTONUP:
				if (GET_XBUTTON_WPARAM(wp) == XBUTTON1) {
					data = 4;
				} else {
					data = 5;
				}
		}
		x=(short)LOWORD(lp);
		y=(short)HIWORD(lp);
		break;
	case WM_MOUSEMOVE:
		x=(short)LOWORD(lp);
		y=(short)HIWORD(lp);
		if (wp&MK_LBUTTON) data=1;
		if (wp&MK_MBUTTON) data=4;
		if (wp&MK_RBUTTON) data=2;
		GetClientRect( hwnd,&rect );
		inRect=(x>=0 && y>=0 && x<rect.right && y<rect.bottom);
		setMouseHwnd( inRect ? hwnd : 0,x,y,source );
		id=BBEVENT_MOUSEMOVE;
		break;
	case WM_MOUSELEAVE:
		if( hwnd==mouseHwnd ) setMouseHwnd( 0,(short)LOWORD(lp),(short)HIWORD(lp),&bbNullObject );
		return;
	case WM_MOUSEWHEEL:
		id=BBEVENT_MOUSEWHEEL;
		data=(short)HIWORD(wp)/120;
		point.x=(short)LOWORD(lp);
		point.y=(short)HIWORD(lp);
		ScreenToClient( hwnd,&point );
		x=point.x;
		y=point.y;
		break;
	case WM_CLOSE:		
		id=BBEVENT_APPTERMINATE;
		break;
	case WM_ACTIVATE:
		if( LOWORD(wp)==WA_INACTIVE || !IsIconic(hwnd) ){
			DWORD proc;
			GetWindowThreadProcessId( hwnd,&proc );
			if( proc!=GetCurrentProcessId() ){
				id = (LOWORD(wp) == WA_INACTIVE) ? BBEVENT_APPSUSPEND : BBEVENT_APPRESUME;
				break;
			}
		}
		return;
		/*
	case WM_ACTIVATEAPP:
		//
		// WM_ACTIVATEAPP appears to be broken.
		//
		// Clicking on taskbar button to minimize an app appears to confuse poor old windows.
		//
		// So, we'll use the WM_ACTIVATE code above courtesy of Seb...
		//
		id=wp ? BBEVENT_APPRESUME : BBEVENT_APPSUSPEND;
		break;
		*/
	default:
		return;
	}
	
	bbSystemEmitEvent( id,source,data,mods,x,y,&bbNullObject );
}

void bbSystemStartup(){
	OSVERSIONINFO os={ sizeof(os) };

	if( started ) return;
	
	if( GetVersionEx( &os ) ){
		if( os.dwPlatformId==VER_PLATFORM_WIN32_NT ){
			_usew=1;
		}
	}
	
	mouseVisible=1;
	mainThreadId=GetCurrentThreadId();
	msghook=SetWindowsHookEx( WH_GETMESSAGE,getMessageHook,0,mainThreadId );

	timeBeginPeriod( 1 );
	
	atexit( bbSystemShutdown );
	started=1;
}

void bbSystemPoll(){
	MSG msg;
	while( PeekMessage( &msg,0,0,0,PM_REMOVE ) ){

		switch( msg.message ){
		case WM_KEYDOWN:case WM_KEYUP:
		case WM_SYSKEYDOWN:case WM_SYSKEYUP:
			switch( msg.wParam ){
			case VK_SHIFT:
			case VK_CONTROL:
			case VK_MENU:
			case VK_LWIN:case VK_RWIN:
				updateMods();
				break;
			}
			break;
		}
		
		if( isControl( msg.hwnd ) ){
			HWND hwnd=GetParent( msg.hwnd );
			while( hwnd && isControl( hwnd ) ) hwnd=GetParent( hwnd );
			if( hwnd && IsDialogMessage( hwnd,&msg ) ) continue;
		}
		
		TranslateMessage( &msg );
		DispatchMessage( &msg );
	}

	// test shift keys current state
	if (shiftKeyState[0] && !(GetKeyState(VK_LSHIFT) & 0x8000)) {
		shiftKeyState[0] = 0;
		bbSystemEmitEvent( BBEVENT_KEYUP,&bbNullObject,VK_LSHIFT,mods,0,0,&bbNullObject );
	}

	if (shiftKeyState[1] && !(GetKeyState(VK_RSHIFT) & 0x8000)) {
		shiftKeyState[1] = 0;
		bbSystemEmitEvent( BBEVENT_KEYUP,&bbNullObject,VK_RSHIFT,mods,0,0,&bbNullObject );
	}
}

void bbSystemWait(){
	MsgWaitForMultipleObjects( 0,0,0,INFINITE,QS_ALLINPUT );	//QS_ALLEVENTS );
	bbSystemPoll();
}

void bbSystemMoveMouse( int x,int y ){
	POINT point={x,y};
	HWND hwnd=GetActiveWindow();
	if( hwnd ) ClientToScreen( hwnd,&point );
	SetCursorPos( point.x,point.y );
}

void bbSystemSetMouseVisible( int visible ){
	mouseVisible=visible;
	updateMouseVisibility();
}

static int systemPanel( BBString *text,int flags ){
	int n;
	
	beginPanel();
	if( _usew ){
		BBChar *p=bbStringToWString( text );
		BBChar *t=bbStringToWString( bbAppTitle );
		n=MessageBoxW( GetActiveWindow(),p,t,flags );
		bbMemFree(t);
		bbMemFree(p);
	}else{
		char *p=bbStringToCString( text );
		char *t=bbStringToCString( bbAppTitle );
		n=MessageBoxA( GetActiveWindow(),p,t,flags );
		bbMemFree(t);
		bbMemFree(p);
	}
	endPanel();
	return n;
}

void bbSystemNotify( BBString *text,int serious ){
	int flags=(serious?MB_ICONWARNING:MB_ICONINFORMATION)|MB_OK|MB_APPLMODAL|MB_TOPMOST;
	
	systemPanel( text,flags );
}

int bbSystemConfirm( BBString *text,int serious ){
	int flags=(serious?MB_ICONWARNING:MB_ICONINFORMATION)|MB_OKCANCEL|MB_APPLMODAL|MB_TOPMOST;
	
	int n=systemPanel( text,flags );
	if( n==IDOK ) return 1;
	return 0;
}

int bbSystemProceed( BBString *text,int serious ){
	int flags=(serious?MB_ICONWARNING:MB_ICONINFORMATION)|MB_YESNOCANCEL|MB_APPLMODAL|MB_TOPMOST;
	
	int n=systemPanel( text,flags );
	if( n==IDYES ) return 1;
	if( n==IDNO ) return 0;
	return -1;
}

BBString *bbSystemRequestFile( BBString *text,BBString *exts,int defext,int save,BBString *file,BBString *dir ){

	BBString *str=&bbEmptyString;
	
	if( _usew ){
		wchar_t buf[MAX_PATH];
		OPENFILENAMEW of={sizeof(of)};
		
		BBChar *p=bbStringToWString( file );
		wcscpy( buf,p );
		bbMemFree(p);

		BBChar *t=bbStringToWString( text );
		BBChar *e=bbStringToWString( exts );
		BBChar *d = 0;

		of.hwndOwner=GetActiveWindow();
		of.lpstrTitle=t;
		of.lpstrFilter=e;
		of.nFilterIndex=defext;
		of.lpstrFile=buf;
		of.lpstrInitialDir=dir->length ? d=bbStringToWString( dir ) : 0;
		of.nMaxFile=MAX_PATH;
		of.Flags=OFN_HIDEREADONLY|OFN_NOCHANGEDIR;
		
		beginPanel();
		if( save ){
			of.lpstrDefExt=L"";
			of.Flags|=OFN_OVERWRITEPROMPT;
			if( GetSaveFileNameW( &of ) ){
				str=bbStringFromWString( buf );
			}
		}else{
			of.Flags|=OFN_FILEMUSTEXIST;
			if( GetOpenFileNameW( &of ) ){
				str=bbStringFromWString( buf );
			}
		}
		endPanel();
		
		bbMemFree(d);
		bbMemFree(e);
		bbMemFree(t);
	}else{
		char buf[MAX_PATH];
		OPENFILENAMEA of={sizeof(of)};

		char *p=bbStringToCString( file );
		strcpy( buf,p );
		bbMemFree(p);

		char *t=bbStringToCString( text );
		char *e=bbStringToCString( exts );
		char *d=0;
		
		of.hwndOwner=GetActiveWindow();
		of.lpstrTitle=t;
		of.lpstrFilter=e;
		of.nFilterIndex=defext;
		of.lpstrFile=buf;
		of.lpstrInitialDir=dir->length ? d=bbStringToCString( dir ) : 0;
		of.nMaxFile=MAX_PATH;
		of.Flags=OFN_HIDEREADONLY|OFN_NOCHANGEDIR;
		
		beginPanel();
		
		if( save ){
			of.lpstrDefExt="";
			of.Flags|=OFN_OVERWRITEPROMPT;
			if( GetSaveFileNameA( &of ) ){
				str=bbStringFromCString( buf );
			}
		}else{
			of.Flags|=OFN_FILEMUSTEXIST;
			if( GetOpenFileNameA( &of ) ){
				str=bbStringFromCString( buf );
			}
		}
		endPanel();
		
		bbMemFree(d);
		bbMemFree(e);
		bbMemFree(t);
	}
	return str;
}

static int CALLBACK BrowseForFolderCallbackW( HWND hwnd,UINT uMsg,LPARAM lp,LPARAM pData ){
	wchar_t szPath[MAX_PATH];
	switch( uMsg ){
	case BFFM_INITIALIZED:
		SendMessageW( hwnd,BFFM_SETSELECTIONW,TRUE,pData );
		break;
	case BFFM_SELCHANGED: 
		if( SHGetPathFromIDListW( (LPITEMIDLIST)lp,szPath ) ){
			SendMessageW( hwnd,BFFM_SETSTATUSTEXTW,0,(LPARAM)szPath );
		}
		break;
	}
	return 0;
}

static int CALLBACK BrowseForFolderCallbackA( HWND hwnd,UINT uMsg,LPARAM lp,LPARAM pData ){
	char szPath[MAX_PATH];
	switch( uMsg ){
	case BFFM_INITIALIZED:
		SendMessageA( hwnd,BFFM_SETSELECTIONA,TRUE,pData );
		break;
	case BFFM_SELCHANGED: 
		if( SHGetPathFromIDListA( (LPITEMIDLIST)lp,szPath ) ){
			SendMessageA( hwnd,BFFM_SETSTATUSTEXTA,0,(LPARAM)szPath );
		}
		break;
	}
	return 0;
}

BBString *bbSystemRequestDir( BBString *text,BBString *dir ){

	BBString *str=&bbEmptyString;

	if( _usew ){
		LPMALLOC shm;
		ITEMIDLIST *idlist;
		BROWSEINFOW bi={0};
		wchar_t buf[MAX_PATH],*p;

		BBChar *d=bbStringToWString( dir );
		GetFullPathNameW( d,MAX_PATH,buf,&p );
		bbMemFree(d);
		
		BBChar *t=bbStringToWString( text );
		
		bi.hwndOwner=GetActiveWindow();
		bi.lpszTitle=t;
		bi.ulFlags=BIF_RETURNONLYFSDIRS|BIF_NEWDIALOGSTYLE;
		bi.lpfn=BrowseForFolderCallbackW;
		bi.lParam=(LPARAM)buf;
		
		beginPanel();
		idlist=SHBrowseForFolderW(&bi);
		endPanel();
		
		bbMemFree(t);
		
		if( idlist ){
			SHGetPathFromIDListW( idlist,buf );
			str=bbStringFromWString( buf );
			//SHFree( idlist );	//?!?	
		}
	} else {
		LPMALLOC shm;
		ITEMIDLIST *idlist;
		BROWSEINFOA bi={0};
		char buf[MAX_PATH],*p;
		
		char *d=bbStringToCString( dir );
		GetFullPathNameA( d,MAX_PATH,buf,&p );
		bbMemFree(d);

		char *t=bbStringToCString( text );

		bi.hwndOwner=GetActiveWindow();
		bi.lpszTitle=t;
		bi.ulFlags=BIF_RETURNONLYFSDIRS|BIF_NEWDIALOGSTYLE;
		bi.lpfn=BrowseForFolderCallbackA;
		bi.lParam=(LPARAM)buf;
		
		beginPanel();
		idlist=SHBrowseForFolderA(&bi);
		endPanel();
		
		bbMemFree(t);
		
		if( idlist ){
			SHGetPathFromIDListA( idlist,buf );
			str=bbStringFromCString( buf );
			//SHFree( idlist );	//?!?	
		}
	}
	return str;
}

int bbOpenURL( BBString *url ){
	int n;
	if( _usew ){
		BBChar *p=bbStringToWString( url );
		n=(int)ShellExecuteW( 0,0,(wchar_t*)p,0,0,10 )>32;	//SW_SHOWDEFAULT
		bbMemFree(p);
	}else{
		char *p=bbStringToCString( url );
		n=(int)ShellExecuteA( 0,0,p,0,0,10 )>32;	//SW_SHOWDEFAULT
		bbMemFree(p);
	}
	return n;
}

static DWORD WINAPI asyncOpThread( void *t ){
	AsyncOp *p=(AsyncOp*)t;
	p->asyncRet=p->asyncOp( p->asyncInfo );
	PostThreadMessage( mainThreadId,WM_BBRESERVED1,0,(LPARAM)p );
}

void bbSystemPostSyncOp( BBSyncOp syncOp,BBObject *syncInfo,size_t asyncRet ){
	AsyncOp *p=(AsyncOp*)malloc( sizeof( AsyncOp ) );
	p->asyncOp=0;
	p->asyncRet=asyncRet;
	p->syncOp=syncOp;
	p->syncInfo=syncInfo;
	PostThreadMessage( mainThreadId,WM_BBRESERVED1,0,(LPARAM)p );
}

void bbSystemStartAsyncOp( BBAsyncOp asyncOp,int asyncInfo,BBSyncOp syncOp,BBObject *syncInfo ){
	DWORD threadId;
	AsyncOp *p=(AsyncOp*)malloc( sizeof( AsyncOp ) );
	BBRETAIN( syncInfo );
	p->asyncOp=asyncOp;
	p->asyncInfo=asyncInfo;
	p->syncOp=syncOp;
	p->syncInfo=syncInfo;
	CreateThread( 0,0,asyncOpThread,p,0,&threadId );
}

int DesktopCaps(int index){
	HWND hwnd = GetDesktopWindow();
	HDC dc = GetDC(hwnd);
	int caps = GetDeviceCaps(dc,index);
	ReleaseDC(hwnd,dc);
	return caps;
}

int bbSystemDesktopWidth(){
	return DesktopCaps(HORZRES);
}

int bbSystemDesktopHeight(){
	return DesktopCaps(VERTRES);
}

int bbSystemDesktopDepth(){
	return DesktopCaps(BITSPIXEL);
}

int bbSystemDesktopHertz(){
	return DesktopCaps(VREFRESH);
}
