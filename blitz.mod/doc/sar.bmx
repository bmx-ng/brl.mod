Rem
Sar is a binary operator that performs the arithmetic shift to right function.
End Rem

SuperStrict

Framework BRL.StandardIO


Local b:Int = $f0f0f0f0
For Local i:Int = 1 To 32
	Print Bin(b)
	b=b Sar 1
Next
