
#include <brl.mod/blitz.mod/blitz.h>
#include <pub.mod/macos.mod/macos.h>
#import <AppKit/AppKit.h>

void __bb_brl_appstub_appstub();

typedef NSApplicationTerminateReply (*BBAppShouldTerminateHook)(NSApplication *app);
typedef void (*BBAppWillTerminateHook)(NSNotification *notification);
typedef int (*BBAppOpenFileHook)(NSApplication *app, BBString *path);

static NSMutableArray *g_shouldTerminateHooks;
static NSMutableArray *g_willTerminateHooks;
static NSMutableArray *g_openFileHooks;

void bbRegisterAppShouldTerminateHook(BBAppShouldTerminateHook hook) {
	if (!g_shouldTerminateHooks) {
		g_shouldTerminateHooks = [[NSMutableArray alloc] init];
	}
	[g_shouldTerminateHooks addObject:[NSValue valueWithBytes:&hook objCType:@encode(BBAppShouldTerminateHook)]];
}

void bbRegisterAppWillTerminateHook(BBAppWillTerminateHook hook) {
	if (!g_willTerminateHooks) {
		g_willTerminateHooks = [[NSMutableArray alloc] init];
	}
	[g_willTerminateHooks addObject:[NSValue valueWithBytes:&hook objCType:@encode(BBAppWillTerminateHook)]];
}

void bbRegisterAppOpenFileHook(BBAppOpenFileHook hook) {
	if (!g_openFileHooks) {
		g_openFileHooks = [[NSMutableArray alloc] init];
	}
	[g_openFileHooks addObject:[NSValue valueWithBytes:&hook objCType:@encode(BBAppOpenFileHook)]];
}

static int app_argc;
static char **app_argv;

static NSMutableArray *_appArgs;

static void createAppMenu( NSString *appName ){

	NSMenu *mainMenu;
	NSMenu *appMenu;
	NSMenu *serviceMenu;
	NSMenu *viewMenu;
	NSMenu *windowMenu;
	NSMenuItem *item;
	NSString *title;
	
	mainMenu = [[NSMenu alloc] init];
	
	[NSApp setMainMenu:mainMenu];
	
	[mainMenu release];
	
	appMenu=[[NSMenu alloc] initWithTitle:@""];
	
	title=[@"About " stringByAppendingString:appName];
    [appMenu addItemWithTitle:title action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];

    [appMenu addItem:[NSMenuItem separatorItem]];

	[appMenu addItemWithTitle:@"Preferences…" action:nil keyEquivalent:@","];

    [appMenu addItem:[NSMenuItem separatorItem]];

    serviceMenu = [[NSMenu alloc] initWithTitle:@""];
    item = (NSMenuItem *)[appMenu addItemWithTitle:@"Services" action:nil keyEquivalent:@""];
    [item setSubmenu:serviceMenu];

    [NSApp setServicesMenu:serviceMenu];
    [serviceMenu release];

    [appMenu addItem:[NSMenuItem separatorItem]];

	title=[@"Hide " stringByAppendingString:appName];
	[appMenu addItemWithTitle:@"Hide" action:@selector(hide:) keyEquivalent:@"h"];

	item=(NSMenuItem*)[appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
	[item setKeyEquivalentModifierMask:(NSAlternateKeyMask|NSCommandKeyMask)];
	
	[appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
	
	[appMenu addItem:[NSMenuItem separatorItem]];

	title=[@"Quit " stringByAppendingString:appName];
	[appMenu addItemWithTitle:title action:@selector(terminate:) keyEquivalent:@"q"];
	
	item=[[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
	[item setSubmenu:appMenu];
	[[NSApp mainMenu] addItem:item];
	[item release];
	
	[NSApp performSelector:NSSelectorFromString(@"setAppleMenu:") withObject:appMenu];

	viewMenu = [[NSMenu alloc] initWithTitle:@"View"];

	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
		item = [[NSMenuItem alloc] initWithTitle:@"Toggle Full Screen" action:@selector(toggleFullScreen:) keyEquivalent:@"f"];
		[item setKeyEquivalentModifierMask:NSEventModifierFlagControl | NSEventModifierFlagCommand];
		[viewMenu addItem:item];
		[item release];
	}

	item = [[NSMenuItem alloc] initWithTitle:@"View" action:nil keyEquivalent:@""];
	[item setSubmenu:viewMenu];
	[[NSApp mainMenu] addItem:item];
	[item release];
	
	windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
	
	[windowMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
	
	[windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
	
	[windowMenu addItemWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];

	item = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
	[item setSubmenu:windowMenu];
	[[NSApp mainMenu] addItem:item];
	[item release];

	[NSApp setWindowsMenu:windowMenu];
	[windowMenu release];
}

static void run(){

	signal( SIGPIPE,SIG_IGN );
	
	bbStartup( app_argc,app_argv,0,0 );

	__bb_brl_appstub_appstub();
	
	exit( 0 );
}

void bbFlushAutoreleasePool(){
	// nothing to do here.
}

@interface BlitzMaxAppDelegate : NSObject{
}
@end

@implementation BlitzMaxAppDelegate
-(void)applicationWillTerminate:(NSNotification*)notification{

	if (g_willTerminateHooks) {
		for (NSValue *v in g_willTerminateHooks) {
			BBAppWillTerminateHook func = [v pointerValue];
			if (func) {
				func(notification);
			}
		}
	}

	exit(0);
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender{
	if (g_shouldTerminateHooks) {
		for (NSValue *v in g_shouldTerminateHooks) {
			BBAppShouldTerminateHook func = [v pointerValue];
			if (func) {
				NSApplicationTerminateReply r = func(sender);
				if (r != NSTerminateNow) {
					return r;
				}
			}
		}
	}
	return NSTerminateCancel;
}

-(BOOL)application:(NSApplication*)app openFile:(NSString*)path{
	if (_appArgs) {
		[_appArgs addObject:path];
	}

	if (g_openFileHooks) {
		BBString * bbPath = NULL;
		for (NSValue *v in g_openFileHooks) {
			BBAppOpenFileHook func = [v pointerValue];
			if (func) {
				if (!bbPath) {
					bbPath = bbStringFromNSString(path);
				}
				int r = func(app, bbPath);
				if (r) {
					return YES;
				}
			}
		}
	}

	return YES;
}

-(void)applicationDidFinishLaunching:(NSNotification*)notification{
	int i;
	app_argc=[_appArgs count];
	app_argv=(char**)malloc( (app_argc+1)*sizeof(char*) );
	for( i=0;i<app_argc;++i ){
		NSString *t=[_appArgs objectAtIndex:i];
		char *p=(char*)malloc( [t length]+1 );
		strcpy( p,[t cString] );
		app_argv[i]=p;
	}
	app_argv[i]=0;
	[_appArgs release];
	_appArgs=nil;

	[NSApp activateIgnoringOtherApps:YES];
	
	run();
}
@end

int main( int argc,char *argv[] ){
	int i;
	CFURLRef url;
	char *app_file,*p;
	
	@autoreleasepool {

		[NSApplication sharedApplication];
		
		app_argc=argc;
		app_argv=argv;
		
		url=CFBundleCopyExecutableURL( CFBundleGetMainBundle() );
	
		app_file=malloc( 4096 );
		CFURLGetFileSystemRepresentation( url,true,(UInt8*)app_file,4096 );
		
		if( strstr( app_file,".app/Contents/MacOS/" ) ){
			//GUI app!
			//
			p=strrchr( app_file,'/' );
			if( p ){
				++p;
			}else{
				 p=app_file;
			}
			createAppMenu( [NSString stringWithCString:p encoding:NSUTF8StringEncoding] );
			free( app_file );
		
			[NSApp setDelegate:[[BlitzMaxAppDelegate alloc] init]];
			
			_appArgs=[[NSMutableArray arrayWithCapacity:10] retain];
			[_appArgs addObject:[NSString stringWithCString:argv[0]] ];
				
			[NSApp run];
		}else{
			//Console app!
			//
			free( app_file );
	
			run();
		}
	
	}
}
