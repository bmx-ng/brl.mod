SuperStrict

Framework brl.standardio
Import BRL.Path

Local dir:TPath = New TPath(".")

' **/*.bmx matches only below the starting directory.
' Use brace expansion to include both "*.bmx" and "**/*.bmx".
Using
	Local it:TPathIterator = dir.GlobIter("{*.bmx,**/*.bmx}", EGlobOptions.GlobStar)
Do
	For Local p:TPath = EachIn it
		Print p.ToString()
	Next
End Using
