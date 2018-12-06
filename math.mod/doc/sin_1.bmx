SuperStrict

Graphics 640,480

SetColor 128,128,128
DrawRect 0,240,360,1

SetColor 0,255,255

For Local t:Int=0 To 359
	Plot t,Float(240+Sin(t)*80)
Next

Flip

Repeat
	WaitKey()
Until KeyDown(KEY_ESCAPE)
