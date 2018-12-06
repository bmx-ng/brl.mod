'
' Tanh Hyperbolic Cosine
'
SuperStrict

Graphics 640,480

For Local t:Float = -.2 To .2 Step .001
	SetColor 255,0,0 'red cosh
	Plot 100 + t * 500 , Float(240 + Tanh(t)*500)
Print t*500+":"+Tanh(t)*500
Next

Flip

Repeat Until KeyDown(KEY_ESCAPE) Or AppTerminate()
