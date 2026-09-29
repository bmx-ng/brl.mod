SuperStrict

Import BRL.Graphics
Import BRL.Pixmap
Import Pub.Glew
Import Pub.OpenGL
Import BRL.SystemDefault

Private

Incbin "gldrawtextfont.bin"

Extern
	Function bbGLGraphicsCreateGraphicsEx:Byte Ptr(width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int,major:Int,minor:Int,profile:Int,share:Byte Ptr)
	Function bbGLGraphicsAttachGraphicsEx:Byte Ptr(widget:Byte Ptr,flags:Long,major:Int,minor:Int,profile:Int,share:Byte Ptr)
	Function bbGLGraphicsShareContexts()
	Function bbGLGraphicsGraphicsModes:Int( buf:Byte Ptr,size:Int )
	Function bbGLGraphicsAttachGraphics:Byte Ptr( widget:Byte Ptr,flags:Long )
	Function bbGLGraphicsCreateGraphics:Byte Ptr( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int )
	Function bbGLGraphicsGetSettings( context:Byte Ptr,width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var )
	Function bbGLGraphicsSupportsFullscreen:Int(context:Byte Ptr)
	Function bbGLGraphicsSetFullscreen:Int(context:Byte Ptr,enabled:Int,width:Int,height:Int,hertz:Int)
	Function bbGLGraphicsFullscreenModes:Int(context:Byte Ptr,buf:Int Ptr,count:Int)
	Function bbGLGraphicsClientSize(context:Byte Ptr,width:Int Var,height:Int Var)
	Function bbGLGraphicsDrawableSize(context:Byte Ptr,width:Int Var,height:Int Var)
	Function bbGLGraphicsSetBorderless:Int(context:Byte Ptr,enabled:Int)
	Function bbGLGraphicsIsBorderless:Int(context:Byte Ptr)
	Function bbGLGraphicsSupportsBorderless:Int(context:Byte Ptr)
	Function bbGLGraphicsResize:Int(context:Byte Ptr,width:Int,height:Int)
	Function bbGLGraphicsPosition:Int(context:Byte Ptr,x:Int,y:Int)
	Function bbGLGraphicsGetPosition(context:Byte Ptr,x:Int Var,y:Int Var)
	Function bbGLGraphicsClose( context:Byte Ptr )	
	Function bbGLGraphicsSetGraphics( context:Byte Ptr )
	Function bbGLGraphicsFlip( sync:Int )
End Extern

Public

Rem
bbdoc: Leaves profile selection to the platform for an explicitly requested OpenGL version.
about: For OpenGL 3.2 and newer, platforms normally select a core profile. Use an explicit profile when your code requires one.
End Rem
Const GL_CONTEXT_ANY:Int=0

Rem
bbdoc: Requests a core profile, without legacy fixed-function drawing APIs.
about: Requires OpenGL 3.2 or newer. BRL.Max2D and GLDraw helpers require legacy functionality and must not use this profile.
End Rem
Const GL_CONTEXT_CORE:Int=1

Rem
bbdoc: Requests a compatibility profile containing legacy and modern drawing APIs.
about: Requires OpenGL 3.2 or newer; unavailable on macOS.
End Rem
Const GL_CONTEXT_COMPATIBILITY:Int=2

Rem
bbdoc: An explicit OpenGL context request for raw OpenGL applications.
about: Pass to GLGraphics or GLGraphicsDriver. Settings are copied when the driver is created. Requests specify a minimum version; the driver may provide a newer compatible version. Unsupported requests return Null when graphics are created. Omitting this object retains legacy behaviour. Create, attach and select graphics on the main thread.
End Rem
Type TGLContextOptions

	Rem
	bbdoc: Minimum OpenGL major version, initially 3.
	End Rem
	Field major:Int=3

	Rem
	bbdoc: Minimum OpenGL minor version, initially 3.
	End Rem
	Field minor:Int=3

	Rem
	bbdoc: Requested profile: GL_CONTEXT_ANY, GL_CONTEXT_CORE or GL_CONTEXT_COMPATIBILITY.
	End Rem
	Field profile:Int=GL_CONTEXT_CORE

	Rem
	bbdoc: Optional live GLGraphics context with which to share textures, buffers and other shareable objects.
	about: Explicit requests do not join the legacy GLShareContexts group automatically. The referenced context must remain open until creation completes and must be compatible with the new context. Vertex arrays and other non-shareable objects remain per-context.
	End Rem
	Field shareWith:TGLGraphics

	Rem
	bbdoc: Creates an explicit minimum-version and profile request.
	param: Minimum major version.
	param: Minimum minor version.
	param: Profile to request; defaults to core. Use GL_CONTEXT_ANY for versions before 3.2.
	End Rem
	Function Create:TGLContextOptions(major:Int,minor:Int,profile:Int=GL_CONTEXT_CORE)
		Local options:TGLContextOptions=New TGLContextOptions
		options.major=major
		options.minor=minor
		options.profile=profile
		Return options
	End Function
End Type

Type TGLGraphics Extends TGraphics

	Method Driver:TGLGraphicsDriver() Override
		Assert _context
		If _driver Then Return _driver
		Return GLGraphicsDriver()
	End Method
	
	Method GetSettings( width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var, x:Int Var, y:Int Var ) Override
		Assert _context
		Local w:Int,h:Int,d:Int,r:Int,f:Long,xp:Int,yp:Int
		bbGLGraphicsGetSettings _context,w,h,d,r,f
		width=w
		height=h
		depth=d
		hertz=r
		flags=f
		bbGLGraphicsGetPosition _context,x,y
	End Method
	
	Method Close() Override
		If Not _context Return
		bbGLGraphicsClose( _context )
		_context=0
	End Method
	
	Method Resize(width:Int, height:Int) Override
		If Not _context Then Throw "GLGraphics: graphics is closed"
		If width<=0 Or height<=0 Then Throw "GLGraphics: window dimensions must be positive"
		If Not bbGLGraphicsResize(_context,width,height) Then Throw "GLGraphics: resize requires an owned windowed context and a successful window-system request"
	End Method
	
	Method Position(x:Int, y:Int) Override
		If Not _context Then Throw "GLGraphics: graphics is closed"
		If Not bbGLGraphicsPosition(_context,x,y) Then Throw "GLGraphics: position requires an owned windowed context and a successful window-system request"
	End Method

	Method SupportsFullscreen:Int()
		Return bbGLGraphicsSupportsFullscreen(_context)
	End Method
	Method FullscreenModes:TGraphicsMode[]()
		Local count:Int=bbGLGraphicsFullscreenModes(_context,Null,0)
		Local data:Int[count*4]
		count=bbGLGraphicsFullscreenModes(_context,data,count)
		Local result:TGraphicsMode[count]
		For Local i:Int=0 Until count
			Local mode:TGraphicsMode=New TGraphicsMode
			mode.width=data[i*4];mode.height=data[i*4+1];mode.depth=data[i*4+2];mode.hertz=data[i*4+3]
			result[i]=mode
		Next
		Return result
	End Method
	Method ClientSize(width:Int Var,height:Int Var)
		bbGLGraphicsClientSize(_context,width,height)
	End Method
	Rem
	bbdoc: Gets the OpenGL drawable size in pixels for viewport and framebuffer operations.
	param: Receives the drawable width in pixels, or zero for closed graphics.
	param: Receives the drawable height in pixels, or zero for closed graphics.
	about: May differ from logical window dimensions on high-DPI displays. Query again after resizing or moving between displays.
	End Rem
	Method DrawableSize(width:Int Var,height:Int Var)
		bbGLGraphicsDrawableSize(_context,width,height)
	End Method

	Method SetFullscreen(enabled:Int,width:Int=0,height:Int=0,hertz:Int=0)
		If Not bbGLGraphicsSetFullscreen(_context,enabled,width,height,hertz) Then Throw "GLGraphics: exclusive transition failed (unsupported window, unavailable exact mode, display busy or native display operation failed)"
	End Method
	Method SupportsBorderless:Int()
		Return bbGLGraphicsSupportsBorderless(_context)
	End Method

	Method IsBorderless:Int()
		Return bbGLGraphicsIsBorderless(_context)
	End Method

	Method SetBorderless(enabled:Int)
		If Not bbGLGraphicsSetBorderless(_context,enabled) Then Throw "GLGraphics: borderless fullscreen is unsupported or the window-system request failed"
	End Method

	Rem
	bbdoc: Driver that created this graphics object; maintained internally.
	End Rem
	Field _driver:TGLGraphicsDriver
	Field _context:Byte Ptr
	
End Type

Type TGLGraphicsDriver Extends TGraphicsDriver

	Private
	Field _major:Int
	Field _minor:Int
	Field _profile:Int
	Field _shareWith:TGLGraphics

	Method ShareContext:Byte Ptr()
		If Not _shareWith Then Return Null
		If Not _shareWith._context Then Throw "GLGraphics: sharing context is closed"
		Return _shareWith._context
	End Method

	Public
	Rem
	bbdoc: Creates a driver with a snapshot of an explicit OpenGL context request.
	param: Version, profile and optional sharing context; must not be Null.
	End Rem
	Function WithContext:TGLGraphicsDriver(options:TGLContextOptions)
		If Not options Then Throw "GLGraphics: context options are required"
		If options.major<1 Or options.minor<0 Then Throw "GLGraphics: invalid context version"
		If (options.major=1 And options.minor>5) Or (options.major=2 And options.minor>1) Or (options.major=3 And options.minor>3) Or (options.major=4 And options.minor>6) Then Throw "GLGraphics: undefined context version"
		If options.profile<GL_CONTEXT_ANY Or options.profile>GL_CONTEXT_COMPATIBILITY Then Throw "GLGraphics: invalid context profile"
		If options.profile<>GL_CONTEXT_ANY And (options.major<3 Or (options.major=3 And options.minor<2)) Then Throw "GLGraphics: profiles require OpenGL 3.2 or newer"
		Local driver:TGLGraphicsDriver=New TGLGraphicsDriver
		driver._major=options.major
		driver._minor=options.minor
		driver._profile=options.profile
		driver._shareWith=options.shareWith
		Return driver
	End Function

	Method GraphicsModes:TGraphicsMode[]() Override
		Local buf:Int[1024*4]
		Local count:Int=bbGLGraphicsGraphicsModes( buf,1024 )
		Local modes:TGraphicsMode[count],p:Int Ptr=buf
		For Local i:Int=0 Until count
			Local t:TGraphicsMode=New TGraphicsMode
			t.width=p[0]
			t.height=p[1]
			t.depth=p[2]
			t.hertz=p[3]
			modes[i]=t
			p:+4
		Next
		Return modes
	End Method
	
	Method AttachGraphics:TGLGraphics( widget:Byte Ptr,flags:Long ) Override
		Local t:TGLGraphics=New TGLGraphics
		If _major
			t._context=bbGLGraphicsAttachGraphicsEx(widget,flags,_major,_minor,_profile,ShareContext())
		Else
			t._context=bbGLGraphicsAttachGraphics(widget,flags)
		End If
		If Not t._context Then Return Null
		t._driver=Self
		Return t
	End Method
	
	Method CreateGraphics:TGLGraphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int ) Override
		Local t:TGLGraphics=New TGLGraphics
		If _major
			t._context=bbGLGraphicsCreateGraphicsEx(width,height,depth,hertz,flags,x,y,_major,_minor,_profile,ShareContext())
		Else
			t._context=bbGLGraphicsCreateGraphics(width,height,depth,hertz,flags,x,y)
		End If
		If Not t._context Then Return Null
		t._driver=Self
		Return t
	End Method
	
	Method SetGraphics( g:TGraphics ) Override
		Local context:Byte Ptr
		Local t:TGLGraphics=TGLGraphics( g )
		If t context=t._context
		bbGLGraphicsSetGraphics context
	End Method
	
	Method Flip:Int( sync:Int) Override
		bbGLGraphicsFlip sync
	End Method
	
	Method CanResize:Int() Override
		Return True
	End Method

	Method ToString:String() Override
		Return "TGLGraphicsDriver"
	End Method
End Type

Rem
bbdoc: Get an OpenGL graphics driver with optional context settings.
param: Explicit context request, or Null for the existing shared legacy driver.
returns: An OpenGL graphics driver
about:
The returned driver can be used with #SetGraphicsDriver
End Rem
Function GLGraphicsDriver:TGLGraphicsDriver(options:TGLContextOptions=Null)
	If options Then Return TGLGraphicsDriver.WithContext(options)
	Global _driver:TGLGraphicsDriver=New TGLGraphicsDriver
	Return _driver
End Function

Rem
bbdoc: Create OpenGL graphics with optional version and profile selection.
param: Window width in logical units.
param: Window height in logical units.
param: Fullscreen colour depth, or zero for a window.
param: Requested refresh/synchronisation rate.
param: Graphics buffer and window flags.
param: Explicit context request, or Null to preserve legacy context creation.
returns: An OpenGL graphics object, or Null if creation or the context request fails.
about:
This is a convenience function that allows you to easily create an OpenGL graphics context.
End Rem
Function GLGraphics:TGraphics( width:Int,height:Int,depth:Int=0,hertz:Int=60,flags:Long=GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER,options:TGLContextOptions=Null )
	SetGraphicsDriver GLGraphicsDriver(options)
	Return Graphics( width,height,depth,hertz,flags )
End Function
	
SetGraphicsDriver GLGraphicsDriver()

'----- Helper Functions -----

Private

Global fontTex:Int
Global fontSeq:Int

Global ortho_mv![16],ortho_pj![16]

Function BeginOrtho()
	Local vp:Int[4]
	
	glPushAttrib GL_ENABLE_BIT|GL_TEXTURE_BIT|GL_TRANSFORM_BIT
	
	glGetIntegerv GL_VIEWPORT,vp
	glGetDoublev GL_MODELVIEW_MATRIX,ortho_mv
	glGetDoublev GL_PROJECTION_MATRIX,ortho_pj
	
	glMatrixMode GL_MODELVIEW
	glLoadIdentity
	glMatrixMode GL_PROJECTION
	glLoadIdentity
	glOrtho 0,vp[2],vp[3],0,-1,1

	glDisable GL_CULL_FACE
	glDisable GL_ALPHA_TEST	
	glDisable GL_DEPTH_TEST
End Function

Function EndOrtho()
	glMatrixMode GL_PROJECTION
	glLoadMatrixd ortho_pj
	glMatrixMode GL_MODELVIEW
	glLoadMatrixd ortho_mv
	
	glPopAttrib
End Function

Public

Rem
bbdoc: Helper function to calculate nearest valid texture size
about: This functions rounds @width and @height up to the nearest valid texture size
End Rem
Function GLAdjustTexSize( width:Int Var,height:Int Var )
	Function Pow2Size:Int( n:Int )
		Local t:Int=1
		While t<n
			t:*2
		Wend
		Return t
	End Function
	width=Pow2Size( width )
	height=Pow2Size( height )
	Repeat
		Local t:Int
		glTexImage2D GL_PROXY_TEXTURE_2D,0,4,width,height,0,GL_RGBA,GL_UNSIGNED_BYTE,Null
		glGetTexLevelParameteriv GL_PROXY_TEXTURE_2D,0,GL_TEXTURE_WIDTH,Varptr t
		If t Return
		If width=1 And height=1 RuntimeError "Unable to calculate tex size"
		If width>1 width:/2
		If height>1 height:/2
	Forever
End Function

Rem
bbdoc: Helper function to create a texture from a pixmap
returns: Integer GL Texture name
about: @pixmap is resized to a valid texture size before conversion.
end rem
Function GLTexFromPixmap:Int( pixmap:TPixmap,mipmap:Int=True )
	If pixmap.format<>PF_RGBA8888 pixmap=pixmap.Convert( PF_RGBA8888 )
	Local width:Int=pixmap.width,height:Int=pixmap.height
	GLAdjustTexSize width,height
	If width<>pixmap.width Or height<>pixmap.height pixmap=ResizePixmap( pixmap,width,height )
	
	Local old_name:Int,old_row_len:Int
	glGetIntegerv GL_TEXTURE_BINDING_2D,Varptr old_name
	glGetIntegerv GL_UNPACK_ROW_LENGTH,Varptr old_row_len

	Local name:Int
	glGenTextures 1,Varptr name
	glBindtexture GL_TEXTURE_2D,name
	
	Local mip_level:Int
	Repeat
		glPixelStorei GL_UNPACK_ROW_LENGTH,pixmap.pitch/BytesPerPixel[pixmap.format]
		glTexImage2D GL_TEXTURE_2D,mip_level,GL_RGBA8,width,height,0,GL_RGBA,GL_UNSIGNED_BYTE,pixmap.pixels
		If Not mipmap Exit
		If width=1 And height=1 Exit
		If width>1 width:/2
		If height>1 height:/2
		pixmap=ResizePixmap( pixmap,width,height )
		mip_level:+1
	Forever
	
	glBindTexture GL_TEXTURE_2D,old_name
	glPixelStorei GL_UNPACK_ROW_LENGTH,old_row_len

	Return name
End Function

Rem
bbdoc:Helper function to output a simple rectangle
about:
Draws a rectangle relative to top-left of current viewport.
End Rem
Function GLDrawRect( x:Int,y:Int,width:Int,height:Int )
	BeginOrtho
	glBegin GL_QUADS
	glVertex2i x,y
	glVertex2i x+width,y
	glVertex2i x+width,y+height
	glVertex2i x,y+height
	glEnd
	EndOrtho
End Function

Rem
bbdoc: Helper function to output some simple 8x16 font text
about:
Draws text relative to top-left of current viewport.<br/>
<br/>
The font used is an internal fixed point 8x16 font.<br/>
<br/>
This function is intended for debugging purposes only - performance is unlikely to be stellar.
End Rem
Function GLDrawText( Text:String,x:Int,y:Int )
'	If fontSeq<>graphicsSeq
	If Not fontTex
		Local pixmap:TPixmap=TPixmap.Create( 1024,16,PF_RGBA8888 )
		Local p:Byte Ptr=IncbinPtr( "gldrawtextfont.bin" )
		For Local y:Int=0 Until 16
			For Local x:Int=0 Until 96
				Local b:Int=p[x]
				For Local n:Int=0 Until 8
					If b & (1 Shl n) 
						pixmap.WritePixel x*8+n,y,~0
					Else
						pixmap.WritePixel x*8+n,y,0
					EndIf
				Next
			Next
			p:+96
		Next
		fontTex=GLTexFromPixmap( pixmap )
		fontSeq=graphicsSeq
	EndIf
	
	BeginOrtho
	
	glEnable GL_TEXTURE_2D
	glBindTexture GL_TEXTURE_2D,fontTex
	
	For Local i:Int=0 Until Text.length
		Local c:Int=Text[i]-32
		If c>=0 And c<96
			Const adv#=8/1024.0
			Local t#=c*adv;
			glBegin GL_QUADS
			glTexcoord2f t,0
			glVertex2f x,y
			glTexcoord2f t+adv,0
			glVertex2f x+8,y
			glTexcoord2f t+adv,1
			glVertex2f x+8,y+16
			glTexcoord2f t,1
			glVertex2f x,y+16
			glEnd
		EndIf
		x:+8
	Next

	EndOrtho
End Function

Rem
bbdoc: Helper function to draw a pixmap to a gl context
about:
Draws the pixmap relative to top-left of current viewport.<br/>
<br/>
This function is intended for debugging purposes only - performance is unlikely to be stellar.
End Rem
Function GLDrawPixmap( pixmap:TPixmap,x:Int,y:Int )
	BeginOrtho

	Local t:TPixmap=YFlipPixmap(pixmap)
	If t.format<>PF_RGBA8888 t=ConvertPixmap( t,PF_RGBA8888 )
	glRasterPos2i 0,0
	glBitmap 0,0,0,0,x,-y-t.height,Null
	glDrawPixels t.width,t.height,GL_RGBA,GL_UNSIGNED_BYTE,t.pixels

	EndOrtho
End Function

Rem
bbdoc: Enable OpenGL context sharing
about:
Calling #GLShareContexts will cause all opengl graphics contexts created to
shared displaylists, textures, shaders etc.

This should be called before any opengl contexts are created.
End Rem
Function GLShareContexts()
	bbGLGraphicsShareContexts
End Function

