'detects which mouse button was pressed 

SuperStrict

Graphics 640,480

Repeat
	DrawText "Click Mouse to exit" , 200 , 200
	Flip 
Until WaitMouse()
