#define GL_SILENCE_DEPRECATION
#import <AppKit/AppKit.h>
#include <math.h>

/* Query the view attached to the active context, without depending on BRL's
   private native context layout. Window/event dimensions remain in points. */
int brl_glmax2d_drawable_size(int *width, int *height) {
    NSOpenGLContext *context = [NSOpenGLContext currentContext];
    NSView *view = [context view];
    if (!view) return 0;
    [context update];
    NSRect bounds = [view bounds];
    if ([view wantsBestResolutionOpenGLSurface] || [view wantsLayer]) {
        bounds = [view convertRectToBacking:bounds];
    }
    *width = (int)lround(NSWidth(bounds));
    *height = (int)lround(NSHeight(bounds));
    return *width > 0 && *height > 0;
}
