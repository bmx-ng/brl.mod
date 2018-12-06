Rem
ATan returns the Inverse Tangent of x
End Rem

SuperStrict

For Local d:Double = -1.0 To 1.0 Step 0.125
	Print "ATan("+d+")="+ATan(d)
Next
