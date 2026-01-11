SuperStrict

Framework brl.standardio
Import BRL.Path

Local dir:TPath = New TPath(".")

Using
	Local it:TPathIterator = dir.GlobIter("**/*.bmx", EGlobOptions.GlobStar)
Do
	For Local p:TPath = EachIn it
		Print p.ToString()
	Next
End Using
