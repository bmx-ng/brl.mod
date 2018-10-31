SuperStrict

Rem
bbdoc: Events/TimersDefault
End Rem
Module BRL.TimerDefault

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Simon Armstrong, Mark Sibly, Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

ModuleInfo "History: 1.00"
ModuleInfo "History: Default/System Timer implementation."

Import BRL.Timer
Import BRL.SystemDefault

?Win32
Import "timer.win32.c"
?MacOS
Import "timer.macos.m"
?Linux
Import "timer.linux.c"
?

Extern
Function bbTimerStart:Byte Ptr( hertz#,timer:TTimer )
Function bbTimerStop( handle:Byte Ptr,timer:TTimer )
End Extern

Function _TimerFired( timer:TTimer ) { nomangle }
	timer.Fire
End Function

Type TDefaultTimer Extends TTimer

	Method Ticks:Int()
		Return _ticks
	End Method
	
	Method Stop()
		If Not _handle Return
		bbTimerStop _handle,Self
		_handle=0
		_event=Null
	End Method
	
	Method Fire()
		If Not _handle Return
		_ticks:+1
		If _event
			EmitEvent _event
		Else
			EmitEvent CreateEvent( EVENT_TIMERTICK,Self,_ticks )
		EndIf
	End Method

	Method Wait:Int()
		If Not _handle Return 0
		Local n:Int
		Repeat
			WaitSystem
			n=_ticks-_wticks
		Until n
		_wticks:+n
		Return n
	End Method
	
	Function Create:TTimer( hertz#,event:TEvent=Null )
		Local t:TDefaultTimer =New TDefaultTimer
		Local handle:Byte Ptr=bbTimerStart( hertz,t )
		If Not handle Return Null
		t._event=event
		t._handle=handle
		Return t
	End Function

	Field _ticks:Int
	Field _wticks:Int
	'Field _cycle:TTimer	'no longer used...see history
	Field _event:TEvent
	Field _handle:Byte Ptr
?win32
	Function _GetHandle:Byte Ptr(timer:TDefaultTimer) { nomangle }
		Return timer._handle
	End Function
?
End Type

Type TDefaultTimerFactory Extends TTimerFactory
	
	Method GetName:String()
		Return "DefaultTimer"
	End Method
	
	Method Create:TTimer(hertz#,event:TEvent=Null)
		Return TDefaultTimer.Create( hertz,event )
	End Method
		
End Type

New TDefaultTimerFactory
