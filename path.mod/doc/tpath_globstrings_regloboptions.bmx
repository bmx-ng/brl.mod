SuperStrict

Framework brl.standardio
Import BRL.Path

Local dir:TPath = New TPath(".")

Local matches:String[] = dir.GlobStrings("**/*.bmx", EGlobOptions.GlobStar)

For Local s:String = EachIn matches
	Print s
Next
