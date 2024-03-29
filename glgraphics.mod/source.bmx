SuperStrict

Import BRL.Graphics
Import BRL.Pixmap
Import Pub.Glew
Import Pub.OpenGL
Import BRL.SystemDefault

Private

Incbin "gldrawtextfont.bin"

Extern
	Function bbGLGraphicsShareContexts()
	Function bbGLGraphicsGraphicsModes:Int( buf:Byte Ptr,size:Int )
	Function bbGLGraphicsAttachGraphics:Byte Ptr( widget:Byte Ptr,flags:Long )
	Function bbGLGraphicsCreateGraphics:Byte Ptr( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int )
	Function bbGLGraphicsGetSettings( context:Byte Ptr,width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var )
	Function bbGLGraphicsClose( context:Byte Ptr )	
	Function bbGLGraphicsSetGraphics( context:Byte Ptr )
	Function bbGLGraphicsFlip( sync:Int )
End Extern

Public

Type TGLGraphics Extends TGraphics

	Method Driver:TGLGraphicsDriver() Override
		Assert _context
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
		x=-1
		y=-1
	End Method
	
	Method Close() Override
		If Not _context Return
		bbGLGraphicsClose( _context )
		_context=0
	End Method
	
	Method Resize(width:Int, height:Int) Override
	End Method
	
	Method Position(x:Int, y:Int) Override
	End Method

	Field _context:Byte Ptr
	
End Type

Type TGLGraphicsDriver Extends TGraphicsDriver

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
		t._context=bbGLGraphicsAttachGraphics( widget,flags )
		Return t
	End Method
	
	Method CreateGraphics:TGLGraphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int ) Override
		Local t:TGLGraphics=New TGLGraphics
		t._context=bbGLGraphicsCreateGraphics( width,height,depth,hertz,flags,x,y )
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
	
	Method ToString:String() Override
		Return "TGLGraphicsDriver"
	End Method
End Type

Rem
bbdoc: Get OpenGL graphics driver
returns: An OpenGL graphics driver
about:
The returned driver can be used with #SetGraphicsDriver
End Rem
Function GLGraphicsDriver:TGLGraphicsDriver()
	Global _driver:TGLGraphicsDriver=New TGLGraphicsDriver
	Return _driver
End Function

Rem
bbdoc: Create OpenGL graphics
returns: An OpenGL graphics object
about:
This is a convenience function that allows you to easily create an OpenGL graphics context.
End Rem
Function GLGraphics:TGraphics( width:Int,height:Int,depth:Int=0,hertz:Int=60,flags:Long=GRAPHICS_BACKBUFFER|GRAPHICS_DEPTHBUFFER )
	SetGraphicsDriver GLGraphicsDriver()
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

