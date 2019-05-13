SuperStrict

Graphics 640,480

Const MY_EVENT:Int = 99
Local myEvent:TEvent=CreateEvent(MY_EVENT)
Local myTimer:TTImer = CreateTimer(10,myEvent)
Repeat
	WaitEvent
	Cls
	If EventID() = MY_EVENT
		DrawText "Timer has ticked " + TimerTicks(myTimer) + " times",10,15
	EndIf
	Flip
Until AppTerminate()
