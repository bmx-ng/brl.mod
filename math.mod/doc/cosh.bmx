'
' Cosh Hyperbolic Cosine
'
SuperStrict

Graphics 640,480

For Local t:Float = - 7To 7 Step .1
	SetColor 255,0,0 'red cosh
	Plot 100 + t * 10 , Float(240 + Cosh(t))
	SetColor 0,255,255 
	Plot 200 + t * 10 , Float(240 + Sinh(t))
Next

Flip

Repeat Until KeyDown(KEY_ESCAPE) Or AppTerminate()
