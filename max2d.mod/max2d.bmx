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
ModuleInfo "History: Added GetLineWidth:Float()"
ModuleInfo "History: Added GetClsColor( red Var,green Var,blue Var )"
ModuleInfo "History: Fixed Object reference bug in Collision system"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed AnimImage collisions"
ModuleInfo "History: Fixed ImagesCollide/ImagesCollide2 parameter types"

Import BRL.PolledInput
Import BRL.LinkedList
Import BRL.Hook

Import "image.bmx"
'Import "renderimage.bmx"
Import "driver.bmx"
Import "imagefont.bmx"

Public

Struct Rect
	Method New (X:Int, Y:Int, width:Int, height:Int)
		Self.X = X
		Self.Y = Y
		Self.width = width
		Self.height = height
	EndMethod
	
	Field X:Int, Y:Int
	Field width:Int, height:Int
EndStruct

Type TMax2DGraphics Extends TGraphics
	Field color:SColor8
	Field color_alpha:Float
	Field clsColor:SColor8
	Field clsColor_alpha:Float
	Field line_width:Float
	Field tform_rot:Float
	Field tform_scale_x:Float
	Field tform_scale_y:Float
	Field tform_ix:Float
	Field tform_iy:Float
	Field tform_jx:Float
	Field tform_jy:Float
	Field viewport_x:Int
	Field viewport_y:Int
	Field viewport_w:Int
	Field viewport_h:Int
	Field origin_x:Float
	Field origin_y:Float
	Field handle_x:Float
	Field handle_y:Float
	Field image_font:TImageFont
	Field blend_mode:Int
	Field vres_width:Float
	Field vres_height:Float
	Field vres_mousexscale:Float
	Field vres_mouseyscale:Float

	Field g_width:Int
	Field g_height:Int

	Global default_font:TImageFont
	Global mask_red:Int
	Global mask_green:Int
	Global mask_blue:Int
	Global auto_midhandle:Int
	Global auto_imageflags:Int = MASKEDIMAGE|FILTEREDIMAGE

	Field _backendGraphics:TGraphics
	Field _initialized:Int
	Field _driver:TMax2DDriver

	'currently active Graphics
	Global _currentGraphics:TMax2DGraphics

	
	Method Driver:TMax2DDriver() Override
		Return _driver
	End Method
	

	Method GetSettings( width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var, x:Int Var, y:Int Var ) Override
		Local w:Int, h:Int, d:Int, r:Int, f:Long, xp:Int, yp:Int
		_backendGraphics.GetSettings(w, h, d, r, f, xp, yp)
		width = w
		height = h
		depth = d
		hertz = r
		flags = f
		x = -1
		y = -1
	End Method
	

	Method Close() Override
		If Not _backendGraphics Then Return
		_backendGraphics.Close()
		_backendGraphics = Null
		_driver = Null
	End Method
	

	Method Validate()
		Local w:Int, h:Int, d:Int, r:Int, f:Long, xp:Int, yp:Int
		_backendGraphics.GetSettings(w, h, d, r, f, xp, yp)
		If w<>g_width Or h<>g_height
			g_width=w
			g_height=h
			vres_width=w
			vres_height=h						
			vres_mousexscale=1
			vres_mouseyscale=1
		EndIf
		SetVirtualResolution(vres_width, vres_height)
		SetBlend(blend_mode)
		SetColor(color, color_alpha)
		SetClsColor(clsColor, 1.0)
		SetLineWidth(line_width)
		SetRotation(tform_rot)
		SetScale(tform_scale_x, tform_scale_y)
		SetViewport(viewport_x, viewport_y, viewport_w, viewport_h)
		SetOrigin(origin_x, origin_y)
		SetHandle(-handle_x, -handle_y)
		SetImageFont(image_font)
	End Method
	

	Method MakeCurrent()
		_currentGraphics = Self
		_max2dDriver = TMax2DDriver( Driver() )
		Assert _max2dDriver
		Validate()
		If _initialized Then Return
		SetRenderImage(Null)
		Cls()
		Flip(0)
		Cls()
		Flip(0)
		_initialized = True
	End Method
	

	Function ClearCurrent()
		_currentGraphics = Null
		_max2dDriver = Null
	End Function
	

	Function Current:TMax2DGraphics()
		Return _currentGraphics
	End Function
	

	Function Create:TMax2DGraphics( backendGraphics:TGraphics, d:TMax2DDriver )
		Local gw:Int,gh:Int,gd:Int,gr:Int,gf:Long,gx:Int,gy:Int
		backendGraphics.GetSettings(gw,gh,gd,gr,gf,gx,gy)
		
		If Not default_font Then default_font = TImageFont.CreateDefault()

		Local t:TMax2DGraphics = New TMax2DGraphics
		
		t.g_width = gw
		t.g_height = gh
		t.blend_mode = MASKBLEND
		t.color = New SColor8(255, 255, 255)
		t.color_alpha = 1.0
		t.clsColor = New SColor8(0, 0, 0)
		t.clsColor_alpha = 1.0
		t.line_width = 1
		t.tform_rot = 0
		t.tform_scale_x = 1
		t.tform_scale_y = 1
		t.tform_ix = 1
		t.tform_iy = 0
		t.tform_jx = 1
		t.tform_jy = 0
		t.viewport_x = 0
		t.viewport_y = 0
		t.viewport_w = gw
		t.viewport_h = gh
		t.origin_x = 0
		t.origin_y = 0
		t.handle_x = 0
		t.handle_y = 0
		t.image_font = default_font
		t.vres_width = gw
		t.vres_height = gh						
		t.vres_mousexscale = 1
		t.vres_mouseyscale = 1

		t._backendGraphics = backendGraphics
		t._driver = d
		t._initialized = False

		Return t
	End Function
	

	Method Resize(width:Int, height:Int) Override
		_backendGraphics.Resize(width, height)
	End Method
	

	Method Position(x:Int, y:Int) Override
		_backendGraphics.Position(x, y)
	End Method
	

	Method SetClsColor(red:Int, green:Int, blue:Int, alpha:Float = 1.0) Final
		SetClsColor(New SColor8(red, green, blue), alpha)
	End Method

	Method SetClsColor(color:SColor8, alpha:Float = 1.0)
		clsColor = color
		clsColor_alpha = alpha
		_max2dDriver.SetClsColor(color, alpha)
	End Method


	Method GetClsColor(red:Int Var, green:Int Var, blue:Int Var)
		red = clsColor.r
		green = clsColor.g
		blue = clsColor.b
	End Method

	Method GetClsColor(red:Int Var, green:Int Var, blue:Int Var, alpha:Float Var)
		red = clsColor.r
		green = clsColor.g
		blue = clsColor.b
		alpha = clsColor_alpha
	End Method

	Method GetClsColor(color:SColor8 Var)
		color = clsColor
	End Method

	Method GetClsColor(color:SColor8 Var, alpha:Float Var)
		color = clsColor
		alpha = clsColor_alpha
	End Method
	

	Method UpdateTransform()
		Local s:Float = Sin(tform_rot)
		Local c:Float = Cos(tform_rot)
		tform_ix = c * tform_scale_x
		tform_iy =-s * tform_scale_y
		tform_jx = s * tform_scale_x
		tform_jy = c * tform_scale_y
		
		_max2dDriver.SetTransform(tform_ix, tform_iy, tform_jx, tform_jy)
		SetCollisions2DTransform(tform_ix, tform_iy, tform_jx, tform_jy)
	End Method


	Method Plot(x:Float, y:Float)
		_max2dDriver.Plot(x + origin_x, y + origin_y)
	End Method
	
	
	Method DrawRect(x:Float, y:Float, width:Float, height:Float)
		_max2dDriver.DrawRect(handle_x, handle_y, ..
		                      handle_x + width, handle_y + height, ..
		                      x + origin_x, y + origin_y)
	End Method


	Method DrawLine(x:Float, y:Float, x2:Float, y2:Float, draw_last_pixel:Int = True)
		_max2dDriver.DrawLine(handle_x, handle_y, ..
		                      handle_x + x2 - x, handle_y + y2 - y, ..
		                      x + origin_x, y + origin_y)
		If Not draw_last_pixel Then Return

		Local px:Float = handle_x + x2 - x
		Local py:Float = handle_y + y2 - y
		_max2dDriver.Plot(px * tform_ix + py * tform_iy + x + origin_x, ..
		                  px * tform_jx + py * tform_jy + y + origin_y)
	End Method


	Method DrawOval(x:Float, y:Float, width:Float, height:Float)
		_max2dDriver.DrawOval(handle_x, handle_y, ..
		                      handle_x + width, handle_y + height, ..
		                      x + origin_x, y + origin_y)
	End Method


	Method DrawPoly(xy:Float[], indices:Int[] = Null)
		_max2dDriver.DrawPoly(xy, handle_x, handle_y, origin_x, origin_y, indices)
	End Method


	Method DrawText(t:String, x:Float, y:Float)
		image_font.Draw(t, ..
		                x + origin_x + handle_x * tform_ix + handle_y * tform_iy, ..
		                y + origin_y + handle_x * tform_jx + handle_y * tform_jy, ..
		                tform_ix, tform_iy, tform_jx, tform_jy)
	End Method


	Method DrawImage(image:TImage, x:Float, y:Float, frame:Int = 0)
		If Not image Then Return
		Local x0:Float = -image.handle_x
		Local x1:Float = x0 + image.width
		Local y0:Float = -image.handle_y
		Local y1:Float = y0 + image.height
		Local iframe:TImageFrame = image.Frame(frame)
		If iframe
			iframe.Draw(x0, y0, x1, y1, x + origin_x, y + origin_y, 0, 0, image.width,image.height)
		EndIf
	End Method


	Method DrawImageRect(image:TImage, x:Float, y:Float, width:Float, height:Float, frame:Int = 0)
		If Not image Then Return
		Local x0:Float = -image.handle_x
		Local x1:Float = x0 + width
		Local y0:Float = -image.handle_y
		Local y1:Float = y0 + height
		Local iframe:TImageFrame = image.Frame(frame)
		If iframe
			iframe.Draw(x0, y0, x1, y1, x + origin_x, y + origin_y, 0, 0, image.width, image.height)
		EndIf
	End Method


	Method DrawSubImageRect(image:TImage, x:Float, y:Float, width:Float, height:Float, sx:Float, sy:Float, swidth:Float,sheight:Float, hx:Float = 0, hy:Float = 0, frame:Int = 0)
		If Not image Then Return
		Local x0:Float = -hx * width / swidth
		Local x1:Float = x0 + width
		Local y0:Float = -hy * height / sheight
		Local y1:Float = y0 + height
		Local iframe:TImageFrame = image.Frame(frame)
		If iframe
			iframe.Draw(x0, y0, x1, y1, x + origin_x, y + origin_y, sx, sy, swidth, sheight)
		EndIf
	End Method


	Method TileImage(image:TImage, x:Float = 0.0, y:Float = 0.0, frame:Int = 0)
		If Not image Then Return

		Local iframe:TImageFrame = image.Frame(frame)
		If Not iframe Then Return
	
		_max2dDriver.SetTransform(1, 0, 0, 1)

		Local w:Int = image.width
		Local h:Int = image.height
		Local ox:Int = viewport_x - w + 1
		Local oy:Int = viewport_y - h + 1
		Local px:Float = x + origin_x - image.handle_x
		Local py:Float = y + origin_y - image.handle_y
		Local fx:Float = px - Floor(px)
		Local fy:Float = py - Floor(py)
		Local tx:Int = Floor(px) - ox
		Local ty:Int = Floor(py) - oy

		If tx >= 0 
			tx = tx Mod w + ox 
		Else
			tx = w - -tx Mod w + ox
		EndIf
		If ty >= 0
			ty = ty Mod h + oy
		Else
			ty = h - -ty Mod h + oy
		EndIf

		Local vr:Int = viewport_x + viewport_w
		Local vb:Int = viewport_y + viewport_h

		Local iy:Int = ty
		While iy < vb
			Local ix:Int = tx
			While ix < vr
				iframe.Draw(0, 0, w, h, ix + fx, iy + fy, 0, 0, w, h)
				ix = ix + w
			Wend
			iy = iy + h
		Wend

		UpdateTransform()
	End Method


	Method SetColor( red:Int, green:Int, blue:Int )
		color = New SColor8(red, green, blue)
		_max2dDriver.SetColor(red,green,blue)
	End Method

	Method SetColor( color:SColor8 )
		Self.color = color
		_max2dDriver.SetColor(color)
	End Method

	Method SetColor( red:Int, green:Int, blue:Int, alpha:Float )
		color = New SColor8(red, green, blue)
		_max2dDriver.SetColor(red,green,blue)

		color_alpha = alpha
		_max2dDriver.SetAlpha(alpha)
	End Method

	Method SetColor( color:SColor8, alpha:Float )
		Self.color = color
		_max2dDriver.SetColor(color)
		
		self.color_alpha = alpha
		_max2dDriver.SetAlpha(alpha)
	End Method


	Method GetColor( red:Int Var,green:Int Var,blue:Int Var )
		red = color.r
		green = color.g
		blue = color.b
	End Method

	Method GetColor( red:Int Var,green:Int Var,blue:Int Var,alpha:Float Var )
		red = color.r
		green = color.g
		blue = color.b
		alpha = color_alpha
	End Method

	Method GetColor( color:SColor8 Var )
		color = Self.color
	End Method

	Method GetColor( color:SColor8 Var,alpha:Float Var )
		color = Self.color
		alpha = Self.color_alpha
	End Method


	Method SetBlend( blend:Int )
		blend_mode = blend
		_max2dDriver.SetBlend(blend)
	End Method


	Method GetBlend:Int()
		Return blend_mode
	End Method


	Method SetAlpha( alpha:Float )
		color_alpha = alpha
		_max2dDriver.SetAlpha(alpha)
	End Method


	Method GetAlpha:Float()
		Return color_alpha
	End Method


	Method SetLineWidth( width:Float )
		line_width = width

		_max2dDriver.SetLineWidth(width)
	End Method


	Method GetLineWidth:Float()
		Return line_width
	End Method


	Function SetMaskColor( red:Int, green:Int, blue:Int )
		mask_red = red
		mask_green = green
		mask_blue = blue
	End Function


	Function GetMaskColor( red:Int Var, green:Int Var, blue:Int Var )
		red = mask_red
		green = mask_green
		blue = mask_blue
	End Function


	Method SetVirtualResolution( width:Float, height:Float )
		vres_width = width
		vres_height = height
		vres_mousexscale = width / GraphicsWidth()
		vres_mouseyscale = height / GraphicsHeight()
		_max2dDriver.SetResolution(width, height)
	End Method


	Method VirtualResolutionWidth:Float()
		Return vres_width
	End Method


	Method VirtualResolutionHeight:Float()
		Return vres_height
	End Method


	Method VirtualMouseX:Float()
		Return MouseX() * vres_mousexscale
	End Method


	Method VirtualMouseY:Float()
		Return MouseY() * vres_mouseyscale
	End Method


	Method VirtualMouseXSpeed:Float()
		Return MouseXSpeed() * vres_mousexscale
	End Method


	Method VirtualMouseYSpeed:Float()
		Return MouseYSpeed() * vres_mouseyscale
	End Method


	Method MoveVirtualMouse( x:Float, y:Float )
		MoveMouse(Int(x / vres_mousexscale), Int(y / vres_mouseyscale))
	End Method


	Method SetViewport(x:Int, y:Int, width:Int, height:Int)
		viewport_x = x
		viewport_y = y
		viewport_w = width
		viewport_h = height

		Local x0:Int=Floor( x / vres_mousexscale )
		Local y0:Int=Floor( y / vres_mouseyscale )
		Local x1:Int=Floor( (x + width) / vres_mousexscale )
		Local y1:Int=Floor( (y + height) / vres_mouseyscale )
		
		_max2dDriver.SetViewport(x0, y0, (x1-x0), (y1-y0))
	End Method


	Method GetViewport( x:Int Var, y:Int Var, width:Int Var, height:Int Var )
		x = viewport_x
		y = viewport_y
		width = viewport_w
		height = viewport_h
	End Method


	Method SetOrigin( x:Float, y:Float )
		origin_x = x
		origin_y = y
	End Method


	Method GetOrigin( x:Float Var, y:Float Var )
		x = origin_x
		y = origin_y
	End Method


	Method SetHandle( x:Float, y:Float )
		handle_x = -x
		handle_y = -y
	End Method


	Method GetHandle( x:Float Var,y:Float Var )
		x = -handle_x
		y = -handle_y
	End Method


	Method SetRotation( Rotation:Float )
		tform_rot = Rotation
		
		UpdateTransform()
	End Method


	Method GetRotation:Float()
		Return tform_rot
	End Method


	Method SetScale( scale_x:Float, scale_y:Float )
		tform_scale_x = scale_x
		tform_scale_y = scale_y
		
		UpdateTransform()
	End Method


	Method GetScale( scale_x:Float Var,scale_y:Float Var )
		scale_x = tform_scale_x
		scale_y = tform_scale_y
	End Method


	Method SetTransform( Rotation:Float=0, scale_x:Float = 1, scale_y:Float = 1 )
		tform_rot = Rotation
		tform_scale_x = scale_x
		tform_scale_y = scale_y

		UpdateTransform()
	End Method


	Method SetImageFont( font:TImageFont )
		'Null = use default
		If Not font Then font = default_font
		image_font = font
	End Method


	Method GetImageFont:TImageFont()
		Return image_font
	End Method


	Method TextWidth:Int( text:String )
		Local width:Int = 0
		For Local n:Int = 0 Until text.length
			Local i:Int = image_font.CharToGlyph( text[n] )
			If i < 0 Continue
			width :+ image_font.LoadGlyph(i).Advance()
		Next
		Return width
	End Method


	Method TextHeight:Int( text:String )
		Return image_font.height()
		Rem
		Local height:Int = 0
		For Local n:Int = 0 Until text.length
			Local c:Int = text[n] - image_font.BaseChar()
			If c < 0 Or c >= image_font.CountGlyphs() Then Continue
			Local x:Int, y:Int, w:Int, h:Int
			image_font.Glyph(c).GetRect(x, y, w, h)
			height = Max(height, h)
		Next
		Return height
		End Rem
	End Method


	Function AutoMidHandle( enable:Int )
		auto_midhandle = enable
	End Function


	Function AutoImageFlags( flags:Int )
		auto_imageflags = flags
	End Function


	Function GetAutoImageFlags:Int()
		Return auto_imageflags
	End Function


	Function LoadImage:TImage( url:Object, flags:Int = -1 )
		If flags = -1 Then flags = auto_imageflags
		Local image:TImage = TImage.Load(url, flags, mask_red, mask_green, mask_blue)
		If Not image Then Return Null
		
		If auto_midhandle Then MidHandleImage(image)
		Return image
	End Function


	Function LoadAnimImage:TImage( url:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int = -1 )
		If flags = -1 Then flags = auto_imageflags
		Local image:TImage = TImage.LoadAnim(url, cell_width, cell_height, first_cell, cell_count, flags, mask_red, mask_green, mask_blue)
		If Not image Then Return Null

		If auto_midhandle Then MidHandleImage(image)
		Return image
	End Function


	Function CreateImage:TImage( width:Int, height:Int, frames:Int = 1, flags:Int = -1 )
		If flags = -1 Then flags = auto_imageflags
		Local image:TImage = TImage.Create(width, height, frames, flags | DYNAMICIMAGE, mask_red, mask_green, mask_blue)
	
		If auto_midhandle Then MidHandleImage(image)
		Return image
	End Function


	Method GrabImage( image:TImage, x:Int, y:Int, frame:Int = 0 )
		Local pixmap:TPixmap = _max2dDriver.GrabPixmap(x, y, image.width, image.height)

		If image.flags & MASKEDIMAGE 
			pixmap = MaskPixmap(pixmap, mask_red, mask_green, mask_blue)
		EndIf
		image.SetPixmap(frame,pixmap)
	End Method

	Method SetBackBuffer()
		SetRenderImage(Null)
	EndMethod
	
	
	Method CanUpdateRenderImages:Int()
		Return _max2ddriver.CanUpdateRenderImages()
	End Method

	
	Function CreateRenderImage:TRenderImage(width:UInt, height:UInt, flags:Int=-1)
		If flags = -1 Then flags = auto_imageflags
		Local image:TRenderImage = TRenderImage.Create(width, height, flags, mask_red, mask_green, mask_blue)
		
		If image And auto_midhandle Then MidHandleImage(image)
		Return image
	End Function


	Function CreateRenderImage:TRenderImage(fromImage:TImage, frame:Int = 0)
		If Not fromImage Then Return Null

		Local pixmap:TPixmap = LockImage(fromImage, frame)
		Return CreateRenderImage(pixmap, fromImage.flags)
	End Function


	Function CreateRenderImage:TRenderImage(fromPixmap:TPixmap, flags:Int = -1)
		If Not fromPixmap Then Return Null

		If flags = -1 Then flags = auto_imageflags
		
		' backup old target
		Local currentTarget:TImageFrame = GetRenderImageFrame()

		' set newly created as target
		Local image:TRenderImage = TRenderImage.Create(fromPixmap.width, fromPixmap.height, flags, mask_red, mask_green, mask_blue)
		If Not image
			Return Null
		EndIf
		
		Local frame:TImageFrame = image.Frame(0)
		If Not frame
			Return Null
		EndIf

		' if render image activation fails, content would be incorrect
		' and thus it is better to return null than drawing on the wrong
		' canvas and returning an image without the desired content.
		If Not _max2ddriver.SetRenderImageFrame(frame)
			Return Null
		EndIf

		' render content into it
		' (it by default ignores scale, rotation, setColor...)
		_max2dDriver.DrawPixmap(fromPixmap, 0,0)
	
		' set old target as current again
		_max2ddriver.SetRenderImageFrame(currentTarget)

		If auto_midhandle Then MidHandleImage(image)
		Return image
	End Function	


	Method SetRenderImage:Int(renderImage:TRenderImage, frame:Int = 0)
		If Not renderImage
			_max2ddriver.SetRenderImageFrame(Null)
			_max2ddriver.SetRenderImageContainer(Null)
			Return True
		Else
			Local imageFrame:TImageFrame = renderImage.Frame(frame)
			If imageFrame
				If _max2ddriver.SetRenderImageFrame(imageFrame)
					_max2ddriver.SetRenderImageContainer(renderImage)
					Return True
				EndIf
			EndIf
		EndIf
		Return False
	End Method


	Method SetRenderImageFrame:Int(renderImageFrame:TImageFrame)
		If Not RenderImageFrame
			_max2ddriver.SetRenderImageFrame(Null)
		Else
			If Not _max2ddriver.SetRenderImageFrame(renderImageFrame)
				Return False
			EndIf
		EndIf
		' while it might belong to a TRenderImage we do not know here
		_max2ddriver.SetRenderImageContainer(Null)
		Return True
	EndMethod


	Method GetRenderImage:TRenderImage()
		' when currently rendering to the backbuffer, this is Null!
		Return TRenderImage(_max2ddriver.GetRenderImageContainer())
	EndMethod


	Method GetRenderImageFrame:TImageFrame()
		Return _max2ddriver.GetRenderImageFrame()
	End Method
End Type

Rem
bbdoc: Clear current graphics buffer
about:
Clears the current graphics buffer to the current cls color as determined by #SetClsColor.
End Rem
Function Cls()
	_max2dDriver.Cls()
End Function


Rem
bbdoc: Set current #Cls color
about:
The @red, @green and @blue parameters should be in the range of 0 to 255.

The default cls color is black.
End Rem
Function SetClsColor(red:Int, green:Int, blue:Int, alpha:Float)
	TMax2DGraphics.Current().SetClsColor(red, green, blue, alpha)
End Function


Rem
bbdoc: Set current #Cls color
about:
The @red, @green and @blue parameters should be in the range of 0 to 255.

The default cls color is black.
End Rem
Function SetClsColor(red:Int, green:Int, blue:Int)
	TMax2DGraphics.Current().SetClsColor(red, green, blue)
End Function

Rem
bbdoc: Set current #Cls color
about:
The default cls color is black.
End Rem
Function SetClsColor(color:SColor8)
	TMax2DGraphics.Current().SetClsColor(color)
End Function


Rem
bbdoc: Get red, green, blue and alpha component of current cls color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
         Alpha in range 0 - 1.0
End Rem
Function GetClsColor(red:Int Var, green:Int Var, blue:Int Var, alpha:Float)
	TMax2DGraphics.Current().GetClsColor(red, green, blue, alpha)
End Function

Rem
bbdoc: Get red, green and blue component of current cls color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
End Rem
Function GetClsColor(red:Int Var, green:Int Var, blue:Int Var)
	TMax2DGraphics.Current().GetClsColor(red, green, blue)
End Function

Rem
bbdoc: Get red, green and blue component of current cls color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
End Rem
Function GetClsColor(color:SColor8 Var)
	TMax2DGraphics.Current().GetClsColor(color)
End Function


Rem
bbdoc: Get red, green, blue and alpha component of current cls color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
         Alpha in range 0 - 1.0
End Rem
Function GetClsColor(color:SColor8 Var, alpha:Float Var)
	TMax2DGraphics.Current().GetClsColor(color, alpha)
End Function

Rem
bbdoc: Plot a pixel
about:
Sets the color of a single pixel on the back buffer to the current drawing color
defined with the #SetColor command. Other commands that affect the operation of
#Plot include #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function Plot(x:Float, y:Float)
	TMax2DGraphics.Current().Plot(x, y)
End Function

Rem
bbdoc: Plot a pixel
about:
Sets the color of a single pixel on the back buffer to the current drawing color
defined with the #SetColor command. Other commands that affect the operation of
#Plot include #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function Plot(x:Double, y:Double)
	TMax2DGraphics.Current().Plot(Float(x), Float(y))
End Function

Rem
bbdoc: Draw a rectangle
about:
Sets the color of a rectangular area of pixels using the current drawing color
defined with the #SetColor command.

Other commands that affect the operation of #DrawRect include #SetHandle, #SetScale,
#SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawRect(x:Float, y:Float, width:Float, height:Float)
	TMax2DGraphics.Current().DrawRect(x, y, width, height)
End Function

Rem
bbdoc: Draw a rectangle
about:
Sets the color of a rectangular area of pixels using the current drawing color
defined with the #SetColor command.

Other commands that affect the operation of #DrawRect include #SetHandle, #SetScale,
#SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawRect( x:Double,y:Double,width:Double,height:Double )
	DrawRect( Float(x),Float(y),Float(width),Float(height) )
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
Function DrawLine(x:Float, y:Float, x2:Float, y2:Float, draw_last_pixel:Int = True)
	TMax2DGraphics.Current().DrawLine(x, y, x2, y2, draw_last_pixel)
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
Function DrawLine(x:Double, y:Double, x2:Double, y2:Double, draw_last_pixel:Int = True)
	TMax2DGraphics.Current().DrawLine(Float(x), Float(y), Float(x2), Float(y2), draw_last_pixel)
End Function

Rem
bbdoc: Draw an oval
about:
#DrawOval draws an oval that fits in the rectangular area defined by @x, @y, @width 
and @height parameters.

BlitzMax commands that affect the drawing of ovals include #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawOval(x:Float, y:Float, width:Float, height:Float)
	TMax2DGraphics.Current().DrawOval(x, y, width, height)
End Function

Rem
bbdoc: Draw an oval
about:
#DrawOval draws an oval that fits in the rectangular area defined by @x, @y, @width 
and @height parameters.

BlitzMax commands that affect the drawing of ovals include #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawOval(x:Double, y:Double, width:Double, height:Double)
	TMax2DGraphics.Current().DrawOval(Float(x), Float(y), Float(width), Float(height))
End Function

Rem
bbdoc: Draw a polygon
about:
#DrawPoly draws a polygon with corners defined by an array of x#,y# coordinate pairs.

BlitzMax commands that affect the drawing of polygons include #SetColor, #SetHandle, 
#SetScale, #SetRotation, #SetOrigin, #SetViewPort, #SetBlend and #SetAlpha.
End Rem
Function DrawPoly( xy:Float[], indices:Int[] = Null )
	TMax2DGraphics.Current().DrawPoly(xy, indices)
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
Function DrawText(t:String, x:Float, y:Float)
	TMax2DGraphics.Current().DrawText(t, x, y)
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
Function DrawText(t:String, x:Double, y:Double)
	TMax2DGraphics.Current().DrawText(t, Float(x), Float(y))
End Function

Rem
bbdoc: Draw an image to the back buffer
about:
Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND the image is affected by the current alpha value
and images with alpha channels are blended correctly with the background.
End Rem
Function DrawImage(image:TImage, x:Float, y:Float, frame:Int = 0)
	TMax2DGraphics.Current().DrawImage(image, x, y, frame)
End Function

Rem
bbdoc: Draw an image to the back buffer
about:
Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND the image is affected by the current alpha value
and images with alpha channels are blended correctly with the background.
End Rem
Function DrawImage(image:TImage, x:Double, y:Double, frame:Int = 0)
	TMax2DGraphics.Current().DrawImage(image, Float(x), Float(y), frame)
End Function

Rem
bbdoc: Draw an image to a rectangular area of the back buffer
about:
@x, @y, @width and @height specify the destination rectangle to draw to.

@frame is the image frame to draw.

Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND, then the image is also affected by the current alpha value.
End Rem
Function DrawImageRect(image:TImage, x:Float, y:Float, width:Float, height:Float, frame:Int = 0)
	TMax2DGraphics.Current().DrawImageRect(image, x, y, width, height)
End Function

Rem
bbdoc: Draw an image to a rectangular area of the back buffer
about:
@x, @y, @width and @height specify the destination rectangle to draw to.

@frame is the image frame to draw.

Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND, then the image is also affected by the current alpha value.
End Rem
Function DrawImageRect(image:TImage, x:Double, y:Double, width:Double, height:Double, frame:Int = 0)
	TMax2DGraphics.Current().DrawImageRect(image, Float(x), Float(y), Float(width), Float(height))
End Function

Rem
bbdoc: Draw a sub rectangle of an image to a rectangular area of the back buffer
about:
@x, @y, @width and @height specify the destination rectangle to draw to.

@sx, @sy, @swidth and @sheight specify the source rectangle within the image to draw from.

@hx and @hy specify a handle offset within the source rectangle.

@frame is the image frame to draw.

Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND, then the image is also affected by the current alpha value.
End Rem
Function DrawSubImageRect(image:TImage, x:Float, y:Float, width:Float, height:Float, sx:Float, sy:Float, swidth:Float,sheight:Float, hx:Float = 0, hy:Float = 0, frame:Int = 0)
	TMax2DGraphics.Current().DrawSubImageRect(image, x, y, width, height, sx, sy, swidth, sheight, hx, hy, frame)
End Function

Rem
bbdoc: Draw a sub rectangle of an image to a rectangular area of the back buffer
about:
@x, @y, @width and @height specify the destination rectangle to draw to.

@sx, @sy, @swidth and @sheight specify the source rectangle within the image to draw from.

@hx and @hy specify a handle offset within the source rectangle.

@frame is the image frame to draw.

Drawing is affected by the current blend mode, color, scale and rotation.

If the blend mode is ALPHABLEND, then the image is also affected by the current alpha value.
End Rem
Function DrawSubImageRect(image:TImage, x:Double, y:Double, width:Double, height:Double, sx:Double, sy:Double, swidth:Double,sheight:Double, hx:Double = 0, hy:Double = 0, frame:Int = 0)
	TMax2DGraphics.Current().DrawSubImageRect(image, Float(x), Float(y), Float(width), Float(height), Float(sx), Float(sy), Float(swidth), Float(sheight), Float(hx), Float(hy), frame)
End Function

Rem
bbdoc: Draw an image in a tiled pattern
about:
#TileImage draws an image in a repeating, tiled pattern, filling the current viewport.
End Rem
Function TileImage(image:TImage, x:Float = 0.0, y:Float = 0.0, frame:Int = 0)
	TMax2DGraphics.Current().TileImage(image, x, y, frame)
End Function

Rem
bbdoc: Draw an image in a tiled pattern
about:
#TileImage draws an image in a repeating, tiled pattern, filling the current viewport.
End Rem
Function TileImage(image:TImage, x:Double = 0:Double, y:Double = 0:Double, frame:Int = 0)
	TMax2DGraphics.Current().TileImage(image, Float(x), Float(y), frame)
End Function

Rem
bbdoc: Set current color
about:
The #SetColor command affects the color of #Plot, #DrawRect, #DrawLine, #DrawText,
#DrawImage and #DrawPoly.

The @red, @green and @blue parameters should be in the range of 0 to 255.
End Rem
Function SetColor( red:Int,green:Int,blue:Int )
	TMax2DGraphics.Current().SetColor(red, green, blue)
End Function

Rem
bbdoc: Set current color and alpha (transparency) level
about:
The #SetColor command affects the color of #Plot, #DrawRect, #DrawLine, #DrawText,
#DrawImage and #DrawPoly.

The @red, @green and @blue parameters should be in the range of 0 to 255.

@alpha controls the transparancy level when the ALPHABLEND blend mode is in effect.
The range from 0.0 to 1.0 allows a range of transparancy from completely transparent 
to completely solid.
End Rem
Function SetColor( red:Int, green:Int, blue:Int, alpha:Float )
	TMax2DGraphics.Current().SetColor(red, green, blue, alpha)
End Function

Rem
bbdoc: Set current color
about:
The #SetColor command affects the color of #Plot, #DrawRect, #DrawLine, #DrawText,
#DrawImage and #DrawPoly.

@color defines the red, green and blue values.
End Rem
Function SetColor( color:SColor8)
	TMax2DGraphics.Current().SetColor(color)
End Function

Rem
bbdoc: Set current color and alpha (transparency)
about:
The #SetColor command affects the color of #Plot, #DrawRect, #DrawLine, #DrawText,
#DrawImage and #DrawPoly.

@color defines the red, green and blue values.

@alpha controls the transparancy level when the ALPHABLEND blend mode is in effect.
The range from 0.0 to 1.0 allows a range of transparancy from completely transparent 
to completely solid.
End Rem
Function SetColor( color:SColor8, alpha:Float )
	TMax2DGraphics.Current().SetColor(color, alpha)
End Function


Rem
bbdoc: Get red, green and blue component of current color.
returns: Red, green and blue values in the range 0..255 in the variables supplied.
End Rem
Function GetColor( red:Int Var,green:Int Var,blue:Int Var )
	TMax2DGraphics.Current().GetColor(red, green, blue)
End Function

Rem
bbdoc: Get red, green, blue component of current color and the current alpha (transparency) value.
returns: Red, green and blue values in the range 0..255 and alpha (transparency) in the range 0..1.0 in the variables supplied.
End Rem
Function GetColor( red:Int Var, green:Int Var, blue:Int Var, alpha:Float Var )
	TMax2DGraphics.Current().GetColor(red, green, blue, alpha)
End Function

Rem
bbdoc: Get current color encoded as SColor8.
returns: Red, green, blue values in the range 0..255 stored in the supplied SColor8 element.
End Rem
Function GetColor( color:SColor8 Var )
	TMax2DGraphics.Current().GetColor(color)
End Function

Rem
bbdoc: Get current rgb color encoded as SColor8 and current alpha (transparency) value separately.
returns: Red, green, blue values in the range 0..255 in the supplied SColor8 element and separately the alpha (transparency) value in the range 0..1.0.
End Rem
Function GetColor( color:SColor8 Var, alpha:Float Var)
	TMax2DGraphics.Current().GetColor(color, alpha)
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
	TMax2DGraphics.Current().SetBlend(blend)
End Function

Rem
bbdoc: Get current blend mode
returns: The current blend mode.
About:
See #SetBlend for possible return values.
End Rem
Function GetBlend:Int()
	Return TMax2DGraphics.Current().GetBlend()
End Function

Rem
bbdoc: Set current alpha level
about:
@alpha should be in the range 0 to 1.

@alpha controls the transparancy level when the ALPHABLEND blend mode is in effect.
The range from 0.0 to 1.0 allows a range of transparancy from completely transparent 
to completely solid.
End Rem
Function SetAlpha( alpha:Float )
	TMax2DGraphics.Current().SetAlpha(alpha)
End Function

Rem
bbdoc: Set current alpha level
about:
@alpha should be in the range 0 to 1.

@alpha controls the transparancy level when the ALPHABLEND blend mode is in effect.
The range from 0.0 to 1.0 allows a range of transparancy from completely transparent 
to completely solid.
End Rem
Function SetAlpha( alpha:Double )
	TMax2DGraphics.Current().SetAlpha(Float(alpha))
End Function

Rem
bbdoc: Get current alpha setting.
returns: the current alpha value in the range 0..1.0 
End Rem
Function GetAlpha:Float()
	Return TMax2DGraphics.Current().GetAlpha()
End Function

Rem
bbdoc: Sets pixel width of lines drawn with the #DrawLine command
End Rem
Function SetLineWidth( width:Float )
	TMax2DGraphics.Current().SetLineWidth(width)
End Function

Rem
bbdoc: Sets pixel width of lines drawn with the #DrawLine command
End Rem
Function SetLineWidth( width:Double )
	TMax2DGraphics.Current().SetLineWidth(Float(width))
End Function

Rem
bbdoc: Get line width
returns: Current line width, in pixels
End Rem
Function GetLineWidth:Float()
	Return TMax2DGraphics.Current().GetLineWidth()
End Function

Rem
bbdoc: Set current mask color
about:
The current mask color is used to build an alpha mask when images are loaded or modified.
The @red, @green and @blue parameters should be in the range of 0 to 255.
End Rem
Function SetMaskColor( red:Int, green:Int, blue:Int )
	TMax2DGraphics.SetMaskColor(red, green, blue)
End Function

Rem
bbdoc: Get red, green and blue component of current mask color
returns: Red, green and blue values in the range 0..255 
End Rem
Function GetMaskColor( red:Int Var, green:Int Var, blue:Int Var )
	TMax2DGraphics.GetMaskColor(red, green, blue)
End Function

Rem
bbdoc: Set virtual graphics resolution
about:
SetResolution allows you to set a 'virtual' resolution independent of the graphics resolution.

This allows you to design an application to work at a fixed resolution, say 640 by 480, and run it
at any graphics resolution.
End Rem
Function SetVirtualResolution( width:Float, height:Float )
	TMax2DGraphics.Current().SetVirtualResolution(width, height)
End Function

Rem
bbdoc: Set virtual graphics resolution
about:
SetResolution allows you to set a 'virtual' resolution independent of the graphics resolution.

This allows you to design an application to work at a fixed resolution, say 640 by 480, and run it
at any graphics resolution.
End Rem
Function SetVirtualResolution( width:Double, height:Double )
	TMax2DGraphics.Current().SetVirtualResolution(Float(width), Float(height))
End Function

Rem
bbdoc: Get virtual graphics resolution width
End Rem
Function VirtualResolutionWidth:Float()
	Return TMax2DGraphics.Current().VirtualResolutionWidth()
End Function

Rem
bbdoc: Get virtual graphics resolution height
End Rem
Function VirtualResolutionHeight:Float()
	Return TMax2DGraphics.Current().VirtualResolutionHeight()
End Function

Rem
bbdoc: Get virtual mouse X coordinate
End Rem
Function VirtualMouseX:Float()
	Return TMax2DGraphics.Current().VirtualMouseX()
End Function

Rem
bbdoc: Get virtual mouse Y coordinate
End Rem
Function VirtualMouseY:Float()
	Return TMax2DGraphics.Current().VirtualMouseY()
End Function

Rem
bbdoc: Get virtual mouse X speed
End Rem
Function VirtualMouseXSpeed:Float()
	Return TMax2DGraphics.Current().VirtualMouseXSpeed()
End Function

Rem
bbdoc: Get virtual mouse Y speed
End Rem
Function VirtualMouseYSpeed:Float()
	Return TMax2DGraphics.Current().VirtualMouseYSpeed()
End Function

Rem
bbdoc: Move virtual mouse
End Rem
Function MoveVirtualMouse( x:Float, y:Float )
	TMax2DGraphics.Current().MoveVirtualMouse(x, y)
End Function

Rem
bbdoc: Move virtual mouse
End Rem
Function MoveVirtualMouse( x:Double, y:Double )
	TMax2DGraphics.Current().MoveVirtualMouse(Float(x), Float(y))
End Function

Rem
bbdoc: Set drawing viewport
about:
The current ViewPort defines an area within the back buffer that all drawing is clipped to. Any
regions of a DrawCommand that fall outside the current ViewPort are not drawn.
End Rem
Function SetViewport( x:Int, y:Int, width:Int, height:Int )
	TMax2DGraphics.Current().SetViewport(x, y, width, height)
End Function

Rem
bbdoc: Get dimensions of current Viewport.
returns: The horizontal, vertical, width and height values of the current Viewport in the variables supplied.
End Rem
Function GetViewport( x:Int Var, y:Int Var, width:Int Var, height:Int Var )
	TMax2DGraphics.Current().GetViewport(x, y, width, height)
End Function

Rem
bbdoc: Set drawing origin
about:
The current Origin is an x,y coordinate added to all drawing x,y coordinates after any rotation or scaling.
End Rem
Function SetOrigin( x:Float, y:Float )
	TMax2DGraphics.Current().SetOrigin(x, y)
End Function

Rem
bbdoc: Set drawing origin
about:
The current Origin is an x,y coordinate added to all drawing x,y coordinates after any rotation or scaling.
End Rem
Function SetOrigin( x:Double, y:Double )
	TMax2DGraphics.Current().SetOrigin(Float(x), Float(y))
End Function

Rem
bbdoc: Get current origin position.
returns: The horizontal and vertical position of the current origin. 
End Rem
Function GetOrigin( x:Float Var, y:Float Var )
	TMax2DGraphics.Current().GetOrigin(x, y)
End Function

Rem
bbdoc: Set drawing handle
about:
The drawing handle is a 2D offset subtracted from the x,y location of all 
drawing commands except #DrawImage as Images have their own unique handles.

Unlike #SetOrigin the drawing handle is subtracted before rotation and scale 
are applied providing a 'local' origin.
End Rem
Function SetHandle( x:Float, y:Float )
	TMax2DGraphics.Current().SetHandle(x, y)
End Function

Rem
bbdoc: Set drawing handle
about:
The drawing handle is a 2D offset subtracted from the x,y location of all 
drawing commands except #DrawImage as Images have their own unique handles.

Unlike #SetOrigin the drawing handle is subtracted before rotation and scale 
are applied providing a 'local' origin.
End Rem
Function SetHandle( x:Double, y:Double )
	TMax2DGraphics.Current().SetHandle(Float(x), Float(y))
End Function

Rem
bbdoc: Get current drawing handle.
returns: The horizontal and vertical position of the current drawing handle.
End Rem
Function GetHandle( x:Float Var,y:Float Var )
	TMax2DGraphics.Current().GetHandle(x, y)
End Function

Rem
bbdoc: Set current rotation
about:
@rotation is given in degrees and should be in the range 0 to 360.
End Rem
Function SetRotation( rotation:Float )
	TMax2DGraphics.Current().SetRotation(rotation)
End Function

Rem
bbdoc: Set current rotation
about:
@rotation is given in degrees and should be in the range 0 to 360.
End Rem
Function SetRotation( rotation:Double )
	TMax2DGraphics.Current().SetRotation(Float(rotation))
End Function

Rem
bbdoc: Get current Max2D rotation setting.
returns: The rotation in degrees.
End Rem
Function GetRotation:Float()
	Return TMax2DGraphics.Current().GetRotation()
End Function

Rem
bbdoc: Set current scale
about:
@scale_x and @scale_y multiply the width and height of drawing
commands where 0.5 will half the size of the drawing and 2.0 is equivalent 
to doubling the size.
End Rem
Function SetScale( scale_x:Float, scale_y:Float )
	TMax2DGraphics.Current().SetScale(scale_x, scale_y)
End Function

Rem
bbdoc: Set current scale
about:
@scale_x and @scale_y multiply the width and height of drawing
commands where 0.5 will half the size of the drawing and 2.0 is equivalent 
to doubling the size.
End Rem
Function SetScale( scale_x:Double, scale_y:Double )
	TMax2DGraphics.Current().SetScale(Float(scale_x), Float(scale_y))
End Function

Rem
bbdoc: Get current Max2D scale settings.
returns: The current x and y scale values in the variables supplied. 
End Rem
Function GetScale( scale_x:Float Var,scale_y:Float Var )
	TMax2DGraphics.Current().GetScale(scale_x, scale_y)
End Function

Rem
bbdoc: Set current rotation and scale
about:
SetTransform is a shortcut for setting both the rotation and
scale parameters in Max2D with a single function call.
End Rem
Function SetTransform( rotation:Float = 0.0, scale_x:Float = 1.0, scale_y:Float = 1.0 )
	TMax2DGraphics.Current().SetTransform(Rotation, scale_x, scale_y)
End Function

Rem
bbdoc: Set current rotation and scale
about:
SetTransform is a shortcut for setting both the rotation and
scale parameters in Max2D with a single function call.
End Rem
Function SetTransform( rotation:Double, scale_x:Double = 1:Double, scale_y:Float = 1:Double )
	TMax2DGraphics.Current().SetTransform(Float(rotation), Float(scale_x), Float(scale_y))
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
Function LoadImageFont:TImageFont( url:Object, size:Int, style:Int = SMOOTHFONT )
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
	TMax2DGraphics.Current().SetImageFont(font)
End Function

Rem
bbdoc: Get current image font.
returns: The current image font.
End Rem
Function GetImageFont:TImageFont()
	Return TMax2DGraphics.Current().GetImageFont()
End Function

Rem
bbdoc: Get width of text
returns: the width, in pixels, of @text based on the current image font.
about:
This command is useful for calculating horizontal alignment of text when using 
the #DrawText command.
End Rem
Function TextWidth:Int( text:String )
	Return TMax2DGraphics.Current().TextWidth(text)
End Function

Rem
bbdoc: Get height of text
returns: the height, in pixels, of @text based on the current image font.
about:
This command is useful for calculating vertical alignment of text when using 
the #DrawText command.
End Rem
Function TextHeight:Int( text:String )
	Return TMax2DGraphics.Current().TextHeight(text)
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
Function LoadImage:TImage( url:Object, flags:Int = -1 )
	Return TMax2DGraphics.LoadImage(url, flags)
End Function

Rem
bbdoc: Load a multi-frame image
returns: An image object
about:
#LoadAnimImage extracts multiple image frames from a single, larger image. @url can be either a string or an
existing pixmap.

See #LoadImage for valid @flags values.
End Rem
Function LoadAnimImage:TImage( url:Object, cell_width:Int, cell_height:Int, first_cell:Int, cell_count:Int, flags:Int = -1 )
	Return TMax2DGraphics.LoadAnimImage(url, cell_width, cell_height, first_cell, cell_count, flags)
End Function

Rem
bbdoc: Clear content of the passed image
about:
@image defines the image to clear.

@r, @g, @b define the red, green and blue components of the clear color. Range is 0 - 255.

@a defines the alpha value and is ranged 0.0 to 1.0.

@frameIndex defines an optional frame if the image is an animated image, -1 clears all existing frames
End Rem
Function ClearImage( image:Timage, r:UInt=0, g:UInt=0, b:UInt=0, a:Float=0.0, frameIndex:Int = -1 )
	image.Clear( r, g, b, a, frameIndex )
End Function

Rem
bbdoc: Clear content of the passed image
about:
@image defines the image to clear.

@color defines the rgba components of the clear color.

@frameIndex defines an optional frame if the image is an animated image, -1 clears all existing frames
End Rem
Function ClearImage( image:Timage, color:SColor8, frameIndex:Int = -1 )
	image.Clear( color.r, color.g, color.b, color.a/255.0, frameIndex )
End Function

Rem
bbdoc: Set an image's handle to an arbitrary point
about:
An image's handle is subtracted from the coordinates of #DrawImage before
rotation and scale are applied.
End Rem
Function SetImageHandle( image:TImage, x:Float, y:Float )
	image.handle_x=x
	image.handle_y=y
End Function

Rem
bbdoc: Set an image's handle to an arbitrary point
about:
An image's handle is subtracted from the coordinates of #DrawImage before
rotation and scale are applied.
End Rem
Function SetImageHandle( image:TImage,x:Double,y:Double )
	SetImageHandle(image,Float(x),Float(y))
End Function

Rem
bbdoc: Enable or disable auto midhandle mode
about:
When auto midhandle mode is enabled, all images are automatically 'midhandled' (see #MidHandleImage)
when they are created. If auto midhandle mode is disabled, images are handled by their top left corner.

AutoMidHandle defaults to False after calling #Graphics.
End Rem
Function AutoMidHandle( enable:Int )
	TMax2DGraphics.AutoMidHandle(enable)
End Function

Rem
bbdoc: Set auto image flags
about:
The auto image flags are used by #LoadImage and #CreateImage when no image 
flags are specified. See #LoadImage for a full list of valid image flags. 
AutoImageFlags defaults to MASKEDIMAGE | FILTEREDIMAGE.
End Rem
Function AutoImageFlags( flags:Int )
	TMax2DGraphics.AutoImageFlags(flags)
End Function

Function GetAutoImageFlags:Int()
	Return TMax2DGraphics.GetAutoImageFlags()
End Function

Rem
bbdoc: Set an image's handle to its center
End Rem
Function MidHandleImage( image:TImage )
	image.handle_x = image.width * 0.5
	image.handle_y = image.height * 0.5
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
Function CreateImage:TImage( width:Int, height:Int, frames:Int = 1, flags:Int = -1 )
	Return TMax2DGraphics.CreateImage(width, height, frames, flags)
End Function

Rem
bbdoc: Lock an image for direct access
returns: A pixmap representing the image contents
about:
Locking an image allows you to directly access an image's pixels.

Only images created with the DYNAMICIMAGE flag can be locked.

Locked images must eventually be unlocked with #UnlockImage before they can be drawn.
End Rem
Function LockImage:TPixmap( image:TImage, frame:Int = 0, read_lock:Int = True, write_lock:Int = True )
	Return image.Lock( frame,read_lock,write_lock )
End Function

Rem
bbdoc: Unlock an image
about:
Unlocks an image previously locked with #LockImage.
end rem
Function UnlockImage( image:TImage, frame:Int = 0 )
End Function

Rem
bbdoc: Grab an image from the back buffer
about:
Copies pixels from the back buffer to an image frame.

Only images created with the DYNAMICIMAGE flag can be grabbed.
End Rem
Function GrabImage( image:TImage, x:Int, y:Int, frame:Int = 0 )
	TMax2DGraphics.Current().GrabImage(image, x, y, frame)
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
bbdoc: Request if render images can be updated now
about:
Certain Backends can not always update render images. 
Ex. Direct3D9 cannot, when the application runs in exclusive fullscreen
    mode and currently is not having focus (running in the background).

returns: True if updating is possible, else False
End Rem
Function CanUpdateRenderImages:Int()
	Return TMax2DGraphics.Current().CanUpdateRenderImages()
End Function


Rem
bbdoc: Create a new render image
about:
@width, @height specify the dimensions of the render image.

@flags defines the image flags.

returns: #TRenderImage with the given dimension
End Rem
Function CreateRenderImage:TRenderImage(width:UInt, height:UInt, flags:Int = -1)
	Return TMax2DGraphics.CreateRenderImage(width, height, flags)
End Function


Rem
bbdoc: Create a new render image
about:
@image specifies the source image to initiate the renderimage with

returns: #TRenderImage with the image rendered into it
End Rem
Function CreateRenderImage:TRenderImage(image:TImage)
	Return TMax2DGraphics.CreateRenderImage(image)
End Function


Rem
bbdoc: Create a new render image
about:
@pixmap specifies the source pixmap to initiate the renderimage with

@imageFlags defines the image flags.

returns: #TRenderImage with the pixmap rendered into it
End Rem
Function CreateRenderImage:TRenderImage(pixmap:TPixmap, imageFlags:Int = -1)
	Return TMax2DGraphics.CreateRenderImage(pixmap, imageFlags)
End Function


Rem
bbdoc: Create a new render image
about:
Alias to CreateRenderImage(pixmap) for backwards compatibility reasons (was available until 2023)

@image specifies the source pixmap to initiate the renderimage with

@useLinearFiltering specifies if the resulting image should be using FILTEREDIMAGE

@max2DGraphics is no longer used, but there for backwards compatibility

returns: #TRenderImage with the pixmap rendered into it
End Rem
Function CreateRenderImageFromPixmap:TRenderImage(pixmap:TPixmap, useLinearFiltering:Int = True, max2DGraphics:TMax2DGraphics = Null)
	If max2DGraphics Then Throw "CreateRenderImageFromPixmap() is deprecated, use CreateRenderImage(pixmap, imageFlags) instead!"

	Local imageFlags:Int = -1
	if useLinearFiltering then imageFlags = FILTEREDIMAGE

	Return CreateRenderImage(pixmap, imageFlags)
End Function


Rem
bbdoc: Set a render image as currently active render target
about:
@renderImage defines the render image to use as target. Set to Null to render on the default graphics buffer again.

@frame defines the frame to use in the image

Returns True if successful, else False 
End Rem
Function SetRenderImage:Int(renderImage:TRenderImage, frame:Int = 0)
	Return TMax2DGraphics.Current().SetRenderImage(renderImage)
End Function


Rem
bbdoc: Get the render image currently set as active render target
about:
Returns Null in case of the backbuffer being the active render target.
End Rem
Function GetRenderImage:TRenderImage()
	Return TMax2DGraphics.Current().GetRenderImage()
End Function


Rem
bbdoc: Set a render image frame as currently active render target
about:
@renderImageFrame defines the render image frame to use as target. Set to Null to render on the default graphics buffer again.

Returns True if successful, else False 
End Rem
Function SetRenderImageFrame:Int(renderImageFrame:TImageFrame)
	Return TMax2DGraphics.Current().SetRenderImageFrame(renderImageFrame)
End Function


Rem
bbdoc: Get the render image frame currently set as active render target
about:
Returns the active render targets image frame or Null in case of rendering to the backbuffer.
End Rem
Function GetRenderImageFrame:TImageFrame()
	Return TMax2DGraphics.Current().GetRenderImageFrame()
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
Function ImagesCollide2:Int(image1:TImage,x1:Int,y1:Int,frame1:Int,rot1:Float,scalex1:Float,scaley1:Float,image2:TImage,x2:Int,y2:Int,frame2:Int,rot2:Float,scalex2:Float,scaley2:Float)
	Local	_scalex:Float,_scaley:Float,_rot:Float,res:Int
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
Function ResetCollisions(mask:Int=0)
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
Function CollideImage:Object[](image:TImage,x:Int,y:Int,frame:Int,collidemask:Int,writemask:Int,id:Object=Null) 
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
Function CollideRect:Object[](x:Int,y:Int,w:Int,h:Int,collidemask:Int,writemask:Int,id:Object=Null) 
	Local	q:TQuad
	q=CreateQuad(Null,0,x,y,w,h,id)
	Return CollideQuad(q,collidemask,writemask)
End Function

Private

Global	cix:Float,ciy:Float,cjx:Float,cjy:Float

Function SetCollisions2DTransform(ix:Float,iy:Float,jx:Float,jy:Float)	'callback from module Blitz2D
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

Function DotProduct:Int(x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float)
	Return (((x2-x1)*(y1-y0))-((x1-x0)*(y2-y1)))
End Function

Function ClockwisePoly(data:Float[],channels:Int)	'flips order if anticlockwise
	Local	count:Int,clk:Int,i:Int,j:Int
	Local	r0:Int,r1:Int,r2:Int
	Local	t:Float
	
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
	Field	data:Float[]
	Field	channels:Int,count:Int,size:Int
	Field	ldat:Float[],ladd:Float[]
	Field	rdat:Float[],radd:Float[]
	Field	Left:Int,Right:Int,top:Int
	Field	state:Int
End Type

Function RenderPolys:Int(vdata:Float[][],channels:Int[],textures:TPixmap[],renderspans:Int(polys:TList,count:Int,ypos:Int))
	Local	polys:rpoly[],p:rpoly,pcount:Int
	Local	active:TList
	Local	top:Int,bot:Int
	Local	n:Int,y:Int,h:Int,i:Int,j:Int,res:Int
	Local	data:Float[]

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
	Local	u:Float,v:Float,ui:Float,vi:Float
	Local	pix:Int Ptr
	Local	src:TPixmap
	Local	tw:Int,th:Int,tp:Int,argb:Int
	Local	width:Int,skip:Float
	

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
	Field	minx:Float,miny:Float,maxx:Float,maxy:Float
	Field	xyuv:Float[16]
		
	Method SetCoords(tx0:Float,ty0:Float,tx1:Float,ty1:Float,tx2:Float,ty2:Float,tx3:Float,ty3:Float)
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
	Local	vertlist:Float[][2]
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

Function CreateQuad:TQuad(image:TImage,frame:Int,x:Float,y:Float,w:Float,h:Float,id:Object)
	Local	x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float
	Local	tx0:Float,ty0:Float,tx1:Float,ty1:Float,tx2:Float,ty2:Float,tx3:Float,ty3:Float
	Local	minx:Float,miny:Float,maxx:Float,maxy:Float
	Local	q:TQuad
	Local	pix:TPixmap
	
	If image
		x0=-image.handle_x
		y0=-image.handle_y
	EndIf
	x1=x0+w
	y1=y0+h
	tx=x+TMax2DGraphics.Current().origin_x
	ty=y+TMax2DGraphics.Current().origin_y
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

Function CollideQuad:Object[](pquad:TQuad,collidemask:Int,writemask:Int) 
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
