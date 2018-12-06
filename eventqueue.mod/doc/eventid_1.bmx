SuperStrict

Import MaxGUI.Drivers

Local window:tgadget=CreateWindow("events",0,0,320,240)

Local button:tgadget=CreateButton("Button1",4,4,80,24,window)
Local canvas:tgadget=CreateCanvas(84,4,80,24,window,1)

Repeat
	WaitEvent()
	If EventID()=EVENT_WINDOWCLOSE End
	
	Select EventID()
		Case EVENT_GADGETACTION Print "gadgetaction (buttonpress, etc.)"
		Case EVENT_MOUSEMOVE Print "canvas mousemove"
	End Select
	
Forever
