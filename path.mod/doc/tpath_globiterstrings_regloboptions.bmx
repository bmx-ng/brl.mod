SuperStrict

Framework brl.standardio
Import BRL.Path

Local dir:TPath = New TPath(".")

Using
	Local it:TGlobIter = dir.GlobIterStrings("**/*.bmx", EGlobOptions.GlobStar)
Do
	For Local s:String = EachIn it
		Print s
	Next
End Using
