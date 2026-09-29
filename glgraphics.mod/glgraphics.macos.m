
#include <AppKit/AppKit.h>
#include <Carbon/Carbon.h>
#include <OpenGL/gl.h>
#include <OpenGL/OpenGL.h>

#include <brl.mod/systemdefault.mod/system.h>

enum{
	FLAGS_BACKBUFFER=	0x2,
	FLAGS_ALPHABUFFER=	0x4,
	FLAGS_DEPTHBUFFER=	0x8,
	FLAGS_STENCILBUFFER=0x10,
	FLAGS_ACCUMBUFFER=	0x20,
	FLAGS_BORDERLESS=	0x40,
	FLAGS_FULLSCREEN_DESKTOP=	0x80,
	FLAGS_FULLSCREEN=	0x80000000
};

enum{
	MODE_WIDGET=		1,
	MODE_WINDOW=		2,
	MODE_DISPLAY=		3
};

/* Presentation options belong to the application, so only the key borderless
   window owns them. Restore the previous options on focus loss or close. */
static int runtimeFocus(void *opaque,int active);
static NSWindow *borderlessPresentationOwner;
static NSApplicationPresentationOptions savedPresentationOptions;
static void releaseBorderlessPresentation(NSWindow *window){
	if(borderlessPresentationOwner==window){
		[NSApp setPresentationOptions:savedPresentationOptions];
		borderlessPresentationOwner=nil;
	}
}
@interface BBGLWindow : NSWindow{
@public
	BOOL borderlessDesktop;
	void *runtimeContext;
}
@end
@implementation BBGLWindow
-(void)windowDidBecomeKey:(NSNotification*)notification{
	runtimeFocus(runtimeContext,1);
	if(borderlessDesktop && borderlessPresentationOwner!=self){
		if(borderlessPresentationOwner)releaseBorderlessPresentation(borderlessPresentationOwner);
		savedPresentationOptions=[NSApp presentationOptions];
		borderlessPresentationOwner=self;
		[NSApp setPresentationOptions:NSApplicationPresentationAutoHideDock|NSApplicationPresentationAutoHideMenuBar];
	}
}
-(void)windowDidResignKey:(NSNotification*)notification{
	runtimeFocus(runtimeContext,0);
	releaseBorderlessPresentation(self);
}
-(void)sendEvent:(NSEvent*)event{
	bbSystemEmitOSEvent( event,[self contentView],&bbNullObject );
	switch( [event type] ){
	case NSKeyDown:case NSKeyUp:
		//prevent 'beeps'!
		return;
	}
	[super sendEvent:event];
}
-(BOOL)windowShouldClose:(id)sender{
	bbSystemEmitEvent( BBEVENT_APPTERMINATE,&bbNullObject,0,0,0,0,&bbNullObject );
	return NO;
}
- (BOOL)canBecomeKeyWindow{
	return YES;
}
@end

typedef struct BBGLContext BBGLContext;

struct BBGLContext{
	int mode,width,height,depth,hertz;
	int borderless;
	int exclusive,exclusiveActive,transition,savedHertz;
	CGDirectDisplayID exclusiveDisplay;
	CGDisplayModeRef desktopMode,exclusiveMode;
	NSInteger savedWindowLevel;
	NSRect savedWindowFrame;
	NSUInteger savedWindowStyle;
	BBInt64 flags;
	int sync;

	NSView *view;
	BBGLWindow *window;
	NSOpenGLContext *glContext;
};

static BBGLContext *_exclusiveOwner;
int bbGLGraphicsSetFullscreen(BBGLContext *context,int enabled,int width,int height,int hertz);
static BBGLContext *_currentContext;
static BBGLContext *_displayContext;

static CFDictionaryRef oldDisplayMode;

extern void bbFlushAutoreleasePool();

void bbGLGraphicsClose( BBGLContext *context );
void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz,BBInt64 *flags );
void bbGLGraphicsSetGraphics( BBGLContext *context );

static int _initAttrs( CGLPixelFormatAttribute attrs[16],BBInt64 flags ){
	int n=0;
	if( flags & FLAGS_BACKBUFFER ) attrs[n++]=kCGLPFADoubleBuffer;
	if( flags & FLAGS_ALPHABUFFER ){ attrs[n++]=kCGLPFAAlphaSize;attrs[n++]=1; }
	if( flags & FLAGS_DEPTHBUFFER ){ attrs[n++]=kCGLPFADepthSize;attrs[n++]=24; }
	if( flags & FLAGS_STENCILBUFFER ){ attrs[n++]=kCGLPFAStencilSize;attrs[n++]=1; }
	if( flags & FLAGS_ACCUMBUFFER ){ attrs[n++]=kCGLPFAAccumSize;attrs[n++]=1; }
	if( flags & FLAGS_FULLSCREEN ){
		attrs[n++]=kCGLPFAFullScreen;
		attrs[n++]=kCGLPFADisplayMask;
		attrs[n++]=CGDisplayIDToOpenGLDisplayMask( kCGDirectMainDisplay );
	}else{
		attrs[n++]=kCGLPFANoRecovery;
	}
	attrs[n]=0;
	return n;
}

static NSOpenGLContext *_sharedContext;

static void _validateSize( BBGLContext *context ){
	NSRect rect;
	
	if(context && context->exclusive)return;
	if( !context || (context->mode!=MODE_WIDGET && context->mode!=MODE_WINDOW) ) return;
	
	rect=[(context->mode==MODE_WIDGET ? context->view : [context->window contentView]) bounds];
	if( rect.size.width==context->width && rect.size.height==context->height ) return;
	
	context->width=rect.size.width;
	context->height=rect.size.height;

	if( context->glContext ) [context->glContext update];
}

static void _validateContext( BBGLContext *context ){
	BBInt64 flags;
	NSOpenGLContext *shared;
	NSOpenGLContext *glContext;
	NSOpenGLPixelFormat *glFormat;
	CGLPixelFormatAttribute attrs[16];
	
	if( !context || context->glContext ) return;

	flags=context->flags;
	
//	if( context->mode==MODE_DISPLAY ) flags|=FLAGS_FULLSCREEN;

	_initAttrs( attrs,flags );

	glFormat=[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	glContext=[[NSOpenGLContext alloc] initWithFormat:glFormat shareContext:_sharedContext];
	[glFormat release];

	if( !glContext ) bbExThrowCString( "Unable to create GL Context" );
	
	switch( context->mode ){
	case MODE_WIDGET:
		[glContext setView:context->view];
		break;
	case MODE_WINDOW:
	case MODE_DISPLAY:
		[glContext setView:[context->window contentView]];
		break;
	}

	context->glContext=glContext;
}

void bbGLGraphicsShareContexts(){
	NSOpenGLPixelFormat *glFormat;
	CGLPixelFormatAttribute attrs[16];
	
	if( _sharedContext ) return;

	_initAttrs( attrs,0 );
	glFormat=[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	_sharedContext=[[NSOpenGLContext alloc] initWithFormat:glFormat shareContext:0];
	[glFormat release];
}

int bbGLGraphicsGraphicsModes( int *modes,int count ){
	int i=0,n=0,sz;
	CFArrayRef displayModeArray;

	displayModeArray = CGDisplayCopyAllDisplayModes(kCGDirectMainDisplay, NULL);
	sz=CFArrayGetCount( displayModeArray );
	
	while( i<sz && n<count ){

		CGDisplayModeRef displayMode;
		int width,height,depth,hertz;
		CFStringRef format;

		displayMode=(CGDisplayModeRef)CFArrayGetValueAtIndex( displayModeArray,i++ );
		format = CGDisplayModeCopyPixelEncoding(displayMode);
		width = CGDisplayModeGetWidth(displayMode);
		height = CGDisplayModeGetHeight(displayMode);
		hertz = (CGDisplayModeGetRefreshRate(displayMode) + 0.5);

		if (CFStringCompare(format, CFSTR(IO32BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
			depth = 32;
		} else if (CFStringCompare(format, CFSTR(IO16BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
			depth = 16;
		} else if (CFStringCompare(format, CFSTR(kIO30BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
			depth = 30;
		} else if (CFStringCompare(format, CFSTR(IO8BitIndexedPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
			depth = 8;
		} else {
			depth = 0;
		}
		
		CFRelease(format);
		
		if (hertz == 0) {
		
			CVDisplayLinkRef link = NULL;
			CVDisplayLinkCreateWithCGDisplay(kCGDirectMainDisplay, &link);
			
			if (link != NULL) {
				CVTime time = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(link);
				if ((time.flags & kCVTimeIsIndefinite) == 0 && time.timeValue != 0) {
					hertz = (long) ((time.timeScale / (double) time.timeValue) + 0.5);
				}
			}
		}
		
		*modes++=width;
		*modes++=height;
		*modes++=depth;
		*modes++=hertz;
		++n;
	}
	
	return n;
}

BBGLContext *bbGLGraphicsAttachGraphics( NSView *view,BBInt64 flags ){
	NSRect rect;
	BBGLContext *context;

	rect=[view bounds];
	
	context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(BBGLContext) );

	context->mode=MODE_WIDGET;	
	context->width=rect.size.width;
	context->height=rect.size.height;
	context->flags=flags;
	context->sync=-1;
	
	context->view=view;
	
	return context;
}

BBGLContext *bbGLGraphicsCreateGraphics( int width,int height,int depth,int hertz,BBInt64 flags, int x, int y ){
	if(depth && _exclusiveOwner)bbExThrowCString("GLGraphics: leave runtime exclusive fullscreen before creating legacy exclusive graphics");
	int mode;
	BBGLWindow *window=0;
	BBGLContext *context;
	int sysv=0;
	
	Gestalt( 'sysv',&sysv );

	if( depth ){
	
		CFDictionaryRef displayMode;
		CGCaptureAllDisplays();
		
		oldDisplayMode=CGDisplayCurrentMode( kCGDirectMainDisplay );
		CFRetain( (CFTypeRef)oldDisplayMode );

		if( !hertz ){
			displayMode=CGDisplayBestModeForParameters( kCGDirectMainDisplay,depth,width,height,0 );
		}else{
			displayMode=CGDisplayBestModeForParametersAndRefreshRate( kCGDirectMainDisplay,depth,width,height,hertz,0 );
		}
		if( CGDisplaySwitchToMode( kCGDirectMainDisplay,displayMode ) ){
			CFRelease( (CFTypeRef)oldDisplayMode );
			bbExThrowCString( "Unable to set display mode" );
		}
		#if MAC_OS_X_VERSION_MAX_ALLOWED < 101500
		HideMenuBar();
		#endif

		window=[[NSWindow alloc]
			initWithContentRect:NSMakeRect( 0,0,width,height )
			styleMask:NSBorderlessWindowMask
			backing:NSBackingStoreBuffered
			willUseFullScreenPresentationOptions:NSApplicationPresentationAutoHideToolbar | NSApplicationPresentationAutoHideMenuBar | NSApplicationPresentationFullScreen
			defer:YES];
		
		[window setOpaque:YES];
		[window setBackgroundColor:[NSColor blackColor]];
		[window setLevel:CGShieldingWindowLevel()];

		[window makeKeyAndOrderFront:NSApp];
		
		mode=MODE_DISPLAY;
		
	}else{
		if (x < 0) x = 0;
		if (y < 0) y = 0;

		NSWindowStyleMask mask = (flags & FLAGS_BORDERLESS) ? 0 : NSTitledWindowMask|NSClosableWindowMask;
		if (flags & FLAGS_FULLSCREEN_DESKTOP) mask |= NSWindowStyleMaskFullScreen;
		
		window=[[BBGLWindow alloc]
			initWithContentRect:NSMakeRect( x, y,width,height )
			styleMask:mask
			backing:NSBackingStoreBuffered
			defer:YES];

		if( !window ) return 0;
		
		[window setDelegate:window];
		[window setAcceptsMouseMovedEvents:YES];

		char *p=bbStringToUTF8String(bbAppTitle);

		[window setTitle:[NSString stringWithUTF8String:p]];
		[window center];

		bbMemFree(p);

		[window makeKeyAndOrderFront:NSApp];
		
		mode=MODE_WINDOW;
	}
	
	context=(BBGLContext*)malloc( sizeof(BBGLContext) );
	memset( context,0,sizeof(BBGLContext) );
	
	context->mode=mode;
	context->width=width;
	context->height=height;
	context->depth=depth;
	context->hertz=hertz;
	context->flags=flags;
	context->sync=-1;
	context->window=window;
	if(mode==MODE_WINDOW)window->runtimeContext=context;
	
	if( mode==MODE_DISPLAY ) _displayContext=context;
	
	return context;
}

void bbGLGraphicsGetSettings( BBGLContext *context,int *width,int *height,int *depth,int *hertz, BBInt64 *flags ){
	_validateSize( context );
	*width=context->width;
	*height=context->height;
	*depth=context->depth;
	*hertz=context->borderless && !context->exclusive ? 0 : context->hertz;
	*flags=context->flags;
}

/* Positions are client-area top-left coordinates, relative to the primary
   desktop's top-left. Window sizes retain Cocoa points, not backing pixels. */
int bbGLGraphicsSupportsBorderless(BBGLContext *context){
	return context && context->mode==MODE_WINDOW;
}
int bbGLGraphicsIsBorderless(BBGLContext *context){
	return context && context->borderless && !context->exclusive;
}
int bbGLGraphicsSetBorderless(BBGLContext *context,int enabled){
	if(!bbGLGraphicsSupportsBorderless(context))return 0;
	if(context->exclusive && !bbGLGraphicsSetFullscreen(context,0,0,0,0))return 0;
	enabled=!!enabled;
	if(context->borderless==enabled)return 1;
	BBGLWindow *window=context->window;
	if(enabled){
		NSScreen *screen=[window screen];
		if(!screen)return 0;
		context->savedWindowFrame=[window frame];
		context->savedWindowStyle=[window styleMask];
		[window setStyleMask:NSWindowStyleMaskBorderless];
		[window setFrame:[screen frame] display:YES];
	}else{
		window->borderlessDesktop=NO;
		releaseBorderlessPresentation(window);
		[window setStyleMask:context->savedWindowStyle];
		[window setFrame:context->savedWindowFrame display:YES];
	}
	context->borderless=enabled;
	window->borderlessDesktop=enabled;
	if(enabled && [window isKeyWindow])[window windowDidBecomeKey:nil];
	_validateSize(context);
	[context->glContext update];
	return 1;
}
void bbGLGraphicsClientSize(BBGLContext *context,int *width,int *height){
 *width=*height=0;if(!context)return;
 NSView *view=context->mode==MODE_WIDGET?context->view:[context->window contentView];
 NSRect bounds=[view bounds];*width=bounds.size.width;*height=bounds.size.height;
}
int bbGLGraphicsSupportsFullscreen(BBGLContext *context){return context && context->mode==MODE_WINDOW;}
static CGDirectDisplayID runtimeDisplay(BBGLContext *context){
 if(context->exclusive)return context->exclusiveDisplay;
 NSScreen *screen=[context->window screen];
 return screen?[[[screen deviceDescription] objectForKey:@"NSScreenNumber"] unsignedIntValue]:0;
}
int bbGLGraphicsFullscreenModes(BBGLContext *context,int *buf,int count){
 int n=0;if(!bbGLGraphicsSupportsFullscreen(context))return 0;
 CGDirectDisplayID display=runtimeDisplay(context);if(!display)return 0;
 CFArrayRef modes=CGDisplayCopyAllDisplayModes(display,NULL);if(!modes)return 0;
 for(CFIndex i=0;i<CFArrayGetCount(modes);++i){
  CGDisplayModeRef mode=(CGDisplayModeRef)CFArrayGetValueAtIndex(modes,i);
  if(!CGDisplayModeIsUsableForDesktopGUI(mode))continue;
  if(buf){if(n==count)break;buf[n*4]=CGDisplayModeGetPixelWidth(mode);buf[n*4+1]=CGDisplayModeGetPixelHeight(mode);buf[n*4+2]=32;buf[n*4+3]=(int)(CGDisplayModeGetRefreshRate(mode)+0.5);}
  ++n;
 }
 CFRelease(modes);return n;
}
static int runtimeFocus(void *opaque,int active){
 BBGLContext *context=(BBGLContext*)opaque;
 if(!context || !context->exclusive || context->transition || active==context->exclusiveActive)return 1;
 context->transition=1;
 if(active){
  if(CGDisplayCapture(context->exclusiveDisplay)!=kCGErrorSuccess){context->transition=0;return 0;}
  if(CGDisplaySetDisplayMode(context->exclusiveDisplay,context->exclusiveMode,NULL)!=kCGErrorSuccess){
   CGDisplayRelease(context->exclusiveDisplay);context->transition=0;return 0;
  }
  context->exclusiveActive=1;
  CGRect bounds=CGDisplayBounds(context->exclusiveDisplay),mainBounds=CGDisplayBounds(CGMainDisplayID());
  [context->window setLevel:CGShieldingWindowLevel()];
  [context->window makeKeyAndOrderFront:nil];
  [context->window setFrame:NSMakeRect(bounds.origin.x,mainBounds.size.height-bounds.origin.y-bounds.size.height,bounds.size.width,bounds.size.height) display:YES];
 }else{
  if(CGDisplaySetDisplayMode(context->exclusiveDisplay,context->desktopMode,NULL)!=kCGErrorSuccess){context->transition=0;return 0;}
  if(CGDisplayRelease(context->exclusiveDisplay)!=kCGErrorSuccess){context->transition=0;return 0;}
  context->exclusiveActive=0;
  [context->window setLevel:context->savedWindowLevel];
 }
 [context->glContext update];context->transition=0;return 1;
}
int bbGLGraphicsSetFullscreen(BBGLContext *context,int enabled,int width,int height,int hertz){
 if(!bbGLGraphicsSupportsFullscreen(context))return 0;
 if(!enabled){
  if(!context->exclusive)return bbGLGraphicsSetBorderless(context,0);
  if(!runtimeFocus(context,0))return 0;
  context->exclusive=0;_exclusiveOwner=NULL;context->depth=0;context->hertz=context->savedHertz;
  CFRelease(context->desktopMode);CFRelease(context->exclusiveMode);context->desktopMode=context->exclusiveMode=NULL;
  return bbGLGraphicsSetBorderless(context,0);
 }
 if(width<0 || height<0 || hertz<0 || _displayContext || (_exclusiveOwner && _exclusiveOwner!=context))return 0;
 if(![context->window isKeyWindow] || ![NSApp isActive])return 0;
 if(!width)width=context->width;if(!height)height=context->height;
 CGDirectDisplayID display=runtimeDisplay(context);if(!display)return 0;
 CFArrayRef modes=CGDisplayCopyAllDisplayModes(display,NULL);if(!modes)return 0;
 CGDisplayModeRef chosen=NULL;
 for(CFIndex i=0;i<CFArrayGetCount(modes);++i){
  CGDisplayModeRef mode=(CGDisplayModeRef)CFArrayGetValueAtIndex(modes,i);
  int rate=(int)(CGDisplayModeGetRefreshRate(mode)+0.5);
  if(!CGDisplayModeIsUsableForDesktopGUI(mode) || CGDisplayModeGetPixelWidth(mode)!=width || CGDisplayModeGetPixelHeight(mode)!=height || (hertz && rate!=hertz))continue;
  if(!chosen || CGDisplayModeGetRefreshRate(mode)>CGDisplayModeGetRefreshRate(chosen))chosen=mode;
 }
 if(chosen)CFRetain(chosen);CFRelease(modes);if(!chosen)return 0;
 if(context->exclusive && context->width==width && context->height==height && context->hertz==(int)(CGDisplayModeGetRefreshRate(chosen)+0.5)){CFRelease(chosen);return 1;}
 if(context->exclusive && !bbGLGraphicsSetFullscreen(context,0,0,0,0)){CFRelease(chosen);return 0;}
 if(context->borderless && !bbGLGraphicsSetBorderless(context,0)){CFRelease(chosen);return 0;}
 CGDisplayModeRef desktop=CGDisplayCopyDisplayMode(display);if(!desktop){CFRelease(chosen);return 0;}
 if(!bbGLGraphicsSetBorderless(context,1)){CFRelease(desktop);CFRelease(chosen);return 0;}
 context->desktopMode=desktop;context->exclusiveMode=chosen;context->exclusiveDisplay=display;
 context->savedWindowLevel=[context->window level];context->savedHertz=context->hertz;
 context->exclusive=1;context->exclusiveActive=0;_exclusiveOwner=context;
 context->width=width;context->height=height;context->depth=32;context->hertz=(int)(CGDisplayModeGetRefreshRate(chosen)+0.5);
 if(!runtimeFocus(context,1)){bbGLGraphicsSetFullscreen(context,0,0,0,0);return 0;}
 return 1;
}
void bbGLGraphicsGetPosition(BBGLContext *context,int *x,int *y){
 *x=*y=-1;
 if(!context)return;
 NSView *view=context->mode==MODE_WIDGET?context->view:[context->window contentView];
 NSWindow *window=[view window];
 if(!window)return;
 NSRect r=[window convertRectToScreen:[view convertRect:[view bounds] toView:nil]];
 *x=(int)NSMinX(r);*y=(int)(NSMaxY([[[NSScreen screens] objectAtIndex:0] frame])-NSMaxY(r));
}
int bbGLGraphicsResize(BBGLContext *context,int width,int height){
 if(!context || context->mode!=MODE_WINDOW || context->borderless || width<=0 || height<=0)return 0;
 NSRect frame=[context->window frame];
 [context->window setContentSize:NSMakeSize(width,height)];
 /* Keep the outer top-left fixed, matching Win32/X11 resizing. */
 NSRect resized=[context->window frame];
 [context->window setFrameOrigin:NSMakePoint(NSMinX(frame),NSMaxY(frame)-NSHeight(resized))];
 _validateSize(context);
 [context->glContext update];
 return 1;
}
int bbGLGraphicsPosition(BBGLContext *context,int x,int y){
 if(!context || context->mode!=MODE_WINDOW || context->borderless)return 0;
 NSRect frame=[context->window frame];
 NSRect client=[context->window contentRectForFrameRect:frame];
 CGFloat top=NSMaxY([[[NSScreen screens] objectAtIndex:0] frame]);
 [context->window setFrameOrigin:NSMakePoint(frame.origin.x+x-client.origin.x,frame.origin.y+top-y-NSMaxY(client))];
 [context->glContext update];
 return 1;
}

void bbGLGraphicsClose( BBGLContext *context ){
	if(context && context->exclusive && !bbGLGraphicsSetFullscreen(context,0,0,0,0))bbExThrowCString("GLGraphics: unable to restore exclusive display");
	if(context && context->mode==MODE_WINDOW)context->window->runtimeContext=NULL;
	if(context && context->window)releaseBorderlessPresentation(context->window);
	if( context==_currentContext ) bbGLGraphicsSetGraphics( 0 );

	[context->glContext clearDrawable];
	[context->glContext release];
	
	switch( context->mode ){
	case MODE_WINDOW:
	case MODE_DISPLAY:
		bbSystemViewClosed( [context->window contentView] );
		[context->window close];
		break;
	}
	if( context==_displayContext ){
		CGDisplaySwitchToMode( kCGDirectMainDisplay,oldDisplayMode );
		CFRelease( (CFTypeRef)oldDisplayMode );
		CGReleaseAllDisplays();
		CGDisplayShowCursor( kCGDirectMainDisplay );
		#if MAC_OS_X_VERSION_MAX_ALLOWED < 101500
		ShowMenuBar();
		#endif
		_displayContext=0;
	}

	free( context );
}

void bbGLGraphicsSetGraphics( BBGLContext *context ){
	if(context && context->exclusive && !context->exclusiveActive && [context->window isKeyWindow] && [NSApp isActive]){
		if(!runtimeFocus(context,1))bbExThrowCString("GLGraphics: unable to resume exclusive display");
	}
	if( context ){
		_validateSize( context );
		_validateContext( context );
		[context->glContext makeCurrentContext];
	}else{
		[NSOpenGLContext clearCurrentContext];
	}
	_currentContext=context;
}

static int updated;

void bbGLGraphicsFlip( int sync ){
	if( !_currentContext ) return;
	
	sync=sync ? 1 : 0;
	
	static int _sync=-1;
	
	if( sync!=_currentContext->sync ){
		_currentContext->sync=sync;
		[_currentContext->glContext setValues:(long*)&sync forParameter:kCGLCPSwapInterval];
	}
	
	[_currentContext->glContext flushBuffer];

	// update the context, at least once - mojave needs this or nothing is rendered.
	if (!updated) {
		updated = 1;
		[_currentContext->glContext update];
	}
}

#include "context_request.h"

/* NSOpenGL offers legacy, 3.2 core and 4.1 core profiles, not arbitrary versions. */
static int configureRequestedContext(BBGLContext *context,int major,int minor,int profile,BBGLContext *share){
	CGLPixelFormatAttribute attrs[24];
	NSOpenGLPixelFormat *format;
	NSOpenGLContext *modern;
	int n;
	if(major>4 || (major==4 && minor>1) || (major==3 && (minor==0 || minor>3)))return 0;
	if(major>=3 && profile==2)return 0;
	/* Validate a lazy sharing context before constructing the new context. */
	if(share)_validateContext(share);
	n=_initAttrs(attrs,context->flags);
	if(major>=3){
		attrs[n++]=kCGLPFAOpenGLProfile;
		attrs[n++]=(major>3 || (major==3 && minor>=3))?kCGLOGLPVersion_GL4_Core:kCGLOGLPVersion_3_2_Core;
		attrs[n]=0;
	}
	format=[[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	if(!format)return 0;
	modern=[[NSOpenGLContext alloc] initWithFormat:format shareContext:share?share->glContext:nil];
	[format release];
	if(!modern)return 0;
	if(context->mode==MODE_WIDGET)[modern setView:context->view];
	else if(context->mode==MODE_WINDOW)[modern setView:[context->window contentView]];
	else{
#if MAC_OS_X_VERSION_MAX_ALLOWED < 101500
		[modern setFullScreen];
#else
		[modern setView:[context->window contentView]];
#endif
	}
	[modern makeCurrentContext];
	if(!bbGLContextMatches(major,minor,profile)){
		[NSOpenGLContext clearCurrentContext];
		[modern clearDrawable];
		[modern release];
		return 0;
	}
	[context->glContext clearDrawable];
	[context->glContext release];
	context->glContext=modern;
	return 1;
}

BBGLContext *bbGLGraphicsCreateGraphicsEx(int width,int height,int depth,int hertz,BBInt64 flags,int x,int y,int major,int minor,int profile,BBGLContext *share){
	NSOpenGLContext *previous=[[NSOpenGLContext currentContext] retain];
	BBGLContext *context=bbGLGraphicsCreateGraphics(width,height,depth,hertz,flags,x,y);
	if(context && !configureRequestedContext(context,major,minor,profile,share)){
		bbGLGraphicsClose(context);
		context=NULL;
	}
	if(previous)[previous makeCurrentContext];
	else [NSOpenGLContext clearCurrentContext];
	[previous release];
	return context;
}

BBGLContext *bbGLGraphicsAttachGraphicsEx(NSView *widget,BBInt64 flags,int major,int minor,int profile,BBGLContext *share){
	NSOpenGLContext *previous=[[NSOpenGLContext currentContext] retain];
	BBGLContext *context=bbGLGraphicsAttachGraphics(widget,flags);
	if(context && !configureRequestedContext(context,major,minor,profile,share)){
		bbGLGraphicsClose(context);
		context=NULL;
	}
	if(previous)[previous makeCurrentContext];
	else [NSOpenGLContext clearCurrentContext];
	[previous release];
	return context;
}

void bbGLGraphicsDrawableSize(BBGLContext *context,int *width,int *height){
	NSView *view;
	NSRect bounds;
	*width=*height=0;
	if(!context)return;
	view=context->mode==MODE_WIDGET?context->view:[context->window contentView];
	if(!view)return;
	[context->glContext update];
	bounds=[view bounds];
	if([view wantsBestResolutionOpenGLSurface] || [view wantsLayer])bounds=[view convertRectToBacking:bounds];
	*width=(int)bounds.size.width;
	*height=(int)bounds.size.height;
}
