SuperStrict

Import MaxGUI.Drivers

Local window:tgadget=CreateWindow("move mouse",0,0,320,240)

Local canvas:tgadget=CreateCanvas(4,4,160,160,window,1)

Repeat
	WaitEvent()
	If EventID()=EVENT_WINDOWCLOSE End
	
	If EventID()=EVENT_MOUSEMOVE
		Print EventY()
	EndIf
Forever
