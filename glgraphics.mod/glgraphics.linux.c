
#include <stdio.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include <X11/extensions/xf86vmode.h>
#include <assert.h>
#include <time.h>

/* Added by BaH */
#include <brl.mod/blitz.mod/blitz.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/extensions/Xrandr.h>

extern void bbSystemPoll();
extern Display *bbSystemDisplay();
extern void bbSetSystemWindow(int window);

static XF86VidModeModeInfo **modes,*mode;
static Display *xdisplay;

static int xscreen,xwindow,xfullscreen;

typedef int (* GLXSWAPINTERVALEXT) (int);

GLXSWAPINTERVALEXT glXSwapIntervalEXT;

void *glXExtension(Display *dpy,int screen,const char *catagory,const char *name){
	const char *extensions;
	extensions=glXQueryExtensionsString(dpy,screen);
	if (strstr(extensions,catagory)) {
		return (void*)glXGetProcAddressARB(name);
	}
	return (void*)0;
}

enum{
	MODE_SHARED=0,
	MODE_WIDGET=1,
	MODE_WINDOW=2,
	MODE_DISPLAY=3
};

enum{
	FLAGS_BACKBUFFER=	0x2,
	FLAGS_ALPHABUFFER=	0x4,
	FLAGS_DEPTHBUFFER=	0x8,
	FLAGS_STENCILBUFFER=0x10,
	FLAGS_ACCUMBUFFER=	0x20,
	FLAGS_BORDERLESS=	0x40,
	FLAGS_FULLSCREEN_DESKTOP=0x80
};

typedef struct BBGLContext BBGLContext;

struct BBGLContext{
	int mode,width,height,depth,hertz;
	BBInt64 flags;
	int sync;
	int savedWindow,savedX,savedY,savedWidth,savedHeight;
	XSizeHints savedHints;
	Window window;
	GLXContext glContext;
};

// glgraphics.bmx interface

int bbGLGraphicsGraphicsModes( int *imodes,int maxcount );
BBGLContext *bbGLGraphicsAttachGraphics( void * window,BBInt64 flags );
BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hz,BBInt64 flags, int x, int y );
void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hz,BBInt64 *flags );
void bbGLGraphicsClose( BBGLContext *context );
void bbGLGraphicsSetGraphics( BBGLContext *context );
void bbGLGraphicsFlip( int sync );
void bbGLExit();
int bbGLGraphicsIsBorderless(BBGLContext *context);
void bbGLGraphicsGetPosition(BBGLContext *context,int *x,int *y);

static BBGLContext *_currentContext;
static BBGLContext *_activeContext;
static BBGLContext *_sharedContext;

#define INTERLACE      0x010
#define DBLSCAN        0x020

static XF86VidModeModeInfo _oldMode;

int _calchertz(XF86VidModeModeInfo *m){
	int	freq;
	freq=(m->dotclock*1000.0)/(m->htotal*m->vtotal)+.5;
	if (m->flags&INTERLACE) freq<<=1;
	if (m->flags&DBLSCAN) freq>>=1;
	return freq;
}

int _initDisplay(){
	int major,minor;
	if (xdisplay) return 0;
	xdisplay=bbSystemDisplay();
	if (!xdisplay) return -1;
	if (glXQueryVersion(xdisplay,&major,&minor)==0) return -1;
	
//	printf("glXVersion=%d.%d\n",major,minor);fflush(stdout);

	XF86VidModeQueryVersion(xdisplay,&major,&minor);
	
//	printf("XF86VidModeExtension-Version %d.%d\n", major,minor);

	xscreen=DefaultScreen(xdisplay);
	
//	glXSwapIntervalEXT=(GLXSWAPINTERVALEXT)glXGetProcAddressARB("glXSwapIntervalSGI");

	glXSwapIntervalEXT=(GLXSWAPINTERVALEXT)glXExtension(xdisplay,xscreen,"GLX_SGI_swap_control","glXSwapIntervalSGI");
	atexit( bbGLExit );
	return 0;
}

int bbGLGraphicsGraphicsModes( int *imodes,int maxcount ){
	XF86VidModeModeInfo		**xmodes,*m;
	int						count,i;

	if (_initDisplay()) return 0;
	XF86VidModeGetAllModeLines(xdisplay,xscreen,&count,&xmodes);
	if (count>maxcount) count=maxcount;
	for (i=0;i<count;i++)
	{
		m=xmodes[i];
		*imodes++=m->hdisplay;	//width
		*imodes++=m->vdisplay;	//height;
		*imodes++=24;
		*imodes++=_calchertz(m);
	}
	XFree(xmodes);
	return count;
}

static void _swapBuffers( BBGLContext *context ){
	if( !context ) return;
	glXSwapBuffers(xdisplay,context->window);
	bbSystemPoll();
}

BBGLContext *bbGLGraphicsAttachGraphics( void * window,BBInt64 flags ){
	BBGLContext *context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(BBGLContext) );
	context->mode=MODE_WIDGET;
	context->flags=flags;
	context->sync=-1;	
	context->window=(Window)window;
	return context;
}

XVisualInfo *_chooseVisual(BBInt64 flags){
	int glspec[32],*s;
	s=glspec;
	*s++=GLX_RGBA;
	if (flags&FLAGS_BACKBUFFER) *s++=GLX_DOUBLEBUFFER;
	if (flags&FLAGS_ALPHABUFFER) {*s++=GLX_ALPHA_SIZE;*s++=1;}
	if (flags&FLAGS_DEPTHBUFFER) {*s++=GLX_DEPTH_SIZE;*s++=1;}
	if (flags&FLAGS_STENCILBUFFER) {*s++=GLX_STENCIL_SIZE;*s++=1;}
	if (flags&FLAGS_ACCUMBUFFER)
	{
		*s++=GLX_ACCUM_RED_SIZE;*s++=1;
		*s++=GLX_ACCUM_GREEN_SIZE;*s++=1;
		*s++=GLX_ACCUM_BLUE_SIZE;*s++=1;
		*s++=GLX_ACCUM_ALPHA_SIZE;*s++=1;
	}
 	*s++=None;
	return glXChooseVisual(xdisplay,xscreen,glspec);	
}

void _makeCurrent(	BBGLContext *context ){
	glXMakeCurrent(xdisplay,context->window,context->glContext);	
	_currentContext=context;
}

static void _validateSize( BBGLContext *context ){
	Window			root_return;
	int				x,y;
	unsigned int	w,h,border,d;
	if( !context || (context->mode!=MODE_WIDGET && context->mode!=MODE_WINDOW) ) return;
	if (_initDisplay()) return;
	XGetGeometry(xdisplay,context->window,&root_return,&x,&y,&w,&h,&border,&d);
	context->width=w;
	context->height=h;
}

static void _validateContext( BBGLContext *context ){
	GLXContext		sharedcontext=0;
	XVisualInfo 	*vizinfo;

	if( !context || context->glContext ) return;

	if (_initDisplay()) return;

	//_initSharedContext();
	if( _sharedContext ) sharedcontext=_sharedContext->glContext;
	
	vizinfo=_chooseVisual(context->flags);
	context->glContext=glXCreateContext(xdisplay,vizinfo,sharedcontext,True);	
	glXMakeCurrent(xdisplay,context->window,context->glContext);	
	bbSetSystemWindow(context->window);
}

void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,BBInt64 *flags ){
	_validateSize( context );
	*width=context->width;
	*height=context->height;
	*depth=context->depth;
	*hertz=bbGLGraphicsIsBorderless(context)?0:context->hertz;
	*flags=context->flags;
}

static Bool WaitForNotify(Display *display,XEvent *event,XPointer arg){
	return (event->type==MapNotify) && (event->xmap.window==(Window)arg);
}

void bbGLGraphicsShareContexts(){
	if( _sharedContext ) return;
	_sharedContext=bbGLGraphicsCreateGraphics(0,0,0,0,0,0,0);
}

BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hz,BBInt64 flags, int x, int y ){
	XSetWindowAttributes swa;
	XVisualInfo *vizinfo;
	XEvent event;
	GLXContext context;
	int window;
	int count,i;
	int displaymode;
	int initingShared=0;
	GLXContext sharedcontext=0;
	char *appTitle;

	if (_initDisplay()) return 0;
	
	if( width==0 && height==0 )
	{
		width=100;
		height=100;
		initingShared=1;
	}
	else
	{
		if( _sharedContext ) sharedcontext=_sharedContext->glContext;
		
		//_initSharedContext();
		//sharedcontext=_sharedContext->glContext;
	}

	vizinfo=_chooseVisual(flags);

	int border = (flags & FLAGS_BORDERLESS) ? 0 : CWBorderPixel;

	if (depth)
	{
		XF86VidModeGetModeLine(xdisplay,xscreen,&_oldMode.dotclock,(XF86VidModeModeLine*)&_oldMode.hdisplay );

		XF86VidModeGetAllModeLines(xdisplay,xscreen,&count,&modes);
		mode=0;
		for (i=0;i<count;i++)
		{
			if (width==modes[i]->hdisplay && height==modes[i]->vdisplay && hz==_calchertz(modes[i]))
			{
				mode=modes[i];
				break;
			}
		}	
		if (mode==0)
		{
			for (i=0;i<count;i++)
			{
				if (width==modes[i]->hdisplay && height==modes[i]->vdisplay)
				{
					mode=modes[i];
					break;
				}
			}	
		}
		if (mode==0) return 0;
		width=mode->hdisplay;
		height=mode->vdisplay;
		vizinfo=_chooseVisual(flags);
		
		swa.border_pixel=0;
		swa.event_mask=StructureNotifyMask;
		swa.colormap=XCreateColormap(xdisplay,RootWindow(xdisplay,0),vizinfo->visual,AllocNone);
		swa.override_redirect=True;	

		XF86VidModeSwitchToMode(xdisplay,xscreen,mode);
		XF86VidModeSetViewPort(xdisplay,xscreen,0,0);

		window=XCreateWindow(
			xdisplay,
			RootWindow(xdisplay,xscreen),
			0,
			0,
			width,height,
			0,
			vizinfo->depth,
			InputOutput,
			vizinfo->visual,
			border|CWEventMask|CWColormap|CWOverrideRedirect,
			&swa
		);

		xfullscreen=1;
		displaymode=MODE_DISPLAY;
	}
	else
	{		
		Atom atom;
		XSizeHints *hints;
		
		if (x < 0) x = 0 ;
		if (y < 0) y = 0 ;	
		
		swa.border_pixel=0;
		swa.event_mask=StructureNotifyMask;
		swa.colormap=XCreateColormap( xdisplay,RootWindow(xdisplay,0),vizinfo->visual,AllocNone );

		window=XCreateWindow(
			xdisplay,
			RootWindow(xdisplay,xscreen),
			x,
			y,  
			width,height,
			0,
			vizinfo->depth,
			InputOutput,
			vizinfo->visual,
			border|CWColormap|CWEventMask,
			&swa
		);

		//Tell window to send us 'close window events'		
		atom=XInternAtom( xdisplay,"WM_DELETE_WINDOW",True );
		XSetWMProtocols( xdisplay,window,&atom,1 );

		//Set window min/max size		
		hints=XAllocSizeHints();
		hints->flags=PMinSize|PMaxSize|PPosition;
		hints->x = x;
		hints->y = y;
		hints->min_width=hints->max_width=width;
		hints->min_height=hints->max_height=height;
		XSetWMNormalHints( xdisplay,window,hints );
		
		displaymode=MODE_WINDOW;
	}
	
	context=glXCreateContext(xdisplay,vizinfo,sharedcontext,True);
		
	if( !initingShared )
	{	
		XMapRaised(xdisplay,window);	
		if (xfullscreen)
		{
			XWarpPointer(xdisplay,None,window,0,0,0,0,0,0);
			XGrabKeyboard(xdisplay,window,True,GrabModeAsync,GrabModeAsync,CurrentTime);
			XGrabPointer(xdisplay,window,True,ButtonPressMask,GrabModeAsync,GrabModeAsync,window,None,CurrentTime);
		}
		glXMakeCurrent(xdisplay,window,context);	
		XIfEvent(xdisplay,&event,WaitForNotify,(XPointer)window);	     
		XSelectInput(xdisplay,window,StructureNotifyMask|FocusChangeMask|PointerMotionMask|ButtonPressMask|ButtonReleaseMask|KeyPressMask|KeyReleaseMask);
		xwindow=window;
		bbSetSystemWindow(xwindow);
	}

	appTitle=bbStringToUTF8String( bbAppTitle );
	
	XChangeProperty( xdisplay,window, XInternAtom( xdisplay,"_NET_WM_NAME",True ),
		XInternAtom( xdisplay,"UTF8_STRING",True ), 8,PropModeReplace,appTitle,strlen( appTitle ) );

	bbMemFree(appTitle);
//	XStoreName( xdisplay,window,appTitle );
	
	bbSystemPoll();

	BBGLContext *bbcontext=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( bbcontext,0,sizeof(BBGLContext) );
	bbcontext->mode=displaymode;	
	bbcontext->width=width;	
	bbcontext->height=height;	
	bbcontext->depth=depth?24:0;
	bbcontext->hertz=hz;
	bbcontext->flags=flags;
	bbcontext->sync=-1;	
	bbcontext->window=window;
	bbcontext->glContext=context;
	return bbcontext;
}

void bbGLGraphicsSetGraphics( BBGLContext *context ){
	if( context ){
		_validateSize( context );
		_validateContext( context );
	}
	if( !context || context==_currentContext ) return;
	_makeCurrent(context);
	_activeContext=context;
}

void bbGLGraphicsFlip( int sync ){
	if( !_currentContext ) return;
	sync=sync ? 1 : 0;
	if( sync!=_currentContext->sync ){
		_currentContext->sync=sync;
		if ( glXSwapIntervalEXT ) {
			 glXSwapIntervalEXT( sync );
		}
	}
	_swapBuffers( _currentContext );
}

/* EWMH fullscreen is desktop borderless, not an exclusive display-mode change. */
static int _hasAtom(Window window,const char *property,Atom wanted){
 Atom type;int format,found=0;unsigned long count,remaining;unsigned char *data=0;
 if(XGetWindowProperty(xdisplay,window,XInternAtom(xdisplay,property,False),0,1024,
   False,XA_ATOM,&type,&format,&count,&remaining,&data)==Success && type==XA_ATOM && format==32){
  unsigned long i;for(i=0;i<count;i++)if(((Atom*)data)[i]==wanted){found=1;break;}
 }
 if(data)XFree(data);
 return found;
}
int bbGLGraphicsSupportsBorderless(BBGLContext *context){
 int major=1,minor=5;
 if(!context || context->mode!=MODE_WINDOW || _initDisplay())return 0;
 if(!XRRQueryVersion(xdisplay,&major,&minor) || major<1 || (major==1 && minor<5))return 0;
 return _hasAtom(RootWindow(xdisplay,xscreen),"_NET_SUPPORTED",XInternAtom(xdisplay,"_NET_WM_STATE_FULLSCREEN",False));
}
int bbGLGraphicsIsBorderless(BBGLContext *context){
 if(!context || context->mode!=MODE_WINDOW || _initDisplay())return 0;
 return _hasAtom(context->window,"_NET_WM_STATE",XInternAtom(xdisplay,"_NET_WM_STATE_FULLSCREEN",False));
}
static int _requestBorderless(BBGLContext *context,int enabled){
 XEvent event;memset(&event,0,sizeof(event));
 event.xclient.type=ClientMessage;
 event.xclient.window=context->window;
 event.xclient.message_type=XInternAtom(xdisplay,"_NET_WM_STATE",False);
 event.xclient.format=32;
 event.xclient.data.l[0]=enabled?1:0;
 event.xclient.data.l[1]=XInternAtom(xdisplay,"_NET_WM_STATE_FULLSCREEN",False);
 event.xclient.data.l[3]=1; /* Normal application, not a pager. */
 int ok=XSendEvent(xdisplay,RootWindow(xdisplay,xscreen),False,
  SubstructureRedirectMask|SubstructureNotifyMask,&event);
 XFlush(xdisplay);return ok;
}
static int _monitorBounds(BBGLContext *context,int *x,int *y,int *width,int *height){
 int count=0,major=1,minor=5,wx,wy;long long best=0;
 if(!XRRQueryVersion(xdisplay,&major,&minor) || major<1 || (major==1 && minor<5))return 0;
 XRRMonitorInfo *monitors=XRRGetMonitors(xdisplay,RootWindow(xdisplay,xscreen),True,&count);
 bbGLGraphicsGetPosition(context,&wx,&wy);
 for(int i=0;i<count;i++){
  XRRMonitorInfo *m=&monitors[i];
  int left=wx>m->x?wx:m->x,top=wy>m->y?wy:m->y;
  int right=wx+context->width<m->x+m->width?wx+context->width:m->x+m->width;
  int bottom=wy+context->height<m->y+m->height?wy+context->height:m->y+m->height;
  long long area=right>left && bottom>top?(long long)(right-left)*(bottom-top):0;
  if(area>best){best=area;*x=m->x;*y=m->y;*width=m->width;*height=m->height;}
 }
 if(monitors)XRRFreeMonitors(monitors);
 return best>0;
}
static int _waitBorderless(BBGLContext *context,int enabled,int x,int y,int width,int height){
 struct timespec start,now,pause={0,5000000};clock_gettime(CLOCK_MONOTONIC,&start);
 for(;;){
  int wx,wy;
  _validateSize(context);bbGLGraphicsGetPosition(context,&wx,&wy);
  if(bbGLGraphicsIsBorderless(context)==enabled && wx==x && wy==y &&
    context->width==width && context->height==height)return 1;
  clock_gettime(CLOCK_MONOTONIC,&now);
  if((now.tv_sec-start.tv_sec)*1000000000LL+now.tv_nsec-start.tv_nsec>=2000000000LL)return 0;
  nanosleep(&pause,0);
 }
}
int bbGLGraphicsSetBorderless(BBGLContext *context,int enabled){
 int x,y,width,height;
 if(!context || context->mode!=MODE_WINDOW || _initDisplay())return 0;
 enabled=enabled!=0;
 if(!enabled && !context->savedWindow && !bbGLGraphicsIsBorderless(context))return 1;
 if(enabled && context->savedWindow && bbGLGraphicsIsBorderless(context))return 1;
 if(!bbGLGraphicsSupportsBorderless(context))return 0;
 if(enabled){
  _validateSize(context);
  if(!_monitorBounds(context,&x,&y,&width,&height))return 0;
  if(!context->savedWindow){
   bbGLGraphicsGetPosition(context,&context->savedX,&context->savedY);
   context->savedWidth=context->width;context->savedHeight=context->height;
   long supplied;
   memset(&context->savedHints,0,sizeof(context->savedHints));
   XGetWMNormalHints(xdisplay,context->window,&context->savedHints,&supplied);
   context->savedWindow=1;
  }
  XSizeHints hints=context->savedHints;
  hints.flags&=~(PMinSize|PMaxSize|PAspect|PResizeInc|PBaseSize);
  XSetWMNormalHints(xdisplay,context->window,&hints);
  if(_requestBorderless(context,1) && _waitBorderless(context,1,x,y,width,height))return 1;
  /* A refused/delayed entry must not strand the caller in fullscreen. */
  XSetWMNormalHints(xdisplay,context->window,&context->savedHints);
  _requestBorderless(context,0);
  if(_waitBorderless(context,0,context->savedX,context->savedY,context->savedWidth,context->savedHeight))context->savedWindow=0;
  return 0;
 }
 if(!context->savedWindow)return 0;
 XSetWMNormalHints(xdisplay,context->window,&context->savedHints);
 if(!_requestBorderless(context,0))return 0;
 if(!_waitBorderless(context,0,context->savedX,context->savedY,context->savedWidth,context->savedHeight))return 0;
 context->savedWindow=0;return 1;
}
int bbGLGraphicsSupportsFullscreen(BBGLContext *context){return 0;}
int bbGLGraphicsSetFullscreen(BBGLContext *context,int enabled,int width,int height,int hertz){
 return enabled?0:bbGLGraphicsSetBorderless(context,0);
}
int bbGLGraphicsFullscreenModes(BBGLContext *context,int *buf,int count){return 0;}
void bbGLGraphicsClientSize(BBGLContext *context,int *width,int *height){
 _validateSize(context);*width=context?context->width:0;*height=context?context->height:0;
}

void bbGLGraphicsGetPosition(BBGLContext *context,int *x,int *y){
 Window child;*x=*y=-1;
 if(!context || _initDisplay())return;
 XTranslateCoordinates(xdisplay,context->window,RootWindow(xdisplay,xscreen),0,0,x,y,&child);
}
/* The WM processes configure requests on another connection. XSync alone
   cannot acknowledge that work. Query real geometry with a bounded wait and
   leave queued input/configure events for BRL.System's normal dispatch. */
static int _waitGeometry(BBGLContext *context,int width,int height,int x,int y,int position){
 struct timespec start,now,pause={0,5000000};
 clock_gettime(CLOCK_MONOTONIC,&start);
 for(;;){
  int actualX,actualY;
  _validateSize(context);
  if(position){
   bbGLGraphicsGetPosition(context,&actualX,&actualY);
   if(actualX==x && actualY==y)return 1;
  }else if(context->width==width && context->height==height)return 1;
  clock_gettime(CLOCK_MONOTONIC,&now);
  if((now.tv_sec-start.tv_sec)*1000000000LL+now.tv_nsec-start.tv_nsec>=1000000000LL)return 0;
  nanosleep(&pause,0);
 }
}
int bbGLGraphicsResize(BBGLContext *context,int width,int height){
 XSizeHints hints;long supplied;
 if(!context || context->mode!=MODE_WINDOW || context->savedWindow || bbGLGraphicsIsBorderless(context) || width<=0 || height<=0 || _initDisplay())return 0;
 memset(&hints,0,sizeof(hints));
 XGetWMNormalHints(xdisplay,context->window,&hints,&supplied);
 hints.flags|=PMinSize|PMaxSize;
 hints.min_width=hints.max_width=width;hints.min_height=hints.max_height=height;
 XSetWMNormalHints(xdisplay,context->window,&hints);
 XResizeWindow(xdisplay,context->window,width,height);
 XFlush(xdisplay);
 return _waitGeometry(context,width,height,0,0,0);
}
int bbGLGraphicsPosition(BBGLContext *context,int x,int y){
 XSizeHints hints;long supplied;
 if(!context || context->mode!=MODE_WINDOW || context->savedWindow || bbGLGraphicsIsBorderless(context) || _initDisplay())return 0;
 memset(&hints,0,sizeof(hints));
 XGetWMNormalHints(xdisplay,context->window,&hints,&supplied);
 hints.flags|=PPosition|PWinGravity;hints.x=x;hints.y=y;hints.win_gravity=StaticGravity;
 XSetWMNormalHints(xdisplay,context->window,&hints);
 XMoveWindow(xdisplay,context->window,x,y);
 XFlush(xdisplay);
 return _waitGeometry(context,0,0,x,y,1);
}

void bbGLGraphicsClose( BBGLContext *context ){
	if (context){
		if (_currentContext==context) _currentContext=0;
		if (context->glContext) 
		{
			glXMakeCurrent(xdisplay,None,NULL);
			glXDestroyContext(xdisplay,context->glContext);	
		}
		if (context->window && context->mode!=MODE_WIDGET){
			XDestroyWindow(xdisplay,context->window);
		}
		if (context->mode==MODE_DISPLAY){
			XF86VidModeSwitchToMode(xdisplay,xscreen,&_oldMode);
			XF86VidModeSetViewPort(xdisplay,xscreen,0,0);
			XFlush(xdisplay);
			XFree(modes);
			modes=0;
			mode=0;
			xfullscreen=0;
		}
		free( context );
	}
}

void bbGLExit(){
	bbGLGraphicsClose( _currentContext );
	bbGLGraphicsClose( _sharedContext );
	_currentContext=0;
	_sharedContext=0;
}
