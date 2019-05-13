SuperStrict

For Local t:Int=0 To 255
	If Not(t Mod 16) Print
	Print "decimal: "+RSet(t,3)+" | hex: "+Hex(t)
Next
