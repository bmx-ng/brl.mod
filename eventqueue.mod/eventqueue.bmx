
SuperStrict

Rem
bbdoc: Events/Event queue
End Rem
Module BRL.EventQueue

ModuleInfo "Version: 1.03"
ModuleInfo "Author: Mark Sibly, Bruce A Henderson"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.03"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.02"
ModuleInfo "History: Reuse TEvent objects."
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: Fixed CurrentEvent being retained in queue array"
ModuleInfo "History: 1.00 Release"
ModuleInfo "History: Created module"

Import BRL.Event
Import BRL.System

Private

Const QUEUESIZE:Int=256
Const QUEUEMASK:Int=QUEUESIZE-1
Global queue:TEvent[QUEUESIZE],queue_put:Int,queue_get:Int

Function Hook:Object( id:Int,data:Object,context:Object )
	Local ev:TEvent=TEvent( data )
	If Not ev Return Null
	
	Select ev.id
	Case EVENT_WINDOWMOVE,EVENT_WINDOWSIZE,EVENT_TIMERTICK,EVENT_GADGETACTION
		PostEvent ev,True
	Default
		PostEvent ev
	End Select
	
	Return data
End Function

AddHook EmitEventHook,Hook,Null,-10000

Global NullEvent:TEvent=New TEvent

Public

Rem
bbdoc: Current Event
about: The #CurrentEvent global variable contains the event most recently returned by
#PollEvent or #WaitEvent.
End Rem
Global CurrentEvent:TEvent=NullEvent

Rem
bbdoc: Examine the next event in the event queue
about:
#PeekEvent examines the next event in the event queue, without removing it from the 
event queue or modifying the #CurrentEvent global variable.

If there are no events in the event queue, #PeekEvent returns #Null.
End Rem
Function PeekEvent:TEvent()
	If queue_get=queue_put
		PollSystem
		If queue_get=queue_put Return Null
	EndIf
	Return queue[queue_get & QUEUEMASK]
End Function

Rem
bbdoc: Get the next event from the event queue
returns: The id of the next event in the event queue, or 0 if the event queue is empty
about:
#PollEvent removes an event from the event queue and updates the #CurrentEvent
global variable.

If there are no events in the event queue, #PollEvent returns 0.
End Rem
Function PollEvent:Int()
	If queue_get=queue_put
		PollSystem
		If queue_get=queue_put
			CurrentEvent=NullEvent
			Return 0
		EndIf
	EndIf
	CurrentEvent=queue[queue_get & QUEUEMASK]
	queue_get:+1
	Return CurrentEvent.id
End Function

Rem
bbdoc: Get the next event from the event queue, waiting if necessary
returns: The id of the next event in the event queue
about:
#WaitEvent removes an event from the event queue and updates the #CurrentEvent
global variable.

If there are no events in the event queue, #WaitEvent halts program execution until
an event is available.
End Rem
Function WaitEvent:Int()
	While queue_get=queue_put
		WaitSystem
	Wend
	CurrentEvent=queue[queue_get & QUEUEMASK]
	queue_get:+1
	Return CurrentEvent.id
End Function

Rem
bbdoc: Post an event to the event queue
about:#PostEvent adds an event to the end of the event queue.

The @update flag can be used to update an existing event. If @update is True
and an event with the same @id and @source is found in the event 
queue, the existing event will be updated instead of @event
being added to the event queue. This can be useful to prevent high frequency
events such as timer events from flooding the event queue.
End Rem
Function PostEvent:Int( event:TEvent,update:Int=False )
	If update
		Local i:Int=queue_get
		While i<>queue_put
			Local t:TEvent=queue[i & QUEUEMASK ]
			If t.id=event.id And t.source=event.source
				t.data=event.data
				t.mods=event.mods
				t.x=event.x
				t.y=event.y
				t.extra=event.extra
				Return True
			EndIf
			i:+1
		Wend
	EndIf
	If queue_put-queue_get=QUEUESIZE Return False
	Local q:TEvent = queue[queue_put & QUEUEMASK]
	If Not q Then
		q = New TEvent
		queue[queue_put & QUEUEMASK] = q
	End If
	q.id = event.id
	q.source = event.source
	q.data=event.data
	q.mods=event.mods
	q.x=event.x
	q.y=event.y
	q.extra=event.extra
	queue_put:+1
	Return True
End Function

Rem
bbdoc: Get current event id
returns: The @id field of the #CurrentEvent global variable
EndRem
Function EventID:Int()
	Return CurrentEvent.id
End Function

Rem
bbdoc: Get current event data
returns: The @data field of the #CurrentEvent global variable
EndRem
Function EventData:Int()
	Return CurrentEvent.data
End Function

Rem
bbdoc: Get current event modifiers
returns: The @mods field of the #CurrentEvent global variable
EndRem
Function EventMods:Int()
	Return CurrentEvent.mods
End Function

Rem
bbdoc: Get current event x value
returns: The @x field of the #CurrentEvent global variable
EndRem
Function EventX:Int()
	Return CurrentEvent.x
End Function

Rem
bbdoc: Get current event y value
returns: The @y field of the #CurrentEvent global variable
EndRem
Function EventY:Int()
	Return CurrentEvent.y
End Function

Rem
bbdoc: Get current event extra value
returns: The @extra field of the #CurrentEvent global variable
EndRem
Function EventExtra:Object()
	Return CurrentEvent.extra
End Function

Rem
bbdoc: Get current event extra value converted to a string
returns: The @extra field of the #CurrentEvent global variable converted to a string
EndRem
Function EventText$()
	Return String( CurrentEvent.extra )
End Function

Rem
bbdoc: Get current event source object
returns: The @source field of the #CurrentEvent global variable
EndRem
Function EventSource:Object()
	Return CurrentEvent.source
End Function

Rem
bbdoc: Get current event source object handle
returns: The @source field of the #CurrentEvent global variable converted to an integer handle
EndRem
Function EventSourceHandle:Size_T()
	Return HandleFromObject( CurrentEvent.source )
End Function
