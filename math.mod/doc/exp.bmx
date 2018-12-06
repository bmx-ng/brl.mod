'
' Exponential
'
SuperStrict

Graphics 640,480

For Local t:Float = - 7 To 7 Step .1
	Plot 100 + t * 10 , Float(240 - Exp(t))
	Print Exp(t)
Next

Flip

Repeat Until KeyDown(KEY_ESCAPE) Or AppTerminate()
