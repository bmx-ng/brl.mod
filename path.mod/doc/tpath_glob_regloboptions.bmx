SuperStrict

Framework brl.standardio
Import BRL.Path

Local dir:TPath = New TPath(".")

Local matches:TPath[] = dir.Glob("**/*.bmx", EGlobOptions.GlobStar)

For Local p:TPath = EachIn matches
	Print p.ToString()
Next
