
Strict

Rem
bbdoc: Graphics/Direct3D9 Max2D
about:
The Direct3D9 Max2D module provides a Direct3D9 driver for #Max2D.
End Rem
Module BRL.D3D9Max2D

ModuleInfo "Version: 1.01"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

ModuleInfo "History: 1.01"
ModuleInfo "History: Changed Assert to Throw. One can at least catch a Throw."

?win32

Import BRL.Max2D
Import BRL.DXGraphics

'Import BRL.D3D7Max2D


Const LOG_ERRS=True'False

Private

Global _gw,_gh,_gd,_gr,_gf,_gx,_gy
Global _color
Global _clscolor
Global _ix#,_iy#,_jx#,_jy#
Global _fverts#[24]
Global _iverts:Int Ptr=Int Ptr( Varptr _fverts[0] )
Global _lineWidth#

Global _bound_texture:IDirect3DTexture9
Global _texture_enabled

Global _active_blend

Global _driver:TD3D9Max2DDriver
Global _d3dDev:IDirect3DDevice9
Global _d3d9Graphics:TD3D9Graphics
Global _max2dGraphics:TMax2dGraphics

Function Pow2Size( n )
	Local t=1
	While t<n
		t:*2
	Wend
	Return t
End Function

Function DisableTex()
	If Not _texture_enabled Return
	_d3dDev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_SELECTARG2
	_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
	_texture_enabled=False
End Function

Function d3derr( str$ )
	If LOG_ERRS WriteStdout "D3DERR: "+str+"~n"
End Function

Public

Type TD3D9ImageFrame Extends TImageFrame

	Method Delete()
		If _texture
			If _seq=GraphicsSeq
				If _texture=_bound_texture
					_d3dDev.SetTexture 0,Null
					_bound_texture=Null
				EndIf
				_d3d9Graphics.ReleaseNow _texture
			EndIf
			_texture=Null
		EndIf
	End Method

	Method Create:TD3D9ImageFrame( pixmap:TPixmap,flags )

		Local width=pixmap.width,pow2width=Pow2Size( width )
		Local height=pixmap.height,pow2height=Pow2Size( height )
		
		If width<pow2width Or height<pow2height
			Local src:TPixmap=pixmap
			pixmap=TPixmap.Create( pow2width,pow2height,PF_BGRA8888 )
			pixmap.Paste src,0,0
			If width<pow2width
				pixmap.Paste pixmap.Window( width-1,0,1,height ),width,0
			EndIf
			If height<pow2height
				pixmap.Paste pixmap.Window( 0,height-1,width,1 ),0,height
				If width<pow2width 
					pixmap.Paste pixmap.Window( width-1,height-1,1,1 ),width,height
				EndIf
			EndIf
		Else
			If pixmap.Format<>PF_BGRA8888 pixmap=pixmap.Convert( PF_BGRA8888 )
		EndIf

		Local levels=(flags & MIPMAPPEDIMAGE)=0
		Local format=D3DFMT_A8R8G8B8
		Local usage=0
		Local pool=D3DPOOL_MANAGED
		
		'_texture = New IDirect3DTexture9
		If _d3dDev.CreateTexture( pow2width,pow2height,levels,usage,format,pool,_texture,Null )<0
			d3derr "Unable to create texture~n"
			_texture = Null
			Return
		EndIf
		
		_d3d9Graphics.AutoRelease _texture

		Local level
		Local dstsurf:IDirect3DSurface9' = New IDirect3DSurface9
		Repeat
			If _texture.GetSurfaceLevel( level,dstsurf )<0
				If level=0
					d3derr "_texture.GetSurfaceLevel failed~n"
				EndIf
				Exit
			EndIf

			Local lockedrect:D3DLOCKED_RECT=New D3DLOCKED_RECT
			If dstsurf.LockRect( lockedrect,Null,0 )<0
				d3derr "dstsurf.LockRect failed~n"
			EndIf
		
			For Local y=0 Until pixmap.height
				Local src:Byte Ptr=pixmap.pixels+y*pixmap.pitch
				Local dst:Byte Ptr=lockedrect.pBits+y*lockedrect.Pitch
				MemCopy dst,src,Size_T(pixmap.width*4)
			Next
		
			dstsurf.UnlockRect
			dstsurf.Release_
			
			If (flags & MIPMAPPEDIMAGE)=0 Exit

			level:+1

			If pixmap.width>1 And pixmap.height>1
				pixmap=ResizePixmap( pixmap,pixmap.width/2,pixmap.height/2 )
			Else If pixmap.width>1
				pixmap=ResizePixmap( pixmap,pixmap.width/2,pixmap.height )
			Else If pixmap.height>1
				pixmap=ResizePixmap( pixmap,pixmap.width,pixmap.height/2 )
			EndIf
		Forever
		
		_uscale=1.0/pow2width
		_vscale=1.0/pow2height

		Local u0#,u1#=width * _uscale
		Local v0#,v1#=height * _vscale

		_fverts[4]=u0
		_fverts[5]=v0
		_fverts[10]=u1
		_fverts[11]=v0
		_fverts[16]=u1
		_fverts[17]=v1
		_fverts[22]=u0
		_fverts[23]=v1
		
		If flags & FILTEREDIMAGE
			_magfilter=D3DTFG_LINEAR
			_minfilter=D3DTFG_LINEAR
			_mipfilter=D3DTFG_LINEAR
		Else
			_magfilter=D3DTFG_POINT
			_minfilter=D3DTFG_POINT
			_mipfilter=D3DTFG_POINT
		EndIf
		
		_seq=GraphicsSeq
		
		Return Self
	End Method
	
	Method Draw( x0#,y0#,x1#,y1#,tx#,ty#,sx#,sy#,sw#,sh# ) Override
		Local u0#=sx * _uscale
		Local v0#=sy * _vscale
		Local u1#=(sx+sw) * _uscale
		Local v1#=(sy+sh) * _vscale
	
		_fverts[0]=x0*_ix+y0*_iy+tx
		_fverts[1]=x0*_jx+y0*_jy+ty
		_iverts[3]=_color
		_fverts[4]=u0
		_fverts[5]=v0
		
		_fverts[6]=x1*_ix+y0*_iy+tx
		_fverts[7]=x1*_jx+y0*_jy+ty
		_iverts[9]=_color
		_fverts[10]=u1
		_fverts[11]=v0
		
		_fverts[12]=x1*_ix+y1*_iy+tx
		_fverts[13]=x1*_jx+y1*_jy+ty
		_iverts[15]=_color
		_fverts[16]=u1
		_fverts[17]=v1
		
		_fverts[18]=x0*_ix+y1*_iy+tx
		_fverts[19]=x0*_jx+y1*_jy+ty
		_iverts[21]=_color
		_fverts[22]=u0
		_fverts[23]=v1
		
		If _texture<>_bound_texture
			_d3dDev.SetTexture 0,_texture
			_d3dDev.SetTextureStageState 0,D3DTSS_MAGFILTER,_magfilter
			_d3dDev.SetTextureStageState 0,D3DTSS_MINFILTER,_minfilter
			_d3dDev.SetTextureStageState 0,D3DTSS_MIPFILTER,_mipfilter
			_bound_texture=_texture
		EndIf
		
		If Not _texture_enabled
			_d3dDev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_MODULATE
			_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_MODULATE
			_texture_enabled=True
		EndIf
		
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,2,_fverts,24
	End Method
	
	Field _texture:IDirect3DTexture9,_seq
	
	Field _magfilter,_minfilter,_mipfilter,_uscale#,_vscale#
	
	Field _fverts#[24],_iverts:Int Ptr=Int Ptr( Varptr _fverts[0] )

End Type


Type TD3D9RenderImageContext Extends TRenderImageContext
	Field _gc:TD3D9Graphics
	Field _d3ddev:IDirect3DDevice9
	Field _backbuffer:IDirect3DSurface9
	Field _matrix:Float[16]
	Field _viewport:D3DVIEWPORT9
	Field _renderImages:TList
	Field _deviceok:Int = True

	Method Delete()
		ReleaseNow()
	End Method
	
	Method ReleaseNow()
		If _renderImages
			For Local ri:TD3D9RenderImage = EachIn _renderImages
				ri.DestroyRenderImage()
			Next
		EndIf

		_renderImages = Null
		_viewport = Null
		_gc = Null

		If _backbuffer
			_backbuffer.release_
			_backbuffer = Null
		EndIf
		If _d3ddev
			_d3ddev.release_
			_d3ddev = Null
		EndIf
	End Method

	Method Create:TD3D9RenderimageContext(g:TGraphics, driver:TGraphicsDriver)
		_gc = TD3D9Graphics(g)

'		_gc.AddDeviceMightGetLostCallback(fnOnDeviceMightGetLost, Self)
		_gc.AddDeviceLostCallback(fnOnDeviceLost, Self)
		_gc.AddDeviceResetCallback(fnOnDeviceReset, Self)

		_d3ddev = _gc.GetDirect3DDevice()
		_d3ddev.AddRef()

		_d3ddev.GetRenderTarget(0, _backbuffer)

		_viewport = New D3DVIEWPORT9
		_d3ddev.GetViewport(_viewport)
		_d3ddev.GetTransform(D3DTS_PROJECTION, _matrix)
			
		_renderImages = New TList

		Return Self
	End Method
	
	Method GraphicsContext:TGraphics()
		Return _gc
	End Method
	
	Method Destroy()
'		_gc.RemoveDeviceMightGetLostCallback(fnOnDeviceMightGetLost)
		_gc.RemoveDeviceLostCallback(fnOnDeviceLost)
		_gc.RemoveDeviceResetCallback(fnOnDeviceReset)
		ReleaseNow()
	End Method

	Method CreateRenderImage:TRenderImage(width:Int, height:Int, UseImageFiltering:Int)
		Local renderimage:TD3D9RenderImage = New TD3D9RenderImage.CreateRenderImage(width, height)
		renderimage.Init(_d3ddev, UseImageFiltering)
		_renderImages.AddLast(renderimage)

		Return renderimage
	End Method
	
	Method CreateRenderImageFromPixmap:TRenderImage(pixmap:TPixmap, UseImageFiltering:Int)
		Local renderimage:TD3D9RenderImage = New TD3D9RenderImage.CreateRenderImage(pixmap.Width, pixmap.Height)
		renderimage.InitFromPixmap(_d3ddev, pixmap, UseImageFiltering)
		_renderImages.AddLast(renderimage)

		Return renderimage
	End Method
	
	Method DestroyRenderImage(renderImage:TRenderImage)
		renderImage.DestroyRenderImage()
		_renderImages.Remove(renderImage)
	End Method

	Method SetRenderImage(renderimage:TRenderimage)
		If Not renderimage
			_d3ddev.SetRenderTarget(0, _backbuffer)	
			_d3ddev.SetTransform D3DTS_PROJECTION,_matrix
			_d3ddev.SetViewport(_viewport)
		Else
			renderimage.SetRenderImage()
		EndIf
	End Method
	
	Method CreatePixmapFromRenderImage:TPixmap(renderImage:TRenderImage)
		Return TD3D9RenderImage(renderImage).ToPixmap()
	End Method

rem
	Method OnDeviceMightGetLost()
		For Local ri:TD3D9RenderImage = EachIn _renderImages
			ri.OnDeviceMightGetLost()
		Next
	End Method
endrem

	Method OnDeviceLost()
		If _deviceok = False Then Return

		For Local ri:TD3D9RenderImage = EachIn _renderImages
			ri.OnDeviceLost()
		Next
		If _backbuffer
			_backbuffer.release_
			_backbuffer = Null
		EndIf

		_deviceok = False
	End Method

	Method OnDeviceReset()
		If _deviceok = True Then Return

		Local hr:Int = _d3ddev.GetRenderTarget(0, _backbuffer)
		if hr = D3D_OK
'			print "  _d3ddev.GetRenderTarget() result: D3D_OK" 
		Elseif hr = D3DERR_INVALIDCALL
			print "  _d3ddev.GetRenderTarget() result: D3DERR_INVALIDCALL" 
		Elseif hr = D3DERR_NOTFOUND
			print "  _d3ddev.GetRenderTarget() result: D3DERR_NOTFOUND"
		Else 
			print "  _d3ddev.GetRenderTarget() result: " + hr
		EndIf
		hr = _d3ddev.GetViewport(_viewport)

		For Local ri:TD3D9RenderImage = EachIn _renderImages
			ri.OnDeviceReset()
		Next

		_deviceok = True
	End Method

rem
	Function fnOnDeviceMightGetLost(obj:Object)
		Local ric:TD3D9RenderImageContext = TD3D9RenderImageContext(obj)
		If Not ric Return
		ric.OnDeviceMightGetLost()
	EndFunction
endrem

	Function fnOnDeviceLost(obj:Object)
		Local ric:TD3D9RenderImageContext = TD3D9RenderImageContext(obj)
		If Not ric Return
		ric.OnDeviceLost()
	EndFunction

	Function fnOnDeviceReset(obj:Object)
		Local ric:TD3D9RenderImageContext = TD3D9RenderImageContext(obj)
		If Not ric Return
		ric.OnDeviceReset()
	EndFunction
EndType



Type TD3D9RenderImageFrame Extends TD3D9ImageFrame
	Field _surface:IDirect3DSurface9
	Field _persistPixmap:TPixmap

	Method Delete()
		ReleaseNow()
	End Method

	'ensure the GPU located render image would survive a "appsuspend"
	'by eg. reading it into a TPixmap
	Method Persist:Int(d3ddev:IDirect3DDevice9, width:Int, height:Int)
		_persistPixmap = ToPixmap(d3ddev, width, height)
		Return True
	End Method

	
	Method ReleaseNow()
		If _surface
			_surface.Release_
			_surface = Null
		EndIf
		If _texture
			_texture.Release_
			_texture = Null
		EndIf
	End Method
	
	Method Clear(d3ddev:IDirect3DDevice9, r:Int=0, g:Int=0, b:Int=0, a:Float=0.0)
		If Not d3ddev Return

		Local c:Int = (int(a*255) Shl 24) | (r Shl 16) | (g Shl 8) | b
		d3ddev.Clear(0, Null, D3DCLEAR_TARGET, c, 0.0, 0)
	End Method

	Method CreateRenderTarget:TD3D9RenderImageFrame( d3ddev:IDirect3DDevice9, width,height )
		d3ddev.CreateTexture(width,height,1,D3DUSAGE_RENDERTARGET,D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT,_texture,Null)
		If _texture _texture.GetSurfaceLevel 0, _surface
		
		_magfilter = D3DTFG_LINEAR
		_minfilter = D3DTFG_LINEAR
		_mipfilter = D3DTFG_LINEAR

		_uscale = 1.0 / width
		_vscale = 1.0 / height

		Return Self
	End Method
	
	Method DestroyRenderImage()
		ReleaseNow()
	End Method
	
rem
	'once a device is lost we cannot simply backup a pixmap, so better
	'do it any time we _could_ loose the device (eg. app suspend)
	Method OnDeviceMightGetLost(d3ddev:IDirect3DDevice9, width:Int, height:Int)
		print "TD3D9ImageFrame.OnDeviceMightGetLost(): persisting to pixmap"
		Persist()
	End Method
endrem

	Method OnDeviceLost(d3ddev:IDirect3DDevice9, width:Int, height:Int)
		'only read in a new pixmap if none was created before
		'in case of "suspend and resum" this ToPixmap() call will return
		'an empty pixmap (because of "D3DERR_DEVICELOST")
		If Not _persistPixmap
			_persistPixmap = ToPixmap(d3ddev, width, height)
		EndIf
		ReleaseNow()
	End Method

	Method OnDeviceReset(d3ddev:IDirect3DDevice9)
		If(_persistpixmap)
			d3ddev.CreateTexture(_persistPixmap.width, _persistPixmap.height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, _texture, Null)
			If _texture 
				_texture.GetSurfaceLevel(0, _surface)
			EndIf

			FromPixmap(d3ddev, _persistPixmap)
		EndIf

		_persistPixmap = Null
	End Method
	
	Method FromPixmap(d3ddev:IDirect3DDevice9, pixmap:TPixmap)
		' use a staging surface to copy the pixmap into
		Local stage:IDirect3DSurface9
		d3ddev.CreateOffscreenPlainSurface(pixmap.width, pixmap.height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, stage, Null)

		Local lockedrect:D3DLOCKED_RECT = New D3DLOCKED_RECT
		stage.LockRect(lockedrect, Null, 0)

		' copy the pixel data across
		For Local y:Int = 0 Until pixmap.height
			Local srcptr:Byte Ptr = pixmap.pixels + y * pixmap.pitch
			Local dstptr:Byte Ptr = lockedrect.pBits + y * lockedrect.Pitch
			MemCopy dstptr, srcptr, size_t(pixmap.width * 4)
		Next
		stage.UnlockRect()

		' copy from the staging surface to the render surface
		d3ddev.UpdateSurface(stage, Null, _surface, Null)

		' cleanup
		stage.release_
	End Method
	
	Method ToPixmap:TPixmap(d3ddev:IDirect3DDevice9, width:Int, height:Int)
		Local pixmap:TPixmap = CreatePixmap(width, height, PF_RGBA8888)

		' use a staging surface to get the texture contents
		Local stage:IDirect3DSurface9
		d3ddev.CreateOffscreenPlainSurface(width, height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, stage, Null)

		Local result:Int = d3ddev.GetRenderTargetData(_surface, stage)
		If result < 0
			If result = D3DERR_DRIVERINTERNALERROR
				Throw "TD3D9RenderImageFrame:ToPixmap:GetRenderTargetData failed: D3DERR_DRIVERINTERNALERROR"
			ElseIf result = D3DERR_DEVICELOST
				'Throw "TD3D9RenderImageFrame:ToPixmap:GetRenderTargetData failed: D3DERR_DEVICELOST"
			ElseIf result = D3DERR_INVALIDCALL
				Throw "TD3D9RenderImageFrame:ToPixmap:GetRenderTargetData failed: D3DERR_INVALIDCALL"
			Else
				Throw "TD3D9RenderImageFrame:ToPixmap:GetRenderTargetData failed."
			EndIf
		EndIf

		' copy the pixel data across
		Local lockedrect:D3DLOCKED_RECT = New D3DLOCKED_RECT
		If stage.LockRect(lockedrect, Null, 0) < 0 Throw "TD3D9RenderImageFrame:ToPixmap:LockRect failed"

		For Local y:Int = 0 Until pixmap.height
			For Local x:Int = 0 Until pixmap.width
				Local srcptr:Int Ptr = Int Ptr (lockedrect.pBits + x * 4 + y * lockedrect.Pitch)
				Local dstptr:Int Ptr = Int Ptr (pixmap.pixels + x * 4 + y * pixmap.pitch)
				dstptr[0] = ((srcptr[0] & $ff) Shl 16) | ((srcptr[0] & $ff0000) Shr 16)| (srcptr[0] & $ff00) | (srcptr[0] & $ff000000)
			Next
		Next
		
		pixmap = ConvertPixmap(pixmap, PF_BGRA)
		
		' cleanup
		stage.UnlockRect()
		stage.release_
		
		Return pixmap
	End Method
EndType

Type TD3D9RenderImage Extends TRenderImage
	Field _d3ddev:IDirect3DDevice9
	Field _viewport:D3DVIEWPORT9
	Field _matrix:Float[]

	Method Delete()
		ReleaseNow()
	End Method

	'ensure the GPU located render image would survive a "appsuspend"
	'by eg. reading it into a TPixmap
	Method Persist:Int() Override
		if TD3D9RenderImageFrame(frames[0])
			Return TD3D9RenderImageFrame(frames[0]).Persist(_d3ddev, width, height)
		EndIf
		Return False
	End Method

	
	Method ReleaseNow()
		If _d3ddev
			_d3ddev.release_
			_d3ddev = Null
		EndIf
	End Method

	Method CreateRenderImage:TD3D9RenderImage(width:Int ,height:Int)
		Self.width=width	' TImage.width
		Self.height=height	' TImage.height
	
		_matrix = [	2.0/width, 0.0, 0.0, 0.0,..
					0.0, -2.0/height, 0.0, 0.0,..
					0.0, 0.0, 1.0, 0.0,..
					-1-(1.0/width), 1+(1.0/height), 1.0, 1.0 ]

		_viewport = New D3DVIEWPORT9
		_viewport.width = width
		_viewport.height = height
		_viewport.MaxZ = 1.0

		Return Self
	End Method
	
	Method DestroyRenderImage()
		ReleaseNow()
		TD3D9RenderImageFrame(frames[0]).ReleaseNow()
	End Method

	Method Init(d3ddev:IDirect3DDevice9, UseImageFiltering:Int)
		_d3ddev = d3ddev
		_d3ddev.AddRef()

		frames = New TD3D9RenderImageFrame[1]
		frames[0] = New TD3D9RenderImageFrame.CreateRenderTarget(_d3ddev, width, height)
		If UseImageFiltering
			TD3D9RenderImageFrame(frames[0])._magfilter=D3DTFG_LINEAR
			TD3D9RenderImageFrame(frames[0])._minfilter=D3DTFG_LINEAR
			TD3D9RenderImageFrame(frames[0])._mipfilter=D3DTFG_LINEAR
		Else
			TD3D9RenderImageFrame(frames[0])._magfilter=D3DTFG_POINT
			TD3D9RenderImageFrame(frames[0])._minfilter=D3DTFG_POINT
			TD3D9RenderImageFrame(frames[0])._mipfilter=D3DTFG_POINT
		EndIf


		'  clear the new render target surface
		Local prevsurf:IDirect3DSurface9
		Local prevmatrix:Float[16]
		Local prevviewport:D3DVIEWPORT9 = New D3DVIEWPORT9
		
		' get previous
		_d3ddev.GetRenderTarget(0, prevsurf)
		_d3ddev.GetTransform(D3DTS_PROJECTION, prevmatrix)
		_d3ddev.GetViewport(prevviewport)

		' set and clear
		_d3ddev.SetRenderTarget(0, TD3D9RenderImageFrame(frames[0])._surface)
		_d3ddev.SetTransform(D3DTS_PROJECTION, _matrix)
		_d3ddev.Clear(0, Null, D3DCLEAR_TARGET, 0, 0.0, 0)

		' reset to previous
		_d3ddev.SetRenderTarget(0, prevsurf)
		_d3ddev.SetTransform(D3DTS_PROJECTION, prevmatrix)
		_d3ddev.SetViewport(prevviewport)

		' cleanup
		If prevsurf Then prevsurf.release_
	End Method
	
	Method InitFromPixmap(d3ddev:IDirect3DDevice9, Pixmap:TPixmap, UseImageFiltering:Int)
		_d3ddev = d3ddev
		_d3ddev.AddRef()

		Pixmap = ConvertPixmap(pixmap, PF_BGRA)

		frames = New TD3D9RenderImageFrame[1]
		frames[0] = New TD3D9RenderImageFrame.CreateRenderTarget(d3ddev, width, height)
		If UseImageFiltering
			TD3D9RenderImageFrame(frames[0])._magfilter=D3DTFG_LINEAR
			TD3D9RenderImageFrame(frames[0])._minfilter=D3DTFG_LINEAR
			TD3D9RenderImageFrame(frames[0])._mipfilter=D3DTFG_LINEAR
		Else
			TD3D9RenderImageFrame(frames[0])._magfilter=D3DTFG_POINT
			TD3D9RenderImageFrame(frames[0])._minfilter=D3DTFG_POINT
			TD3D9RenderImageFrame(frames[0])._mipfilter=D3DTFG_POINT
		EndIf

		TD3D9RenderImageFrame(frames[0]).FromPixmap(d3ddev, Pixmap)
	End Method	

	Method Clear(r:Int=0, g:Int=0, b:Int=0, a:Float=0.0)
		If frames[0] Then TD3D9RenderImageFrame(frames[0]).Clear(_d3ddev, r, g, b, a)
	End Method

	Method Frame:TImageFrame(index=0)
		If Not frames Return Null
		If Not frames[0] Return Null
		Return frames[0]
	End Method
	
	Method SetRenderImage()
		Local pTexture:IDirect3DTexture9
		_d3ddev.GetTexture(0, pTexture)
		
		Local frame:TD3D9RenderImageFrame = TD3D9RenderImageFrame(frames[0])
		If frame._texture <> pTexture
			_d3ddev.SetTexture(0, pTexture)
		EndIf
		
		If pTexture pTexture.Release_
		
		_d3ddev.SetRenderTarget(0, TD3D9RenderImageFrame(frames[0])._surface)
		_d3ddev.SetTransform(D3DTS_PROJECTION,_matrix)
		_d3ddev.SetViewport(_viewport)
	End Method
	
	Method ToPixmap:TPixmap()
		Return TD3D9RenderImageFrame(frames[0]).ToPixmap(_d3ddev, width, height)
	End Method
	
	Method SetViewport(x:Int, y:Int, width:Int, height:Int)
		If width = 0
			width = Self.width
			height = Self.height
		EndIf

		If x + width > Self.width
			width:-(x + width - Self.width)
		EndIf
		If y + height > Self.height
			height:-(y + height - Self.height)
		EndIf

		If x = 0 And y = 0 And width = Self.width And height = Self.height
			_d3ddev.SetRenderState(D3DRS_SCISSORTESTENABLE, False)
		Else
			_d3ddev.SetRenderState(D3DRS_SCISSORTESTENABLE, True)
			Local rect[] = [x , y, x + width, y + height]
			_d3ddev.SetScissorRect(rect)
		EndIf

	End Method

'	Method OnDeviceMightGetLost()
'		TD3D9RenderImageFrame(frames[0]).OnDeviceMightGetLost(_d3ddev, width, height)
'	End Method

	Method OnDeviceLost()
		'invalidate (even with existing persistPixmap!)
		_valid = False

		TD3D9RenderImageFrame(frames[0]).OnDeviceLost(_d3ddev, width, height)
	End Method

	Method OnDeviceReset()
		TD3D9RenderImageFrame(frames[0]).OnDeviceReset(_d3ddev)
	End Method
EndType



Type TD3D9Max2DDriver Extends TMax2dDriver

	Method ToString$() Override
		Return "DirectX9"
	End Method

	Method Create:TD3D9Max2DDriver()

		If Not D3D9GraphicsDriver() Return Null

		Local d3d:IDirect3D9 = D3D9GraphicsDriver().GetDirect3D()
		
		If d3d.CheckDeviceFormat( D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,D3DFMT_X8R8G8B8,0,D3DRTYPE_TEXTURE,D3DFMT_A8R8G8B8 )<0
			Return Null
		EndIf

		Return Self
	End Method

	'***** TGraphicsDriver *****
	Method GraphicsModes:TGraphicsMode[]() Override
		Return D3D9GraphicsDriver().GraphicsModes()
	End Method
	
	Method AttachGraphics:TGraphics( widget:Byte Ptr,flags ) Override
		Local g:TD3D9Graphics=D3D9GraphicsDriver().AttachGraphics( widget,flags )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method CreateGraphics:TGraphics( width,height,depth,hertz,flags,x,y ) Override
		Local g:TD3D9Graphics=D3D9GraphicsDriver().CreateGraphics( width,height,depth,hertz,flags,x,y )
		If Not g Return Null
		Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method SetGraphics( g:TGraphics ) Override

		If Not g
			If _d3dDev
				_d3dDev.EndScene
				_d3dDev=Null
			EndIf
			_d3d9graphics=Null
			_max2dGraphics=Null
			TMax2DGraphics.ClearCurrent
			D3D9GraphicsDriver().SetGraphics Null
			Return
		EndIf

		_max2dGraphics=TMax2dGraphics( g )

		_d3d9graphics=TD3D9Graphics( _max2dGraphics._graphics )

		If Not _max2dGraphics Or Not _d3d9graphics Then
			Throw "SetGraphics failed for D3D9"
		End If

		_d3dDev=_d3d9Graphics.GetDirect3DDevice()
		
		D3D9GraphicsDriver().SetGraphics _d3d9Graphics

		If _d3dDev.TestCooperativeLevel()<>D3D_OK Return
		
		ResetDevice

		_max2dGraphics.MakeCurrent
		
	End Method
	
	Method Flip( sync ) Override
		_d3dDev.EndScene
		If D3D9GraphicsDriver().Flip( sync )
			_d3dDev.BeginScene
		Else If _d3dDev.TestCooperativeLevel()=D3D_OK
			ResetDevice
			_max2dGraphics.MakeCurrent
		EndIf

	End Method
	
	Method ResetDevice()
		_d3d9graphics.ValidateSize
		_d3d9graphics.GetSettings _gw,_gh,_gd,_gr,_gf,_gx,_gy
	
		Local viewport:D3DVIEWPORT9
		viewport.X = 0
		viewport.Y = 0
		viewport.Width = _gw
		viewport.Height = _gh
		viewport.MinZ = 0.0
		viewport.MaxZ = 1.0
		_d3dDev.SetViewport(viewport)

		_d3dDev.SetRenderState D3DRS_ALPHAREF,$80
		_d3dDev.SetRenderState D3DRS_ALPHAFUNC,D3DCMP_GREATEREQUAL

		_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
		_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,False
		_active_blend=SOLIDBLEND
		
		_d3dDev.SetRenderState D3DRS_LIGHTING,False
		_d3dDev.SetRenderState D3DRS_CULLMODE,D3DCULL_NONE	
		
		_d3dDev.SetTexture 0,Null
		_bound_texture=Null

		_d3dDev.SetFVF D3DFVF_XYZ|D3DFVF_DIFFUSE|D3DFVF_TEX1
		
		_d3dDev.SetTextureStageState 0,D3DTSS_COLORARG1,D3DTA_TEXTURE		
		_d3dDev.SetTextureStageState 0,D3DTSS_COLORARG2,D3DTA_DIFFUSE		
		_d3dDev.SetTextureStageState 0,D3DTSS_COLOROP,D3DTOP_SELECTARG2
		_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAARG1,D3DTA_TEXTURE
		_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAARG2,D3DTA_DIFFUSE
		_d3dDev.SetTextureStageState 0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG2
		_texture_enabled=False
		
		_d3dDev.SetTextureStageState 0,D3DTSS_ADDRESS,D3DTADDRESS_CLAMP
	
		_d3dDev.SetTextureStageState 0,D3DTSS_MAGFILTER,D3DTFG_POINT
		_d3dDev.SetTextureStageState 0,D3DTSS_MINFILTER,D3DTFN_POINT
		_d3dDev.SetTextureStageState 0,D3DTSS_MIPFILTER,D3DTFP_POINT
		
		_d3dDev.BeginScene

	End Method

	'***** TMax2DDriver *****

	Method CreateRenderImageContext:Object(g:TGraphics) Override
		Return New TD3D9RenderImageContext.Create(g, Self)
	End Method
	
	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags ) Override
		Return New TD3D9ImageFrame.Create( pixmap,flags )
	End Method
	
	Method SetBlend( blend ) Override
		If blend=_active_blend Return
		Select blend
		Case SOLIDBLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,False
		Case MASKBLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,True
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,False
		Case ALPHABLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,True
			_d3dDev.SetRenderState D3DRS_SRCBLEND,D3DBLEND_SRCALPHA
			_d3dDev.SetRenderState D3DRS_DESTBLEND,D3DBLEND_INVSRCALPHA
		Case LIGHTBLEND
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,True
			_d3dDev.SetRenderState D3DRS_SRCBLEND,D3DBLEND_SRCALPHA
			_d3dDev.SetRenderState D3DRS_DESTBLEND,D3DBLEND_ONE
		Case SHADEBLEND		
			_d3dDev.SetRenderState D3DRS_ALPHATESTENABLE,False
			_d3dDev.SetRenderState D3DRS_ALPHABLENDENABLE,True
			_d3dDev.SetRenderState D3DRS_SRCBLEND,D3DBLEND_ZERO
			_d3dDev.SetRenderState D3DRS_DESTBLEND,D3DBLEND_SRCCOLOR
		End Select
		_active_blend=blend
	End Method
	
	Method SetAlpha( alpha# ) Override
		alpha=Max(Min(alpha,1),0)
		_color=(Int(255*alpha) Shl 24)|(_color&$ffffff)
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method
	
	Method SetColor( red,green,blue ) Override
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		_color=(_color&$ff000000)|(red Shl 16)|(green Shl 8)|blue		
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method

	Method SetColor( color:SColor8 ) Override
		_color=(_color&$ff000000)|color.ToARGB()	
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method
	
	Method SetClsColor( red,green,blue ) Override
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		_clscolor=$ff000000|(red Shl 16)|(green Shl 8)|blue
	End Method
	
	Method SetClsColor( color:SColor8 ) Override
		_clscolor=$ff000000|color.ToARGB()
	End Method
	
	Method SetViewport( x,y,width,height ) Override
		If x=0 And y=0 And width=_gw And height=_gh 'GraphicsWidth() And height=GraphicsHeight()
			_d3dDev.SetRenderState D3DRS_SCISSORTESTENABLE,False
		Else
			_d3dDev.SetRenderState D3DRS_SCISSORTESTENABLE,True
			Local rect[]=[x,y,x+width,y+height]
			_d3dDev.SetScissorRect rect
		EndIf
	End Method
	
	Method SetTransform( xx#,xy#,yx#,yy# ) Override
		_ix=xx
		_iy=xy
		_jx=yx
		_jy=yy		
	End Method
	
	Method SetLineWidth( width# ) Override
		_lineWidth=width
	End Method
	
	Method Cls() Override
		_d3dDev.Clear 0,Null,D3DCLEAR_TARGET,_clscolor,0,0
	End Method
	
	Method Plot( x#,y# ) Override
		_fverts[0]=x+.5
		_fverts[1]=y+.5
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_POINTLIST,1,_fverts,24
	End Method
	
	Method DrawLine( x0#,y0#,x1#,y1#,tx#,ty# ) Override
		Local lx0# = x0*_ix + y0*_iy + tx
		Local ly0# = x0*_jx + y0*_jy + ty
		Local lx1# = x1*_ix + y1*_iy + tx
		Local ly1# = x1*_jx + y1*_jy + ty
		If _lineWidth<=1
			_fverts[0]=lx0+.5
			_fverts[1]=ly0+.5
			_fverts[6]=lx1+.5
			_fverts[7]=ly1+.5
			DisableTex
			_d3dDev.DrawPrimitiveUP D3DPT_LINELIST,1,_fverts,24
			Return
		EndIf
		Local lw#=_lineWidth*.5
		If Abs(ly1-ly0)>Abs(lx1-lx0)
			_fverts[0]=lx0-lw
			_fverts[1]=ly0
			_fverts[6]=lx0+lw
			_fverts[7]=ly0
			_fverts[12]=lx1-lw
			_fverts[13]=ly1
			_fverts[18]=lx1+lw
			_fverts[19]=ly1
		Else
			_fverts[0]=lx0
			_fverts[1]=ly0-lw
			_fverts[6]=lx0
			_fverts[7]=ly0+lw
			_fverts[12]=lx1
			_fverts[13]=ly1-lw
			_fverts[18]=lx1
			_fverts[19]=ly1+lw
		EndIf
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLESTRIP,2,_fverts,24
	End Method
	
	Method DrawRect( x0#,y0#,x1#,y1#,tx#,ty# ) Override
		_fverts[0]  = x0*_ix + y0*_iy + tx
		_fverts[1]  = x0*_jx + y0*_jy + ty
		_fverts[6]  = x1*_ix + y0*_iy + tx
		_fverts[7]  = x1*_jx + y0*_jy + ty
		_fverts[12] = x0*_ix + y1*_iy + tx
		_fverts[13] = x0*_jx + y1*_jy + ty
		_fverts[18] = x1*_ix + y1*_iy + tx
		_fverts[19] = x1*_jx + y1*_jy + ty
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLESTRIP,2,_fverts,24
	End Method
	
	Method DrawOval( x0#,y0#,x1#,y1#,tx#,ty# ) Override
		Local xr#=(x1-x0)*.5
		Local yr#=(y1-y0)*.5
		Local segs=Abs(xr)+Abs(yr)
		segs=Max(segs,12)&~3
		x0:+xr
		y0:+yr
		Local fverts#[segs*6]
		Local iverts:Int Ptr=Int Ptr( Varptr fverts[0] )
		For Local i=0 Until segs
			Local th#=-i*360#/segs
			Local x#=x0+Cos(th)*xr
			Local y#=y0-Sin(th)*yr
			fverts[i*6+0]=x*_ix+y*_iy+tx
			fverts[i*6+1]=x*_jx+y*_jy+ty			
			iverts[i*6+3]=_color
		Next
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,segs-2,fverts,24
	End Method
	
	Method DrawPoly( verts#[],handlex#,handley#,tx#,ty# ) Override
		If verts.length<6 Or (verts.length&1) Return
		Local segs=verts.length/2
		Local fverts#[segs*6]
		Local iverts:Int Ptr=Int Ptr( Varptr fverts[0] )
		For Local i=0 Until segs
			Local x#=verts[i*2+0]+handlex
			Local y#=verts[i*2+1]+handley
			fverts[i*6+0]= x*_ix + y*_iy + tx
			fverts[i*6+1]= x*_jx + y*_jy + ty
			iverts[i*6+3]=_color
		Next
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,segs-2,fverts,24
	End Method
		
	'GetDC/BitBlt MUCH faster than locking backbuffer!	
	Method DrawPixmap( pixmap:TPixmap,x,y ) Override
		Local width=pixmap.width,height=pixmap.height
	
		Local dstsurf:IDirect3DSurface9' = New IDirect3DSurface9
		If _d3dDev.GetRenderTarget( 0,dstsurf )<0
			d3derr "GetRenderTarget failed~n"
			Return
		EndIf
		
		Local desc:D3DSURFACE_DESC
		If dstsurf.GetDesc( desc )<0
			d3derr "GetDesc failed~n"
		EndIf
		
		Local rect[]=[x,y,x+width,y+height]
		Local lockedrect:D3DLOCKED_RECT=New D3DLOCKED_RECT
		If dstsurf.LockRect( lockedrect,rect,0 )<0
			d3derr "Unable to lock render target surface~n"
			dstsurf.Release_
			Return
		EndIf
		
		Local dstpixmap:TPixmap=CreateStaticPixmap( lockedrect.pBits,width,height,lockedrect.Pitch,PF_BGRA8888 );
		
		dstpixmap.Paste pixmap,0,0
		
		dstsurf.UnlockRect
		dstsurf.Release_
	End Method

	'GetDC/BitBlt MUCH faster than locking backbuffer!	
	Method GrabPixmap:TPixmap( x,y,width,height ) Override
	
		Local srcsurf:IDirect3DSurface9
		If _d3dDev.GetRenderTarget( 0,srcsurf )<0
			d3derr "GetRenderTarget failed~n"
		EndIf

		Local dstsurf:IDirect3DSurface9
		If _d3dDev.CreateOffscreenPlainSurface( width,height,D3DFMT_X8R8G8B8,D3DPOOL_SYSTEMMEM,dstsurf,Null )<0
			d3derr "CreateOffscreenPlainSurface failed~n"
		EndIf
		
		Local srcdc:Byte Ptr
		If srcsurf.GetDC( srcdc )<0
			d3derr "srcsurf.GetDC failed~n"
		EndIf
		
		Local dstdc:Byte Ptr
		If dstsurf.GetDC( dstdc )<0
			d3derr "dstsurf.GetDC failed~n"
		EndIf
		
		BitBlt dstdc,0,0,width,height,srcdc,x,y,ROP_SRCCOPY
		
		srcsurf.ReleaseDC srcdc
		dstsurf.ReleaseDC dstdc
		
		Local lockedrect:D3DLOCKED_RECT=New D3DLOCKED_RECT
		If dstsurf.LockRect( lockedrect,Null,D3DLOCK_READONLY )<0
			d3derr "dstsurf.LockRect failed~n"
		EndIf
		
		Local pixmap:TPixmap=CreatePixmap( width,height,PF_BGRA8888 )
		
		'Copy and set alpha in the process...
		For Local y=0 Until height
			Local src:Int Ptr=Int Ptr( lockedrect.pBits+y*lockedrect.Pitch )
			Local dst:Int Ptr=Int Ptr( pixmap.PixelPtr( 0,y ) )
			For Local x=0 Until width
				dst[x]=src[x] | $ff000000
			Next
		Next
		
		srcsurf.Release_
		dstsurf.Release_
		
		Return pixmap
	End Method
	
	Method SetResolution( width#,height# ) Override
		Local matrix#[]=[..
		2.0/width,0.0,0.0,0.0,..
		 0.0,-2.0/height,0.0,0.0,..
		 0.0,0.0,1.0,0.0,..
		 -1-(1.0/width),1+(1.0/height),1.0,1.0]

		_d3dDev.SetTransform D3DTS_PROJECTION,matrix
	End Method
	
End Type

Rem
bbdoc: Get Direct3D9 Max2D Driver
about:
The returned driver can be used with #SetGraphicsDriver to enable Direct3D9 Max2D rendering.
End Rem
Function D3D9Max2DDriver:TD3D9Max2DDriver()
	Global _done
	If Not _done
		_driver=New TD3D9Max2DDriver.Create()
		_done=True
	EndIf
	Return _driver
End Function

Local driver:TD3D9Max2DDriver=D3D9Max2DDriver()
If driver SetGraphicsDriver driver

?
