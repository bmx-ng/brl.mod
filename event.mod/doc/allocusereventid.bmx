SuperStrict

Graphics 640,480

Local myEventID:Int = AllocUserEventId("My optional event description")
Local myEvent:TEvent = CreateEvent(myEventID)
Local myTimer:TTImer = CreateTimer(10, myEvent)
Repeat
	WaitEvent
	Cls
	If EventID() = myEventID
		DrawText "Timer has ticked " + TimerTicks(myTimer) + " times",10,15
	EndIf
	Flip
Until AppTerminate()
