Rem
Catch defines an exception handler following a Try..EndTry Block.
End Rem

SuperStrict

Local a:Int
Try
	Repeat
		a:+1
		Print a
		If a>20 Throw "chunks"
	Forever
Catch e:String
	Print "caught exception "+e
EndTry
