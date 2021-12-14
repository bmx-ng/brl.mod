
SuperStrict

Rem
bbdoc: Graphics/Max2D
End Rem
Module BRL.Max2D

ModuleInfo "Version: 1.23"
ModuleInfo "Author: Mark Sibly, Simon Armstrong"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.23"
ModuleInfo "History: Changed to SuperStrict"
ModuleInfo "History: Extended flags to Long"
ModuleInfo "History: 1.22 Release"
ModuleInfo "History: fixed ResetCollision not resetting recycled collision quads"
ModuleInfo "History: 1.21 Release"
ModuleInfo "History: makecurrent now does validate before initial cls"
ModuleInfo "History: 1.20 Release"
ModuleInfo "History: Fixed TImageFont.Draw so it uses float translation"
ModuleInfo "History: 1.19 Release"
ModuleInfo "History: Fixed collision bug with non alpha/masked images"
ModuleInfo "History: 1.18 Release"
ModuleInfo "History: Add Flip Hook and polledinput"
ModuleInfo "History: 1.17 Release"
ModuleInfo "History: Added MIPMAPPEDIMAGE to smooth fonts"
ModuleInfo "History: Fixed ImageFont TImage.Load parameters in wrong order!"
ModuleInfo "History: 1.16 Release"
ModuleInfo "History: Improved ImageFont unicode support"
ModuleInfo "History: 1.15 Release"
ModuleInfo "History: Added OnEnd EndGraphics"
ModuleInfo "History: 1.14 Release"
ModuleInfo "History: CreateImage/LockImage now always returns RGBA8888 pixmap"
ModuleInfo "History: Fixed multiple Graphics calls crashing due to using Flip before DetectSync"
ModuleInfo "History: 1.13 Release"
ModuleInfo "History: LoadImageFont generates filteredimage images only for smoothfont fonts"
ModuleInfo "History: 1.12 Release"
ModuleInfo "History: Added MIPMAPPEDIMAGE flag"
ModuleInfo "History: 1.11 Release"
ModuleInfo "History: Fixed Garbage at graphics startup"
ModuleInfo "History: 1.10 Release"
ModuleInfo "History: Fixed LockImage bug"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Integrated with new graphics system"
ModuleInfo "History: ImageFrames now lazily evaluated"
ModuleInfo "History: Fixed GetMaskColor"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Collision system optimized"
ModuleInfo "History: Graphics now does an EndGraphics first"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added GetLineWidth#()"
ModuleInfo "History: Added GetClsColor( red Var,green Var,blue Var )"
ModuleInfo "History: Fixed Object reference bug in Collision system"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed AnimImage collisions"
ModuleInfo "History: Fixed ImagesCollide/ImagesCollide2 parameter types"

Import BRL.PolledInput
Import BRL.LinkedList
Import BRL.Hook

Import "image.bmx"
Import "renderimage.bmx"
Import "driver.bmx"
Import "imagefont.bmx"

Private

Global gc:TMax2DGraphics

Function UpdateTransform()
	Local s#=Sin(gc.tform_rot)
	Local c#=Cos(gc.tform_rot)
	gc.tform_ix= c*gc.tform_scale_x
	gc.tform_iy=-s*gc.tform_scale_y
	gc.tform_jx= s*gc.tform_scale_x
	gc.tform_jy= c*gc.tform_scale_y
	_max2dDriver.SetTransform gc.tform_ix,gc.tform_iy,gc.tform_jx,gc.tform_jy
	SetCollisions2DTransform gc.tform_ix,gc.tform_iy,gc.tform_jx,gc.tform_jy
End Function

Public

Type TMax2DGraphics Extends TGraphics

	'Field color_red,color_green,color_blue
	Field color:SColor8
	Field color_alpha#
	'Field clscolor_red,clscolor_green,clscolor_blue
	Field clscolor:SColor8
	Field line_width#
	Field tform_rot#,tform_scale_x#,tform_scale_y#
	Field tform_ix#,tform_iy#,tform_jx#,tform_jy#
	Field viewport_x:Int,viewport_y:Int,viewport_w:Int,viewport_h:Int
	Field origin_x#,origin_y#
	Field handle_x#,handle_y#
	Field image_font:TImageFont
	Field blend_mode:Int
	Field vres_width#,vres_height#
	Field vres_mousexscale#,vres_mouseyscale#

	Field g_width:Int,g_height:Int

	Global default_font:TImageFont
	Global mask_red:Int,mask_green:Int,mask_blue:Int
	Global auto_midhandle:Int
	Global auto_imageflags:Int=MASKEDIMAGE|FILTEREDIMAGE

	Field _graphics:TGraphics,_driver:TMax2DDriver,_setup:Int
	Field _ric:TRenderImageContext
	
	Method Driver:TMax2DDriver() Override
		Return _driver
	End Method
	
	Method GetSettings( width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var, x:Int Var, y:Int Var ) Override
		Local w:Int,h:Int,d:Int,r:Int,f:Long,xp:Int,yp:Int
		_graphics.GetSettings w,h,d,r,f,xp,yp
		width=w
		height=h
		depth=d
		hertz=r
		flags=f
		x=-1
		y=-1
	End Method
	
	Method Close() Override
		If Not _graphics Return
		_graphics.Close
		_graphics=Null
		_driver=Null
	End Method
	
	Method Validate()
		Local w:Int,h:Int,d:Int,r:Int,f:Long,xp:Int,yp:Int
		_graphics.GetSettings w,h,d,r,f,xp,yp
		If w<>g_width Or h<>g_height
			g_width=w
			g_height=h
			vres_width=w
			vres_height=h						
			vres_mousexscale=1
			vres_mouseyscale=1
		EndIf
		SetVirtualResolution vres_width,vres_height
		SetBlend blend_mode
		SetColor color
		SetAlpha color_alpha
		SetClsColor clscolor
		SetLineWidth line_width
		SetRotation tform_rot
		SetScale tform_scale_x,tform_scale_y
		SetViewport viewport_x,viewport_y,viewport_w,viewport_h
		SetOrigin origin_x,origin_y
		SetHandle -handle_x,-handle_y
		SetImageFont image_font
	End Method
	
	Method MakeCurrent()
		gc=Self
		_max2dDriver=TMax2DDriver( Driver() )
		Assert _max2dDriver
		Validate
		If _setup Return
		Cls
		Flip 0
		Cls
		Flip 0
		_setup=True	
	End Method
	
	Function ClearCurrent()
		gc=Null
		_max2dDriver=Null
	End Function
	
	Function Current:TMax2DGraphics()
		Return gc
	End Function
	
	Function Create:TMax2DGraphics( g:TGraphics,d:TMax2DDriver )
		Local gw:Int,gh:Int,gd:Int,gr:Int,gf:Long,gx:Int,gy:Int
		g.GetSettings gw,gh,gd,gr,gf,gx,gy
		
		If Not default_font default_font=TImageFont.CreateDefault()

		Local t:TMax2DGraphics=New TMax2DGraphics
		
		t.g_width=gw
		t.g_height=gh
		t.blend_mode=MASKBLEND
		t.color = New SColor8(255, 255, 255)
		t.color_alpha=1
		t.clscolor = New SColor8(0, 0, 0)
		t.line_width=1
		t.tform_rot=0
		t.tform_scale_x=1
		t.tform_scale_y=1
		t.tform_ix=1
		t.tform_iy=0
		t.tform_jx=1
		t.tform_jy=0
		t.viewport_x=0
		t.viewport_y=0
		t.viewport_w=gw
		t.viewport_h=gh
		t.origin_x=0
		t.origin_y=0
		t.handle_x=0
		t.handle_y=0
		t.image_font=default_font
		t.vres_width=gw
		t.vres_height=gh						
		t.vres_mousexscale=1
		t.vres_mouseyscale=1

		t._graphics=g
		t._driver=d
		t._setup=False

		Return t
	End Function
	
	Method Resize(width:Int, height:Int) Override
		_graphics.Resize(width, height)
	End Method
	
	Method Position(x:Int, y:Int) Override
		_graphics.Position(x, y)
	End Method


	Method CreateRenderImage:TRenderImage(width:Int, height:Int, UseLinearFlitering:Int = True, max2DGraphics:TGraphics = Null)
		If Not max2DGraphics Then max2DGraphics = self
		Local max2D:TMax2DGraphics = TMax2DGraphics(max2DGraphics)
		If Not max2D Then Return Null 'only supporting Max2D graphics
		
		If _ric And _ric.GraphicsContext() <> max2D._graphics
			_ric.Destroy()
			_ric = Null
		EndIf
		
		If Not _ric	
			_ric = TRenderImageContext(max2D._driver.CreateRenderImageContext(max2D._graphics))
		EndIf
		
		'sanity check
		?debug
		Assert _ric <> Null, "The code for the current TGraphics instance doesn't exist yet for rendering to a texture, feel free to write one."
		?

		Return _ric.CreateRenderImage(width, height, UseLinearFlitering)
	End Method

	
	Method DestroyRenderImage(renderImage:TRenderImage)
		' sanity check
		?debug
		Assert _ric <> Null, "No TRenderImage instances have been created"
		?

		_ric.DestroyRenderImage(renderImage)
	End Method


	Method SetRenderImage(renderimage:TRenderImage)
		' sanity check
		?debug
		Assert _ric <> Null, "No TRenderImage instances have been created"
		?

		_ric.SetRenderImage(renderimage)
	End Method


	Method CreatePixmapFromRenderImage:TPixmap(renderimage:TRenderImage)
		' sanity check
		?debug
		Assert _ric <> Null, "No TRenderImage instances have been created"
		?

		Return _ric.CreatePixmapFromRenderImage(renderimage)
	End Method


	Method SetRenderImageViewport(renderimage:TRenderimage, x:Int, y:Int, width:Int, height:Int)
		' sanity check
		?debug
		Assert _ric <> Null, "No TRenderImage instances have been created"
		?

		renderimage.SetViewport(x, y, width, height)
	End Method


	Method ClearRenderImage(renderimage:TRenderimage, r:Int=0, g:Int=0, b:Int=0, a:Float=0.0)
		' sanity check
		?debug
		Assert _ric <> Null, "No TRenderImage instances have been created"
		?

		renderimage.Clear(r,g,b,a)
	End Method


	Method CreateRenderImageFromPixmap:TRenderImage(Pixmap:TPixmap, UseLinearFlitering:Int = True, max2DGraphics:TGraphics = Null)
		If Not max2DGraphics then max2DGraphics = self
		Local max2d:TMax2DGraphics = TMax2DGraphics(max2DGraphics)
		If Not max2d Then Return Null ' only supports Max2D
	
		If _ric And _ric.GraphicsContext() <> max2d._graphics
			_ric.Destroy()
			_ric = Null
		EndIf
		
		If Not _ric 
			_ric = TRenderImageContext(max2D._driver.CreateRenderImageContext(max2D._graphics))
		EndIf
		
		'sanity check
		?debug
		Assert _ric <> Null, "The code for the current TGraphics instance doesn't exist yet for rendering to a texture, feel free to write one."
		Assert Pixmap <> Null, "Invalid pixmap"
		Assert Pixmap.Width <> 0 And Pixmap.Height <> 0, "Invalid pixmap"
		?

		Return _ric.CreateRenderImageFromPixmap(Pixmap, UseLinearFlitering)
	End Method
End Type

Rem
bbdoc: Clear graphics buffer
about:
Clears the graphics buffer to the current cls color as determined by #SetClsColor.
End Rem
Function Cls()
	_max2dDriver.Cls
End Function

Rem
bbdoc: Set current #Cls color
about:
The @red, @green and @blue parameters should be in the range of 0 to 255.

The default cls color is black.
End Rem
Function SetClsColor( red:Int,green:Int,blue:Int )
	gc.clscolor = New SColor8(red, green, blue)
	_max2dDriver.SetClsColor red,green,blue
End Function

Function SetClsColor( color:SColor8 )
	gc.clscolor = color
	_max2dDriver.SetClsColor color
End Function

Rem
bbdoc: Get red, green and blue component of current cls color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
End Rem
Function GetClsColor( red:Int Var,green:Int Var,blue:Int Var )
	red=gc.clscolor.r
	green=gc.clscolor.g
	blue=gc.clscolor.b
End Function

Rem
bbdoc: Plot a pixel
about:
Sets the color of a single pixel on the back buffer to the current drawing color
defined with the #SetColor command. Other commands that affect the operation of
#Plot include #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function Plot( x#,y# )
	_max2dDriver.Plot x+gc.origin_x,y+gc.origin_y
End Function

Rem
bbdoc: Draw a rectangle
about:
Sets the color of a rectangular area of pixels using the current drawing color
defined with the #SetColor command.

Other commands that affect the operation of #DrawRect include #SetHandle, #SetScale,
#SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawRect( x#,y#,width#,height# )
	_max2dDriver.DrawRect..
	gc.handle_x,gc.handle_y,..
	gc.handle_x+width,gc.handle_y+height,..
	x+gc.origin_x,y+gc.origin_y
End Function

Rem
bbdoc: Draw a line
about:
#DrawLine draws a line from @x, @y to @x2, @y2 with the current drawing color.

BlitzMax commands that affect the drawing of lines include #SetLineWidth, #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
The optional @draw_last_pixel parameter can be used to control whether the last pixel of the line is drawn or not.
Not drawing the last pixel can be useful if you are using certain blending modes.
End Rem 
Function DrawLine( x#,y#,x2#,y2#,draw_last_pixel:Int=True )
	_max2dDriver.DrawLine..
	gc.handle_x,gc.handle_y,..
	gc.handle_x+x2-x,gc.handle_y+y2-y,..
	x+gc.origin_x,y+gc.origin_y
	If Not draw_last_pixel Return
	Local px#=gc.handle_x+x2-x,py#=gc.handle_y+y2-y
	_max2dDriver.Plot..
	px*gc.tform_ix+py*gc.tform_iy+x+gc.origin_x,px*gc.tform_jx+py*gc.tform_jy+y+gc.origin_y
End Function

Rem
bbdoc: Draw an oval
about:
#DrawOval draws an oval that fits in the rectangular area defined by @x, @y, @width 
and @height parameters.

BlitzMax commands that affect the drawing of ovals include #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawOval( x#,y#,width#,height# )
	_max2dDriver.DrawOval..
	gc.handle_x,gc.handle_y,..
	gc.handle_x+width,gc.handle_y+height,..
	x+gc.origin_x,y+gc.origin_y
End Function

Rem
bbdoc: Draw a polygon
about:
#DrawPoly draws a polygon with corners defined by an array of x#,y# coordinate pairs.

BlitzMax commands that affect the drawing of polygons include #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawPoly( xy#[] )
	_max2dDriver.DrawPoly xy,..
	gc.handle_x,gc.handle_y,..
	gc.origin_x,gc.origin_y
End Function

Rem
bbdoc: Draw text
about:
#DrawText prints strings at position @x,@y of the graphics display using
the current image font specified by the #SetImageFont command.

Other commands that affect #DrawText include #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.

It is recomended that the blend mode be set to ALPHABLEND using the #SetBlend
command for non jagged antialiased text. Text that will be drawn at a smaller
size using the #SetScale command should use fonts loaded with the SMOOTHFONT
style to benefit from mip-mapped filtering, see #LoadImageFont for more information.
End Rem
Function DrawText( t$,x#,y# )
	gc.image_font.Draw t,..
	x+gc.origin_x+gc.handle_x*gc.tform_ix+gc.handle_y*gc.tform_iy,..
	y+gc.origin_y+gc.handle_x*gc.tform_jx+gc.handle_y*gc.tform_jy,..
	gc.tform_ix,gc.tform_iy,gc.tform_jx,gc.tform_jy
End Function

Rem
bbdoc: Draw an image to the back buffer
about:
Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND the image is affected by the current alpha value
and images with alpha channels are blended correctly with the background.
End Rem
Function DrawImage( image:TImage,x#,y#,frame:Int=0 )
	Local x0#=-image.handle_x,x1#=x0+image.width
	Local y0#=-image.handle_y,y1#=y0+image.height
	Local iframe:TImageFrame=image.Frame(frame)
	If iframe iframe.Draw x0,y0,x1,y1,x+gc.origin_x,y+gc.origin_y,0,0,image.width,image.height
End Function

Rem
bbdoc: Draw an image to a rectangular area of the back buffer
about:
@x, @y, @w and @h specify the destination rectangle to draw to.

@frame is the image frame to draw.

Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND, then the image is also affected by the current alpha value.
End Rem
Function DrawImageRect( image:TImage,x#,y#,w#,h#,frame:Int=0 )
	Local x0#=-image.handle_x,x1#=x0+w
	Local y0#=-image.handle_y,y1#=y0+h
	Local iframe:TImageFrame=image.Frame(frame)
	If iframe iframe.Draw x0,y0,x1,y1,x+gc.origin_x,y+gc.origin_y,0,0,image.width,image.height
End Function

Rem
bbdoc: Draw a sub rectangle of an image to a rectangular area of the back buffer
about:
@x, @y, @w and @h specify the destination rectangle to draw to.

@sx, @sy, @sw and @sh specify the source rectangle within the image to draw from.

@hx and @hy specify a handle offset within the source rectangle.

@frame is the image frame to draw.

Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND, then the image is also affected by the current alpha value.
End Rem
Function DrawSubImageRect( image:TImage,x#,y#,w#,h#,sx#,sy#,sw#,sh#,hx#=0,hy#=0,frame:Int=0 )
	Local x0#=-hx*w/sw,x1#=x0+w
	Local y0#=-hy*h/sh,y1#=y0+h
	Local iframe:TImageFrame=image.Frame(frame)
	If iframe iframe.Draw x0,y0,x1,y1,x+gc.origin_x,y+gc.origin_y,sx,sy,sw,sh
End Function

Rem
bbdoc: Draw an image in a tiled pattern
about:
#TileImage draws an image in a repeating, tiled pattern, filling the current viewport.
End Rem
Function TileImage( image:TImage,x#=0#,y#=0#,frame:Int=0 )
	Local iframe:TImageFrame=image.Frame(frame)
	If Not iframe Return
	
	_max2dDriver.SetTransform 1,0,0,1

	Local w:Int=image.width
	Local h:Int=image.height
	Local ox:Int=gc.viewport_x-w+1
	Local oy:Int=gc.viewport_y-h+1
	Local px#=x+gc.origin_x-image.handle_x
	Local py#=y+gc.origin_y-image.handle_y
	Local fx#=px-Floor(px)
	Local fy#=py-Floor(py)
	Local tx:Int=Floor(px)-ox
	Local ty:Int=Floor(py)-oy

	If tx>=0 tx=tx Mod w + ox Else tx=w - -tx Mod w + ox
	If ty>=0 ty=ty Mod h + oy Else ty=h - -ty Mod h + oy

	Local vr:Int=gc.viewport_x+gc.viewport_w,vb:Int=gc.viewport_y+gc.viewport_h

	Local iy:Int=ty
	While iy<vb
		Local ix:Int=tx
		While ix<vr
			iframe.Draw 0,0,w,h,ix+fx,iy+fy,0,0,w,h
			ix=ix+w
		Wend
		iy=iy+h
	Wend

	UpdateTransform

End Function

Rem
bbdoc: Set current color
about:
The #SetColor command affects the color of #Plot, #DrawRect, #DrawLine, #DrawText,
#DrawImage and #DrawPoly.

The @red, @green and @blue parameters should be in the range of 0 to 255.
End Rem
Function SetColor( red:Int,green:Int,blue:Int )
	gc.color = New SColor8(red, green, blue)
	_max2dDriver.SetColor red,green,blue
End Function

Function SetColor( color:SColor8 )
	gc.color = color
	_max2dDriver.SetColor color
End Function

Rem
bbdoc: Get red, green and blue component of current color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
End Rem
Function GetColor( red:Int Var,green:Int Var,blue:Int Var )
	red=gc.color.r
	green=gc.color.g
	blue=gc.color.b
End Function

Function GetColor( color:SColor8 Var )
	color = gc.color
End Function

Rem
bbdoc: Set current blend mode
about: 
SetBlend controls how pixels are combined with existing pixels in the back buffer when drawing
commands are used in BlitzMax.

@blend should be one of:

[ @{Blend mode} | @Effect
* MASKBLEND | Pixels are drawn only if their alpha component is greater than .5
* SOLIDBLEND | Pixels overwrite existing backbuffer pixels
* ALPHABLEND | Pixels are alpha blended with existing backbuffer pixels
* LIGHTBLEND | Pixel colors are added to backbuffer pixel colors, giving a 'lighting' effect
* SHADEBLEND | Pixel colors are multiplied with backbuffer pixel colors, giving a 'shading' effect
]
End Rem
Function SetBlend( blend:Int )
	gc.blend_mode=blend
	_max2dDriver.SetBlend blend
End Function

Rem
bbdoc: Get current blend mode
returns: The current blend mode.
About:
See #SetBlend for possible return values.
End Rem
Function GetBlend:Int()
	Return gc.blend_mode
End Function

Rem
bbdoc: Set current alpha level
about:
@alpha should be in the range 0 to 1.

@alpha controls the transparancy level when the ALPHABLEND blend mode is in effect.
The range from 0.0 to 1.0 allows a range of transparancy from completely transparent 
to completely solid.
End Rem
Function SetAlpha( alpha# )
	gc.color_alpha=alpha
	_max2dDriver.SetAlpha alpha
End Function

Rem
bbdoc: Get current alpha setting.
returns: the current alpha value in the range 0..1.0 
End Rem
Function GetAlpha#()
	Return gc.color_alpha
End Function

Rem
bbdoc: Sets pixel width of lines drawn with the #DrawLine command
End Rem
Function SetLineWidth( width# )
	gc.line_width=width
	_max2dDriver.SetLineWidth width
End Function

Rem
bbdoc: Get line width
returns: Current line width, in pixels
End Rem
Function GetLineWidth#()
	Return gc.line_width
End Function

Rem
bbdoc: Set current mask color
about:
The current mask color is used to build an alpha mask when images are loaded or modified.
The @red, @green and @blue parameters should be in the range of 0 to 255.
End Rem
Function SetMaskColor( red:Int,green:Int,blue:Int )
	gc.mask_red=red
	gc.mask_green=green
	gc.mask_blue=blue
End Function

Rem
bbdoc: Get red, green and blue component of current mask color
returns: Red, green and blue values in the range 0..255 
End Rem
Function GetMaskColor( red:Int Var,green:Int Var,blue:Int Var )
	red=gc.mask_red
	green=gc.mask_green
	blue=gc.mask_blue
End Function

Rem
bbdoc: Set virtual graphics resolution
about:
SetResolution allows you to set a 'virtual' resolution independent of the graphics resolution.

This allows you to design an application to work at a fixed resolution, say 640 by 480, and run it
at any graphics resolution.
End Rem
Function SetVirtualResolution( width#,height# )
	gc.vres_width=width
	gc.vres_height=height
	gc.vres_mousexscale=width/GraphicsWidth()
	gc.vres_mouseyscale=height/GraphicsHeight()
	_max2dDriver.SetResolution width,height
End Function

Rem
bbdoc: Get virtual graphics resolution width
End Rem
Function VirtualResolutionWidth#()
	Return gc.vres_width
End Function

Rem
bbdoc: Get virtual graphics resolution height
End Rem
Function VirtualResolutionHeight#()
	Return gc.vres_height
End Function

Rem
bbdoc: Get virtual mouse X coordinate
End Rem
Function VirtualMouseX#()
	Return MouseX() * gc.vres_mousexscale
End Function

Rem
bbdoc: Get virtual mouse Y coordinate
End Rem
Function VirtualMouseY#()
	Return MouseY() * gc.vres_mouseyscale
End Function

Rem
bbdoc: Get virtual mouse X speed
End Rem
Function VirtualMouseXSpeed#()
	Return MouseXSpeed() * gc.vres_mousexscale
End Function

Rem
bbdoc: Get virtual mouse Y speed
End Rem
Function VirtualMouseYSpeed#()
	Return MouseYSpeed() * gc.vres_mouseyscale
End Function

Rem
bbdoc: Move virtual mouse
End Rem
Function MoveVirtualMouse( x#,y# )
	MoveMouse Int(x/gc.vres_mousexscale),Int(y/gc.vres_mouseyscale)
End Function

Rem
bbdoc: Set drawing viewport
about:
The current ViewPort defines an area within the back buffer that all drawing is clipped to. Any
regions of a DrawCommand that fall outside the current ViewPort are not drawn.
End Rem
Function SetViewport( x:Int,y:Int,width:Int,height:Int )
	gc.viewport_x=x
	gc.viewport_y=y
	gc.viewport_w=width
	gc.viewport_h=height
	Local x0:Int=Floor( x / gc.vres_mousexscale )
	Local y0:Int=Floor( y / gc.vres_mouseyscale )
	Local x1:Int=Floor( (x+width) / gc.vres_mousexscale )
	Local y1:Int=Floor( (y+height) / gc.vres_mouseyscale )
	_max2dDriver.SetViewport x0,y0,(x1-x0),(y1-y0)
End Function

Rem
bbdoc: Get dimensions of current Viewport.
returns: The horizontal, vertical, width and height values of the current Viewport in the variables supplied.
End Rem
Function GetViewport( x:Int Var,y:Int Var,width:Int Var,height:Int Var )
	x=gc.viewport_x
	y=gc.viewport_y
	width=gc.viewport_w
	height=gc.viewport_h
End Function

Rem
bbdoc: Set drawing origin
about:
The current Origin is an x,y coordinate added to all drawing x,y coordinates after any rotation or scaling.
End Rem
Function SetOrigin( x#,y# )
	gc.origin_x=x
	gc.origin_y=y
End Function

Rem
bbdoc: Get current origin position.
returns: The horizontal and vertical position of the current origin. 
End Rem
Function GetOrigin( x# Var,y# Var )
	x=gc.origin_x
	y=gc.origin_y
End Function

Rem
bbdoc: Set drawing handle
about:
The drawing handle is a 2D offset subtracted from the x,y location of all 
drawing commands except #DrawImage as Images have their own unique handles.

Unlike #SetOrigin the drawing handle is subtracted before rotation and scale 
are applied providing a 'local' origin.
End Rem
Function SetHandle( x#,y# )
	gc.handle_x=-x
	gc.handle_y=-y
End Function

Rem
bbdoc: Get current drawing handle.
returns: The horizontal and vertical position of the current drawing handle.
End Rem
Function GetHandle( x# Var,y# Var )
	x=-gc.handle_x
	y=-gc.handle_y
End Function

Rem
bbdoc: Set current rotation
about:
@rotation is given in degrees and should be in the range 0 to 360.
End Rem
Function SetRotation( Rotation# )
	gc.tform_rot=Rotation
	UpdateTransform
End Function

Rem
bbdoc: Get current Max2D rotation setting.
returns: The rotation in degrees.
End Rem
Function GetRotation#()
	Return gc.tform_rot
End Function

Rem
bbdoc: Set current scale
about:
@scale_x and @scale_y multiply the width and height of drawing
commands where 0.5 will half the size of the drawing and 2.0 is equivalent 
to doubling the size.
End Rem
Function SetScale( scale_x#,scale_y# )
	gc.tform_scale_x=scale_x
	gc.tform_scale_y=scale_y
	UpdateTransform
End Function

Rem
bbdoc: Get current Max2D scale settings.
returns: The current x and y scale values in the variables supplied. 
End Rem
Function GetScale( scale_x# Var,scale_y# Var )
	scale_x=gc.tform_scale_x
	scale_y=gc.tform_scale_y
End Function

Rem
bbdoc: Set current rotation and scale
about:
SetTransform is a shortcut for setting both the rotation and
scale parameters in Max2D with a single function call.
End Rem
Function SetTransform( Rotation#=0,scale_x#=1,scale_y#=1 )
	gc.tform_rot=Rotation
	gc.tform_scale_x=scale_x
	gc.tform_scale_y=scale_y
	UpdateTransform
End Function

Rem
bbdoc: Make the mouse pointer visible
End Rem
Rem
Function ShowMouse()
	_max2dDriver.SetMouseVisible True
End Function
End Rem

Rem
bbdoc: Make the mouse pointer invisible
End Rem
Rem
Function HideMouse()
	_max2dDriver.SetMouseVisible False
End Function
End Rem

Rem
bbdoc: Load an image font
returns: An image font object
about:
@style can be a combination of BOLDFONT, ITALICFONT and SMOOTHFONT
flags. Use the SMOOTHFONT flag for improved filtering if the font is to be rotated or
scaled.
End Rem
Function LoadImageFont:TImageFont( url:Object,size:Int,style:Int=SMOOTHFONT )
	Return TImageFont.Load( url,size,style )
End Function

Rem
bbdoc: Set current image font
about:
In order to #DrawText in fonts other than the default system font use the #SetImageFont 
command with a font handle returned by the #LoadImageFont command.

Use &{SetImageFont Null} to select the default, built-in font.
End Rem
Function SetImageFont( font:TImageFont )
	If Not font font=gc.default_font
	gc.image_font=font
End Function

Rem
bbdoc: Get current image font.
returns: The current image font.
End Rem
Function GetImageFont:TImageFont()
	Return gc.image_font
End Function

Rem
bbdoc: Get width of text
returns: the width, in pixels, of @text based on the current image font.
about:
This command is useful for calculating horizontal alignment of text when using 
the #DrawText command.
End Rem
Function TextWidth:Int( Text$ )
	Local width:Int=0
	For Local n:Int=0 Until Text.length
		Local i:Int=gc.image_font.CharToGlyph( Text[n] )
		If i<0 Continue
		width:+gc.image_font.LoadGlyph(i).Advance()
	Next
	Return width
End Function

Rem
bbdoc: Get height of text
returns: the height, in pixels, of @text based on the current image font.
about:
This command is useful for calculating vertical alignment of text when using 
the #DrawText command.
End Rem
Function TextHeight:Int( Text$ )
	Return gc.image_font.Height()
	Rem
	Local height=0
	For Local n=0 Until text.length
		Local c=text[n]-image_font.BaseChar()
		If c<0 Or c>=image_font.CountGlyphs() Continue
		Local x,y,w,h
		image_font.Glyph(c).GetRect( x,y,w,h )
		height=Max(height,h)
	Next
	Return height
	End Rem
End Function

Rem
bbdoc: Load an image
returns: A new image object
about:
@url can be either a string or an existing pixmap.

@flags can be 0, -1 or any combination of:

[ @{Flags value} | @{Effect}

* MASKEDIMAGE | The image is masked with the current mask color.

* FILTEREDIMAGE | The image is smoothed when scaled up to greater than its original
size, when rotated, or when drawn at fractional pixel coordinates.

* MIPMAPPEDIMAGE | The image is smoothed when scaled down to less than its original size.

* DYNAMICIMAGE | The image can be modified using #LockImage or #GrabImage.
]


Note MIPMAPPEDIMAGE images consume extra video memory, so this flag should only be used
when really necessary.

If flags is -1, the auto image flags are used: See #AutoImageFlags.

To combine flags, use the | (boolean OR) operator.
End Rem
Function LoadImage:TImage( url:Object,flags:Int=-1 )
	If flags=-1 flags=gc.auto_imageflags
	Local image:TImage=TImage.Load( url,flags,gc.mask_red,gc.mask_green,gc.mask_blue )
	If Not image Return null
	If gc.auto_midhandle MidHandleImage image
	Return image
End Function

Rem
bbdoc: Load a multi-frame image
returns: An image object
about:
#LoadAnimImage extracts multiple image frames from a single, larger image. @url can be either a string or an
existing pixmap.

See #LoadImage for valid @flags values.
End Rem
Function LoadAnimImage:TImage( url:Object,cell_width:Int,cell_height:Int,first_cell:Int,cell_count:Int,flags:Int=-1 )
	If flags=-1 flags=gc.auto_imageflags
	Local image:TImage=TImage.LoadAnim( url,cell_width,cell_height,first_cell,cell_count,flags,gc.mask_red,gc.mask_green,gc.mask_blue )
	If Not image Return null
	If gc.auto_midhandle MidHandleImage image
	Return image
End Function 

Rem
bbdoc: Set an image's handle to an arbitrary point
about:
An image's handle is subtracted from the coordinates of #DrawImage before
rotation and scale are applied.
End Rem
Function SetImageHandle( image:TImage,x#,y# )
	image.handle_x=x
	image.handle_y=y
End Function

Rem
bbdoc: Enable or disable auto midhandle mode
about:
When auto midhandle mode is enabled, all images are automatically 'midhandled' (see #MidHandleImage)
when they are created. If auto midhandle mode is disabled, images are handled by their top left corner.

AutoMidHandle defaults to False after calling #Graphics.
End Rem
Function AutoMidHandle( enable:Int )
	gc.auto_midhandle=enable
End Function

Rem
bbdoc: Set auto image flags
about:
The auto image flags are used by #LoadImage and #CreateImage when no image 
flags are specified. See #LoadImage for a full list of valid image flags. 
AutoImageFlags defaults to MASKEDIMAGE | FILTEREDIMAGE.
End Rem
Function AutoImageFlags( flags:Int )
	If flags=-1 Return
	gc.auto_imageflags=flags
End Function

Function GetAutoImageFlags:Int()
	Return gc.auto_imageflags
End Function

Rem
bbdoc: Set an image's handle to its center
End Rem
Function MidHandleImage( image:TImage )
	image.handle_x=image.width*.5
	image.handle_y=image.height*.5
End Function

Rem
bbdoc: Get width of an image
returns: The width, in pixels, of @image
End Rem
Function ImageWidth:Int( image:TImage )
	Return image.width
End Function

Rem
bbdoc: Get height of an image
returns: The height, in pixels, of @image
End Rem
Function ImageHeight:Int( image:TImage )
	Return image.height
End Function

Rem
bbdoc: Create an empty image
returns: A new image object
about:
#CreateImage creates an 'empty' image, which should be initialized using either #GrabImage or #LockImage
before being drawn.

Please refer to #LoadImage for valid @flags values. The @flags value is always combined with DYNAMICIMAGE.
End Rem
Function CreateImage:TImage( width:Int,height:Int,frames:Int=1,flags:Int=-1 )
	If flags=-1 flags=gc.auto_imageflags
	Local image:TImage=TImage.Create( width,height,frames,flags|DYNAMICIMAGE,gc.mask_red,gc.mask_green,gc.mask_blue )
	If gc.auto_midhandle MidHandleImage image
	Return image
End Function

Rem
bbdoc: Lock an image for direct access
returns: A pixmap representing the image contents
about:
Locking an image allows you to directly access an image's pixels.

Only images created with the DYNAMICIMAGE flag can be locked.

Locked images must eventually be unlocked with #UnlockImage before they can be drawn.
End Rem
Function LockImage:TPixmap( image:TImage,frame:Int=0,read_lock:Int=True,write_lock:Int=True )
	Return image.Lock( frame,read_lock,write_lock )
End Function

Rem
bbdoc: Unlock an image
about:
Unlocks an image previously locked with #LockImage.
end rem
Function UnlockImage( image:TImage,frame:Int=0 )
End Function

Rem
bbdoc: Grab an image from the back buffer
about:
Copies pixels from the back buffer to an image frame.

Only images created with the DYNAMICIMAGE flag can be grabbed.
End Rem
Function GrabImage( image:TImage,x:Int,y:Int,frame:Int=0 )
	Local pixmap:TPixmap=_max2dDriver.GrabPixmap( x,y,image.width,image.height )
	If image.flags&MASKEDIMAGE 
		pixmap=MaskPixmap( pixmap,gc.mask_red,gc.mask_green,gc.mask_blue )
	EndIf
	image.SetPixmap frame,pixmap
End Function

Rem
bbdoc: Draw pixmap
end rem
Function DrawPixmap( pixmap:TPixmap,x:Int,y:Int )
	_max2dDriver.DrawPixmap pixmap,x,y
End Function

Rem
bbdoc: Grab pixmap
end rem
Function GrabPixmap:TPixmap( x:Int,y:Int,width:Int,height:Int )
	Return _max2dDriver.GrabPixmap( x,y,width,height )
End Function


Rem
bbdoc: Create a new render image
about:
@width, @height specify the dimensions of the render image.

@useLinearFlitering defines the image flag to filter images when scaling.

@max2DGraphics is an optional parameter to pass a custom Max2DGraphics context.

returns: #TRenderImage with the given dimension
End Rem
Function CreateRenderImage:TRenderImage(width:Int, height:Int, useLinearFlitering:Int = True, max2DGraphics:TMax2DGraphics = Null)
	Return gc.CreateRenderImage(width, height, useLinearFlitering, max2DGraphics)
End Function

Rem
bbdoc: Create a render image from a given #TPixmap
about:
@pixmap defines the #TPixmap to create a new #TRenderImage from.

@useLinearFlitering defines the image flag to filter images when scaling.

@max2DGraphics is an optional parameter to pass a custom Max2DGraphics context.

returns: #TRenderImage with the content of the passed #TPixmap
End Rem
Function CreateRenderImageFromPixmap:TRenderImage(pixmap:TPixmap, useLinearFlitering:Int = True, max2DGraphics:TMax2DGraphics = Null)
	Return gc.CreateRenderImageFromPixmap(pixmap, useLinearFlitering, max2DGraphics)
EndFunction

Rem
bbdoc: Destroy a no longer needed render image
End Rem
Function DestroyRenderImage(renderImage:TRenderImage)
	gc.DestroyRenderImage(renderImage)
End Function

Rem
bbdoc: Set a render image as currently active render target
about:
@renderImage defines the render image to use as target. Set to Null to render on the default graphics buffer again.
End Rem
Function SetRenderImage(renderImage:TRenderImage)
	gc.SetRenderImage(renderImage)
End Function

Rem
bbdoc: Clear content of the passed render image
about:
@renderImage defines the render image to clear.

@r, @g, @b define the red, green and blue components of the clear color. Range is 0 - 255.

@a defines the alpha value and is ranged 0.0 to 1.0.
End Rem
Function ClearRenderImage(renderImage:TRenderImage, r:Int=0, g:Int=0, b:Int=0, a:Float=0.0)
	gc.ClearRenderImage(renderImage, r,g,b,a)
End Function

Rem
bbdoc: Create a #TPixmap from a render image
about:
@renderImage defines the render image from where the #TPixmap is to generate

returns: #TPixmap of the render image
End Rem
Function CreatePixmapFromRenderImage:TPixmap(renderImage:TRenderImage)
	Return gc.CreatePixmapFromRenderImage(renderImage)
End Function

Rem
bbdoc: Set the viewport of the given render image
about:
@renderImage defines the render image to set the viewport for

@x, @y, @width, @height define the dimension of the viewport
End Rem
Function SetRenderImageViewport(renderImage:TRenderImage, x:Int, y:Int, width:Int, height:Int)
	gc.SetRenderImageViewport(renderImage, x, y, width, height)
End Function

Rem
bbdoc: Backup the render image (from GPU to RAM)
about:
When a running application is suspended (eg user logs out from the OS or hibernation) 
then Direct3D-graphics loose their context ("D3DERR_DEVICELOST").
To enable restoration an render image needs to "persist" as else after resume the texture
will be blank.
Use this for dynamically created render image content which you do not re-draw each frame.
Also use #RenderImageValid() to check if content needs to be recreated.

@renderImage defines the render image to backup
End Rem
Function PersistRenderImage:Int(renderImage:TRenderImage)
	If renderImage Then Return renderImage.Persist()
	Return False
End Function

Rem
bbdoc: Check if render image content is still valid
about:
When a running application is suspended (eg user logs out from the OS or hibernation) 
then Direct3D-graphics loose their context ("D3DERR_DEVICELOST") and so the textures.
If that happens, the render image is flagged to no longer be valid.

@renderImage defines the render image to backup

returns: False if content the render image needs to be recreated
End Rem
Function RenderImageValid:Int(renderImage:TRenderImage)
	If renderImage Then Return renderImage.Valid()
	Return False
End Function

Rem
bbdoc: Mark a render image (in-)valid
about:
When a running application is suspended (eg user logs out from the OS or hibernation) 
then Direct3D-graphics loose their context ("D3DERR_DEVICELOST") and so the textures.
Once you restored/recreated the content of your render image you can set it
to be valid again.

@renderImage defines the render image to backup

@bool defines the new state of the valid flag (True or False)
End Rem
Function SetRenderImageValid(renderImage:TRenderImage, bool:Int = True)
	If renderImage Then renderImage.SetValid(bool)
End Function

Const COLLISION_LAYER_ALL:Int=0
Const COLLISION_LAYER_1:Int=$0001
Const COLLISION_LAYER_2:Int=$0002
Const COLLISION_LAYER_3:Int=$0004
Const COLLISION_LAYER_4:Int=$0008
Const COLLISION_LAYER_5:Int=$0010
Const COLLISION_LAYER_6:Int=$0020
Const COLLISION_LAYER_7:Int=$0040
Const COLLISION_LAYER_8:Int=$0080
Const COLLISION_LAYER_9:Int=$0100
Const COLLISION_LAYER_10:Int=$0200
Const COLLISION_LAYER_11:Int=$0400
Const COLLISION_LAYER_12:Int=$0800
Const COLLISION_LAYER_13:Int=$1000
Const COLLISION_LAYER_14:Int=$2000
Const COLLISION_LAYER_15:Int=$4000
Const COLLISION_LAYER_16:Int=$8000
Const COLLISION_LAYER_17:Int=$00010000
Const COLLISION_LAYER_18:Int=$00020000
Const COLLISION_LAYER_19:Int=$00040000
Const COLLISION_LAYER_20:Int=$00080000
Const COLLISION_LAYER_21:Int=$00100000
Const COLLISION_LAYER_22:Int=$00200000
Const COLLISION_LAYER_23:Int=$00400000
Const COLLISION_LAYER_24:Int=$00800000
Const COLLISION_LAYER_25:Int=$01000000
Const COLLISION_LAYER_26:Int=$02000000
Const COLLISION_LAYER_27:Int=$04000000
Const COLLISION_LAYER_28:Int=$08000000
Const COLLISION_LAYER_29:Int=$10000000
Const COLLISION_LAYER_30:Int=$20000000
Const COLLISION_LAYER_31:Int=$40000000
Const COLLISION_LAYER_32:Int=$80000000

Rem
bbdoc: Tests if two images collide
returns: True if any pixels of the two images specified at the given location overlap. 
about:
#ImagesCollide uses the current Rotation and Scale factors from the most previous
call to #SetScale and #SetRotation to calculate at a pixel level if the two images collide. 
End Rem
Function ImagesCollide:Int(image1:TImage,x1:Int,y1:Int,frame1:Int,image2:TImage,x2:Int,y2:Int,frame2:Int)
	ResetCollisions COLLISION_LAYER_32
	CollideImage image1,x1,y1,frame1,0,COLLISION_LAYER_32
	If CollideImage(image2,x2,y2,frame2,COLLISION_LAYER_32,0) Return True
End Function

Rem
bbdoc: Tests if two images with arbitrary Rotation and Scales collide
returns: True if any pixels of the two images specified at the given location overlap. 
about:
#ImagesCollide2 uses the specified Rotation and Scale paramteters
to calculate at a pixel level if the two images collide (overlap).
End Rem
Function ImagesCollide2:Int(image1:TImage,x1:Int,y1:Int,frame1:Int,rot1#,scalex1#,scaley1#,image2:TImage,x2:Int,y2:Int,frame2:Int,rot2#,scalex2#,scaley2#)
	Local	_scalex#,_scaley#,_rot#,res:Int
	_rot=GetRotation()
	GetScale _scalex,_scaley
	ResetCollisions COLLISION_LAYER_32
	SetRotation rot1
	SetScale scalex1,scaley1
	CollideImage image1,x1,y1,frame1,0,COLLISION_LAYER_32
	SetRotation rot2
	SetScale scalex2,scaley2
	If CollideImage(image2,x2,y2,frame2,COLLISION_LAYER_32,0) res=True
	SetRotation _rot
	SetScale _scalex,_scaley
	Return res
End Function

Rem
bbdoc: Clears collision layers specified by the value of @mask, mask=0 for all layers. 
about:
The BlitzMax 2D collision system manages 32 layers, the @mask parameter can
be a combination of the following values or the special value COLLISION_LAYER_ALL in order 
to perform collision operations on multiple layers.

Note: COLLISION_LAYER_32 is used by the #ImagesCollide and #ImagesCollide2 commands.

[ @Layer | @{Mask value}
* COLLISION_LAYER_ALL | 0
* COLLISION_LAYER_1 | $0001
* COLLISION_LAYER_2 | $0002
* COLLISION_LAYER_3 | $0004
* COLLISION_LAYER_4 | $0008
* COLLISION_LAYER_5 | $0010
* COLLISION_LAYER_6 | $0020
* COLLISION_LAYER_7 | $0040
* COLLISION_LAYER_8 | $0080
* COLLISION_LAYER_9 | $0100
* COLLISION_LAYER_10 | $0200
* COLLISION_LAYER_11 | $0400
* COLLISION_LAYER_12 | $0800
* COLLISION_LAYER_13 | $1000
* COLLISION_LAYER_14 | $2000
* COLLISION_LAYER_15 | $4000
* COLLISION_LAYER_16 | $8000
]
EndRem
Function ResetCollisions(mask%=0)
	Local	i:Int,q:TQuad
	For i=0 To 31
		If mask=0 Or mask&(1 Shl i)
			q=quadlayer[i]
			If q
				q.mask=Null
				q.id=Null
				While q.link
					q=q.link
					q.mask=Null
					q.id=Null
				Wend
				q.link=freequads				
				q=quadlayer[i]
				freequads=q
				quadlayer[i]=Null
			EndIf
		EndIf
	Next
End Function

Rem 
bbdoc: Pixel accurate collision testing between transformed Images. 
about:
The @collidemask specifies any layers to test for collision with. 

The @writemask specifies which if any collision layers the @image is added to in it's currently transformed state. 

The id specifies an object to be returned to future #CollideImage calls when collisions occur. 
EndRem
Function CollideImage:Object[](image:TImage,x:Int,y:Int,frame:Int,collidemask%,writemask%,id:Object=Null) 
	Local	q:TQuad
	q=CreateQuad(image,frame,x,y,image.width,image.height,id)
	Return CollideQuad(q,collidemask,writemask)
End Function

Rem
bbdoc: Pixel accurate collision testing between image layers 
about:
The @collidemask specifies any layers to test for collision with.

The @writemask specifies which if any collision layers the @image is added to in it's currently transformed state.

The @id specifies an object to be returned to future #CollideImage calls when collisions occur.
EndRem
Function CollideRect:Object[](x:Int,y:Int,w:Int,h:Int,collidemask%,writemask%,id:Object=Null) 
	Local	q:TQuad
	q=CreateQuad(Null,0,x,y,w,h,id)
	Return CollideQuad(q,collidemask,writemask)
End Function

Private

Global	cix#,ciy#,cjx#,cjy#

Function SetCollisions2DTransform(ix#,iy#,jx#,jy#)	'callback from module Blitz2D
	cix=ix
	ciy=iy
	cjx=jx
	cjy=jy
End Function

Global TextureMaps:TPixmap[]
Global LineBuffer:Int[]
Global quadlayer:TQuad[32]
Global freequads:TQuad

Const POLYX:Int=0
Const POLYY:Int=1
Const POLYU:Int=2
Const POLYV:Int=3

Function DotProduct:Int(x0#,y0#,x1#,y1#,x2#,y2#)
	Return (((x2-x1)*(y1-y0))-((x1-x0)*(y2-y1)))
End Function

Function ClockwisePoly(data#[],channels:Int)	'flips order if anticlockwise
	Local	count:Int,clk:Int,i:Int,j:Int
	Local	r0:Int,r1:Int,r2:Int
	Local	t#
	
	count=Len(data)/channels
' clock wise test
	r0=0
	r1=channels
	clk=2
	For i=2 To count-1
		r2=r1+channels
		If DotProduct(data[r0+POLYX],data[r0+POLYY],data[r1+POLYX],data[r1+POLYY],data[r2+POLYX],data[r2+POLYY])>=0 clk:+1	
		r1=r2
	Next
	If clk<count Return
' flip order for anticockwise
	r0=0
	r1=(count-1)*channels
	While r0<r1
		For j=0 To channels-1
			t=data[r0+j]
			data[r0+j]=data[r1+j]
			data[r1+j]=t
		Next
		r0:+channels
		r1:-channels
	Wend
End Function

Type rpoly
	Field	texture:TPixmap
	Field	data#[]
	Field	channels:Int,count:Int,size:Int
	Field	ldat#[],ladd#[]
	Field	rdat#[],radd#[]
	Field	Left:Int,Right:Int,top:Int
	Field	state:Int
End Type

Function RenderPolys:Int(vdata#[][],channels:Int[],textures:TPixmap[],renderspans:Int(polys:TList,count:Int,ypos:Int))
	Local	polys:rpoly[],p:rpoly,pcount:Int
	Local	active:TList
	Local	top:Int,bot:Int
	Local	n:Int,y:Int,h:Int,i:Int,j:Int,res:Int
	Local	data#[]

	bot=$80000000
	top=$7fffffff
	n=Len(vdata)
' create polys an array of poly renderers	
	polys=New rpoly[n]		
	For i=0 Until n
		p=New rpoly
		polys[i]=p
		p.texture=textures[i]
		p.data=vdata[i]
		p.channels=channels[i]
		p.count=Len(p.data)/p.channels
		p.size=p.count*p.channels
		ClockwisePoly(p.data,p.channels)	'flips order if anticlockwise
' find top verticies
		p.Left=0
		j=0
		p.top=$7fffffff
		While j<p.size
			y=p.data[j+POLYY]		'float to int conversion
			If y<p.top p.top=y;p.Left=j
			If y<top top=y
			If y>bot bot=y
			j:+p.channels
		Wend
		p.Right=p.Left
	Next
	active=New TList
	pcount=0
' draw top to bottom
	For y=top To bot-1
' get left gradient
		For p=EachIn polys			
			If p.state=2 Continue 
			If p.state=0 And y<p.top Continue
			data=p.data
			If y>=Int(data[p.Left+POLYY])
				j=p.Left
				i=(p.Left-p.channels)
				If i<0 i:+p.size
				While i<>p.Left
					If Int(data[i+POLYY])>y Exit
					j=i
					i=(i-p.channels)
					If i<0 i:+p.size
				Wend
				h=Int(data[i+POLYY])-Int(data[j+POLYY])
				If i=p.Left Or h<=0
					active.remove p
'					p.remove
					pcount:-1
					p.state=2
					Continue
				EndIf
				p.ldat=data[j..j+p.channels]
				p.ladd=data[i..i+p.channels]				
				For j=0 To p.channels-1
					p.ladd[j]=(p.ladd[j]-p.ldat[j])/h
					p.ldat[j]:+p.ladd[j]*0.5
				Next
				p.Left=i			
				If p.state=0
					p.state=1
					active.AddLast p
					pcount:+1
				EndIf			
			EndIf
' get right gradient
			If y>=Int(data[p.Right+POLYY])
				i=(p.Right+p.channels) Mod p.size
				j=p.Right
				While i<>p.Right
					If Int(data[i+POLYY])>y Exit
					j=i
					i=(i+p.channels)Mod p.size
				Wend
				h=Int(data[i+POLYY])-Int(data[j+POLYY])
				If i=p.Right Or h<=0
					active.remove p
					pcount:-1
					p.state=2
					Continue
				EndIf
				p.rdat=data[j..j+p.channels]
				p.radd=data[i..i+p.channels]
				For j=0 To p.channels-1
					p.radd[j]=(p.radd[j]-p.rdat[j])/h
					p.rdat[j]:+p.radd[j]*0.5
				Next
				p.Right=i
				If p.state=0
					p.state=1
					active.AddLast p
					pcount:+1
				EndIf			
			EndIf
		Next	
' call renderer
		If pcount
			res=renderspans(active,pcount,y)
			If res<0 Return res
		EndIf
' increment spans
		For p=EachIn active
			For j=0 To p.channels-1
				p.ldat[j]:+p.ladd[j]
				p.rdat[j]:+p.radd[j]
			Next
		Next
	Next
	Return res
End Function

Function CollideSpans:Int(polys:TList,count:Int,y:Int)
	Local	p:rpoly
	Local	startx:Int,endx:Int
	Local	x0:Int,x1:Int,w:Int,x:Int
	Local	u#,v#,ui#,vi#
	Local	pix:Int Ptr
	Local	src:TPixmap
	Local	tw:Int,th:Int,tp:Int,argb:Int
	Local	width:Int,skip#
	

	startx=$7fffffff
	endx=$80000000
	If count<2 Return 0
	p=rpoly(polys.ValueAtIndex(0))
	startx=p.ldat[POLYX]
	endx=p.rdat[POLYX]
	p=rpoly(polys.ValueAtIndex(1))
	x0=p.ldat[POLYX]
	x1=p.rdat[POLYX]
	If x0>=endx Return 0
	If x1<=startx Return 0
	If x0>startx startx=x0
	If x1<endx endx=x1
	width=endx-startx
	If width<=0 Return 0
	If width>Len(LineBuffer) LineBuffer=New Int[width]
	MemClear LineBuffer,Size_T(width*4)
	For p=EachIn polys
		src=p.texture
		If src
			x0=p.ldat[POLYX]
			x1=p.rdat[POLYX]
			w=x1-x0
			If w<=0 Continue		
			u=p.ldat[POLYU]
			v=p.ldat[POLYV]
			ui=(p.rdat[POLYU]-u)/w
			vi=(p.rdat[POLYV]-v)/w
			skip=(startx-x0)+0.5
			u=u+ui*skip
			v=v+vi*skip			
			pix=Int Ptr(src.pixels)
			tw=src.width
			th=src.height
			tp=src.pitch/4
			For x=0 Until width
				If u<0.0 u=0.0
				If v<0.0 v=0.0
				If u>1.0 u=1.0
				If v>1.0 v=1.0
?BigEndian
				argb=$00000080 & pix[(Int(v*th))*tp+(Int(u*tw))]
?LittleEndian
				argb=$80000000 & pix[(Int(v*th))*tp+(Int(u*tw))]
?
				If (argb)
					If LineBuffer[x] Return -1
					LineBuffer[x]=argb
				EndIf
				u:+ui
				v:+vi
			Next
		Else
			For x=0 Until width
				If LineBuffer[x] Return -1
				LineBuffer[x]=-1
			Next
		EndIf
	Next
	Return 0
End Function

Type TQuad
	Field	link:TQuad
	Field	id:Object
	Field	mask:TPixmap
	Field	frame:Int
	Field	minx#,miny#,maxx#,maxy#
	Field	xyuv#[16]
		
	Method SetCoords(tx0#,ty0#,tx1#,ty1#,tx2#,ty2#,tx3#,ty3#)
		xyuv[0]=tx0
		xyuv[1]=ty0
		xyuv[2]=0.0
		xyuv[3]=0.0		
		xyuv[4]=tx1
		xyuv[5]=ty1
		xyuv[6]=1.0
		xyuv[7]=0.0				
		xyuv[8]=tx2
		xyuv[9]=ty2
		xyuv[10]=1.0
		xyuv[11]=1.0		
		xyuv[12]=tx3
		xyuv[13]=ty3
		xyuv[14]=0.0
		xyuv[15]=1.0
		minx=Min(Min(Min(tx0,tx1),tx2),tx3)
		miny=Min(Min(Min(ty0,ty1),ty2),ty3)
		maxx=Max(Max(Max(tx0,tx1),tx2),tx3)
		maxy=Max(Max(Max(ty0,ty1),ty2),ty3)
	End Method
End Type

Function QuadsCollide:Int(p:TQuad,q:TQuad)
	If p.maxx<q.minx Or p.maxy<q.miny Or p.minx>q.maxx Or p.miny>q.maxy Return False
	Local	vertlist#[][2]
	Local	textures:TPixmap[2]
	Local	channels:Int[2]	
	vertlist[0]=p.xyuv	
	vertlist[1]=q.xyuv	
	textures[0]=p.mask
	textures[1]=q.mask
	channels[0]=4
	channels[1]=4
	Return RenderPolys(vertlist,channels,textures,CollideSpans)
End Function

Function CreateQuad:TQuad(image:TImage,frame:Int,x#,y#,w#,h#,id:Object)
	Local	x0#,y0#,x1#,y1#,tx#,ty#
	Local	tx0#,ty0#,tx1#,ty1#,tx2#,ty2#,tx3#,ty3#
	Local	minx#,miny#,maxx#,maxy#
	Local	q:TQuad
	Local	pix:TPixmap
	
	If image
		x0=-image.handle_x
		y0=-image.handle_y
	EndIf
	x1=x0+w
	y1=y0+h
	tx=x+gc.origin_x
	ty=y+gc.origin_y
	tx0=x0*cix+y0*ciy+tx
	ty0=x0*cjx+y0*cjy+ty
	tx1=x1*cix+y0*ciy+tx
	ty1=x1*cjx+y0*cjy+ty
	tx2=x1*cix+y1*ciy+tx
	ty2=x1*cjx+y1*cjy+ty
	tx3=x0*cix+y1*ciy+tx
	ty3=x0*cjx+y1*cjy+ty
	If freequads
		q=freequads
		freequads=q.link
		q.link=Null
	Else
		q=New TQuad
	EndIf
	q.id=id
	If image
		pix=image.Lock( frame,True,False )
		If AlphaBitsPerPixel[pix.format] q.mask=pix
	EndIf
	q.setcoords(tx0,ty0,tx1,ty1,tx2,ty2,tx3,ty3)	
	Return q
End Function

Function CollideQuad:Object[](pquad:TQuad,collidemask%,writemask%) 
	Local	result:Object[]
	Local	p:TQuad,q:TQuad
	Local	i:Int,j:Int,count:Int

	p=pquad				'CreateImageQuad(image,frame,x,y)
' check for collisions
	For i=0 To 31
		If collidemask & (1 Shl i)
			q=quadlayer[i]
			While q
				If QuadsCollide(p,q)
					If count=Len(result) result=result[..((count+4)*1.2)]
					result[count]=q.id
					count:+1
				EndIf				
				q=q.link
			Wend		
		EndIf
	Next
' write to layers	
	For i=0 To 31
		If writemask & (1 Shl i)
			If freequads
				q=freequads
				freequads=q.link
			Else
				q=New TQuad
			EndIf
			q.id=p.id;	'TODO:optimize with memcpy?
			q.mask=p.mask;
			q.frame=p.frame
			MemCopy q.xyuv,p.xyuv,64
			q.minx=p.minx;q.miny=p.miny;q.maxx=p.maxx;q.maxy=p.maxy;
			q.link=quadlayer[i]
			quadlayer[i]=q
		EndIf
	Next
' return result
	If count Return result[..count]
End Function
