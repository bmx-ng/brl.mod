' mousez.bmx

' prints mousez() the mousewheel position

SuperStrict

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	DrawText "MouseZ()="+MouseZ(),0,0
	Flip
Wend
