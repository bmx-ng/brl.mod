SuperStrict

Import MaxGUI.Drivers

Local window:tgadget=CreateWindow("events",0,0,320,240)

Local button1:tgadget=CreateButton("Button1",4,4,80,24,window)
Local button2:tgadget=CreateButton("Button2",84,4,80,24,window)

Repeat
	WaitEvent()
	If EventID()=EVENT_WINDOWCLOSE End
	
	Select EventSource()
		Case button1 Print "button1"
		Case button2 Print "button2"
	End Select
	
Forever
