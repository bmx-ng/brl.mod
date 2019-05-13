'
' Drop a file onto the window to see EventText() return the path.
'
SuperStrict

Import MaxGUI.Drivers

Local window:tgadget=CreateWindow("move mouse",0,0,320,240,Null,15|WINDOW_ACCEPTFILES)

Repeat
	WaitEvent()
	If EventID()=EVENT_WINDOWCLOSE End
	
	If EventID()=EVENT_WINDOWACCEPT
		Print EventText()
	EndIf
Forever
