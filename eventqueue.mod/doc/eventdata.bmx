SuperStrict

Import MaxGUI.Drivers

Local window:tgadget=CreateWindow("leftclick/rightclick",0,0,320,240)

Local canvas:tgadget=CreateCanvas(4,4,160,160,window,1)

Repeat
	WaitEvent()
	If EventID()=EVENT_WINDOWCLOSE End
	
	Select EventData()
		Case 1 Print "leftclick"
		Case 2 Print "rightclick"
	End Select
Forever
