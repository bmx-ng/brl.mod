'
' Sinh Hyperbolic Sine
'
SuperStrict

Graphics 640,480

For Local t:Float=-7To 7 Step .1
	Plot 100+t*10,Float(240+Sinh(t))
Next

Flip

Repeat Until KeyDown(KEY_ESCAPE) Or AppTerminate()
