
SuperStrict

Rem
bbdoc: Graphics/Graphics
End Rem
Module BRL.Graphics

ModuleInfo "Version: 1.09"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.09"
ModuleInfo "History: Changed to SuperStrict"
ModuleInfo "History: Extended flags to Long"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Mouse repositioned only in fullscreen mode"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: Flip mode for attached graphics changed to 0"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Fixed softsync period init bug"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed softsync routine to prevent overflow"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Graphics exceptions now caught"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Added DefaultGraphicsFlags() Function"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Restored FlipHook"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Added default flags to SetGraphicsDriver"

Import BRL.System
Import BRL.PolledInput

Rem
bbdoc: Flip Hook id
about:
Use this id with #AddHook to register a function that
is called every #Flip.
End Rem
Global FlipHook:Int=AllocHookId()

Const GRAPHICS_BACKBUFFER:Int=	$2
Const GRAPHICS_ALPHABUFFER:Int=	$4
Const GRAPHICS_DEPTHBUFFER:Int=	$8
Const GRAPHICS_STENCILBUFFER:Int=	$10
Const GRAPHICS_ACCUMBUFFER:Int=	$20
Const GRAPHICS_BORDERLESS:Int=$40

'Const GRAPHICS_SWAPINTERVAL0=	$40
'Const GRAPHICS_SWAPINTERVAL1=	$80

'Const GRAPHICS_SWAPINTERVALMASK=GRAPHICS_SWAPINTERVAL0|GRAPHICS_SWAPINTERVAL1

Type TGraphics

	Method _pad()
	End Method

	Method Driver:TGraphicsDriver() Abstract

	Method GetSettings( width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var,flags:Long Var, x:Int Var, y:Int Var ) Abstract

	Method Close() Abstract
	
	Method Resize(width:Int, height:Int) Abstract
	
	Method Position(x:Int, y:Int) Abstract

End Type

Type TGraphicsMode

	Field width:Int,height:Int,depth:Int,hertz:Int
	Field display:Int
	
	Method ToString$() Override
		Return width+","+height+","+depth+" "+hertz+"Hz (" + display + ")"
	End Method

End Type

Type TGraphicsDriver

	Method GraphicsModes:TGraphicsMode[]() Abstract
	
	Method AttachGraphics:TGraphics( widget:Byte Ptr,flags:Long ) Abstract
	
	Method CreateGraphics:TGraphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int ) Abstract
	
	Method SetGraphics( g:TGraphics ) Abstract
	
	Method Flip:Int( sync:Int ) Abstract
	
	Method CanResize:Int()
		Return False
	End Method

End Type

Private

Global _defaultFlags:Long
Global _driver:TGraphicsDriver
Global _graphicsModes:TGraphicsMode[]
Global _graphics:TGraphics,_gWidth:Int,_gHeight:Int,_gDepth:Int,_gHertz:Int,_gFlags:Long,_gx:Int,_gy:Int

Global _exGraphics:TGraphics

'Only valid if _exGraphics=_graphics
Global _softSync:Int,_hardSync:Int,_syncRate:Int,_syncPeriod:Int,_syncFrac:Int,_syncAccum:Int,_syncTime:Int

Public

Global GraphicsSeq:Int=1

Function BumpGraphicsSeq()
	GraphicsSeq:+1
	If Not GraphicsSeq GraphicsSeq=1
End Function

Rem
bbdoc: Set current graphics driver
about:
The current graphics driver determines what kind of graphics are created when you use
the #CreateGraphics or #Graphics functions, as well as the graphics modes available.

The #GLGraphicsDriver, #GLMax2DDriver, #D3D7Max2DDriver and #D3D9Max2DDriver functions can all be
used to obtain a graphics driver.

The @defaultFlags parameter allows you to specify graphics flags that will be applied to any
graphics created with #CreateGraphics or #Graphics.
End Rem
Function SetGraphicsDriver( driver:TGraphicsDriver,defaultFlags:Long=GRAPHICS_BACKBUFFER )
	BumpGraphicsSeq
	If driver<>_driver
		If _driver And _graphics _driver.SetGraphics Null
		_graphicsModes=Null
		_driver=driver
	EndIf
	_defaultFlags=defaultFlags
	_graphics=Null
	_gWidth=0
	_gHeight=0
	_gDepth=0
	_gHertz=0
	_gFlags=0
	_gx=0
	_gy=0
End Function

Rem
bbdoc: Get current graphics driver
about:
Returns the current graphics driver as selected by #SetGraphicsDriver
End Rem
Function GetGraphicsDriver:TGraphicsDriver()
	Return _driver
End Function

Rem
bbdoc: Get current default graphics flags
End Rem
Function DefaultGraphicsFlags:Long()
	Return _defaultFlags
End Function

Rem
bbdoc: Get graphics modes available under the current graphics driver
returns: An array of TGraphicsMode objects
about:
A TGraphicsMode object contains the following fields: @width, @height, @depth and @hertz
End Rem
Function GraphicsModes:TGraphicsMode[]()
	If Not _graphicsModes _graphicsModes=_driver.GraphicsModes()
	Return _graphicsModes[..]
End Function

Rem
bbdoc: Get number of graphics modes available under the current graphics driver
returns: Number of available Graphics modes
about:
Use #GetGraphicsMode To obtain information about an individual Graphics mode
End Rem
Function CountGraphicsModes:Int()
	Return GraphicsModes().length
End Function

Rem
bbdoc: Get information about a graphics mode
about:
#GetGraphicsMode returns information about a specific graphics mode. @mode should be
in the range 0 (inclusive) to the value returned by #CountGraphicsModes (exclusive).
End Rem
Function GetGraphicsMode( index:Int,width:Int Var,height:Int Var,depth:Int Var,hertz:Int Var )
	Local Mode:TGraphicsMode=GraphicsModes()[index]
	width=Mode.width
	height=Mode.height
	depth=Mode.depth
	hertz=Mode.hertz
End Function

Rem
bbdoc: Determine if a graphics mode exists
returns: True if a matching graphics mode is found
about:
A value of 0 for any of @width, @height, @depth or @hertz will cause that
parameter to be ignored.
End Rem
Function GraphicsModeExists:Int( width:Int,height:Int,depth:Int=0,hertz:Int=0 )
	For Local Mode:TGraphicsMode=EachIn GraphicsModes()
		If width And width<>Mode.width Continue
		If height And height<>Mode.height Continue
		If depth And depth<>Mode.depth Continue
		If hertz And hertz<>Mode.hertz Continue
		Return True
	Next
	Return False
End Function

Rem
bbdoc: Create a graphics object
returns: A graphics object
about:
#CreateGraphics creates a graphics object. To use this object for rendering, you will
first have to select it using #SetGraphics.

The kind of graphics object returned depends upon the current graphics driver as set by
#SetGraphicsDriver.
End Rem
Function CreateGraphics:TGraphics( width:Int,height:Int,depth:Int,hertz:Int,flags:Long,x:Int,y:Int )
	flags:|_defaultFlags
	Local g:TGraphics
	Try
		g=_driver.CreateGraphics( width,height,depth,hertz,flags,x,y )
	Catch ex:Object
?Debug
		WriteStdout "CreateGraphics failed:"+ex.ToString()
?
	End Try
	Return g
End Function

Function AttachGraphics:TGraphics( widget:Byte Ptr,flags:Long )
	flags:|_defaultFlags
	Local g:TGraphics
	Try
		g=_driver.AttachGraphics( widget,flags )
	Catch ex:Object
?Debug
		WriteStdout "AttachGraphics failed:"+ex.ToString()
?
	End Try
	Return g
End Function

Rem
bbdoc: Close a graphics object
about:
Once closed, a graphics object can no longer be used.
End Rem
Function CloseGraphics( g:TGraphics )
	If g=_exGraphics _exGraphics=Null
	If g=_graphics SetGraphics Null
	g.Close
End Function

Rem
bbdoc: Set current graphics object
about:
#SetGraphics will also change the current graphics driver if @g uses a different driver
than the current driver.
End Rem
Function SetGraphics( g:TGraphics )
	If Not g
		If _driver And _graphics _driver.SetGraphics Null
		_graphics=Null
		_gWidth=0
		_gHeight=0
		_gDepth=0
		_gHertz=0
		_gFlags=0
		_gx=0
		_gy=0
		Return
	EndIf
	Local d:TGraphicsDriver=g.Driver()
	If d<>_driver
		If _driver And _graphics _driver.SetGraphics Null
		_graphicsModes=Null
		_driver=d
	EndIf
	g.GetSettings _gWidth,_gHeight,_gDepth,_gHertz,_gFlags,_gx,_gy
	d.SetGraphics g
	_graphics=g
End Function

Rem
bbdoc: Resize the current graphics object to @width, @height.
End Rem
Function GraphicsResize( width:Int, height:Int )
	If _driver And _driver.CanResize() And _graphics Then
		_gWidth = width
		_gHeight = height
		_graphics.Resize(width, height)
	End If
End Function

Rem
bbdoc: Sets the position of the graphics window to @x, @y.
End Rem
Function GraphicsPosition( x:Int, y:Int )
	If _driver And _graphics Then
		_gx = x
		_gy = y
		_graphics.Position(x, y)
	End If
End Function

Rem
bbdoc: Get width of current graphics object
returns: The width, in pixels, of the current graphics object
about:
The current graphics object can be changed using #SetGraphics.
End Rem
Function GraphicsWidth:Int()
	Return _gWidth
End Function

Rem
bbdoc: Get height of current graphics object
returns: The height, in pixels, of the current graphics object
about:
The current graphics object can be changed using #SetGraphics.
End Rem
Function GraphicsHeight:Int()
	Return _gHeight
End Function

Rem
bbdoc: Get depth of current graphics object
returns: The depth, in bits, of the current graphics object
about:
The current graphics object can be changed using #SetGraphics.
End Rem
Function GraphicsDepth:Int()
	Return _gDepth
End Function

Rem
bbdoc: Get refresh rate of current graphics object
returns: The refresh rate, in frames per second, of the current graphics object
about:
The current graphics object can be changed using #SetGraphics.
End Rem
Function GraphicsHertz:Int()
	Return _gHertz
End Function

Rem
bbdoc: Get flags of current graphics object
returns: The flags of the current graphics object
about:
The current graphics object can be changed using #SetGraphics.
End Rem
Function GraphicsFlags:Long()
	Return _gFlags
End Function

Function GraphicsX:Int()
	Return _gx
End Function

Function GraphicsY:Int()
	Return _gy
End Function

Rem
bbdoc: Flip current graphics object
about:
#Flip swap the front and back buffers of the current graphics objects.

If @sync is 0, then the flip occurs as soon as possible. If @sync is 1, then the flip occurs
on the next vertical blank.

If @sync is -1 and the current graphics object was created with the #Graphics command,
then flips will occur at the graphics object's refresh rate, unless the graphics object was 
created with a refresh rate of 0 in which case flip occurs immediately.

If @sync is -1 and the current graphics object was NOT created with the #Graphics command,
then the flip will occur on the next vertical blank.
End Rem
Function Flip( sync:Int=-1 )
	RunHooks FlipHook,Null

	If sync<>-1
		_driver.Flip sync
		Return
	EndIf
	
	If _graphics<>_exGraphics
		_driver.Flip True
		Return
	EndIf

	If _softSync
		_syncTime:+_syncPeriod
		_syncAccum:+_syncFrac
		If _syncAccum>=_syncRate
			_syncAccum:-_syncRate
			_syncTime:+1
		EndIf
		Local dt:Int=_syncTime-MilliSecs()
		If dt>0
			Delay dt
		Else
			_syncTime:-dt
		EndIf
		_driver.Flip False
	Else If _hardSync
		_driver.Flip True
	Else
		_driver.Flip False
	EndIf

End Function

Rem
Function Flip( sync=-1 )
	RunHooks FlipHook,Null
	If sync<>-1
		_driver.Flip sync
		Return
	EndIf
	If _graphics<>_exGraphics Or Not _softSync
		Local sync=False
		If _gDepth sync=True
		_driver.Flip sync
		Return
	EndIf
	_syncTime:+_syncPeriod
	_syncAccum:+_syncFrac
	If _syncAccum>=_syncRate
		_syncAccum:-_syncRate
		_syncTime:+1
	EndIf
	Local dt=_syncTime-MilliSecs()
	If dt>0
		Delay dt
	Else
		_syncTime:-dt
	EndIf
	_driver.Flip False
End Function
End Rem

Rem
bbdoc: Begin graphics
returns: A graphics object
about:
#Graphics is a convenience function that simplifies the process of creating a graphics
object.

Once #Graphics has executed, you can begin rendering immediately without any need for 
#SetGraphics.

#Graphics also enables #{polled input} mode, providing a simple way to monitor the keyboard
and mouse.
End Rem
Function Graphics:TGraphics( width:Int,height:Int,depth:Int=0,hertz:Int=60,flags:Long=0,x:Int=-1,y:Int=-1 )
	EndGraphics
	flags:|_defaultFlags
	
	Local g:TGraphics=CreateGraphics( width,height,depth,hertz,flags,x,y )
	If Not g Return Null
	
	BumpGraphicsSeq

	SetGraphics g

	If depth
		_softSync=False
		_hardSync=(hertz<>0)
		MoveMouse width/2,height/2
	Else
		_hardSync=False
		_softSync=(hertz<>0)
	EndIf
	
	If _softSync
		_syncRate=hertz
		If _syncRate _syncPeriod=1000/_syncRate Else _syncPeriod=0
		_syncFrac=1000-_syncPeriod*_syncRate
		_syncAccum=0
		_syncTime=MilliSecs()
	EndIf

	EnablePolledInput
	
	_exGraphics=g
	
	Global _onEnd:Int
	If Not _onEnd
		_onEnd=True
		OnEnd EndGraphics
	EndIf

	Return g
End Function

Rem
Function Graphics:TGraphics( width,height,depth=0,hertz=60,flags=0 )

	EndGraphics
	flags:|_defaultFlags

	Local g:TGraphics=CreateGraphics( width,height,depth,hertz,flags )
	If Not g Return
	
	GraphicsSeq:+1
	If Not GraphicsSeq GraphicsSeq=1
	
	SetGraphics g
	
	_softSync=True
	If Not hertz
		_softSync=False
	Else If depth
		Local e=MilliSecs()+1000,n
		While e-MilliSecs()>0
			Local t=MilliSecs()
			_driver.Flip True
			t=(MilliSecs()-t)-1000/hertz
			If t>=-1 And t<=1
				n:+1
				If n<3 Continue
				_softSync=False
				Exit
			EndIf
			n=0
		Wend
	EndIf
	_syncRate=hertz
	If _syncRate _syncPeriod=1000/_syncRate Else _syncPeriod=0
	_syncFrac=1000-_syncPeriod*_syncRate
	_syncAccum=0
	_syncTime=MilliSecs()

	_exGraphics=g

	If depth
		MoveMouse width/2,height/2
	EndIf
	
	EnablePolledInput
	
	Global _onEnd
	If Not _onEnd
		_onEnd=True
		OnEnd EndGraphics
	EndIf

	Return g

End Function
End Rem

Rem
bbdoc: End graphics
about:
#EndGraphics closes the graphics object returned by #Graphics.
End Rem
Function EndGraphics()
	If Not _exGraphics Return

	GraphicsSeq:+1
	If Not GraphicsSeq GraphicsSeq=1

	DisablePolledInput

	CloseGraphics _exGraphics
End Function
