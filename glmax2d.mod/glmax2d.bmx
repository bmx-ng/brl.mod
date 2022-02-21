
SuperStrict

Rem
bbdoc: Graphics/OpenGL Max2D
about:
The OpenGL Max2D module provides an OpenGL driver for #Max2D.
End Rem
Module BRL.GLMax2D

ModuleInfo "Version: 1.14"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.14"
ModuleInfo "History: Changed to SuperStrict"
ModuleInfo "History: Extended flags to Long"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: Cleaned up SetGraphics"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Fixed filtered image min filters"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Fixed texture delete logic"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Add SetColor/SetClsColor clamping"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Fixed DrawPixmap using current blend mode - now always uses SOLIDBLEND"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Added MIPMAPPEDIMAGE support"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Now default driver for MacOS/Linux only (D3D7 for windows)"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Ripped out a bunch of dead code"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Added checks to prevent invalid textures deletes"

?Not opengles And Not nx And Not raspberrypi And Not haiku

Import BRL.Max2D
Import BRL.GLGraphics
Import BRL.Threads

Private

Global _driver:TGLMax2DDriver

'Naughty!
Const GL_BGR:Int=$80E0
Const GL_BGRA:Int=$80E1
Const GL_CLAMP_TO_EDGE:Int=$812F
Const GL_CLAMP_TO_BORDER:Int=$812D

Global ix#,iy#,jx#,jy#
Global color4ub:Byte[4]

Global state_blend:Int
Global state_boundtex:Int
Global state_texenabled:Int

Function BindTex( name:Int )
	If name=state_boundtex Return
	glBindTexture GL_TEXTURE_2D,name
	state_boundtex=name
End Function

Function EnableTex( name:Int )
	BindTex name
	If state_texenabled Return
	glEnable GL_TEXTURE_2D
	state_texenabled=True
End Function

Function DisableTex()
	If Not state_texenabled Return
	glDisable GL_TEXTURE_2D
	state_texenabled=False
End Function

Function Pow2Size:Int( n:Int )
	Local t:Int=1
	While t<n
		t:*2
	Wend
	Return t
End Function

Global dead_texs:TDynamicArray = New TDynamicArray(32),dead_tex_seq:Int

Extern
	Function bbAtomicAdd:Int( target:Int Ptr,value:Int )="int bbAtomicAdd( int *,int )!"
End Extern

'Enqueues a texture for deletion, to prevent release textures on wrong thread.
Function DeleteTex( name:Int,seq:Int )
	If seq<>dead_tex_seq Return

	dead_texs.AddLast(name)
End Function

Function CreateTex:Int( width:Int,height:Int,flags:Int,pixmap:TPixmap )
	If pixmap.dds_fmt<>0 Return pixmap.tex_name ' if dds texture already exists
	
	'alloc new tex
	Local name:Int
	glGenTextures 1,Varptr name
	
	'flush dead texs
	If dead_tex_seq=GraphicsSeq
		Local n:Int = dead_texs.RemoveLast()
		While n <> $FFFFFFFF
			glDeleteTextures 1, Varptr n
			n = dead_texs.RemoveLast()
		Wend
	EndIf

	dead_tex_seq=GraphicsSeq

	'bind new tex
	BindTex name
	
	'set texture parameters
	glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE
	glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE
	
	If flags & FILTEREDIMAGE
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
		If flags & MIPMAPPEDIMAGE
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR
		Else
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
		EndIf
	Else
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST
		If flags & MIPMAPPEDIMAGE
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_NEAREST
		Else
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST
		EndIf
	EndIf

	Local mip_level:Int

	Repeat
		glTexImage2D GL_TEXTURE_2D,mip_level,GL_RGBA8,width,height,0,GL_RGBA,GL_UNSIGNED_BYTE,Null
		If Not (flags & MIPMAPPEDIMAGE) Exit
		If width=1 And height=1 Exit
		If width>1 width:/2
		If height>1 height:/2
		mip_level:+1
	Forever

	Return name
End Function

Function UploadTex( pixmap:TPixmap,flags:Int )
	Local mip_level:Int
	If pixmap.dds_fmt<>0 Return ' if dds texture already exists
	Repeat
		glPixelStorei GL_UNPACK_ROW_LENGTH,pixmap.pitch/BytesPerPixel[pixmap.format]
		glTexSubImage2D GL_TEXTURE_2D,mip_level,0,0,pixmap.width,pixmap.height,GL_RGBA,GL_UNSIGNED_BYTE,pixmap.pixels
		If Not (flags & MIPMAPPEDIMAGE) Exit
		If pixmap.width>1 And pixmap.height>1
			pixmap=ResizePixmap( pixmap,pixmap.width/2,pixmap.height/2 )
		Else If pixmap.width>1
			pixmap=ResizePixmap( pixmap,pixmap.width/2,pixmap.height )
		Else If pixmap.height>1
			pixmap=ResizePixmap( pixmap,pixmap.width,pixmap.height/2 )
		Else
			Exit
		EndIf
		mip_level:+1
	Forever
	glPixelStorei GL_UNPACK_ROW_LENGTH,0
End Function

Function AdjustTexSize( width:Int Var,height:Int Var )
	'calc texture size
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

Type TDynamicArray

	Private
	
	Field data:Int Ptr
	Field size:Size_T
	Field capacity:Size_T
	
	Field guard:TMutex
	
	Public
	
	Method New(initialCapacity:Int = 8)
		capacity = initialCapacity
		data = malloc_(Size_T(initialCapacity * 4))
		guard = CreateMutex()
	End Method

	Method AddLast(value:Int)
		guard.Lock()
		If size = capacity Then
			capacity :* 2
			Local d:Byte Ptr = realloc_(data, capacity * 4)
			If Not d Then
				Throw "Failed to allocate more memory"
			End If
			data = d
		End If
		
		data[size] = value
		size :+ 1
		guard.Unlock()
	End Method
	
	Method RemoveLast:Int()
		guard.Lock()
		Local v:Int
		
		If size > 0 Then
			size :- 1
			v = data[size]
		Else
			v = $FFFFFFFF
		End If
		
		guard.Unlock()
		
		Return v
	End Method

	Method Delete()
		free_(data)
		CloseMutex(guard)
	End Method
	
End Type




Global glewIsInit:Int

Type TGLRenderImageContext Extends TRenderImageContext
	Field _gc:TGLGraphics
	Field _backbuffer:Int
	Field _width:Int
	Field _height:Int
	Field _renderimages:TList
	
	Field _matrix:Float[16]

	Method Delete()
		Destroy()
	EndMethod

	Method Destroy()
		_gc = Null
		If _renderimages
			For Local ri:TGLRenderImage = EachIn _renderimages
				ri.DestroyRenderImage()
			Next
		EndIf
	EndMethod

	Method Create:TGLRenderimageContext(gc:TGraphics, driver:TGraphicsDriver)
		If Not glewIsInit
			glewInit()
			glewIsInit = True
		EndIf

		_renderimages = New TList
		_gc = TGLGraphics(gc)
		_width = GraphicsWidth()
		_height = GraphicsHeight()

		' get the backbuffer - usually 0
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, Varptr _backbuffer)
		glGetFloatv(GL_PROJECTION_MATRIX, _matrix)
		
		Return Self
	EndMethod

	Method GraphicsContext:TGraphics()
		Return _gc
	EndMethod

	Method CreateRenderImage:TRenderImage(width:Int, height:Int, UseImageFiltering:Int)
		Local renderimage:TGLRenderImage = New TGLRenderImage.CreateRenderImage(width, height)
		renderimage.Init(UseImageFiltering, Null)
		Return  renderimage
	EndMethod
	
	Method CreateRenderImageFromPixmap:TRenderImage(pixmap:TPixmap, UseImageFiltering:Int)
		Local renderimage:TGLRenderImage = New TGLRenderImage.CreateRenderImage(pixmap.width, pixmap.height)
		renderimage.Init(UseImageFiltering, pixmap)
		Return  renderimage
	EndMethod
	
	Method DestroyRenderImage(renderImage:TRenderImage)
		renderImage.DestroyRenderImage()
		_renderImages.Remove(renderImage)
	EndMethod

	Method SetRenderImage(renderimage:TRenderimage)
		If Not renderimage
			glBindFramebuffer(GL_FRAMEBUFFER,_backbuffer)
		
			glMatrixMode(GL_PROJECTION)
			glLoadMatrixf(_matrix)
			
			glViewport(0,0,_width,_height)
		Else
			renderimage.SetRenderImage()
		EndIf
	EndMethod
	
	Method CreatePixmapFromRenderImage:TPixmap(renderImage:TRenderImage)
		Return TGLRenderImage(renderImage).ToPixmap()
	EndMethod
End Type


Type TGLRenderImageFrame Extends TGLImageFrame
	Field _fbo:Int
	
	Method Delete()
		DeleteFramebuffer
	EndMethod
	
	Method DeleteFramebuffer()
		If _fbo
			glDeleteFramebuffers(1, Varptr _fbo)
			_fbo = -1 '???
		EndIf
	EndMethod
	
	Method Clear(r:Int=0, g:Int=0, b:Int=0, a:Float=0.0)
		'backup current state
		Local prevC:Float[4]
		Local prevFBO:Int
		Local prevTexture:Int
		glGetFloatv(GL_COLOR_CLEAR_VALUE, prevC)		
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, Varptr prevFBO)
		glGetIntegerv(GL_TEXTURE_BINDING_2D,Varptr prevTexture)

		'set render target active
		glBindTexture(GL_TEXTURE_2D, name)
		glBindFramebuffer(GL_FRAMEBUFFER, _fbo)
		'clear content
		glClearColor(r/255.0, g/255.0, b/255.0, a)
		glClear(GL_COLOR_BUFFER_BIT)

		'restore last previous state
		glClearColor(prevC[0], prevC[1], prevC[2], prevC[3])
		glBindTexture(GL_TEXTURE_2D, prevTexture)
		glBindFramebuffer(GL_FRAMEBUFFER, prevFBO)
	End Method

	Method CreateRenderTarget:TGLRenderImageFrame(width:Int, height:Int, UseImageFiltering:Int, pixmap:TPixmap)
		If pixmap pixmap = ConvertPixmap(pixmap, PF_RGBA)
		
		glDisable(GL_SCISSOR_TEST)

		glGenTextures(1, Varptr name)
		glBindTexture(GL_TEXTURE_2D, name)
		If pixmap
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixmap.pixels)
		Else
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, Null)
		EndIf

		If UseImageFiltering
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
		Else
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST
		EndIf
		
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE
		glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE
		
		glGenFramebuffers(1,Varptr _fbo)
		glBindFramebuffer GL_FRAMEBUFFER,_fbo

		glBindTexture GL_TEXTURE_2D,name
		glFramebufferTexture2D GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,name,0

		If Not pixmap
			Clear()
			' set and clear to a default colour
			'glClearColor 0, 0, 0, 0
			'glClear(GL_COLOR_BUFFER_BIT)
		EndIf

		uscale = 1.0 / width
		vscale = 1.0 / height

		Return Self
	EndMethod
	
	Method DestroyRenderTarget()
		DeleteFramebuffer()
	EndMethod
	
	Method ToPixmap:TPixmap(width:Int, height:Int)
		Local prevTexture:Int
		
		glGetIntegerv(GL_TEXTURE_BINDING_2D,Varptr prevTexture)
		glBindTexture(GL_TEXTURE_2D,name)

		Local pixmap:TPixmap = CreatePixmap(width, height, PF_RGBA8888)		
		glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixmap.pixels)
		
		glBindTexture(GL_TEXTURE_2D,prevTexture)
				
		Return pixmap
	EndMethod
EndType

Type TGLRenderImage Extends TRenderImage
	Field _matrix:Float[16]

	Method CreateRenderImage:TGLRenderImage(width:Int, height:Int)
		Self.width = width		' TImage.width
		Self.height = height	' TImage.height

		_matrix = [	2.0/width, 0.0, 0.0, 0.0,..
					0.0, 2.0/height, 0.0, 0.0,..
					0.0, 0.0, 1.0, 0.0,..
					-1-(1.0/width), -1-(1.0/height), 1.0, 1.0 ]

		Return Self
	EndMethod
	
	Method DestroyRenderImage()
		TGLRenderImageFrame(frames[0]).DestroyRenderTarget()
	EndMethod
	
	Method Init(UseImageFiltering:Int, pixmap:TPixmap)
		Local prevFBO:Int
		Local prevTexture:Int
		Local prevScissorTest:Int

		glGetIntegerv(GL_FRAMEBUFFER_BINDING, Varptr prevFBO)
		glGetIntegerv(GL_TEXTURE_BINDING_2D,Varptr prevTexture)
		glGetIntegerv(GL_SCISSOR_TEST, Varptr prevScissorTest)
		
		frames = New TGLRenderImageFrame[1]
		frames[0] = New TGLRenderImageFrame.CreateRenderTarget(width, height, UseImageFiltering, pixmap)
		
		If prevScissorTest glEnable(GL_SCISSOR_TEST)
		glBindTexture GL_TEXTURE_2D,prevTexture
		glBindFramebuffer GL_FRAMEBUFFER,prevFBO
	EndMethod
	
	Method Clear(r:Int=0, g:Int=0, b:Int=0, a:Float=0.0)
		If frames[0] Then TGLRenderImageFrame(frames[0]).Clear(r, g, b, a)
	End Method

	Method Frame:TImageFrame(index:Int=0)
		Return frames[0]
	EndMethod
	
	Method SetRenderImage()
		glBindFrameBuffer(GL_FRAMEBUFFER, TGLRenderImageFrame(frames[0])._fbo)

		glMatrixMode(GL_PROJECTION)
		glLoadMatrixf(_matrix)
	
		glViewport 0,0,width,height 
	EndMethod
	
	Method ToPixmap:TPixmap()
		Return TGLRenderImageFrame(frames[0]).ToPixmap(width, height)
	EndMethod
	
	Method SetViewport(x:Int, y:Int, width:Int, height:Int)
		If x = 0 And y = 0 And width = Self.width And height = Self.height
			glDisable GL_SCISSOR_TEST
		Else
			glEnable GL_SCISSOR_TEST
			glScissor x, y, width, height
		EndIf
	EndMethod
EndType




Public

Type TGLImageFrame Extends TImageFrame

	Field u0#,v0#,u1#,v1#,uscale#,vscale#

	Field name:Int,seq:Int
	
	Method New()
		seq=GraphicsSeq
	End Method
	
	Method Delete()
		If Not seq Return
		DeleteTex name,seq
		seq=0
	End Method
	
	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# ) Override
		Assert seq=GraphicsSeq Else "Image does not exist"

		Local u0#=sx * uscale
		Local v0#=sy * vscale
		Local u1#=(sx+sw) * uscale
		Local v1#=(sy+sh) * vscale
		
		EnableTex name
		glBegin GL_QUADS
		glTexCoord2f u0,v0
		glVertex2f x0*ix+y0*iy+tx,x0*jx+y0*jy+ty
		glTexCoord2f u1,v0
		glVertex2f x1*ix+y0*iy+tx,x1*jx+y0*jy+ty
		glTexCoord2f u1,v1
		glVertex2f x1*ix+y1*iy+tx,x1*jx+y1*jy+ty
		glTexCoord2f u0,v1
		glVertex2f x0*ix+y1*iy+tx,x0*jx+y1*jy+ty
		glEnd
	End Method
	
	Function CreateFromPixmap:TGLImageFrame( src:TPixmap,flags:Int )
		'determine tex size
		Local tex_w:Int=src.width
		Local tex_h:Int=src.height
		AdjustTexSize tex_w,tex_h
		
		'make sure pixmap fits texture
		Local width:Int=Min( src.width,tex_w )
		Local height:Int=Min( src.height,tex_h )
		If src.width<>width Or src.height<>height src=ResizePixmap( src,width,height )

		'create texture pixmap
		Local tex:TPixmap=src
		
		'"smear" right/bottom edges if necessary
		If width<tex_w Or height<tex_h
			tex=TPixmap.Create( tex_w,tex_h,PF_RGBA8888 )
			tex.Paste src,0,0
			If width<tex_w
				tex.Paste src.Window( width-1,0,1,height ),width,0
			EndIf
			If height<tex_h
				tex.Paste src.Window( 0,height-1,width,1 ),0,height
				If width<tex_w 
					tex.Paste src.Window( width-1,height-1,1,1 ),width,height
				EndIf
			EndIf
		Else
			If tex.dds_fmt=0 ' not dds
				If tex.format<>PF_RGBA8888 tex=tex.Convert( PF_RGBA8888 )
			EndIf
		EndIf
		
		'create tex
		Local name:Int=CreateTex( tex_w,tex_h,flags,tex )
		
		'upload it
		UploadTex tex,flags

		'done!
		Local frame:TGLImageFrame=New TGLImageFrame
		frame.name=name
		frame.uscale=1.0/tex_w
		frame.vscale=1.0/tex_h
		frame.u1=width * frame.uscale
		frame.v1=height * frame.vscale
		Return frame

	End Function

End Type

Type TGLMax2DDriver Extends TMax2DDriver

	Method Create:TGLMax2DDriver()
		If Not GLGraphicsDriver() Return Null
		
		Return Self
	End Method

	'graphics driver overrides
	Method GraphicsModes:TGraphicsMode[]() Override
		Return GLGraphicsDriver().GraphicsModes()
	End Method
	
	Method AttachGraphics:TMax2DGraphics( widget:Byte Ptr,flags:Long ) Override
		Local g:TGLGraphics=GLGraphicsDriver().AttachGraphics( widget,flags )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method CreateGraphics:TMax2DGraphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int ) Override
		Local g:TGLGraphics=GLGraphicsDriver().CreateGraphics( width,height,depth,hertz,flags,x,y )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method SetGraphics( g:TGraphics ) Override
		If Not g
			TMax2DGraphics.ClearCurrent
			GLGraphicsDriver().SetGraphics Null
			Return
		EndIf
	
		Local t:TMax2DGraphics=TMax2DGraphics(g)
		Assert t And TGLGraphics( t._graphics )

		GLGraphicsDriver().SetGraphics t._graphics

		ResetGLContext t
		
		t.MakeCurrent
	End Method
	
	Method ResetGLContext( g:TGraphics )
		Local gw:Int,gh:Int,gd:Int,gr:Int,gf:Long,gx:Int,gy:Int
		g.GetSettings gw,gh,gd,gr,gf,gx,gy
		
		state_blend=0
		state_boundtex=0
		state_texenabled=0
		glDisable GL_TEXTURE_2D
		glMatrixMode GL_PROJECTION
		glLoadIdentity
		glOrtho 0,gw,gh,0,-1,1
		glMatrixMode GL_MODELVIEW
		glLoadIdentity
		glViewport 0,0,gw,gh
	End Method
	
	Method Flip:Int( sync:Int ) Override
		GLGraphicsDriver().Flip sync
	End Method
	
	Method ToString$() Override
		Return "OpenGL"
	End Method

	Method CreateRenderImageContext:Object(g:TGraphics) Override
		Return new TGLRenderImageContext.Create(g, self)
	End Method
	
	Method CreateFrameFromPixmap:TGLImageFrame( pixmap:TPixmap,flags:Int ) Override
		Return TGLImageFrame.CreateFromPixmap( pixmap,flags )
	End Method

	Method SetBlend( blend:Int ) Override
		If blend=state_blend Return
		state_blend=blend
		Select blend
		Case MASKBLEND
			glDisable GL_BLEND
			glEnable GL_ALPHA_TEST
			glAlphaFunc GL_GEQUAL,.5
		Case SOLIDBLEND
			glDisable GL_BLEND
			glDisable GL_ALPHA_TEST
		Case ALPHABLEND
			glEnable GL_BLEND
			glBlendFunc GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA
			glDisable GL_ALPHA_TEST
		Case LIGHTBLEND
			glEnable GL_BLEND
			glBlendFunc GL_SRC_ALPHA,GL_ONE
			glDisable GL_ALPHA_TEST
		Case SHADEBLEND
			glEnable GL_BLEND
			glBlendFunc GL_DST_COLOR,GL_ZERO
			glDisable GL_ALPHA_TEST
		Default
			glDisable GL_BLEND
			glDisable GL_ALPHA_TEST
		End Select
	End Method

	Method SetAlpha( alpha# ) Override
		If alpha>1.0 alpha=1.0
		If alpha<0.0 alpha=0.0
		color4ub[3]=alpha*255
		glColor4ubv color4ub
	End Method

	Method SetLineWidth( width# ) Override
		glLineWidth width
	End Method
	
	Method SetColor( red:Int,green:Int,blue:Int ) Override
		color4ub[0]=Min(Max(red,0),255)
		color4ub[1]=Min(Max(green,0),255)
		color4ub[2]=Min(Max(blue,0),255)
		glColor4ubv color4ub
	End Method

	Method SetColor( color:SColor8 ) Override
		color4ub[0]=color.r
		color4ub[1]=color.g
		color4ub[2]=color.b
		glColor4ubv color4ub
	End Method

	Method SetClsColor( red:Int,green:Int,blue:Int ) Override
		red=Min(Max(red,0),255)
		green=Min(Max(green,0),255)
		blue=Min(Max(blue,0),255)
		glClearColor red/255.0,green/255.0,blue/255.0,1.0
	End Method

	Method SetClsColor( color:SColor8 ) Override
		glClearColor color.r/255.0,color.g/255.0,color.b/255.0,1.0
	End Method
	
	Method SetViewport( x:Int,y:Int,w:Int,h:Int ) Override
		If x=0 And y=0 And w=GraphicsWidth() And h=GraphicsHeight()
			glDisable GL_SCISSOR_TEST
		Else
			glEnable GL_SCISSOR_TEST
			glScissor x,GraphicsHeight()-y-h,w,h
		EndIf
	End Method

	Method SetTransform( xx#,xy#,yx#,yy# ) Override
		ix=xx
		iy=xy
		jx=yx
		jy=yy
	End Method

	Method Cls() Override
		glClear GL_COLOR_BUFFER_BIT
	End Method

	Method Plot( x#,y# ) Override
		DisableTex
		glBegin GL_POINTS
		glVertex2f x+.5,y+.5
		glEnd
	End Method

	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# ) Override
		DisableTex
		glBegin GL_LINES
		glVertex2f x0*ix+y0*iy+tx+.5,x0*jx+y0*jy+ty+.5
		glVertex2f x1*ix+y1*iy+tx+.5,x1*jx+y1*jy+ty+.5
		glEnd
	End Method

	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# ) Override
		DisableTex
		glBegin GL_QUADS
		glVertex2f x0*ix+y0*iy+tx,x0*jx+y0*jy+ty
		glVertex2f x1*ix+y0*iy+tx,x1*jx+y0*jy+ty
		glVertex2f x1*ix+y1*iy+tx,x1*jx+y1*jy+ty
		glVertex2f x0*ix+y1*iy+tx,x0*jx+y1*jy+ty
		glEnd
	End Method
	
	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# ) Override
	
		Local xr#=(x1-x0)*.5
		Local yr#=(y1-y0)*.5
		Local segs:Int=Abs(xr)+Abs(yr)
		
		segs=Max(segs,12)&~3

		x0:+xr
		y0:+yr
		
		DisableTex
		glBegin GL_POLYGON
		For Local i:Int=0 Until segs
			Local th#=i*360#/segs
			Local x#=x0+Cos(th)*xr
			Local y#=y0-Sin(th)*yr
			glVertex2f x*ix+y*iy+tx,x*jx+y*jy+ty
		Next
		glEnd
		
	End Method
	
	Method DrawPoly( xy#[],handle_x#,handle_y#,origin_x#,origin_y# ) Override
		If xy.length<6 Or (xy.length&1) Return
		
		DisableTex
		glBegin GL_POLYGON
		For Local i:Int=0 Until Len xy Step 2
			Local x#=xy[i+0]+handle_x
			Local y#=xy[i+1]+handle_y
			glVertex2f x*ix+y*iy+origin_x,x*jx+y*jy+origin_y
		Next
		glEnd
	End Method
		
	Method DrawPixmap( p:TPixmap,x:Int,y:Int ) Override
		Local blend:Int=state_blend
		DisableTex
		SetBlend SOLIDBLEND
	
		Local t:TPixmap=p
		If t.format<>PF_RGBA8888 t=ConvertPixmap( t,PF_RGBA8888 )

		glPixelZoom 1,-1
		glRasterPos2i 0,0
		glBitmap 0,0,0,0,x,-y,Null
		glPixelStorei GL_UNPACK_ROW_LENGTH, t.pitch Shr 2
		glDrawPixels t.width,t.height,GL_RGBA,GL_UNSIGNED_BYTE,t.pixels
		glPixelStorei GL_UNPACK_ROW_LENGTH,0
		glPixelZoom 1,1
		
		SetBlend blend
	End Method

	Method GrabPixmap:TPixmap( x:Int,y:Int,w:Int,h:Int ) Override
		Local blend:Int=state_blend
		SetBlend SOLIDBLEND
		Local p:TPixmap=CreatePixmap( w,h,PF_RGBA8888 )
		glReadPixels x,GraphicsHeight()-h-y,w,h,GL_RGBA,GL_UNSIGNED_BYTE,p.pixels
		p=YFlipPixmap( p )
		SetBlend blend
		Return p
	End Method
	
	Method SetResolution( width#,height# ) Override
		glMatrixMode GL_PROJECTION
		glLoadIdentity
		glOrtho 0,width,height,0,-1,1
		glMatrixMode GL_MODELVIEW
	End Method
	
End Type

Rem
bbdoc: Get OpenGL Max2D Driver
about:
The returned driver can be used with #SetGraphicsDriver to enable OpenGL Max2D 
rendering.
End Rem
Function GLMax2DDriver:TGLMax2DDriver()
	Global _done:Int
	If Not _done
		_driver=New TGLMax2DDriver.Create()
		_done=True
	EndIf
	Return _driver
End Function

Local driver:TGLMax2DDriver=GLMax2DDriver()
If driver SetGraphicsDriver driver

?
