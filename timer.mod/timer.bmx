
SuperStrict

Rem
bbdoc: Events/Timers
End Rem
Module BRL.Timer

ModuleInfo "Version: 1.04"
ModuleInfo "Author: Simon Armstrong, Mark Sibly, Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"

ModuleInfo "History: 1.04"
ModuleInfo "History: New factory-based timer implementation."
ModuleInfo "History: 1.03"
ModuleInfo "History: Update to use Byte Ptr instead of int."

Import BRL.Event

Rem
History:

Removed use of _cycle:TTimer field to keep timer's alive - didn't work with 'real' GC!
Replaced with BBRETAIN/BBRELEASE in C code.

Added check for OS timer creation failure

Added check for Win32 timer firing after timeKillEvent

Removed brl.standardio dependancy
End Rem

Type TTimer Abstract

	Method Ticks:Int() Abstract
	
	Method Stop() Abstract
	
	Method Fire() Abstract

	Method Wait:Int() Abstract
	
	Function Create:TTimer( hertz#,event:TEvent=Null ) Abstract

End Type

Rem
bbdoc: Create a timer
returns: A new timer object
about:
#CreateTimer creates a timer object that 'ticks' @hertz times per second.

Each time the timer ticks, @event will be emitted using #EmitEvent.

If @event is Null, an event with an @id equal to EVENT_TIMERTICK and 
@source equal to the timer object will be emitted instead.
End Rem
Function CreateTimer:TTimer( hertz#,event:TEvent=Null )
	If timer_factories Then
		Return timer_factories.Create(hertz, event)
	Else
		Throw "No Timer installed. Maybe Import BRL.TimerDefault ?"
	End If
End Function

Rem
bbdoc: Get timer tick counter
returns: The number of times @timer has ticked over
End Rem
Function TimerTicks:Int( timer:TTimer )
	Return timer.Ticks()
End Function

Rem
bbdoc: Wait until a timer ticks
returns: The number of ticks since the last call to #WaitTimer
End Rem
Function WaitTimer:Int( timer:TTimer )
	Return timer.Wait()
End Function

Rem
bbdoc: Stop a timer
about:Once stopped, a timer can no longer be used.
End Rem
Function StopTimer( timer:TTimer )
	timer.Stop
End Function

Private

Global timer_factories:TTimerFactory

Public

Type TTimerFactory
	Field _succ:TTimerFactory
	
	Method New()
		If _succ <> Null Then
			Throw "Timer already installed : " + _succ.GetName()
		End If
		_succ=timer_factories
		timer_factories=Self
	End Method
	
	Method GetName:String() Abstract
	
	Method Create:TTimer(hertz#,event:TEvent=Null) Abstract
		
End Type

