' mousey.bmx

' the following tracks the position of the mouse

SuperStrict

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawRect MouseX()-10,MouseY()-10,20,20
	Flip
Wend
