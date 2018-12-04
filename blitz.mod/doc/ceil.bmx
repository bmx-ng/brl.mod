Rem
Ceil(x#) returns the smallest integral value not less than x
End Rem

SuperStrict

For Local i:Float = -1 To 1 Step .2
	Print "Ceil("+i+")="+Ceil(i)
Next
