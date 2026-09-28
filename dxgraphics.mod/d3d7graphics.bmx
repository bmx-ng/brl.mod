SuperStrict

Import BRL.Graphics
Import BRL.SystemDefault
Import Pub.Win32
Import "d3d7graphics.cpp"

Private
Function D3D7WndProc:LParam(hwnd:Byte Ptr,msg:UInt,wp:WParam,lp:LParam) "win32"
 bbSystemEmitOSEvent hwnd,Int(msg),wp,lp,Null
 Select msg
 Case WM_CLOSE
  Return 0
 Case WM_SYSKEYDOWN
  If wp<>KEY_F4 Then Return 0
 End Select
 Return DefWindowProcW(hwnd,msg,wp,lp)
End Function

Function D3D7Require(ok:Int)
 If Not ok Then Throw "BRL D3D7: "+String.FromUTF8String(bmx_d3d7_error())
End Function

Public
' Windowed D3D7 foundation. Native interfaces are borrowed and valid until Close.
Type TD3D7Graphics Extends TGraphics
 Field _hwnd:Byte Ptr
 Field native:Byte Ptr
 Field _width:Int,_height:Int
 Field _flags:Long
 Method Driver:TGraphicsDriver() Override
  Return D3D7GraphicsDriver()
 End Method
 Method GetSettings(width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var,x:Int Var,y:Int Var) Override
  width=_width; height=_height; depth=0; hertz=0; flags=_flags
  Local pt:Int[]=[0,0]
  ClientToScreen _hwnd,pt
  x=pt[0]; y=pt[1]
 End Method
 Method Ready:Int()
  Local result:Int=bmx_d3d7_ready(native)
  If result<0 Then D3D7Require(False)
  Return result
 End Method
 Method Generation:Int()
  Return bmx_d3d7_generation(native)
 End Method
 Method DirectDraw7:Byte Ptr()
  Return bmx_d3d7_dd(native)
 End Method
 Method Direct3DDevice7:Byte Ptr()
  Return bmx_d3d7_device(native)
 End Method
 Method RenderSurface:Byte Ptr()
  Return bmx_d3d7_surface(native)
 End Method
 Method Resize(width:Int,height:Int) Override
  Throw "BRL D3D7: window resizing is not supported yet"
 End Method
 Method Position(x:Int,y:Int) Override
  Throw "BRL D3D7: window positioning is not supported yet"
 End Method
 Method Close() Override
  If native Then bmx_d3d7_close(native)
  native=Null
  If _hwnd Then DestroyWindow(_hwnd)
  _hwnd=Null
  Local d:TD3D7GraphicsDriver=D3D7GraphicsDriver()
  If d.current=Self Then d.current=Null
  If d.live=Self Then d.live=Null
 End Method
End Type

Type TD3D7GraphicsDriver Extends TGraphicsDriver
 Field current:TD3D7Graphics
 Field live:TD3D7Graphics
 Method GraphicsModes:TGraphicsMode[]() Override
  ' Exclusive fullscreen is not exposed by this first implementation.
  Return New TGraphicsMode[0]
 End Method
 Method AttachGraphics:TGraphics(widget:Byte Ptr,flags:Long) Override
  Throw "BRL D3D7: widget attachment is not supported yet"
 End Method
 Method CreateGraphics:TD3D7Graphics(width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int) Override
  If live Then Throw "BRL D3D7: only one window is supported"
  If depth<>0 Then Throw "BRL D3D7: fullscreen is not supported yet"
  Global registered:Int
  If Not registered Then
   Local name:Short Ptr="BBDX7Device Window Class".ToWString()
   Local wc:WNDCLASSW=New WNDCLASSW
   wc.SethInstance(GetModuleHandleW(Null))
   wc.SetlpfnWndProc(D3D7WndProc)
   wc.SethCursor(LoadCursorW(Null,Short Ptr IDC_ARROW))
   wc.SetlpszClassName(name)
   Local atom:Int=RegisterClassW(wc.classPtr)
   MemFree(name)
   If Not atom Then Throw "BRL D3D7: window class registration failed"
   registered=True
  End If
  Local rect:Int[]=[0,0,width,height]
  Local style:Int=WS_CAPTION|WS_SYSMENU|WS_MINIMIZEBOX
  AdjustWindowRect(rect,style,False)
  Local desktop:Int[4]
  GetWindowRect(GetDesktopWindow(),desktop)
  If x=-1 Then x=(desktop[2]-width)/2
  If y=-1 Then y=(desktop[3]-height)/2
  Local g:TD3D7Graphics=New TD3D7Graphics
  g._hwnd=CreateWindowExW(0,"BBDX7Device Window Class",AppTitle,style,x+rect[0],y+rect[1],rect[2]-rect[0],rect[3]-rect[1],Null,Null,GetModuleHandleW(Null),Null)
  If Not g._hwnd Then Throw "BRL D3D7: window creation failed"
  g._width=width; g._height=height; g._flags=flags
  g.native=bmx_d3d7_open(g._hwnd,width,height)
  If Not g.native Then
   g.Close()
   D3D7Require(False)
  End If
  live=g
  ShowWindow(g._hwnd,SW_SHOW)
  Return g
 End Method
 Method SetGraphics(g:TGraphics) Override
  current=TD3D7Graphics(g)
 End Method
 Method Flip:Int(sync:Int) Override
  If Not current Then Return False
  Local result:Int=bmx_d3d7_present(current.native,sync<>0)
  If result<0 Then D3D7Require(False)
  Return result
 End Method
 Method ToString:String() Override
  Return "Direct3D7"
 End Method
End Type

Function D3D7GraphicsDriver:TD3D7GraphicsDriver()
 Global driver:TD3D7GraphicsDriver=New TD3D7GraphicsDriver
 Return driver
End Function

Extern "C"
 Function bmx_d3d7_error:Byte Ptr()
 Function bmx_d3d7_open:Byte Ptr(hwnd:Byte Ptr,width:Int,height:Int)
 Function bmx_d3d7_close(context:Byte Ptr)
 Function bmx_d3d7_ready:Int(context:Byte Ptr)
 Function bmx_d3d7_generation:Int(context:Byte Ptr)
 Function bmx_d3d7_present:Int(context:Byte Ptr,sync:Int)
 Function bmx_d3d7_dd:Byte Ptr(context:Byte Ptr)
 Function bmx_d3d7_device:Byte Ptr(context:Byte Ptr)
 Function bmx_d3d7_surface:Byte Ptr(context:Byte Ptr)
End Extern
