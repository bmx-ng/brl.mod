# BRL.GLGraphics: choosing an OpenGL context

`BRL.GLGraphics` creates windows and OpenGL contexts. `Pub.GLEW`, which it imports,
exposes modern OpenGL functions. Initialise GLEW **after** the context is current.

Existing calls retain their platform's legacy context creation behaviour:

```blitzmax
Framework BRL.GLGraphics
Graphics 800, 600
```

## Request a version and profile

```blitzmax
SuperStrict
Framework BRL.GLGraphics

Local options:TGLContextOptions = TGLContextOptions.Create(3, 3, GL_CONTEXT_CORE)
Local window:TGraphics = GLGraphics(800, 600, 0, 60, GRAPHICS_BACKBUFFER, options)
If Not window Then RuntimeError "OpenGL 3.3 core is unavailable."
If glewInit() <> 0 Then RuntimeError "GLEW could not initialise."
If Not GL_VERSION_3_3 Then RuntimeError "OpenGL 3.3 functions are unavailable."

' Set up shaders, a vertex array and buffers, then draw through Pub.GLEW.
```

The request specifies a **minimum version**, not a cap. A 3.3 request may return a
4.1 context, for example. Query `glGetString(GL_VERSION)` after creation to see
what was supplied. An unsupported request returns `Null`; it does not silently
fall back to a lower version or a different requested profile.

| Profile | Meaning |
| --- | --- |
| `GL_CONTEXT_CORE` | Modern OpenGL without legacy fixed-function drawing. Requires a request of 3.2 or newer. This is the options object's default. |
| `GL_CONTEXT_COMPATIBILITY` | Modern OpenGL with legacy functionality. Requires 3.2 or newer and driver support. |
| `GL_CONTEXT_ANY` | Do not explicitly constrain the profile. Use this for requests before 3.2. For newer versions, expect a core context unless you explicitly request compatibility. |

For example, `TGLContextOptions.Create(2, 1, GL_CONTEXT_ANY)` requests OpenGL 2.1.
Omitting the options object entirely preserves the old creation path, rather
than expressing a minimum-version request.

macOS provides legacy OpenGL up to 2.1 and core profiles up to 4.1. It does not
provide modern compatibility profiles or an OpenGL 3.0 compatibility context.
A 3.1 request with `GL_CONTEXT_ANY` can use its 3.2 core profile; requests of 3.3
or 4.0 can use its 4.1 core profile. Hardware support still determines whether
creation succeeds. Windows uses `WGL_ARB_create_context`; Linux/X11 uses
`GLX_ARB_create_context` and framebuffer configurations matching the window.

## Configure a driver

For repeated creation or attachment to a native widget, configure a driver:

```blitzmax
Local driver:TGLGraphicsDriver = GLGraphicsDriver(TGLContextOptions.Create(3, 3))
SetGraphicsDriver(driver)
Graphics 800, 600
```

The driver snapshots the version/profile options. Editing the options object
later does not change it. Each graphics object remembers its creating driver,
so `SetGraphics` can switch between graphics created with different requests.
`GLGraphicsDriver()` without options always returns the original legacy driver.

`driver.CreateGraphics(...)` and `driver.AttachGraphics(...)` return `Null` on an
unsupported request. Select a successfully created object using `SetGraphics`
before initialising GLEW or drawing. Attached widgets must have a compatible
native visual/pixel format. All creation and context selection belongs on the
main window-system thread.

## Drawable pixels and high DPI

`TGLGraphics.DrawableSize(width, height)` returns the framebuffer dimensions in
pixels. Use these for `glViewport` and pixel readback. Logical window dimensions
can be smaller on a Retina display. Query again after window/display changes:

```blitzmax
Local pixelWidth:Int
Local pixelHeight:Int
TGLGraphics(window).DrawableSize(pixelWidth, pixelHeight)
glViewport(0, 0, pixelWidth, pixelHeight)
```

## Context sharing

Existing `GLShareContexts()` behaviour is unchanged for legacy contexts.
Explicit version requests do **not** automatically join that legacy share group.
To share resources between explicitly created contexts:

```blitzmax
Local options:TGLContextOptions = TGLContextOptions.Create(3, 3)
options.shareWith = firstWindow ' A live TGLGraphics object.
Local driver:TGLGraphicsDriver = GLGraphicsDriver(options)
Local secondWindow:TGLGraphics = driver.CreateGraphics(640, 480, 0, 60, GRAPHICS_BACKBUFFER, -1, -1)
```

The source context must remain open until creation completes. The native driver
must support sharing between the contexts; incompatible requests fail. Textures
and buffers can be shared, but objects such as vertex arrays remain per-context.

Creating an explicitly configured context restores the previously current
context before returning, including after a failed request. GLEW has global
function pointers and capability flags: initialise it for the context you intend
to use, and refresh them when switching between contexts with differing drivers
or capabilities.

## Compatibility with Max2D

No changes are needed for existing BRL.Max2D applications. Leave their context
creation defaults alone. A core profile removes APIs used by BRL.GLMax2D and the
legacy `GLDraw*` helpers. Choosing core does not modernise code that uses those
APIs; it is intended for applications doing their own shader-based drawing.

No GL loader is initialised merely by requesting a version. Importing the module
retains its existing default-driver registration behaviour.

## Example

[opengl33_triangle.bmx](examples/opengl33_triangle.bmx) requests a 3.3 core
context, initialises GLEW, compiles shaders and draws a triangle using a vertex
array and buffer. Escape or the window close button exits. Pass `--test` to exit
after three frames; the example also checks a rendered pixel. Pass `--compat`
to explicitly request a 3.3 compatibility context instead, for a driver that
does not provide a core profile. There is no automatic fallback.

```sh
bin/bmk makeapp -r -t gui mod/brl.mod/glgraphics.mod/examples/opengl33_triangle.bmx
```

The accompanying small C helper preserves the nested `const` string pointer
required by `glShaderSource`; Pub.GLEW's older BlitzMax declaration otherwise
triggers a type error on strict recent C compilers. The other OpenGL operations
in the example call Pub.GLEW directly.
