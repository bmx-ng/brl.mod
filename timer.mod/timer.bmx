
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
Import pub.stdc

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



Rem
bbdoc: A high resolution timing mechanism.
End Rem
Type TChrono

	Const TICKS_PER_MILLIS:Int = 10000
	Const TICKS_PER_SEC:Int = TICKS_PER_MILLIS * 1000
	Const SECS_TO_NS:ULong = 1000000000:ULong
	
	Const FREQUENCY:Double = 1000000000.0
	Const tickFrequency:Double = TICKS_PER_SEC / FREQUENCY
	
	Field isRunning:Int
	Field startTimestamp:ULong
	Field elapsed:ULong
	
	Rem
	bbdoc: Creates a new #TChrono instance.
	End Rem
	Method New()
		Reset()
	End Method
	
	Method Reset()
		elapsed = 0
		isRunning = False
		startTimestamp = 0
	End Method
	
	Rem
	bbdoc: Restarts the timing mechanism.
	End Rem
	Method Restart()
		elapsed = 0
		startTimestamp = GetTimestamp()
		isRunning = True
	End Method

	Rem
	bbdoc: Returns the number of elapsed ticks since the timing mechanism was started.
	End Rem
	Method GetElapsedTicks:Long()
		Local timeElapsed:Long = elapsed
		
		If isRunning Then
			Local currentTimestamp:ULong = GetTimestamp()
			Local elapsedUntilNow:ULong = currentTimestamp - startTimestamp
			timeElapsed :+ elapsedUntilNow
		End If
		
		Return timeElapsed
	End Method
	
	Rem
	bbdoc: Returns the number of elapsed milliseconds since the timing mechanism was started.
	End Rem
	Method GetElapsedMilliseconds:ULong()
		Return GetElapsedDateTimeTicks() / TICKS_PER_MILLIS
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetElapsedDateTimeTicks:ULong()
		Local ticks:Double = GetElapsedTicks()
		ticks :* tickFrequency
		Return ULong(ticks)
	End Method
	
	Rem
	bbdoc: Returns the current timestamp, in ns.
	End Rem
	Function GetTimestamp:ULong()
?Not macos
		Local tv:STimeSpec
		clock_gettime_(1, tv)
		Return tv.tv_sec * SECS_TO_NS + tv.tv_nsec
?macos
		Return mach_absolute_time_ns()
?
	End Function
	
	Rem
	bbdoc: Starts the timimg mechanism.
	End Rem
	Method Start()
		If Not isRunning Then
			startTimestamp = GetTimestamp()
			isRunning = True
		End If
	End Method
	
	Rem
	bbdoc: Stops the timing mechanism.
	End Rem
	Method Stop()
		If isRunning Then
			Local endTimestamp:ULong = GetTimestamp()
			Local elapsedThisPeriod:ULong = endTimestamp - startTimestamp
			elapsed :+ elapsedThisPeriod
			isRunning = False
		End If
	End Method
	
	Rem
	bbdoc: Creates, and optionally starts an instance of #TChrono.
	End Rem
	Function Create:TChrono(start:Int = True)
		Local stopWatch:TChrono = New TChrono
		If start Then
			stopWatch.Start()
		End If
		Return stopWatch
	End Function
	
End Type
