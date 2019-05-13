' mousedown.bmx

SuperStrict

Graphics 640,480

While Not KeyHit(KEY_ESCAPE)
	Cls
	If MouseDown(1) DrawRect 0,0,200,200
	If MouseDown(2) DrawRect 200,0,200,200
	If MouseDown(3) DrawRect 400,0,200,200
	Flip
Wend
