SuperStrict

Graphics 640,480

Local myEventID:Int = AllocUserEventId("My optional event description")
Local myEvent:TEvent = CreateEvent(myEventID)
Local myTimer:TTImer = CreateTimer(10, myEvent)
Local myQuitEventID:Int = AllocUserEventId("We want to quit now")
Local myQuitEvent:TEvent = CreateEvent(myQuitEventID)

Repeat
	WaitEvent
	Cls
	Select EventID()
		Case myEventID
			DrawText "Timer has ticked " + TimerTicks(myTimer) + " times",10,15
			
			' exit application after 50 ticks
			If TimerTicks(myTimer) = 50
				EmitEvent(myQuitEvent)
			EndIf
		Case myQuitEventID
			End
	End Select
	Flip
Until AppTerminate()
