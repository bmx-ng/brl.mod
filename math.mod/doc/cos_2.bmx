'
' How to draw a 'dotted' flower using Sin/Cos
'
SuperStrict

Graphics 640,480

Local radius:Int

SetColor 0,255,255

For Local t:Int=0 To 359 Step 4
	radius=Sin(t*8)*40+80
	Plot Float(320+Sin(t)*radius), Float(240+Cos(t)*radius)
Next

Flip

Repeat
	WaitKey()
Until KeyDown(KEY_ESCAPE)
