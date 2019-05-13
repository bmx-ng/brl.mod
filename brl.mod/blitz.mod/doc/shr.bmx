Rem
Shr is a binary operator that performs the shift to right function.
End Rem

SuperStrict

Local b:Int = -1
For Local i:Int = 1 To 32
	Print Bin(b)
	b=b Shr 1
Next
