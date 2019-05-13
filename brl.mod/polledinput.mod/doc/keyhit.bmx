' keyhit.bmx

' the following code draws a circle every time the
' program detects the spacebar has been pressed
' and exits when it detects the ESCAPE key has
' been pressed

SuperStrict

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	If KeyHit(KEY_SPACE) DrawOval 0,0,640,480
	Flip
Wend
