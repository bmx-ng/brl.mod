
SuperStrict

Rem
bbdoc: Graphics/Direct3D9 Max2D
about:
The Direct3D9 Max2D module provides a Direct3D9 driver for #Max2D.
End Rem
Module BRL.D3D9Max2D

ModuleInfo "Version: 1.02"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

ModuleInfo "History: 1.02"
ModuleInfo "History: Changed to SuperStrict"
ModuleInfo "History: Extended flags to Long"
ModuleInfo "History: 1.01"
ModuleInfo "History: Changed Assert to Throw. One can at least catch a Throw."

?win32

Import BRL.Max2D
Import BRL.DXGraphics

Const LOG_ERRS:Int=True'False

Private

Global _gw:Int,_gh:Int,_gd:Int,_gr:Int,_gf:Long,_gx:Int,_gy:Int
Global _color:Int
Global _clscolor:Int
Global _ix:Float,_iy:Float,_jx:Float,_jy:Float
Global _fverts:Float[24]
Global _iverts:Int Ptr=Int Ptr( Varptr _fverts[0] )
Global _lineWidth:Float

Global _bound_texture:IDirect3DTexture9
Global _texture_enabled:Int

Global _active_blend:Int

Global _driver:TD3D9Max2DDriver
Global _d3dDev:IDirect3DDevice9
Global _d3d9Graphics:TD3D9Graphics
Global _max2dGraphics:TMax2dGraphics

Global _BackbufferRenderImageFrame:TD3D9RenderImageFrame
Global _CurrentRenderImageFrame:TD3D9RenderImageFrame
Global _CurrentRenderImageContainer:Object
Global _D3D9Scissor_BMaxViewport:Rect = New Rect

Function Pow2Size:Int( n:Int )
	Local t:Int=1
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

Function d3derr( str:String )
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

	Method Create:TD3D9ImageFrame( pixmap:TPixmap,flags:Int )

		Local width:Int=pixmap.width,pow2width:Int=Pow2Size( width )
		Local height:Int=pixmap.height,pow2height:Int=Pow2Size( height )
		
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
			If pixmap.format<>PF_BGRA8888 pixmap=pixmap.Convert( PF_BGRA8888 )
		EndIf

		Local levels:Int=(flags & MIPMAPPEDIMAGE)=0
		Local format:Int=D3DFMT_A8R8G8B8
		Local usage:Int=0
		Local pool:Int=D3DPOOL_MANAGED
		
		'_texture = New IDirect3DTexture9
		If _d3dDev.CreateTexture( pow2width,pow2height,levels,usage,format,pool,_texture,Null )<0
			d3derr "Unable to create texture~n"
			_texture = Null
			Return Null
		EndIf
		
		_d3d9Graphics.AutoRelease _texture

		Local level:Int
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
		
			For Local y:Int=0 Until pixmap.height
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

		Local u0:Float,u1:Float=width * _uscale
		Local v0:Float,v1:Float=height * _vscale

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
	
	Method Draw( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float,sx:Float,sy:Float,sw:Float,sh:Float ) Override
		Local u0:Float = sx * _uscale
		Local v0:Float = sy * _vscale
		Local u1:Float = (sx + sw) * _uscale
		Local v1:Float = (sy + sh) * _vscale
	
		_fverts[0] = x0 * _ix + y0 * _iy + tx
		_fverts[1] = x0 * _jx + y0 * _jy + ty
		_iverts[3] = _color
		_fverts[4] = u0
		_fverts[5] = v0
		
		_fverts[6] = x1 * _ix + y0 * _iy + tx
		_fverts[7] = x1 * _jx + y0 * _jy + ty
		_iverts[9] = _color
		_fverts[10] = u1
		_fverts[11] = v0
		
		_fverts[12] = x1 * _ix + y1 * _iy + tx
		_fverts[13] = x1 * _jx + y1 * _jy + ty
		_iverts[15] = _color
		_fverts[16] = u1
		_fverts[17] = v1
		
		_fverts[18] = x0 * _ix + y1 * _iy + tx
		_fverts[19] = x0 * _jx + y1 * _jy + ty
		_iverts[21] = _color
		_fverts[22] = u0
		_fverts[23] = v1
		
		If _texture<>_bound_texture
			_d3dDev.SetTexture 0,_texture
			_d3dDev.SetTextureStageState(0, D3DTSS_MAGFILTER, _magfilter)
			_d3dDev.SetTextureStageState(0, D3DTSS_MINFILTER, _minfilter)
			_d3dDev.SetTextureStageState(0, D3DTSS_MIPFILTER, _mipfilter)
			_bound_texture = _texture
		EndIf
		
		If Not _texture_enabled
			_d3dDev.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE)
			_d3dDev.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE)
			_texture_enabled = True
		EndIf
		
		_d3dDev.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, _fverts, 24)
	End Method
	
	Field _texture:IDirect3DTexture9, _seq:Int
	Field _magfilter:Int, _minfilter:Int, _mipfilter:Int, _uscale:Float, _vscale:Float
	Field _fverts:Float[24], _iverts:Int Ptr=Int Ptr( Varptr _fverts[0] )
End Type

Type TD3D9RenderImageFrame Extends TD3D9ImageFrame
	Field _surface:IDirect3DSurface9
	Field _offscreenSurface:IDirect3DSurface9
	Field _stagingPixmap:TPixmap
	Field _width:UInt, _height:UInt

	Method Delete()
		ReleaseNow()
	End Method
	
	Method ReleaseNow()
		If _surface
			_surface.Release_
			_surface = Null
		EndIf
		If _offscreenSurface
			_offscreenSurface.Release_
			_offscreenSurface = Null
		EndIf
		If _texture
			_texture.Release_
			_texture = Null
		EndIf
	End Method

	Function Create:TD3D9RenderImageFrame(width:UInt, height:UInt, flags:Int )
		Local D3D9Texture:IDirect3DTexture9
		If _d3ddev.CreateTexture(width, height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8,D3DPOOL_DEFAULT, D3D9Texture, Null) < 0
			Throw "Could not create D3D9 Render Image : Width " + width + ", Height " + height + ", Flags " + flags
			Return Null
		EndIf

		Local D3D9Surface:IDirect3DSurface9
		If D3D9Texture
			If D3D9Texture.GetSurfaceLevel(0, D3D9Surface) < 0
				Throw "Could not get surface index 0 for D3D9 Render Image : Width " + width + ", Height " + height + ", Flags " + flags
				Return Null
			EndIf
		EndIf
		
		Local RenderImage:TD3D9RenderImageFrame = New TD3D9RenderImageFrame
		RenderImage._texture = D3D9Texture
		RenderImage._surface = D3D9Surface
		RenderImage._magfilter = D3DTFG_LINEAR
		RenderImage._minfilter = D3DTFG_LINEAR
		RenderImage._mipfilter = D3DTFG_LINEAR

		RenderImage._uscale = 1.0 / width
		RenderImage._vscale = 1.0 / height
		RenderImage._width = width
		RenderImage._height = height

		Return RenderImage
	End Function

	Method OnDeviceLost()
		Local BackBuffer:TD3D9RenderImageFrame = _BackBufferRenderImageFrame
		If Self <> BackBuffer And Not _stagingpixmap
			If _surface
				_stagingPixmap  = RenderTargetToPixmap()
			EndIf
		EndIf
		ReleaseNow()
	End Method

	Method OnDeviceReset()		
		' dont re-create until the device is ready
		If _d3dDev.TestCooperativeLevel() = 0
			If(_stagingPixmap)
				LoadFromPixmap(_stagingPixmap)
				_stagingPixmap = Null
			EndIf
		EndIf
	End Method

Private
	Method PastePixmap(pixmap:TPixmap, x:Int, y:Int)
		' nothing to do if the area is outside of the valid area
		If x + pixmap.width < 0 Or y + pixmap.height < 0 Or x >= Self._width Or y >= Self._height
			Return
		EndIf

		' create (cpu ram) offscreen surface if not done yet
		If Not Self._offscreenSurface
			If _d3dDev.CreateOffscreenPlainSurface(Self._width, Self._height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, Self._offscreenSurface, Null) < 0
				d3derr "CreateOffscreenPlainSurface failed~n"
				Return
			EndIf
		EndIf

		' copy renderimage data into offscreen surface
		If _d3dDev.GetRenderTargetData(Self._surface, Self._offscreenSurface) < 0
			d3derr "GetRenderTargetData failed~n"
			Return
		EndIf

		' limit pixmap / surface rect size
		Local lockedWidth:Int = Min(pixmap.width, Self._width - x)
		Local lockedHeight:Int = Min(pixmap.height, Self._height - y)

		' lock (lockable) offscreen surface
		Local rect:Int[] = [x, y, x + lockedWidth, y + lockedHeight]
		Local lockedRect:D3DLOCKED_RECT = New D3DLOCKED_RECT
		If  Self._offscreenSurface.LockRect(lockedRect,rect, 0) < 0 Then
			d3derr "Unable to lock offscreen surface~n"
			Return
		EndIf

		' paste pixmap into locked offscreen surface rect
		Local dstPixmap:TPixmap = CreateStaticPixmap(lockedRect.pBits, lockedWidth, lockedHeight, lockedRect.Pitch, PF_BGRA8888)
		dstPixmap.Paste(pixmap.Window(0,0, lockedWidth, lockedHeight), 0, 0)

		' unlock offscreen surface again
		 Self._offscreenSurface.UnlockRect()

		' update content of the renderimage
		If _d3ddev.UpdateSurface(Self._offscreenSurface, Null, Self._surface, Null)
			Throw "Failed to copy the replacement surface texture data to the render target"
			Return
		EndIf
	End Method


	Method LoadFromPixmap(pixmap:TPixmap)
		If _d3ddev.CreateTexture(_width, _height, 1, D3DUSAGE_RENDERTARGET, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, _texture, Null) < 0
			Throw "Failed to create render target"
			Return
		EndIf
		
		If _texture.GetSurfaceLevel(0, _surface) < 0
			Throw "Failed to get surface of render target"
			ReleaseNow()
			Return
		EndIf

		Local replacementSurface:IDirect3DSurface9
		If _d3ddev.CreateOffscreenPlainSurface(_width, _height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, replacementSurface, Null) < 0
			Throw "Failed to create a replacement surface"
			ReleaseNow()
			Return
		EndIf

		Local lockedrect:D3DLOCKED_RECT = New D3DLOCKED_RECT
		If replacementSurface.LockRect(lockedrect, Null, 0) < 0
			Throw "Failed to lock the replacement surface"
			ReleaseNow()
			replacementSurface.Release_()
			Return
		EndIf

		For Local y:Int = 0 Until _height
			Local srcptr:Byte Ptr = pixmap.pixels + y * pixmap.pitch
			Local dstptr:Byte Ptr = lockedrect.pBits + y * lockedrect.Pitch
			MemCopy dstptr, srcptr, Size_T(pixmap.width * 4)
		Next
		replacementSurface.UnlockRect()

		If _d3ddev.UpdateSurface(replacementSurface, Null, _surface, Null) < 0
			Throw "Failed to copy the replacement surface texture data to the render target"
			ReleaseNow()
			replacementSurface.Release_()
			Return
		EndIf

		replacementSurface.Release_()
	End Method
	
	Method RenderTargetToPixmap:TPixmap()	
		' use a staging surface to get the texture contents
		Local StagingSurface:IDirect3DSurface9
		If _d3ddev.CreateOffscreenPlainSurface(_width, _height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, StagingSurface, Null) < 0
			Throw "Failed to create staging texture to receive render target data"
			Return Null
		EndIf
		
		If _d3ddev.GetRenderTargetData(_surface, StagingSurface) < 0
			Throw "Failed to get render target data from render target into the staging buffer"
			StagingSurface.Release_()
			Return Null
		EndIf
		
		' copy the pixel data across
		Local lockedrect:D3DLOCKED_RECT = New D3DLOCKED_RECT
		If StagingSurface.LockRect(lockedrect, Null, 0) < 0
			StagingSurface.UnlockRect()
			StagingSurface.Release_()
			Throw "Failed to lock the staging buffer to get pixel data"
			StagingSurface.Release_()
			Return Null
		EndIf

		Local pixmap:TPixmap = CreatePixmap(_width, _height, PF_RGBA8888)
		For Local y:Int = 0 Until pixmap.height
			For Local x:Int = 0 Until pixmap.width
				Local srcptr:Int Ptr = Int Ptr (lockedrect.pBits + x * 4 + y * lockedrect.Pitch)
				Local dstptr:Int Ptr = Int Ptr (pixmap.pixels + x * 4 + y * pixmap.pitch)
				dstptr[0] = ((srcptr[0] & $ff) Shl 16) | ((srcptr[0] & $ff0000) Shr 16)| (srcptr[0] & $ff00) | (srcptr[0] & $ff000000)
			Next
		Next
		
		StagingSurface.UnlockRect()
		StagingSurface.Release_()
		
		Return ConvertPixmap(pixmap, PF_BGRA)
	End Method
EndType

Type TD3D9Max2DDriver Extends TMax2dDriver

	Method ToString:String() Override
		Return "DirectX9"
	End Method

	Method ApiIdentifier:String() Override
		Return "BRL.Direct3D9"
	End Method

	Method Create:TD3D9Max2DDriver()
		If Not D3D9GraphicsDriver() Return Null

		Local d3d:IDirect3D9 = D3D9GraphicsDriver().GetDirect3D()
		
		If d3d.CheckDeviceFormat( D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,D3DFMT_X8R8G8B8,0,D3DRTYPE_TEXTURE,D3DFMT_A8R8G8B8 ) < 0
			Return Null
		EndIf

		Return Self
	End Method

	'***** TGraphicsDriver *****
	Method GraphicsModes:TGraphicsMode[]() Override
		Return D3D9GraphicsDriver().GraphicsModes()
	End Method
	
	Method AttachGraphics:TGraphics( widget:Byte Ptr,flags:Long ) Override
		Local g:TD3D9Graphics=D3D9GraphicsDriver().AttachGraphics( widget,flags )
		If g Return TMax2DGraphics.Create( g,Self )
	End Method
	
	Method CreateGraphics:TGraphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int ) Override
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

		_d3d9graphics=TD3D9Graphics( _max2dGraphics._backendGraphics )

		If Not _max2dGraphics Or Not _d3d9graphics Then
			Throw "SetGraphics failed for D3D9"
		End If

		_d3dDev=_d3d9Graphics.GetDirect3DDevice()
		
		D3D9GraphicsDriver().SetGraphics _d3d9Graphics

		If _d3dDev.TestCooperativeLevel()<>D3D_OK Return
		
		ResetDevice

		_max2dGraphics.MakeCurrent
		
	End Method
	
	Method Flip:Int( sync:Int ) Override
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
		viewport.width = _gw
		viewport.height = _gh
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
		
		_d3d9graphics.AddDeviceLostCallback(OnDeviceLost, Self)
		_d3d9graphics.AddDeviceResetCallback(OnDeviceReset, Self)
		
		' Create default back buffer render image
		AssignBackBufferRenderImage()
	End Method

	'***** TMax2DDriver *****
	Method CreateFrameFromPixmap:TImageFrame( pixmap:TPixmap,flags:Int ) Override
		Return New TD3D9ImageFrame.Create( pixmap,flags )
	End Method
	
	Method SetBlend( blend:Int ) Override
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
	
	Method SetAlpha( alpha:Float ) Override
		alpha=Max(Min(alpha,1),0)
		_color=(Int(255*alpha) Shl 24)|(_color&$ffffff)
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method
	
	Method SetColor( red:Int,green:Int,blue:Int ) Override
		red=Max(Min(red,255),0)
		green=Max(Min(green,255),0)
		blue=Max(Min(blue,255),0)
		_color=(_color&$ff000000)|(red Shl 16)|(green Shl 8)|blue		
		_iverts[3]=_color
		_iverts[9]=_color
		_iverts[15]=_color
		_iverts[21]=_color
	End Method
	
	Method SetClsColor( red:Int,green:Int,blue:Int, alpha:Float ) Override
		red = Max(Min(red, 255), 0)
		green = Max(Min(green, 255), 0)
		blue = Max(Min(blue, 255), 0)
		Local a:Int = Max(Min(alpha * 255.0, 255), 0)
		_clscolor = (a Shl 24) | (red Shl 16) | (green Shl 8) | blue
	End Method
	
	Method SetViewport( x:Int,y:Int,width:Int,height:Int ) Override
		_D3D9Scissor_BMaxViewport.x = x
		_D3D9Scissor_BMaxViewport.y = y
		_D3D9Scissor_BMaxViewport.width = width
		_D3D9Scissor_BMaxViewport.height = height
		SetScissor(x, y, width, height)
	End Method
	
	Method SetTransform( xx:Float,xy:Float,yx:Float,yy:Float ) Override
		_ix=xx
		_iy=xy
		_jx=yx
		_jy=yy		
	End Method
	
	Method SetLineWidth( width:Float ) Override
		_lineWidth=width
	End Method
	
	Method Cls() Override
		_d3dDev.Clear 0,Null,D3DCLEAR_TARGET,_clscolor,0,0
	End Method
	
	Method Plot( x:Float,y:Float ) Override
		_fverts[0]=x+.5
		_fverts[1]=y+.5
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_POINTLIST,1,_fverts,24
	End Method
	
	Method DrawLine( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float ) Override
		Local lx0:Float = x0*_ix + y0*_iy + tx
		Local ly0:Float = x0*_jx + y0*_jy + ty
		Local lx1:Float = x1*_ix + y1*_iy + tx
		Local ly1:Float = x1*_jx + y1*_jy + ty
		If _lineWidth<=1
			_fverts[0]=lx0+.5
			_fverts[1]=ly0+.5
			_fverts[6]=lx1+.5
			_fverts[7]=ly1+.5
			DisableTex
			_d3dDev.DrawPrimitiveUP D3DPT_LINELIST,1,_fverts,24
			Return
		EndIf
		Local lw:Float=_lineWidth*.5
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
	
	Method DrawRect( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float ) Override
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
	
	Method DrawOval( x0:Float,y0:Float,x1:Float,y1:Float,tx:Float,ty:Float ) Override
		Local xr:Float=(x1-x0)*.5
		Local yr:Float=(y1-y0)*.5
		Local segs:Int=Abs(xr)+Abs(yr)
		segs=Max(segs,12)&~3
		x0:+xr
		y0:+yr
		Local fverts:Float[segs*6]
		Local iverts:Int Ptr=Int Ptr( Varptr fverts[0] )
		For Local i:Int=0 Until segs
			Local th:Float=-i*360:Float/segs
			Local x:Float=x0+Cos(th)*xr
			Local y:Float=y0-Sin(th)*yr
			fverts[i*6+0]=x*_ix+y*_iy+tx
			fverts[i*6+1]=x*_jx+y*_jy+ty			
			iverts[i*6+3]=_color
		Next
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,segs-2,fverts,24
	End Method
	
	Method DrawPoly( verts:Float[],handlex:Float,handley:Float,tx:Float,ty:Float, indices:Int[] ) Override
		If verts.length<6 Or (verts.length&1) Return
		Local segs:Int=verts.length/2
		Local fverts:Float[segs*6]
		Local iverts:Int Ptr=Int Ptr( Varptr fverts[0] )
		For Local i:Int=0 Until segs
			Local x:Float=verts[i*2+0]+handlex
			Local y:Float=verts[i*2+1]+handley
			fverts[i*6+0]= x*_ix + y*_iy + tx
			fverts[i*6+1]= x*_jx + y*_jy + ty
			iverts[i*6+3]=_color
		Next
		DisableTex
		_d3dDev.DrawPrimitiveUP D3DPT_TRIANGLEFAN,segs-2,fverts,24
	End Method

			
	Method DrawPixmap(pixmap:TPixmap, x:Int, y:Int) Override
		If _CurrentRenderImageFrame <> _BackBufferRenderImageFrame
			_CurrentRenderImageFrame.PastePixmap(pixmap, x, y)
		Else
			DrawPixmapToBackBuffer(pixmap, x, y)
		EndIf
	End Method


	Method DrawPixmapToBackBuffer(pixmap:TPixmap, x:Int, y:Int)
		' nothing to do if the area is outside of the valid area
		If x + pixmap.width < 0 Or y + pixmap.height < 0 Or x >= _gw Or y >= _gh
			Return
		EndIf

		Local dstsurf:IDirect3DSurface9
		If _d3dDev.GetRenderTarget(0, dstsurf) < 0
			d3derr "GetRenderTarget failed~n"
			Return
		EndIf
		
		Rem
		Local desc:D3DSURFACE_DESC
		If dstsurf.GetDesc(desc) < 0
			d3derr "GetDesc failed~n"
		EndIf
		End Rem

		' limit pixmap / surface rect size
		Local lockedWidth:Int = Min(pixmap.width, _gw - x)
		Local lockedHeight:Int = Min(pixmap.height, _gh - y)

		' lock (lockable) offscreen surface
		Local rect:Int[] = [x, y, x + lockedWidth, y + lockedHeight]
		Local lockedRect:D3DLOCKED_RECT = New D3DLOCKED_RECT
		If dstsurf.LockRect( lockedrect,rect,0 )<0
			d3derr "Unable to lock render target surface~n"
			dstsurf.Release_
			Return
		EndIf

		' paste pixmap into locked offscreen surface rect
		Local dstPixmap:TPixmap = CreateStaticPixmap(lockedRect.pBits, lockedWidth, lockedHeight, lockedRect.Pitch, PF_BGRA8888)
		dstPixmap.Paste(pixmap.Window(0,0, lockedWidth, lockedHeight), 0, 0)
		
		dstsurf.UnlockRect()
		dstsurf.Release_()
	End Method


	'GetDC/BitBlt MUCH faster than locking backbuffer!	
	Method GrabPixmap:TPixmap( x:Int,y:Int,width:Int,height:Int ) Override
		'for render targets we handle it differently to the backbuffer
		If _CurrentRenderImageFrame <> _BackBufferRenderImageFrame
			Return _CurrentRenderImageFrame.RenderTargetToPixmap()
		EndIf

	
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
		For Local y:Int=0 Until height
			Local src:Int Ptr=Int Ptr( lockedrect.pBits+y*lockedrect.Pitch )
			Local dst:Int Ptr=Int Ptr( pixmap.PixelPtr( 0,y ) )
			For Local x:Int=0 Until width
				dst[x]=src[x] | $ff000000
			Next
		Next
		
		srcsurf.Release_
		dstsurf.Release_
		
		Return pixmap
	End Method
	
	Method SetResolution( width:Float,height:Float ) Override
		Local matrix:Float[]=[..
		2.0/width,0.0,0.0,0.0,..
		 0.0,-2.0/height,0.0,0.0,..
		 0.0,0.0,1.0,0.0,..
		 -1-(1.0/width),1+(1.0/height),1.0,1.0]

		_d3dDev.SetTransform D3DTS_PROJECTION,matrix
	End Method
	
	' Render Image --------------------
	Method AssignBackBufferRenderImage()
		Local BackBufferRenderImageFrame:TD3D9RenderImageFrame = New TD3D9RenderImageFrame
		BackBufferRenderImageFrame._width = _gw
		BackBufferRenderImageFrame._height = _gh
		_d3dDev.GetBackBuffer(0, 0, 0, Varptr BackBufferRenderImageFrame._surface)
	
		' cache it
		_BackBufferRenderImageFrame = BackBufferRenderImageFrame
		_CurrentRenderImageFrame = _BackBufferRenderImageFrame
		_CurrentRenderImageContainer = Null
		
		AddToRenderImageList(BackBufferRenderImageFrame)
	End Method
	
	Method AddToRenderImageList(RenderImage:TD3D9RenderImageFrame)
		_RenderImageList.AddLast(RenderImage)
	End Method
	
	Method RemoveFromRenderImageList(RenderImage:TD3D9RenderImageFrame)
		If(_RenderImageList.Contains(RenderImage))
			_RenderImageList.Remove(RenderImage)
		EndIf
	End Method

	Method CreateRenderImageFrame:TImageFrame(width:UInt, height:UInt, flags:Int) Override
		Local RenderImage:TD3D9RenderImageFrame = TD3D9RenderImageFrame.Create(width, height, flags)
		AddToRenderImageList(RenderImage)
		Return RenderImage
	End Method
	
	Method SetRenderImageFrame(RenderImageFrame:TImageFrame) Override
		If RenderImageFrame = _CurrentRenderImageFrame
			Return
		ElseIf renderImageFrame = Null
			renderImageFrame = _BackBufferRenderImageFrame
		EndIf

		Local D3D9RenderImageFrame:TD3D9RenderImageFrame = TD3D9RenderImageFrame(RenderImageFrame)
		_d3dDev.SetRenderTarget(0, D3D9RenderImageFrame._surface)
		_CurrentRenderImageFrame = D3D9RenderImageFrame
		'unset render image container (re-assign in SetRenderImage if called from there!)
		_CurrentRenderImageContainer = Null
		
		Local vp:Rect = _D3D9Scissor_BMaxViewport
		SetScissor(vp.x, vp.y, vp.width, vp.height)
		SetMatrixAndViewportToCurrentRenderImage()
	End Method

	Method GetRenderImageFrame:TImageFrame() Override
		' Return Null if currently rendering to the backbuffer
		If _BackBufferRenderImageFrame = _CurrentRenderImageFrame
			Return Null
		Else
			Return _CurrentRenderImageFrame
		EndIf
	End Method
	
	Method SetRenderImageContainer(renderImageContainer:Object) Override
		_CurrentRenderImageContainer = renderImageContainer
	EndMethod

	Method GetRenderImageContainer:Object() Override
		Return _CurrentRenderImageContainer
	EndMethod
		
	Function OnDeviceLost(obj:Object)
		Local Driver:TD3D9Max2DDriver = TD3D9Max2DDriver(obj)
		Local RenderImageList:TList = Driver._RenderImageList
		
		For Local RenderImage:TD3D9RenderImageFrame = EachIn RenderImageList
			RenderImage.OnDeviceLost()
		Next
		Driver.RemoveFromRenderImageList(_BackBufferRenderImageFrame)
	EndFunction
	
	Function OnDeviceReset(obj:Object)
		Local Driver:TD3D9Max2DDriver = TD3D9Max2DDriver(obj)
		Local RenderImageList:TList = Driver._RenderImageList

		For Local RenderImage:TD3D9RenderImageFrame = EachIn RenderImageList
			RenderImage.OnDeviceReset()
		Next
	EndFunction
		
Private
	Field _RenderImageList:TList = New TList
	
	Method SetMatrixAndViewportToCurrentRenderImage()
		Local width:Float = _CurrentRenderImageFrame._width
		Local height:Float = _CurrentRenderImageFrame._height
		
		Local matrix:Float[] = [..
		2.0 / width, 0.0, 0.0, 0.0,..
		0.0, -2.0/height, 0.0, 0.0,..
		0.0, 0.0, 1.0, 0.0,..
		-1 - (1.0 / width), 1 + (1.0 / height), 1.0, 1.0]

		_d3dDev.SetTransform D3DTS_PROJECTION,matrix
		
		Local Viewport:D3DViewport9 = New D3DViewport9
		Viewport.X = 0
		Viewport.Y = 0
		Viewport.width = width
		Viewport.height = height
		Viewport.MinZ = 0.0
		Viewport.MaxZ = 1.0
		_d3dDev.SetViewport(Viewport)
	EndMethod

	Method SetScissor(x:Int, y:Int, width:Int, height:Int)
		If x = 0 And y = 0 And width = _CurrentRenderImageFrame._width And height = _CurrentRenderImageFrame._height
			_d3dDev.SetRenderState(D3DRS_SCISSORTESTENABLE, False)
		Else
			_d3dDev.SetRenderState(D3DRS_SCISSORTESTENABLE, True)
			Local Scissor:Rect = New Rect(x, y, x + width, y + height)
			_d3dDev.SetScissorRect(Varptr Scissor)
		EndIf
	EndMethod
End Type

Rem
bbdoc: Get Direct3D9 Max2D Driver
about:
The returned driver can be used with #SetGraphicsDriver to enable Direct3D9 Max2D rendering.
End Rem
Function D3D9Max2DDriver:TD3D9Max2DDriver()
	Global _done:Int
	If Not _done
		_driver=New TD3D9Max2DDriver.Create()
		_done=True
	EndIf
	Return _driver
End Function

Local driver:TD3D9Max2DDriver=D3D9Max2DDriver()
If driver SetGraphicsDriver driver

?
