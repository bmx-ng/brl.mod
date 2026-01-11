SuperStrict

Framework brl.standardio
Import BRL.Path

Local dir:TPath = New TPath(".")

Using
	Local it:TPathDirIterator = dir.IterDir()
Do
	For Local p:TPath = EachIn it
		Print p.Name()
	Next
End Using
