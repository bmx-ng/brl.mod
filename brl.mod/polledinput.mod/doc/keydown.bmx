' keydown.bmx

' the following code draws a circle if the
' program detects the spacebar is pressed
' and exits when it detects the ESCAPE key has
' been pressed

SuperStrict

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	If KeyDown(KEY_SPACE) DrawOval 0,0,640,480
	Flip
Wend
