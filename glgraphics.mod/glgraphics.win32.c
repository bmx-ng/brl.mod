
#include <windows.h>

#include <gl/gl.h>

#include <brl.mod/systemdefault.mod/system.h>

enum{
	_BACKBUFFER=	0x2,
	_ALPHABUFFER=	0x4,
	_DEPTHBUFFER=	0x8,
	_STENCILBUFFER=	0x10,
	_ACCUMBUFFER=	0x20,

	_MULTISAMPLE2X=	0x40,
	_MULTISAMPLE4X=	0x80,
	_MULTISAMPLE8X=	0x100,
	_MULTISAMPLE16X=0x200,
	_HIDDEN=0x400,
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

static BOOL _wglChoosePixelFormatARB( int hDC, const int *intAttribs, const FLOAT *floatAttribs, unsigned int maxFormats, int *lPixelFormat, unsigned int *numFormats){
	//Define function pointer datatype
	typedef BOOL (APIENTRY * WGLCHOOSEPIXELFORMATARB) (int hDC, const int *intAttribs, const FLOAT *floatAttribs, unsigned int maxFormats, int *lPixelFormat, unsigned int *numFormats);

	//Get the "wglChoosePixelFormatARB" function
	WGLCHOOSEPIXELFORMATARB wglChoosePixelFormatARB = (WGLCHOOSEPIXELFORMATARB)wglGetProcAddress("wglChoosePixelFormatARB");
	if(wglChoosePixelFormatARB)
		return wglChoosePixelFormatARB(hDC, intAttribs, floatAttribs, maxFormats, lPixelFormat, numFormats);
	else
		MessageBox(0,"wglChoosePixelFormatARB() function not found!","Error",0);
	return 0;
}

static int MyChoosePixelFormat( int hDC, const int flags ){
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
	int mode,width,height,depth,hertz,flags;
	
	HDC hdc;
	HWND hwnd;
	HGLRC hglrc;
};

static BBGLContext *_contexts;
static BBGLContext *_sharedContext;
static BBGLContext *_currentContext;

typedef BOOL (APIENTRY * WGLSWAPINTERVALEXT) (int);

void bbGLGraphicsClose( BBGLContext *context );
void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,int *flags );
void bbGLGraphicsSetGraphics( BBGLContext *context );

static void _initPfd( PIXELFORMATDESCRIPTOR *pfd,int flags ){

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
	if( context->mode==MODE_WIDGET ){
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

BBGLContext *bbGLGraphicsAttachGraphics( HWND hwnd,int flags ){
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

BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hertz,int flags ){
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

		rect.left=desktopRect.right/2-width/2;		
		rect.top=desktopRect.bottom/2-height/2;		
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
	memset( context,0,sizeof(context) );
	
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

void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,int *flags ){
	_validateSize( context );
	*width=context->width;
	*height=context->height;
	*depth=context->depth;
	*hertz=context->hertz;
	*flags=context->flags;
}

void bbGLGraphicsClose( BBGLContext *context ){
	BBGLContext **p,*t;
	
	for( p=&_contexts;(t=*p) && (t!=context);p=&t->succ ){}
	if( !t ) return;
	
	if( t==_currentContext ){
		bbGLGraphicsSetGraphics( 0 );
	}
	
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
