Rem
Function marks the end of a BlitzMax function declaration.
End Rem

SuperStrict

Function RandomName:String()
	Local a:String[]=["Bob","Joe","Bill"]
	Return a[Rnd(Len a)]
End Function

For Local i:Int = 1 To 5
	Print RandomName$()
Next
