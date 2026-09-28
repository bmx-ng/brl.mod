
#include <windows.h>

#include <gl/gl.h>

#include <brl.mod/systemdefault.mod/system.h>

enum{
	_BACKBUFFER=	0x2,
	_ALPHABUFFER=	0x4,
	_DEPTHBUFFER=	0x8,
	_STENCILBUFFER=	0x10,
	_ACCUMBUFFER=	0x20,
	_BORDERLESS=	0x40,
	_FULLSCREEN_DESKTOP= 0x80,

	//win32 exclusive
	_MULTISAMPLE2X=	0x100,
	_MULTISAMPLE4X=	0x200,
	_MULTISAMPLE8X=	0x400,
	_MULTISAMPLE16X=0x800,
	_HIDDEN=0x1000,
	
	//add them here so they are not accidentally used
	_SWAPINTERVAL0 = 0x10000,
	_SWAPINTERVAL1 = 0x20000,
};

enum{
	MODE_SHARED,
	MODE_WIDGET,
	MODE_WINDOW,
	MODE_DISPLAY
};

//------------
// NEW SECTION
//------------

#define WGL_NUMBER_PIXEL_FORMATS_ARB        0x2000
#define WGL_DRAW_TO_WINDOW_ARB              0x2001
#define WGL_DRAW_TO_BITMAP_ARB              0x2002
#define WGL_ACCELERATION_ARB                0x2003
#define WGL_NEED_PALETTE_ARB                0x2004
#define WGL_NEED_SYSTEM_PALETTE_ARB         0x2005
#define WGL_SWAP_LAYER_BUFFERS_ARB          0x2006
#define WGL_SWAP_METHOD_ARB                 0x2007
#define WGL_NUMBER_OVERLAYS_ARB             0x2008
#define WGL_NUMBER_UNDERLAYS_ARB            0x2009
#define WGL_TRANSPARENT_ARB                 0x200A
#define WGL_TRANSPARENT_RED_VALUE_ARB       0x2037
#define WGL_TRANSPARENT_GREEN_VALUE_ARB     0x2038
#define WGL_TRANSPARENT_BLUE_VALUE_ARB      0x2039
#define WGL_TRANSPARENT_ALPHA_VALUE_ARB     0x203A
#define WGL_TRANSPARENT_INDEX_VALUE_ARB     0x203B
#define WGL_SHARE_DEPTH_ARB                 0x200C
#define WGL_SHARE_STENCIL_ARB               0x200D
#define WGL_SHARE_ACCUM_ARB                 0x200E
#define WGL_SUPPORT_GDI_ARB                 0x200F
#define WGL_SUPPORT_OPENGL_ARB              0x2010
#define WGL_DOUBLE_BUFFER_ARB               0x2011
#define WGL_STEREO_ARB                      0x2012
#define WGL_PIXEL_TYPE_ARB                  0x2013
#define WGL_COLOR_BITS_ARB                  0x2014
#define WGL_RED_BITS_ARB                    0x2015
#define WGL_RED_SHIFT_ARB                   0x2016
#define WGL_GREEN_BITS_ARB                  0x2017
#define WGL_GREEN_SHIFT_ARB                 0x2018
#define WGL_BLUE_BITS_ARB                   0x2019
#define WGL_BLUE_SHIFT_ARB                  0x201A
#define WGL_ALPHA_BITS_ARB                  0x201B
#define WGL_ALPHA_SHIFT_ARB                 0x201C
#define WGL_ACCUM_BITS_ARB                  0x201D
#define WGL_ACCUM_RED_BITS_ARB              0x201E
#define WGL_ACCUM_GREEN_BITS_ARB            0x201F
#define WGL_ACCUM_BLUE_BITS_ARB             0x2020
#define WGL_ACCUM_ALPHA_BITS_ARB            0x2021
#define WGL_DEPTH_BITS_ARB                  0x2022
#define WGL_STENCIL_BITS_ARB                0x2023
#define WGL_AUX_BUFFERS_ARB                 0x2024
#define WGL_NO_ACCELERATION_ARB             0x2025
#define WGL_GENERIC_ACCELERATION_ARB        0x2026
#define WGL_FULL_ACCELERATION_ARB           0x2027
#define WGL_SWAP_EXCHANGE_ARB               0x2028
#define WGL_SWAP_COPY_ARB                   0x2029
#define WGL_SWAP_UNDEFINED_ARB              0x202A
#define WGL_TYPE_RGBA_ARB                   0x202B
#define WGL_TYPE_COLORINDEX_ARB             0x202C
#define WGL_SAMPLE_BUFFERS_ARB              0x2041
#define WGL_SAMPLES_ARB                     0x2042

static BOOL _wglChoosePixelFormatARB( HDC hDC, const int *intAttribs, const FLOAT *floatAttribs, unsigned int maxFormats, int *lPixelFormat, unsigned int *numFormats){
	//Define function pointer datatype
	typedef BOOL (APIENTRY * WGLCHOOSEPIXELFORMATARB) (HDC hDC, const int *intAttribs, const FLOAT *floatAttribs, unsigned int maxFormats, int *lPixelFormat, unsigned int *numFormats);

	//Get the "wglChoosePixelFormatARB" function
	WGLCHOOSEPIXELFORMATARB wglChoosePixelFormatARB = (WGLCHOOSEPIXELFORMATARB)wglGetProcAddress("wglChoosePixelFormatARB");
	if(wglChoosePixelFormatARB)
		return wglChoosePixelFormatARB(hDC, intAttribs, floatAttribs, maxFormats, lPixelFormat, numFormats);
	else
		MessageBox(0,"wglChoosePixelFormatARB() function not found!","Error",0);
	return 0;
}

static int MyChoosePixelFormat( HDC hDC, const BBInt64 flags ){
	//Extract multisample mode from flags 
	int multisample = 0;
	if (_MULTISAMPLE2X & flags) multisample = 2;
	else if (_MULTISAMPLE4X & flags) multisample = 4;
	else if (_MULTISAMPLE8X & flags) multisample = 8;
	else if (_MULTISAMPLE16X & flags) multisample = 16;

	//Empty float attributes array
	float floatAttribs[] = {0.0,0.0};
	
	//Some variables
	int lPixelFormat = 0;
	int numFormats=1;
	int result=0;

	//Include the multisample in the flags
	if (multisample > 0){
		int intAttribs[] = {WGL_DRAW_TO_WINDOW_ARB,GL_TRUE,WGL_SUPPORT_OPENGL_ARB,GL_TRUE,WGL_ACCELERATION_ARB,WGL_FULL_ACCELERATION_ARB,WGL_COLOR_BITS_ARB,24,WGL_ALPHA_BITS_ARB,8,WGL_DEPTH_BITS_ARB,16,WGL_DOUBLE_BUFFER_ARB,GL_TRUE,WGL_SAMPLE_BUFFERS_ARB,GL_TRUE,WGL_SAMPLES_ARB,multisample,0,0};
		result=_wglChoosePixelFormatARB(hDC, &intAttribs, &floatAttribs, 1, &lPixelFormat, &numFormats);
	}else{
		int intAttribs[] = {WGL_DRAW_TO_WINDOW_ARB,GL_TRUE,WGL_SUPPORT_OPENGL_ARB,GL_TRUE,WGL_ACCELERATION_ARB,WGL_FULL_ACCELERATION_ARB,WGL_COLOR_BITS_ARB,24,WGL_ALPHA_BITS_ARB,8,WGL_DEPTH_BITS_ARB,16,WGL_DOUBLE_BUFFER_ARB,GL_TRUE,WGL_SAMPLE_BUFFERS_ARB,GL_FALSE,0,0};
		result=_wglChoosePixelFormatARB(hDC, &intAttribs, &floatAttribs, 1, &lPixelFormat, &numFormats);
	}

	//If result=True return lPixelFormat
	if (result > 0){
		return lPixelFormat;
	}else{
		MessageBox(0,"wglChoosePixelFormatARB() failed.","Error",MB_OK);
		return 0;
	}
}

//------------
//
//------------

extern int _bbusew;

static const char *CLASS_NAME="BlitzMax GLGraphics";
static const wchar_t *CLASS_NAMEW=L"BlitzMax GLGraphics";

typedef struct BBGLContext BBGLContext;

struct BBGLContext{
	BBGLContext *succ;
	int mode,width,height,depth,hertz;
	int borderless;
	int exclusive,exclusiveActive,transition,savedHertz;
	WCHAR displayName[CCHDEVICENAME];
	DEVMODEW desktopMode,exclusiveMode;
	RECT savedWindowRect;
	LONG_PTR savedStyle,savedExStyle;
	BBInt64 flags;
	
	HDC hdc;
	HWND hwnd;
	HGLRC hglrc;
};

static BBGLContext *_exclusiveOwner;
static int runtimeFocus(BBGLContext *context,int active);
int bbGLGraphicsSetFullscreen(BBGLContext *context,int enabled,int width,int height,int hertz);
static BBGLContext *_contexts;
static BBGLContext *_sharedContext;
static BBGLContext *_currentContext;

typedef BOOL (APIENTRY * WGLSWAPINTERVALEXT) (int);

void bbGLGraphicsClose( BBGLContext *context );
void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,BBInt64 *flags );
void bbGLGraphicsSetGraphics( BBGLContext *context );

static void _initPfd( PIXELFORMATDESCRIPTOR *pfd,BBInt64 flags ){

	memset( pfd,0,sizeof(*pfd) );

	pfd->nSize=sizeof(pfd);
	pfd->nVersion=1;
	pfd->cColorBits=1;
	pfd->iPixelType=PFD_TYPE_RGBA;
	pfd->iLayerType=PFD_MAIN_PLANE;
	pfd->dwFlags=PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL;

	pfd->dwFlags|=(flags & _BACKBUFFER) ? PFD_DOUBLEBUFFER : 0;
	pfd->cAlphaBits=(flags & _ALPHABUFFER) ? 1 : 0;
	pfd->cDepthBits=(flags & _DEPTHBUFFER) ? 1 : 0;
	pfd->cStencilBits=(flags & _STENCILBUFFER) ? 1 : 0;
	pfd->cAccumBits=(flags & _ACCUMBUFFER) ? 1 : 0;
}

static int _setSwapInterval( int n ){
	WGLSWAPINTERVALEXT 	wglSwapIntervalEXT=(WGLSWAPINTERVALEXT)wglGetProcAddress("wglSwapIntervalEXT");
	if( wglSwapIntervalEXT ) wglSwapIntervalEXT( n );
}

static _stdcall long _wndProc( HWND hwnd,UINT msg,WPARAM wp,LPARAM lp ){

	static HWND _fullScreen;

	BBGLContext *c;
	for( c=_contexts;c && c->hwnd!=hwnd;c=c->succ ){}
	if( !c ){
		return _bbusew ? DefWindowProcW( hwnd,msg,wp,lp ) : DefWindowProc( hwnd,msg,wp,lp );
	}

	bbSystemEmitOSEvent( hwnd,msg,wp,lp,&bbNullObject );

	switch( msg ){
	case WM_CLOSE:
		return 0;
	case WM_SYSCOMMAND:
		if (wp==SC_SCREENSAVE) return 1;
		if (wp==SC_MONITORPOWER) return 1;
		break;
	case WM_SYSKEYDOWN:
		if( wp!=VK_F4 ) return 0;
		break;
	case WM_SETFOCUS:
		if(c->exclusive && !c->transition)runtimeFocus(c,1);
		if( c && c->mode==MODE_DISPLAY && hwnd!=_fullScreen ){
			DEVMODE dm;
			int swapInt=0;
			memset( &dm,0,sizeof(dm) );
			dm.dmSize=sizeof(dm);
			dm.dmPelsWidth=c->width;
			dm.dmPelsHeight=c->height;
			dm.dmBitsPerPel=c->depth;
			dm.dmFields=DM_PELSWIDTH|DM_PELSHEIGHT|DM_BITSPERPEL;
			if( c->hertz ){
				dm.dmDisplayFrequency=c->hertz;
				dm.dmFields|=DM_DISPLAYFREQUENCY;
				swapInt=1;
			}
			if( ChangeDisplaySettings( &dm,CDS_FULLSCREEN )==DISP_CHANGE_SUCCESSFUL ){
				_fullScreen=hwnd;
			}else if( dm.dmFields & DM_DISPLAYFREQUENCY ){
				dm.dmDisplayFrequency=0;
				dm.dmFields&=~DM_DISPLAYFREQUENCY;
				if( ChangeDisplaySettings( &dm,CDS_FULLSCREEN )==DISP_CHANGE_SUCCESSFUL ){
					_fullScreen=hwnd;
					swapInt=0;
				}
			}

			if( !_fullScreen ) bbExThrowCString( "GLGraphicsDriver failed to set display mode" );
			
			_setSwapInterval( swapInt );
		}
		return 0;
	case WM_DESTROY:
	case WM_KILLFOCUS:
		if(c->exclusive && !c->transition)runtimeFocus(c,0);
		if( hwnd==_fullScreen ){
			ChangeDisplaySettings( 0,CDS_FULLSCREEN );
			ShowWindow( hwnd,SW_MINIMIZE );
			_setSwapInterval( 0 );
			_fullScreen=0;
		}
		return 0;
	case WM_PAINT:
		ValidateRect( hwnd,0 );
		return 0;
	case WM_LBUTTONDOWN: case WM_RBUTTONDOWN: case WM_MBUTTONDOWN:
		if( !_fullScreen ) SetCapture( hwnd );
		return 0;
	case WM_LBUTTONUP: case WM_RBUTTONUP: case WM_MBUTTONUP:
		if( !_fullScreen ) ReleaseCapture();
		return 0;
	}
	return _bbusew ? DefWindowProcW( hwnd,msg,wp,lp ) : DefWindowProc( hwnd,msg,wp,lp );
}

static void _initWndClass(){
	static int _done;
	if( _done ) return;

	if( _bbusew ){
		WNDCLASSEXW wc={sizeof(wc)};
		wc.style=CS_HREDRAW|CS_VREDRAW|CS_OWNDC;
		wc.lpfnWndProc=(WNDPROC)_wndProc;
		wc.hInstance=GetModuleHandle(0);
		wc.lpszClassName=CLASS_NAMEW;
		wc.hCursor=(HCURSOR)LoadCursor( 0,IDC_ARROW );
		wc.hIcon = bbAppIcon(wc.hInstance);
		wc.hbrBackground=0;
		if( !RegisterClassExW( &wc ) ) exit( -1 );
	}else{
		WNDCLASSEX wc={sizeof(wc)};
		wc.style=CS_HREDRAW|CS_VREDRAW|CS_OWNDC;
		wc.lpfnWndProc=(WNDPROC)_wndProc;
		wc.hInstance=GetModuleHandle(0);
		wc.lpszClassName=CLASS_NAME;
		wc.hCursor=(HCURSOR)LoadCursor( 0,IDC_ARROW );
		wc.hIcon = bbAppIcon(wc.hInstance);
		wc.hbrBackground=0;
		if( !RegisterClassEx( &wc ) ) exit( -1 );
	}

	_done=1;
}

static void _validateSize( BBGLContext *context ){
	if(context->exclusive)return;
	if( context->mode==MODE_WIDGET || context->mode==MODE_WINDOW ){
		RECT rect;
		GetClientRect( context->hwnd,&rect );
		context->width=rect.right-rect.left;
		context->height=rect.bottom-rect.top;
	}
}

void bbGLGraphicsShareContexts(){
	BBGLContext *context;
	HDC hdc;
	HWND hwnd;
	HGLRC hglrc;
	long pf;
	PIXELFORMATDESCRIPTOR pfd;
	
	if( _sharedContext ) return;
	
	_initWndClass();
	
	if( _bbusew ){
		hwnd=CreateWindowExW( 0,CLASS_NAMEW,0,WS_POPUP,0,0,1,1,0,0,GetModuleHandle(0),0 );
	}else{
		hwnd=CreateWindowEx( 0,CLASS_NAME,0,WS_POPUP,0,0,1,1,0,0,GetModuleHandle(0),0 );
	}
		
	_initPfd( &pfd,0 );
	
	hdc=GetDC( hwnd );
	pf=ChoosePixelFormat( hdc,&pfd );
	if( !pf ){
		exit(0);
		DestroyWindow( hwnd );
		return;
	}
	SetPixelFormat( hdc,pf,&pfd );
	hglrc=wglCreateContext( hdc );
	if( !hglrc ) exit(0);
	
	_sharedContext=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( _sharedContext,0,sizeof(BBGLContext) );

	_sharedContext->mode=MODE_SHARED;	
	_sharedContext->width=1;
	_sharedContext->height=1;
	
	_sharedContext->hdc=hdc;
	_sharedContext->hwnd=hwnd;
	_sharedContext->hglrc=hglrc;
}

int bbGLGraphicsGraphicsModes( int *modes,int count ){
	int i=0,n=0;
	while( n<count ){
		DEVMODE	mode;
		mode.dmSize=sizeof(DEVMODE);
		mode.dmDriverExtra=0;

		if( !EnumDisplaySettings(0,i++,&mode) ) break;

		if( mode.dmBitsPerPel<16 ) continue;

		*modes++=mode.dmPelsWidth;
		*modes++=mode.dmPelsHeight;
		*modes++=mode.dmBitsPerPel;
		*modes++=mode.dmDisplayFrequency;
		++n;
	}
	return n;
}

BBGLContext *bbGLGraphicsAttachGraphics( HWND hwnd,BBInt64 flags ){
	BBGLContext *context;
	
	HDC hdc;
	HGLRC hglrc;
	
	long pf;
	PIXELFORMATDESCRIPTOR pfd;
	RECT rect;
	
	_initWndClass();
	
	hdc=GetDC( hwnd );
	if( !hdc ) return 0;
	
	_initPfd( &pfd,flags );

	int multisample = 0;
	if (_MULTISAMPLE2X & flags) multisample = 2;
	else if (_MULTISAMPLE4X & flags) multisample = 4;
	else if (_MULTISAMPLE8X & flags) multisample = 8;
	else if (_MULTISAMPLE16X & flags) multisample = 16;
	if (multisample>0){
		pf=MyChoosePixelFormat( hdc,flags );
	}else{
		pf=ChoosePixelFormat( hdc,&pfd );
	}
	if( !pf ) return 0;
	SetPixelFormat( hdc,pf,&pfd );
	hglrc=wglCreateContext( hdc );
	
	if( _sharedContext ) wglShareLists( _sharedContext->hglrc,hglrc );
	
	GetClientRect( hwnd,&rect );
	
	context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(*context) );
	
	context->mode=MODE_WIDGET;
	context->width=rect.right;
	context->height=rect.bottom;
	context->flags=flags;
	
	context->hdc=hdc;
	context->hwnd=hwnd;
	context->hglrc=hglrc;
	
	context->succ=_contexts;
	_contexts=context;
	
	return context;
}

BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hertz, BBInt64 flags, int x, int y ){
	if(depth && _exclusiveOwner)bbExThrowCString("GLGraphics: leave runtime exclusive fullscreen before creating legacy exclusive graphics");
	BBGLContext *context;
	
	int mode;
	HDC hdc;
	HWND hwnd;
	HGLRC hglrc;
	
	long pf;
	PIXELFORMATDESCRIPTOR pfd;
	int hwnd_style;
	RECT rect={0,0,width,height};
	
	_initWndClass();
	
	if( depth ){
		mode=MODE_DISPLAY;
		hwnd_style=WS_POPUP;
	}else{
		HWND desktop = GetDesktopWindow();
		RECT desktopRect;
		GetWindowRect(desktop, &desktopRect);

		rect.left=(x == -1) ? desktopRect.right/2-width/2 : x + GetSystemMetrics(SM_CXBORDER);
		rect.top=(y == -1) ? desktopRect.bottom/2-height/2: y + GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYFIXEDFRAME);
		rect.right=rect.left+width;
		rect.bottom=rect.top+height;
		
		mode=MODE_WINDOW;
		hwnd_style=WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX;
	}
		
	AdjustWindowRectEx( &rect,hwnd_style,0,0 );
	
	if( _bbusew ){
		BBChar *p=bbStringToWString( bbAppTitle );
		hwnd=CreateWindowExW( 
			0,CLASS_NAMEW,p,
			hwnd_style,rect.left,rect.top,rect.right-rect.left,rect.bottom-rect.top,0,0,GetModuleHandle(0),0 );
		bbMemFree(p);
	}else{
		char *p=bbStringToCString( bbAppTitle );
		hwnd=CreateWindowEx( 
			0,CLASS_NAME,p,
			hwnd_style,rect.left,rect.top,rect.right-rect.left,rect.bottom-rect.top,0,0,GetModuleHandle(0),0 );
		bbMemFree(p);
	}
		
	if( !hwnd ) return 0;

	GetClientRect( hwnd,&rect );
	width=rect.right-rect.left;
	height=rect.bottom-rect.top;
		
	_initPfd( &pfd,flags );

	hdc=GetDC( hwnd );
	int multisample = 0;
	if (_MULTISAMPLE2X & flags) multisample = 2;
	else if (_MULTISAMPLE4X & flags) multisample = 4;
	else if (_MULTISAMPLE8X & flags) multisample = 8;
	else if (_MULTISAMPLE16X & flags) multisample = 16;
	if (multisample>0){
		pf=MyChoosePixelFormat( hdc,flags );
	}else{
		pf=ChoosePixelFormat( hdc,&pfd );
	}
	if( !pf ){
		DestroyWindow( hwnd );
		return 0;
	}
	SetPixelFormat( hdc,pf,&pfd );
	hglrc=wglCreateContext( hdc );
	
	if( _sharedContext ) wglShareLists( _sharedContext->hglrc,hglrc );
	
	context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(*context) );
	
	context->mode=mode;
	context->width=width;
	context->height=height;
	context->depth=depth;
	context->hertz=hertz;
	context->flags=flags;
	
	context->hdc=hdc;
	context->hwnd=hwnd;
	context->hglrc=hglrc;
	
	context->succ=_contexts;
	_contexts=context;
	
	ShowWindow( hwnd,SW_SHOW );
	
	return context;
}

void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,BBInt64 *flags ){
	_validateSize( context );
	*width=context->width;
	*height=context->height;
	*depth=context->depth;
	*hertz=context->borderless && !context->exclusive ? 0 : context->hertz;
	*flags=context->flags;
}

int bbGLGraphicsSupportsBorderless(BBGLContext *context){
	return context && context->mode==MODE_WINDOW;
}
int bbGLGraphicsIsBorderless(BBGLContext *context){
	return context && context->borderless && !context->exclusive;
}
static int setWindowStyle(HWND window,int index,LONG_PTR style){
	SetLastError(0);
	return SetWindowLongPtr(window,index,style)!=0 || GetLastError()==0;
}
int bbGLGraphicsSetBorderless(BBGLContext *context,int enabled){
	RECT before,target;
	LONG_PTR style,exStyle,newStyle,newExStyle;
	MONITORINFO monitor;
	if(!bbGLGraphicsSupportsBorderless(context))return 0;
	if(context->exclusive && !bbGLGraphicsSetFullscreen(context,0,0,0,0))return 0;
	enabled=!!enabled;
	if(context->borderless==enabled)return 1;
	if(!GetWindowRect(context->hwnd,&before))return 0;
	style=GetWindowLongPtr(context->hwnd,GWL_STYLE);
	exStyle=GetWindowLongPtr(context->hwnd,GWL_EXSTYLE);
	if(enabled){
		memset(&monitor,0,sizeof(monitor));monitor.cbSize=sizeof(monitor);
		if(!GetMonitorInfo(MonitorFromWindow(context->hwnd,MONITOR_DEFAULTTONEAREST),&monitor))return 0;
		target=monitor.rcMonitor;
		newStyle=(style & ~WS_OVERLAPPEDWINDOW)|WS_POPUP;
		newExStyle=exStyle & ~(WS_EX_WINDOWEDGE|WS_EX_CLIENTEDGE|WS_EX_STATICEDGE|WS_EX_DLGMODALFRAME);
	}else{
		target=context->savedWindowRect;
		newStyle=context->savedStyle;newExStyle=context->savedExStyle;
	}
	if(!setWindowStyle(context->hwnd,GWL_STYLE,newStyle) ||
	   !setWindowStyle(context->hwnd,GWL_EXSTYLE,newExStyle) ||
	   !SetWindowPos(context->hwnd,NULL,target.left,target.top,target.right-target.left,target.bottom-target.top,
	                 SWP_FRAMECHANGED|SWP_NOZORDER|SWP_NOACTIVATE)){
		setWindowStyle(context->hwnd,GWL_STYLE,style);
		setWindowStyle(context->hwnd,GWL_EXSTYLE,exStyle);
		SetWindowPos(context->hwnd,NULL,before.left,before.top,before.right-before.left,before.bottom-before.top,
		             SWP_FRAMECHANGED|SWP_NOZORDER|SWP_NOACTIVATE);
		_validateSize(context);
		return 0;
	}
	if(enabled){
		context->savedWindowRect=before;
		context->savedStyle=style;context->savedExStyle=exStyle;
	}
	context->borderless=enabled;
	_validateSize(context);
	return 1;
}
void bbGLGraphicsClientSize(BBGLContext *context,int *width,int *height){
 RECT r={0};if(context)GetClientRect(context->hwnd,&r);*width=r.right;*height=r.bottom;
}
int bbGLGraphicsSupportsFullscreen(BBGLContext *context){return context && context->mode==MODE_WINDOW;}
static int runtimeMonitor(BBGLContext *context,MONITORINFOEXW *monitor){
 memset(monitor,0,sizeof(*monitor));monitor->cbSize=sizeof(*monitor);
 return GetMonitorInfoW(MonitorFromWindow(context->hwnd,MONITOR_DEFAULTTONEAREST),(MONITORINFO*)monitor);
}
int bbGLGraphicsFullscreenModes(BBGLContext *context,int *buf,int count){
 MONITORINFOEXW monitor;DEVMODEW mode;int n=0,index;
 if(!bbGLGraphicsSupportsFullscreen(context)||!runtimeMonitor(context,&monitor))return 0;
 for(index=0;;++index){
  memset(&mode,0,sizeof(mode));mode.dmSize=sizeof(mode);
  if(!EnumDisplaySettingsW(monitor.szDevice,index,&mode))break;
  if(mode.dmBitsPerPel!=32)continue;
  if(buf){if(n==count)break;buf[n*4]=mode.dmPelsWidth;buf[n*4+1]=mode.dmPelsHeight;buf[n*4+2]=32;buf[n*4+3]=mode.dmDisplayFrequency;}
  ++n;
 }
 return n;
}
static int runtimeFocus(BBGLContext *context,int active){
 MONITORINFOEXW monitor;int ok=1;
 if(!context->exclusive || context->transition || active==context->exclusiveActive)return 1;
 context->transition=1;
 if(active){
  ok=ChangeDisplaySettingsExW(context->displayName,&context->exclusiveMode,NULL,CDS_FULLSCREEN,NULL)==DISP_CHANGE_SUCCESSFUL;
  if(ok){
   context->exclusiveActive=1;
   if(runtimeMonitor(context,&monitor))ok=SetWindowPos(context->hwnd,NULL,monitor.rcMonitor.left,monitor.rcMonitor.top,
     monitor.rcMonitor.right-monitor.rcMonitor.left,monitor.rcMonitor.bottom-monitor.rcMonitor.top,SWP_NOZORDER|SWP_NOACTIVATE)!=0;
  }
 }else{
  ok=ChangeDisplaySettingsExW(context->displayName,&context->desktopMode,NULL,0,NULL)==DISP_CHANGE_SUCCESSFUL;
  if(ok)context->exclusiveActive=0;
 }
 context->transition=0;
 return ok;
}
int bbGLGraphicsSetFullscreen(BBGLContext *context,int enabled,int width,int height,int hertz){
 MONITORINFOEXW monitor;DEVMODEW mode,chosen;int found=0,index;
 if(!bbGLGraphicsSupportsFullscreen(context))return 0;
 if(!enabled){
  if(!context->exclusive)return bbGLGraphicsSetBorderless(context,0);
  if(!runtimeFocus(context,0))return 0;
  context->exclusive=0;_exclusiveOwner=NULL;context->depth=0;context->hertz=context->savedHertz;
  return bbGLGraphicsSetBorderless(context,0);
 }
 if(GetForegroundWindow()!=context->hwnd)return 0;
 if(width<0 || height<0 || hertz<0 || (_exclusiveOwner && _exclusiveOwner!=context))return 0;
 for(BBGLContext *c=_contexts;c;c=c->succ)if(c->mode==MODE_DISPLAY)return 0;
 if(!runtimeMonitor(context,&monitor))return 0;
 if(!width)width=context->width;if(!height)height=context->height;
 memset(&chosen,0,sizeof(chosen));
 for(index=0;;++index){
  memset(&mode,0,sizeof(mode));mode.dmSize=sizeof(mode);
  if(!EnumDisplaySettingsW(monitor.szDevice,index,&mode))break;
  if(mode.dmBitsPerPel!=32 || mode.dmPelsWidth!=(DWORD)width || mode.dmPelsHeight!=(DWORD)height || (hertz && mode.dmDisplayFrequency!=(DWORD)hertz))continue;
  if(!found || mode.dmDisplayFrequency>chosen.dmDisplayFrequency){chosen=mode;found=1;}
 }
 if(!found || ChangeDisplaySettingsExW(monitor.szDevice,&chosen,NULL,CDS_TEST,NULL)!=DISP_CHANGE_SUCCESSFUL)return 0;
 if(context->exclusive && context->width==width && context->height==height && context->hertz==(int)chosen.dmDisplayFrequency)return 1;
 if(context->exclusive && !bbGLGraphicsSetFullscreen(context,0,0,0,0))return 0;
 if(context->borderless && !bbGLGraphicsSetBorderless(context,0))return 0;
 memset(&context->desktopMode,0,sizeof(context->desktopMode));context->desktopMode.dmSize=sizeof(context->desktopMode);
 if(!EnumDisplaySettingsW(monitor.szDevice,ENUM_CURRENT_SETTINGS,&context->desktopMode))return 0;
 if(!bbGLGraphicsSetBorderless(context,1))return 0;
 memcpy(context->displayName,monitor.szDevice,sizeof(context->displayName));context->exclusiveMode=chosen;
 context->savedHertz=context->hertz;context->exclusive=1;context->exclusiveActive=0;_exclusiveOwner=context;
 context->width=width;context->height=height;context->depth=32;context->hertz=chosen.dmDisplayFrequency;
 if(!runtimeFocus(context,1)){
  bbGLGraphicsSetFullscreen(context,0,0,0,0);return 0;
 }
 return 1;
}
void bbGLGraphicsGetPosition(BBGLContext *context,int *x,int *y){
 POINT p={0,0};*x=*y=-1;
 if(context && ClientToScreen(context->hwnd,&p)){*x=p.x;*y=p.y;}
}
int bbGLGraphicsResize(BBGLContext *context,int width,int height){
 RECT r={0,0,width,height};
 if(!context || context->mode!=MODE_WINDOW || context->borderless || width<=0 || height<=0)return 0;
 if(!AdjustWindowRectEx(&r,(DWORD)GetWindowLongPtr(context->hwnd,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtr(context->hwnd,GWL_EXSTYLE)))return 0;
 if(!SetWindowPos(context->hwnd,NULL,0,0,r.right-r.left,r.bottom-r.top,SWP_NOMOVE|SWP_NOZORDER|SWP_NOACTIVATE))return 0;
 _validateSize(context);
 return 1;
}
int bbGLGraphicsPosition(BBGLContext *context,int x,int y){
 RECT r={0,0,0,0};
 if(!context || context->mode!=MODE_WINDOW || context->borderless)return 0;
 if(!AdjustWindowRectEx(&r,(DWORD)GetWindowLongPtr(context->hwnd,GWL_STYLE),FALSE,(DWORD)GetWindowLongPtr(context->hwnd,GWL_EXSTYLE)))return 0;
 return SetWindowPos(context->hwnd,NULL,x+r.left,y+r.top,0,0,SWP_NOSIZE|SWP_NOZORDER|SWP_NOACTIVATE)!=0;
}

void bbGLGraphicsClose( BBGLContext *context ){
	BBGLContext **p,*t;
	
	for( p=&_contexts;(t=*p) && (t!=context);p=&t->succ ){}
	if( !t ) return;
	
	if( t==_currentContext ){
		bbGLGraphicsSetGraphics( 0 );
	}
	
	if(context->exclusive && !bbGLGraphicsSetFullscreen(context,0,0,0,0))bbExThrowCString("GLGraphics: unable to restore desktop display mode");
	wglDeleteContext( context->hglrc );

	if( t->mode==MODE_DISPLAY || t->mode==MODE_WINDOW ){
		DestroyWindow( t->hwnd );
	}
	
	*p=t->succ;
}

void bbGLGraphicsSwapSharedContext(){

	if( wglGetCurrentContext()!=_sharedContext->hglrc ){
		wglMakeCurrent( _sharedContext->hdc,_sharedContext->hglrc );
	}else if( _currentContext ){
		wglMakeCurrent( _currentContext->hdc,_currentContext->hglrc );
	}else{
		wglMakeCurrent( 0,0 );
	}
}

void bbGLGraphicsSetGraphics( BBGLContext *context ){
	if(context && context->exclusive && !context->exclusiveActive && GetForegroundWindow()==context->hwnd){
		if(!runtimeFocus(context,1))bbExThrowCString("GLGraphics: unable to resume exclusive display mode");
	}

	if( context==_currentContext ) return;
	
	_currentContext=context;
	
	if( context ){
		wglMakeCurrent( context->hdc,context->hglrc );
	}else{
		wglMakeCurrent( 0,0 );
	}
}

void bbGLGraphicsFlip( int sync ){
	if( !_currentContext ) return;
	
	_setSwapInterval( sync ? 1 : 0 );
	
	/*
	static int _sync=-1;

	sync=sync ? 1 : 0;
	if( sync!=_sync ){
		_sync=sync;
		_setSwapInterval( _sync );
	}
	*/

	SwapBuffers( _currentContext->hdc );
}
