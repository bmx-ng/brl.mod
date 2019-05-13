' cls.bmx

' a spinning text message
' remove the call to cls to illustrate the
' need for clearing the screen every frame

SuperStrict

Graphics 640,480
SetOrigin 320,240

Local frame:Float

While Not KeyHit(KEY_ESCAPE)
	Cls 
	SetRotation frame
	DrawText "Press Escape To Exit",0,0
	Flip
	frame:+1
Wend
