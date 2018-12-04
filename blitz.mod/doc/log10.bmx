Rem
Log10(n#) returns the Base 10 logarithm of n
End Rem

SuperStrict

For Local n:Float = 0 To 100 Step 10
	Print "Log10("+n+")="+Log10(n)
Next
