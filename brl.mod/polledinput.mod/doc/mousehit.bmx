' mousehit.bmx

SuperStrict

Graphics 640,480

While Not KeyHit(KEY_ESCAPE)
	Cls
	If MouseHit(1) DrawRect 0,0,200,200
	If MouseHit(2) DrawRect 200,0,200,200
	If MouseHit(3) DrawRect 400,0,200,200
	Flip
Wend
