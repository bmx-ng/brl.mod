SuperStrict

Import BRL.Graphics
Import BRL.SystemDefault
Import Pub.Direct3D11
Import "d3d11graphics.cpp"

Private
Function D3D11WndProc:LParam(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam) "win32"
 bbSystemEmitOSEvent hwnd,Int(msg),wp,lp,Null
 Select msg
 Case WM_CLOSE
  Return 0
 Case WM_SYSKEYDOWN
  If wp<>KEY_F4 Then Return 0
 End Select
 Return DefWindowProcW(hwnd,msg,wp,lp)
End Function

Function D3D11Require(ok:Int)
 If Not ok Then Throw "BRL D3D11: "+String.FromUTF8String(bmx_d3d11_error())
End Function

Public
Type TD3D11Display
 Field name:String
 Field x:Int,y:Int,width:Int,height:Int
 Field modes:TGraphicsMode[]
End Type

' Snapshot of attached outputs, with the primary display first. Refresh after display changes.
Function D3D11Displays:TD3D11Display[]()
 Local snapshot:Byte Ptr=bmx_d3d11_displays()
 Local result:TD3D11Display[]=New TD3D11Display[bmx_d3d11_display_count(snapshot)]
 For Local i:Int=0 Until result.Length
  Local display:TD3D11Display=New TD3D11Display
  display.name=String.FromWString(bmx_d3d11_display_info(snapshot,i,display.x,display.y,display.width,display.height))
  display.modes=New TGraphicsMode[bmx_d3d11_mode_count(snapshot,i)]
  Local count:Int
  For Local j:Int=0 Until display.modes.Length
   Local mode:TGraphicsMode=New TGraphicsMode
   bmx_d3d11_mode_info(snapshot,i,j,mode.width,mode.height,mode.hertz)
   mode.depth=32
   Local duplicate:Int
   For Local k:Int=0 Until count
    Local prior:TGraphicsMode=display.modes[k]
    If prior.width=mode.width And prior.height=mode.height And prior.hertz=mode.hertz Then duplicate=True;Exit
   Next
   If Not duplicate Then display.modes[count]=mode;count:+1
  Next
  display.modes=display.modes[..count];result[i]=display
 Next
 bmx_d3d11_displays_close(snapshot)
 Return result
End Function

' D3D11 foundation. Native interfaces are borrowed until device replacement or Close.
' Backbuffer views also become invalid when the swap chain is resized.
Type TD3D11Graphics Extends TGraphics
 Field _hwnd:Byte Ptr
 Field native:Byte Ptr
 Field _width:Int,_height:Int
 Field _depth:Int,_hertz:Int,_display:Int=-1
 Field _fullscreenWidth:Int,_fullscreenHeight:Int
 Field _borderless:Int
 Field _windowDpi:Int=96
 Field generation:Int=1
 Field _flags:Long
 Method Driver:TGraphicsDriver() Override
  Return D3D11GraphicsDriver()
 End Method
 Method GetSettings(width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var,x:Int Var,y:Int Var) Override
  Local rect:Int[4]
  GetClientRect(_hwnd,rect)
  If rect[2]>0 And rect[3]>0 Then
   _width=rect[2]; _height=rect[3]
   If Not _depth Then
    Local dpi:Int=bmx_d3d11_window_dpi(_hwnd)
    _width=Int((Long(_width)*_windowDpi+dpi/2)/dpi)
    _height=Int((Long(_height)*_windowDpi+dpi/2)/dpi)
   End If
  End If
  width=_width; height=_height; depth=_depth; hertz=_hertz; flags=_flags
  Local pt:Int[]=[0,0]
  ClientToScreen _hwnd,pt
  x=pt[0]; y=pt[1]
 End Method
 Method DeviceStatus:Int()
?d3d11_recovery_test
  If D3D11TestRemoved Then Return DXGI_ERROR_DEVICE_REMOVED
?
  Return bmx_d3d11_status(native)
 End Method
 ' The caller must release every device-dependent resource before replacement.
 Method RecreateDevice()
  If native Then bmx_d3d11_close(native)
  native=Null
?d3d11_recovery_test
  If D3D11TestRecreateFailure Then Throw "BRL D3D11: injected replacement failure"
  D3D11TestRemoved=False
?
  Local width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int
  GetSettings(width,height,depth,hertz,flags,x,y)
  native=bmx_d3d11_open(_hwnd,width,height,_display,_windowDpi)
  D3D11Require(native<>Null)
  If _depth Then D3D11Require(bmx_d3d11_recover_fullscreen(native,_fullscreenWidth,_fullscreenHeight,_hertz))
  If _borderless Then D3D11Require(bmx_d3d11_borderless(native,True))
  generation:+1
 End Method
 Method Ready:Int()
  Local result:Int=bmx_d3d11_ready(native)
  If result<0 Then D3D11Require(False)
  Return result
 End Method
 Method GetDirect3DDevice:ID3D11Device()
  Return bmx_d3d11_device(native)
 End Method
 Method GetDeviceContext:ID3D11DeviceContext()
  Return bmx_d3d11_context(native)
 End Method
 Method GetRenderTarget:Byte Ptr()
  Return bmx_d3d11_target(native)
 End Method
 Method SetFullscreen(enabled:Int,width:Int=0,height:Int=0,hertz:Int=0)
  If width=0 Then width=_width
  If height=0 Then height=_height
  Local result:Int=bmx_d3d11_fullscreen(native,enabled,width,height,hertz)
  SyncFullscreen()
  If _depth And result Then _fullscreenWidth=width;_fullscreenHeight=height
  D3D11Require(result)
 End Method
 Method SetBorderless(enabled:Int)
  Local result:Int=bmx_d3d11_borderless(native,enabled)
  SyncFullscreen()
  D3D11Require(result)
 End Method
 Method SyncFullscreen()
  _borderless=bmx_d3d11_is_borderless(native)
  If bmx_d3d11_is_fullscreen(native) Then
   _depth=32;_hertz=bmx_d3d11_hertz(native)
  Else
   _depth=0;_hertz=0
  End If
 End Method
 Method Resize(width:Int,height:Int) Override
  If _depth Then
   SetFullscreen(True,width,height)
  Else
   D3D11Require(bmx_d3d11_resize(native,width,height))
  End If
 End Method
 Method Position(x:Int,y:Int) Override
  D3D11Require(bmx_d3d11_position(native,x,y))
 End Method
 Method Close() Override
  If native Then bmx_d3d11_close(native)
  native=Null
  If _hwnd Then DestroyWindow(_hwnd)
  _hwnd=Null
  Local d:TD3D11GraphicsDriver=D3D11GraphicsDriver()
  If d.current=Self Then d.current=Null
  If d.live=Self Then d.live=Null
 End Method
End Type

Type TD3D11GraphicsDriver Extends TGraphicsDriver
 Field current:TD3D11Graphics
 Field live:TD3D11Graphics
 Field display:Int=-1
 Method GraphicsModes:TGraphicsMode[]() Override
  Local displays:TD3D11Display[]=D3D11Displays()
  Local index:Int=Max(0,display)
  If index>=displays.Length Then Return New TGraphicsMode[0]
  Return displays[index].modes
 End Method
 Method AttachGraphics:TGraphics(widget:Byte Ptr,flags:Long) Override
  Throw "BRL D3D11: widget attachment is not supported yet"
 End Method
 Method CreateGraphics:TD3D11Graphics(width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int) Override
  If live Then Throw "BRL D3D11: only one window is supported"
  If depth<>0 And depth<>32 Then Throw "BRL D3D11: fullscreen requires depth 32"
  Local displays:TD3D11Display[]=D3D11Displays()
  If display < -1 Or Max(0,display)>=displays.Length Then Throw "BRL D3D11: invalid or unavailable display"
  Local output:TD3D11Display=displays[Max(0,display)]
  Global registered:Int
  If Not registered Then
   Local name:Short Ptr="BBDX11Device Window Class".ToWString()
   Local wc:WNDCLASSW=New WNDCLASSW
   wc.SethInstance(GetModuleHandleW(Null))
   wc.SetlpfnWndProc(D3D11WndProc)
   wc.SethCursor(LoadCursorW(Null,Short Ptr IDC_ARROW))
   wc.SetlpszClassName(name)
   Local atom:Int=RegisterClassW(wc.classPtr)
   MemFree(name)
   If Not atom Then Throw "BRL D3D11: window class registration failed"
   registered=True
  End If
  Local rect:Int[]=[0,0,width,height]
  Local style:Int=WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX|WS_MAXIMIZEBOX|WS_THICKFRAME
  AdjustWindowRect(rect,style,False)
  Local centerX:Int=x=-1,centerY:Int=y=-1
  If x=-1 Then x=output.x+(output.width-width)/2
  If y=-1 Then y=output.y+(output.height-height)/2
  Local g:TD3D11Graphics=New TD3D11Graphics
  g._hwnd=CreateWindowExW(0,"BBDX11Device Window Class",AppTitle,style,x+rect[0],y+rect[1],rect[2]-rect[0],rect[3]-rect[1],Null,Null,GetModuleHandleW(Null),Null)
  If Not g._hwnd Then Throw "BRL D3D11: window creation failed"
  g._width=width; g._height=height; g._flags=flags
  g._display=display
  ' Windowed dimensions are always 96-DPI logical units, even in an aware process.
  g._windowDpi=96
  If Not bmx_d3d11_size_initial_window(g._hwnd,width,height,centerX,centerY) Then
   g.Close()
   D3D11Require(False)
  End If
  g.native=bmx_d3d11_open(g._hwnd,width,height,display,g._windowDpi)
  If Not g.native Then
   g.Close()
   D3D11Require(False)
  End If
  live=g
  ShowWindow(g._hwnd,SW_SHOW)
  If depth Then
   Try
    g.SetFullscreen(True,width,height,hertz)
   Catch error:Object
    g.Close()
    Throw error
   End Try
  End If
  Return g
 End Method
 Method SetGraphics(g:TGraphics) Override
  current=TD3D11Graphics(g)
 End Method
 Method Flip:Int(sync:Int) Override
  If Not current Then Return False
?d3d11_recovery_test
  If D3D11TestPresentRemoved Then
   D3D11TestPresentRemoved=False;D3D11TestRemoved=True
   Throw "BRL D3D11: injected removal during Present"
  End If
?
  Local result:Int=bmx_d3d11_present(current.native,sync<>0)
  If result<0 Then D3D11Require(False)
  Return result
 End Method
 Method CanResize:Int() Override
  Return True
 End Method
 Method ToString:String() Override
  Return "Direct3D11"
 End Method
End Type

Function D3D11GraphicsDriver:TD3D11GraphicsDriver()
 Global driver:TD3D11GraphicsDriver=New TD3D11GraphicsDriver
 Return driver
End Function

Extern "C"
 Function bmx_d3d11_displays:Byte Ptr()
 Function bmx_d3d11_displays_close(snapshot:Byte Ptr)
 Function bmx_d3d11_display_count:Int(snapshot:Byte Ptr)
 Function bmx_d3d11_display_info:Short Ptr(snapshot:Byte Ptr,index:Int,x:Int Var,y:Int Var,width:Int Var,height:Int Var)
 Function bmx_d3d11_mode_count:Int(snapshot:Byte Ptr,index:Int)
 Function bmx_d3d11_mode_info(snapshot:Byte Ptr,index:Int,mode:Int,width:Int Var,height:Int Var,hertz:Int Var)
 Function bmx_d3d11_borderless:Int(context:Byte Ptr,enabled:Int)
 Function bmx_d3d11_is_borderless:Int(context:Byte Ptr)
 Function bmx_d3d11_fullscreen:Int(context:Byte Ptr,enabled:Int,width:Int,height:Int,hertz:Int)
 Function bmx_d3d11_recover_fullscreen:Int(context:Byte Ptr,width:Int,height:Int,hertz:Int)
 Function bmx_d3d11_size_initial_window:Int(hwnd:Byte Ptr,width:Int,height:Int,centerX:Int,centerY:Int)
 Function bmx_d3d11_window_dpi:Int(hwnd:Byte Ptr)
 Function bmx_d3d11_is_fullscreen:Int(context:Byte Ptr)
 Function bmx_d3d11_hertz:Int(context:Byte Ptr)
 Function bmx_d3d11_error:Byte Ptr()
 Function bmx_d3d11_open:Byte Ptr(hwnd:Byte Ptr,width:Int,height:Int,display:Int,windowDpi:Int)
 Function bmx_d3d11_close(context:Byte Ptr)
 Function bmx_d3d11_status:Int(context:Byte Ptr)
 Function bmx_d3d11_ready:Int(context:Byte Ptr)
 Function bmx_d3d11_present:Int(context:Byte Ptr,sync:Int)
 Function bmx_d3d11_resize:Int(context:Byte Ptr,width:Int,height:Int)
 Function bmx_d3d11_position:Int(context:Byte Ptr,x:Int,y:Int)
 Function bmx_d3d11_device:ID3D11Device(context:Byte Ptr)
 Function bmx_d3d11_context:ID3D11DeviceContext(context:Byte Ptr)
 Function bmx_d3d11_target:Byte Ptr(context:Byte Ptr)
End Extern

?d3d11_recovery_test
Global D3D11TestRemoved:Int
Global D3D11TestRecreateFailure:Int
Global D3D11TestPresentRemoved:Int
Global D3D11TestOperationRemoved:Int
?
