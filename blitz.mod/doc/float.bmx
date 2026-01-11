Rem
Float is a 32 bit floating point BlitzMax primitive type.
End Rem

SuperStrict

Framework BRL.StandardIO


Local a:Float

a=1

For Local i:Int = 1 To 8
	Print a
	a=a*0.1
Next

For Local i:Int = 1 To 8
	a=a*10
	Print a
Next
