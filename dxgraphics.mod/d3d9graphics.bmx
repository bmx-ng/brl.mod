
SuperStrict

Import BRL.Graphics
Import "d3d9window.c"

Import Pub.DirectX

Import BRL.LinkedList
Import brl.systemdefault

Private
Extern "C"
 Function bmx_d9_initial_pixels:Int(value:Int)
 Function bmx_d9_window_logical:Int(hwnd:Byte Ptr,value:Int)
 Function bmx_d9_window_on_adapter:Int(hwnd:Byte Ptr,monitor:Byte Ptr)
 Function bmx_d9_window_resize:Int(hwnd:Byte Ptr,width:Int,height:Int,logicalSize:Int)
 Function bmx_d9_window_position:Int(hwnd:Byte Ptr,x:Int,y:Int)
 Function bmx_d9_window_create:Byte Ptr(hwnd:Byte Ptr)
 Function bmx_d9_window_free(state:Byte Ptr)
 Function bmx_d9_window_mode:Int(state:Byte Ptr,enabled:Int)
 Function bmx_d9_window_geometry(hwnd:Byte Ptr,w:Int Var,h:Int Var,x:Int Var,y:Int Var)
End Extern
Extern
	Function bbAppIcon:Byte Ptr(inst:Byte Ptr)="HICON bbAppIcon(HINSTANCE)!"
	Function GetSystemMetrics:Int(index:Int) "win32"="int __stdcall GetSystemMetrics(int)!"
End Extern

Global _wndClass:String="BBDX9Device Window Class"

Global _driver:TD3D9graphicsDriver

Global _d3d:IDirect3D9
Global _d3dCaps:D3DCAPS9
Global _modes:TGraphicsMode[]

Global _d3dDev:IDirect3DDevice9
Global _d3dDevRefs:Int

Global _resetPending:Int
Global _resetNotified:Int

Global _presentParams:D3DPRESENT_PARAMETERS

Global _graphics:TD3D9Graphics

Global _autoRelease:TList

Global _d3dOccQuery:IDirect3DQuery9

Type TD3D9AutoRelease
	Field unk:IUnknown_
End Type

Function D3D9WndProc:LParam( hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam) "win32"

	bbSystemEmitOSEvent hwnd,Int(msg),wp,lp,Null
	
	Select msg
	Case WM_CLOSE
		Return 0
	Case WM_SYSKEYDOWN
		If wp<>KEY_F4 Return 0
	Case WM_ACTIVATE
		If _graphics _graphics.OnWMActivate(wp)
		Return 0
	End Select

	Return DefWindowProcW( hwnd,msg,wp,lp )

End Function

Function OpenD3DDevice:Int( hwnd:Byte Ptr,width:Int,height:Int,depth:Int,hertz:Int,flags:Long)
	If _d3dDevRefs
		If Not _presentParams.Windowed Return False
		If depth<>0 Return False
		_d3dDevRefs:+1
		Return True
	EndIf

	Local windowed:Int=(depth=0)
	Local fullscreen:Int=(depth<>0)	

	Local pp:D3DPRESENT_PARAMETERS
	pp.BackBufferWidth = width
	pp.BackBufferHeight = height
	pp.BackBufferCount = 1
	pp.BackBufferFormat = (D3DFMT_X8R8G8B8 * fullscreen) + (D3DFMT_UNKNOWN * windowed)
	pp.MultiSampleType = D3DMULTISAMPLE_NONE
	pp.SwapEffect = (D3DSWAPEFFECT_DISCARD * fullscreen) + (D3DSWAPEFFECT_COPY * windowed)
	pp.hDeviceWindow = hwnd
	pp.Windowed = windowed
	pp.Flags = D3DPRESENTFLAG_LOCKABLE_BACKBUFFER
	pp.FullScreen_RefreshRateInHz = hertz * fullscreen
	pp.PresentationInterval = D3DPRESENT_INTERVAL_ONE	'IMMEDIATE
	
	Local cflags:Int=D3DCREATE_FPU_PRESERVE
	
	'_d3dDev' = New IDirect3DDevice9

	Function CheckDepthFormat:Int(format:Int)
	    Return _d3d.CheckDeviceFormat(0,D3DDEVTYPE_HAL,D3DFMT_X8R8G8B8,D3DUSAGE_DEPTHSTENCIL,D3DRTYPE_SURFACE,format)=D3D_OK
	End Function

	If flags&GRAPHICS_DEPTHBUFFER Or flags&GRAPHICS_STENCILBUFFER
	    pp.EnableAutoDepthStencil = True
	    If flags&GRAPHICS_STENCILBUFFER
	        If Not CheckDepthFormat( D3DFMT_D24S8 )
	            If Not CheckDepthFormat( D3DFMT_D24FS8 )
	                If Not CheckDepthFormat( D3DFMT_D24X4S4 )
	                    If Not CheckDepthFormat( D3DFMT_D15S1 )
	                        Return False
	                    Else
	                        pp.AutoDepthStencilFormat = D3DFMT_D15S1
	                    EndIf
	                Else
	                    pp.AutoDepthStencilFormat = D3DFMT_D24X4S4
	                EndIf
	            Else
	                pp.AutoDepthStencilFormat = D3DFMT_D24FS8
	            EndIf
	        Else
	            pp.AutoDepthStencilFormat = D3DFMT_D24S8
	        EndIf
	    Else
	        If Not CheckDepthFormat( D3DFMT_D32 )
	            If Not CheckDepthFormat( D3DFMT_D24X8 )
	                If Not CheckDepthFormat( D3DFMT_D16 )
	                    Return False
	                Else
	                    pp.AutoDepthStencilFormat = D3DFMT_D16
	                EndIf
	            Else
	                pp.AutoDepthStencilFormat = D3DFMT_D24X8
	            EndIf
	        Else
	            pp.AutoDepthStencilFormat = D3DFMT_D32
	        EndIf
	    EndIf
	EndIf
	
	'OK, try hardware vertex processing...
	Local tflags:Int=D3DCREATE_PUREDEVICE|D3DCREATE_HARDWARE_VERTEXPROCESSING|cflags
	If _d3d.CreateDevice( 0,D3DDEVTYPE_HAL,hwnd,tflags,pp,_d3dDev )<0

		'Failed! Try mixed vertex processing...
		tflags=D3DCREATE_MIXED_VERTEXPROCESSING|cflags
		If _d3d.CreateDevice( 0,D3DDEVTYPE_HAL,hwnd,tflags,pp,_d3dDev )<0

			'Failed! Try software vertex processing...	
			tflags=D3DCREATE_SOFTWARE_VERTEXPROCESSING|cflags
			If _d3d.CreateDevice( 0,D3DDEVTYPE_HAL,hwnd,tflags,pp,_d3dDev )<0
			
				_d3dDev = Null
				'Failed! Go home and watch family guy instead...
				Return False
			EndIf
		EndIf
	EndIf

	_presentParams=pp
	_resetPending=False
	_resetNotified=False

	_d3dDevRefs:+1
	
	_autoRelease=New TList

	'Occlusion Query
	If Not _d3dOccQuery
		'_d3dOccQuery = New IDirect3DQuery9
		If _d3ddev.CreateQuery(9,_d3dOccQuery)<0 '9 hardcoded for D3DQUERYTYPE_OCCLUSION
			DebugLog "Cannot create Occlussion Query!"
			_d3dOccQuery = Null
		EndIf
	EndIf
	If _d3dOccQuery _d3dOccQuery.Issue(2) 'D3DISSUE_BEGIN
	
	Return True
End Function

Function CloseD3DDevice()
	_d3dDevRefs:-1
	If Not _d3dDevRefs

		For Local t:TD3D9AutoRelease=EachIn _autoRelease
			t.unk.Release_
		Next
		_autoRelease=Null

		If _d3dOccQuery _d3dOccQuery.Release_
		_d3dOccQuery = Null

		_d3dDev.Release_
		_d3dDev=Null
		_presentParams=Null
	EndIf
End Function

Function ResetD3DDevice:Int()
	_resetPending=True
	If Not _resetNotified
		_resetNotified=True
		If _graphics Then _graphics.OnDeviceLost()
	EndIf
	If _d3dOccQuery
		_d3dOccQuery.Release_
		_d3dOccQuery = Null
	Else
		'_d3dOccQuery' = New IDirect3DQuery9
	EndIf
	
	Local params:D3DPRESENT_PARAMETERS=_presentParams
	Local result:Int
?d3d9_recovery_test
	If D3D9TestResetLost Then
		result=D3DERR_DEVICELOST
	Else
		result=_d3dDev.Reset(params)
	EndIf
?Not d3d9_recovery_test
	result=_d3dDev.Reset(params)
?
	If result=D3DERR_DEVICELOST Then Return False
	If result<0 Then Throw "D3D9 Reset failed: " + result
	_resetPending=False
	_resetNotified=False

	If _graphics
		_graphics.OnDeviceReset()
	EndIf
	If _d3ddev.CreateQuery(9,_d3dOccQuery)<0
		_d3dOccQuery = Null
		DebugLog "Cannot create Occlussion Query!"
	EndIf
	If _d3dOccQuery _d3dOccQuery.Issue(2) 'D3DISSUE_BEGIN
	Return True
End Function

Public

' Fault injection is absent from normal module builds.
?d3d9_recovery_test
Global D3D9TestStatus:Int=D3D_OK
Global D3D9TestResetLost:Int
?

Global UseDX9RenderLagFix:Int = 0

Type TD3D9DeviceStateCallback
	Field _fnCallback(obj:Object)
	Field _obj:Object
	
	Method Create:TD3D9DeviceStateCallback(fnCallback(obj:Object), obj:Object)
		_fnCallback = fnCallback
		_obj = obj

		Return Self
	EndMethod
EndType


Type TD3D9Graphics Extends TGraphics
	Method New()
		_onDeviceLostCallbacks = New TList
		_onDeviceResetCallbacks = New TList
	EndMethod

	Method Attach:TD3D9Graphics( hwnd:Byte Ptr,flags:Long )
		Local rect:Int[4]
		GetClientRect hwnd,rect
		Local width:Int=rect[2]-rect[0]
		Local height:Int=rect[3]-rect[1]

		OpenD3DDevice hwnd,width,height,0,0,flags
		
		_hwnd=hwnd
		_width=width
		_height=height
		_flags=flags
		_attached=True

		Return Self
	End Method
	
	Method Create:TD3D9Graphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int)
		Const SM_CYCAPTION:Int = 4
		Const SM_CXBORDER:Int = 5
		Const SM_CYFIXEDFRAME:Int = 8
		
		Local wstyle:Int

		If depth
			wstyle=WS_VISIBLE|WS_POPUP
		Else
			wstyle=WS_VISIBLE|WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX
		EndIf
		
		Local rect:Int[4]

		If Not depth
			If _logicalSize Then width=bmx_d9_initial_pixels(width);height=bmx_d9_initial_pixels(height)
			Local desktopRect:Int[4]
			GetWindowRect GetDesktopWindow(),desktopRect
				
			If x = -1 Then
				x = desktopRect[2]/2-width/2
			Else
				x = x + GetSystemMetrics(SM_CXBORDER)
			End If
			If y = -1 Then
				y = desktopRect[3]/2-height/2
			Else
				y = y + GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYFIXEDFRAME)
			End If
			rect[0]=x;
			rect[1]=y;
			rect[2]=rect[0]+width;
			rect[3]=rect[1]+height;
				
			AdjustWindowRect rect,wstyle,0
		EndIf

		Local hwnd:Byte Ptr=CreateWindowExW( 0,_wndClass,AppTitle,wstyle,rect[0],rect[1],rect[2]-rect[0],rect[3]-rect[1],Null,Null,GetModuleHandleA(Null),Null )
		If Not hwnd Return Null

		If Not depth
			GetClientRect hwnd,rect
			width=rect[2]-rect[0];height=rect[3]-rect[1]
			If _logicalSize Then
				width=bmx_d9_window_logical(hwnd,width);height=bmx_d9_window_logical(hwnd,height)
			EndIf
		EndIf

		If Not OpenD3DDevice( hwnd,width,height,depth,hertz,flags )
			DestroyWindow hwnd
			Return Null
		EndIf
		
		_hwnd=hwnd
		_width=width
		_height=height
		_depth=depth
		_hertz=hertz
		_flags=flags
		
		Return Self
	End Method
	
	Method OnWMActivate(wp:WParam)
		If _runtimeFullscreen Then Return ' Runtime switching uses real device-reset callbacks.
		' this covers the alt-tab issue for render-texture management
		Local activate:Short = wp & $FFFF
		Local state:Short = (wp Shr 16) & $FFFF
		
		' only release when fullscreen
		If _depth <> 0
			If activate = 0			' deactive
				OnDeviceLost()
			EndIf
			If activate = 1
				OnDeviceReset()		' active
			EndIf
		EndIf
	EndMethod

	Method AddDeviceLostCallback(fnOnDeviceLostCallback(obj:Object), obj:Object)
		_onDeviceLostCallbacks.AddLast(New TD3D9DeviceStateCallback.Create(fnOnDeviceLostCallback, obj))
	EndMethod
	
	Method AddDeviceResetCallback(fnOnDeviceResetCallback(obj:Object), obj:Object)
		_onDeviceResetCallbacks.AddLast(New TD3D9DeviceStateCallback.Create(fnOnDeviceResetCallback, obj))
	EndMethod
	
	Method RemoveDeviceLostCallback(fnOnDeviceLostCallback(obj:Object))
		For Local statecallback:TD3D9DeviceStateCallback = EachIn _onDeviceLostCallbacks
			If statecallback._fnCallback = fnOnDeviceLostCallback
				_onDeviceLostCallbacks.Remove(statecallback)
				Exit
			EndIf
		Next
	EndMethod

	Method RemoveDeviceResetCallback(fnOnDeviceResetCallback(obj:Object))
		For Local statecallback:TD3D9DeviceStateCallback = EachIn _onDeviceResetCallbacks
			If statecallback._fnCallback = fnOnDeviceResetCallback
				_onDeviceResetCallbacks.Remove(statecallback)
				Exit
			EndIf
		Next
	EndMethod

	Method OnDeviceLost()
		For Local callback:TD3D9DeviceStateCallback = EachIn _onDeviceLostCallbacks
			callback._fnCallback(callback._obj)
		Next
	EndMethod
	
	Method OnDeviceReset()
		For Local callback:TD3D9DeviceStateCallback = EachIn _onDeviceResetCallbacks
			callback._fnCallback(callback._obj)
		Next
	EndMethod
	
	Method GetDirect3DDevice:IDirect3DDevice9()
		Return _d3dDev
	End Method

	Method ValidateSize()
		If _attached
			Local rect:Int[4]
			GetClientRect _hwnd,rect
			_width=rect[2]-rect[0]
			_height=rect[3]-rect[1]
			If _width>_presentParams.BackBufferWidth Or _height>_presentParams.BackBufferHeight
				_presentParams.BackBufferWidth = Max( _width,_presentParams.BackBufferWidth) 
				_presentParams.BackBufferHeight = Max( _height,_presentParams.BackbufferHeight) 
				ResetD3DDevice
			EndIf
		EndIf
	End Method
	
	Method PresentResult:Int(result:Int)
		If result>=0 Then Return True
		If result=D3DERR_DEVICELOST Or result=D3DERR_DEVICENOTRESET Then Return False
		Throw "D3D9 Present failed: " + result
	End Method

	Method DeviceStatus:Int()
?d3d9_recovery_test
		If D3D9TestStatus<>D3D_OK Then Return D3D9TestStatus
?
		Local result:Int=_d3dDev.TestCooperativeLevel()
		If result=D3D_OK And _resetPending Then Return D3DERR_DEVICENOTRESET
		Return result
	End Method

	'NOTE: Returns 1 if flip was successful, otherwise device lost or reset...
	Method Flip:Int( sync:Int )
	
		If sync sync=D3DPRESENT_INTERVAL_ONE Else sync=D3DPRESENT_INTERVAL_IMMEDIATE
		If sync<>_presentParams.PresentationInterval
			_presentParams.PresentationInterval = sync
			_resetPending=True
		EndIf
		
		Local status:Int=DeviceStatus()
		Select status
		Case D3DERR_DRIVERINTERNALERROR
			Throw "D3D Internal Error"
		Case D3D_OK
			If _resetPending

				ResetD3DDevice

			Else If _attached
			
				Local rect:Int[]=[0,0,_width,_height]
				Return PresentResult(_d3dDev.Present( rect,rect,_hwnd,Null ))

			Else

				Return PresentResult(_d3dDev.Present( Null,Null,_hwnd,Null ))

			EndIf
		Case D3DERR_DEVICENOTRESET
			ResetD3DDevice
		Case D3DERR_DEVICELOST
			Return False
		Default
			Throw "D3D9 device status failed: " + status
		End Select
		
		
	End Method

	Method Driver:TGraphicsDriver() Override
		Return _driver
	End Method
	
	Method ClientSize(width:Int Var,height:Int Var)
		Local x:Int,y:Int
		bmx_d9_window_geometry(_hwnd,width,height,x,y)
	End Method

	Method GetSettings( width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var, x:Int Var, y:Int Var ) Override
		'
		ValidateSize
		'
		width=_width
		height=_height
		depth=_depth
		hertz=_hertz
		If _borderless Then hertz=0
		Local cw:Int,ch:Int
		bmx_d9_window_geometry(_hwnd,cw,ch,x,y)
		flags=_flags
	End Method

	Method Close() Override
		If Not _hwnd Return
		CloseD3DDevice
		bmx_d9_window_free(_windowState);_windowState=Null
		If Not _attached DestroyWindow( _hwnd )
		_hwnd=0
	End Method

	Method AutoRelease( unk:IUnknown_ )
		Local t:TD3D9AutoRelease=New TD3D9AutoRelease
		t.unk=unk
		_autoRelease.AddLast t
	End Method
	
	Method ReleaseNow( unk:IUnknown_ )
		For Local t:TD3D9AutoRelease=EachIn _autoRelease
			If t.unk=unk
				unk.Release_
				_autoRelease.Remove t
				Return
			EndIf
		Next
	End Method

	Method SupportsFullscreen:Int()
		Return _hwnd<>Null And Not _attached And _d3dDevRefs=1 And (Not _depth Or _runtimeFullscreen)
	End Method

	Method SelectFullscreenMode:TGraphicsMode(width:Int,height:Int,hertz:Int)
		If width<0 Or height<0 Or hertz<0 Then Throw "D3D9: fullscreen dimensions and rate must not be negative"
		If Not width Then width=_width
		If Not height Then height=_height
		Local selected:TGraphicsMode
		Local nativeMode:D3DDISPLAYMODE
		For Local i:Int=0 Until _d3d.GetAdapterModeCount(D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8)
			If _d3d.EnumAdapterModes(D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8,i,nativeMode)<0 Then Continue
			If nativeMode.width<>width Or nativeMode.height<>height Then Continue
			If hertz And nativeMode.refreshRate<>hertz Then Continue
			If selected And selected.hertz>=nativeMode.refreshRate Then Continue
			selected=New TGraphicsMode
			selected.width=width;selected.height=height;selected.depth=32;selected.hertz=nativeMode.refreshRate
		Next
		If Not selected Then Throw "D3D9: requested exclusive display mode is unavailable"
		Return selected
	End Method

	Method SetFullscreen(enabled:Int,width:Int=0,height:Int=0,hertz:Int=0)
		If Not SupportsFullscreen() Then Throw "D3D9: exclusive switching requires a single owned runtime window"
		If _graphics<>Self Then Throw "D3D9: select graphics before switching fullscreen"
		Local mode:TGraphicsMode
		If enabled Then
			mode=SelectFullscreenMode(width,height,hertz)
			If Not bmx_d9_window_on_adapter(_hwnd,_d3d.GetAdapterMonitor(D3DADAPTER_DEFAULT)) Then Throw "D3D9: exclusive fullscreen requires the default adapter's monitor"
			If _depth And mode.width=_width And mode.height=_height And mode.hertz=_hertz Then Return
		Else If Not _depth Then
			If _borderless Then SetBorderless(False)
			Return
		End If
		If DeviceStatus()<>D3D_OK Then Throw "D3D9: device unavailable for fullscreen transition"
		If _borderless Then SetBorderless(False)
		Local previous:D3DPRESENT_PARAMETERS=_presentParams
		Local oldWidth:Int=_width,oldHeight:Int=_height,oldDepth:Int=_depth,oldHertz:Int=_hertz
		If Not _windowState Then _windowState=bmx_d9_window_create(_hwnd)
		If Not _windowState Then Throw "D3D9: cannot allocate window state"
		_runtimeFullscreen=True
		If enabled Then
			If Not _depth Then
				_windowWidth=_width;_windowHeight=_height;_windowHertz=_hertz
			End If
			If Not bmx_d9_window_mode(_windowState,True) Then Throw "D3D9: cannot prepare fullscreen window"
			_width=mode.width;_height=mode.height;_depth=32;_hertz=mode.hertz
			_presentParams.Windowed=False
			_presentParams.BackBufferFormat=D3DFMT_X8R8G8B8
			_presentParams.SwapEffect=D3DSWAPEFFECT_DISCARD
			_presentParams.FullScreen_RefreshRateInHz=_hertz
		Else
			_width=_windowWidth;_height=_windowHeight;_depth=0;_hertz=_windowHertz
			_presentParams.Windowed=True
			_presentParams.BackBufferFormat=D3DFMT_UNKNOWN
			_presentParams.SwapEffect=D3DSWAPEFFECT_COPY
			_presentParams.FullScreen_RefreshRateInHz=0
		End If
		_presentParams.BackBufferWidth=_width
		_presentParams.BackBufferHeight=_height
		Local complete:Int
		Try
			complete=ResetD3DDevice()
		Catch error:Object
			_presentParams=previous
			_width=oldWidth;_height=oldHeight;_depth=oldDepth;_hertz=oldHertz
			Try
				ResetD3DDevice()
			Catch rollback:Object
				If Not oldDepth Then bmx_d9_window_mode(_windowState,False)
				Throw error.ToString()+"; rollback reset failed: "+rollback.ToString()
			End Try
			If Not oldDepth Then bmx_d9_window_mode(_windowState,False)
			Throw error
		End Try
		If Not enabled Then
			If Not bmx_d9_window_mode(_windowState,False) Then Throw "D3D9: device is windowed but restoring window geometry failed"
		End If
		If Not complete Then Throw "D3D9: fullscreen transition awaits device recovery"
	End Method

	Field _runtimeFullscreen:Int
	Field _windowWidth:Int,_windowHeight:Int,_windowHertz:Int

	Method SupportsBorderless:Int()
		Return _hwnd<>Null And Not _attached And Not _depth And _d3dDevRefs=1
	End Method

	Method SetBorderless(enabled:Int)
		If Not SupportsBorderless() Then Throw "D3D9: borderless requires a single owned windowed device"
		If _graphics<>Self Then Throw "D3D9: select the graphics context before switching borderless"
		enabled=enabled<>0
		If enabled=_borderless Then Return
		If DeviceStatus()<>D3D_OK Then Throw "D3D9: device unavailable for borderless transition"
		If Not _windowState Then _windowState=bmx_d9_window_create(_hwnd)
		If Not _windowState Then Throw "D3D9: cannot allocate window state"
		If Not bmx_d9_window_mode(_windowState,enabled) Then Throw "D3D9: borderless window transition failed"
		_borderless=enabled
		Local x:Int,y:Int
		bmx_d9_window_geometry(_hwnd,_width,_height,x,y)
		If _logicalSize Then _width=bmx_d9_window_logical(_hwnd,_width);_height=bmx_d9_window_logical(_hwnd,_height)
		_presentParams.BackBufferWidth=_width
		_presentParams.BackBufferHeight=_height
		If Not ResetD3DDevice() Then Throw "D3D9: window changed; device reset pending recovery"
	End Method

	Field _borderless:Int
	Field _windowState:Byte Ptr
	Method Resize(width:Int, height:Int) Override
		If Not SupportsBorderless() Or _borderless Then Throw "D3D9: resize requires a single owned windowed device"
		If _graphics<>Self Then Throw "D3D9: select the graphics context before resizing"
		If width<=0 Or height<=0 Then Throw "D3D9: window dimensions must be positive"
		If width=_width And height=_height Then Return
		If DeviceStatus()<>D3D_OK Then Throw "D3D9: device unavailable for resize"
		If Not bmx_d9_window_resize(_hwnd,width,height,_logicalSize) Then Throw "D3D9: window resize failed"
		Local x:Int,y:Int
		bmx_d9_window_geometry(_hwnd,_width,_height,x,y)
		If _logicalSize Then _width=bmx_d9_window_logical(_hwnd,_width);_height=bmx_d9_window_logical(_hwnd,_height)
		_presentParams.BackBufferWidth=_width
		_presentParams.BackBufferHeight=_height
		If Not ResetD3DDevice() Then Throw "D3D9: window resized; device reset pending recovery"
	End Method

	Method Position(x:Int, y:Int) Override
		If Not _hwnd Or _attached Or _depth Or _borderless Then Throw "D3D9: position requires an owned windowed context"
		If Not bmx_d9_window_position(_hwnd,x,y) Then Throw "D3D9: window position failed"
	End Method
	
	Field _hwnd:Byte Ptr
	Field _width:Int
	Field _height:Int
	Field _depth:Int
	Field _hertz:Int
	Field _flags:Int
	Field _logicalSize:Int
	Field _attached:Int
	Field _onDeviceLostCallbacks:TList
	Field _onDeviceResetCallbacks:TList
End Type

Type TD3D9GraphicsDriver Extends TGraphicsDriver
	Method CanResize:Int() Override
		Return True
	End Method

	Method Create:TD3D9GraphicsDriver()

		'create d3d9
		'If Not d3d9Lib Return Null
		
		_d3d=Direct3DCreate9( 32 )
		If Not _d3d Return Null

		'get caps
		'_d3dCaps=New D3DCAPS9
		If _d3d.GetDeviceCaps( D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,_d3dCaps)<0
			_d3d.Release_
			_d3d=Null
			Return Null
		EndIf

		'enum graphics modes		
		Local n:Int=_d3d.GetAdapterModeCount( D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8 )
		_modes=New TGraphicsMode[n]
		Local j:Int

		Local d3dmode:D3DDISPLAYMODE' = New D3DDISPLAYMODE
		For Local i:Int=0 Until n
			If _d3d.EnumAdapterModes( D3DADAPTER_DEFAULT,D3DFMT_X8R8G8B8,i,d3dmode)<0
				Continue
			EndIf

			Local Mode:TGraphicsMode=New TGraphicsMode
			Mode.width=d3dmode.width
			Mode.height=d3dmode.height
			Mode.hertz=d3dmode.refreshRate
			Mode.depth=32
			_modes[j]=Mode
			j:+1
		Next
		_modes=_modes[..j]
	
	
		Local name:Short Ptr = _wndClass.ToWString()
		'register wndclass
		Local wndclass:WNDCLASSW=New WNDCLASSW
		wndclass.SethInstance(GetModuleHandleW( Null ))
		wndclass.SetlpfnWndProc(D3D9WndProc)
		wndclass.SethCursor(LoadCursorW( Null,Short Ptr IDC_ARROW ))
		wndClass.SethIcon(bbAppIcon(GetModuleHandleW( Null )))
		wndclass.SetlpszClassName(name)
		RegisterClassW wndclass.classPtr
		MemFree name

		Return Self
	End Method
	
	Method GraphicsModes:TGraphicsMode[]() Override
		Return _modes
	End Method
	
	Method AttachGraphics:TD3D9Graphics( widget:Byte Ptr,flags:Long ) Override
		Return New TD3D9Graphics.Attach( widget,flags )
	End Method
	
	Method CreateGraphics:TD3D9Graphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int) Override
		Return New TD3D9Graphics.Create( width,height,depth,hertz,flags,x,y )
	End Method

	' Opt-in 96-DPI units for clients that map native input separately.
	' Ordinary CreateGraphics retains BRL's native client-coordinate contract.
	Method CreateLogicalGraphics:TD3D9Graphics(width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int)
		Local graphics:TD3D9Graphics=New TD3D9Graphics
		graphics._logicalSize=True
		Return graphics.Create(width,height,depth,hertz,flags,x,y)
	End Method

	Method Graphics:TD3D9Graphics()
		Return _graphics
	End Method
		
	Method SetGraphics( g:TGraphics ) Override
		_graphics=TD3D9Graphics( g )
	End Method
	
	Method Flip:Int( sync:Int ) Override
		Local present:Int = _graphics.Flip(sync)
		If present And UseDX9RenderLagFix Then
			Local pixelsdrawn:Int
			If _d3dOccQuery
				_d3dOccQuery.Issue(1) 'D3DISSUE_END
				
				While _d3dOccQuery.GetData( Varptr pixelsdrawn,4,1 )=1 'D3DGETDATA_FLUSH
					If _graphics.DeviceStatus()<>D3D_OK Then Exit
					If  _d3dOccQuery.GetData( Varptr pixelsdrawn,4,1 )<0 Exit
				Wend

				If _graphics.DeviceStatus()=D3D_OK Then _d3dOccQuery.Issue(2) 'D3DISSUE_BEGIN
			EndIf
		End If
		
		Return present
	End Method
	
	Method GetDirect3D:IDirect3D9()
		Return _d3d
	End Method

	Method ToString:String() Override
		Return "TD3D9GraphicsDriver"
	End Method

End Type

Function D3D9GraphicsDriver:TD3D9GraphicsDriver()
	Global _done:Int
	If Not _done
		_driver=New TD3D9GraphicsDriver.Create()
		_done=True
	EndIf
	Return _driver
End Function
