Rem
Shl is a binary operator that performs the shift to left function.
End Rem

SuperStrict

Local b:Int = 1
For Local i:Int = 1 To 32
	Print Bin(b)
	b=b Shl 1
Next
