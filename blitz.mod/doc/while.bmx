Rem
While executes the following section of code repeatedly while a given condition is true.
End Rem

SuperStrict

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)	'loop until escape key is pressed
	Cls
	For Local i:Int = 1 To 200
		DrawLine Rnd(640),Rnd(480),Rnd(640),Rnd(480)
	Next
	Flip
Wend
