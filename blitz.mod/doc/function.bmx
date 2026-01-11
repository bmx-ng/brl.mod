Rem
Function marks the beginning of a BlitzMax function declaration.

When a function does not return a value the use of brackets when
calling the function is optional.
End Rem

SuperStrict

Framework BRL.StandardIO


Function NextArg(a:String)
	Local p:Int
	p=Instr(a,",")
	If p 
		NextArg a[p..]
		Print a[..p-1]
	Else
		Print a
	EndIf
End Function

NextArg("one,two,three,four")

NextArg "22,25,20"	'look ma, no brackets
