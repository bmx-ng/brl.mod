SuperStrict

Graphics 640,480

Local radius:Int=80

SetColor 0,255,255

For Local t:Int=0 To 359 Step 4
	Plot Float(320+Sin(t)*radius), Float(240+Cos(t)*radius)
Next

Flip

Repeat
	WaitKey()
Until KeyDown(KEY_ESCAPE)
