SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
(base / "sub").CreateDir(True)

Using
	Local s:TStream = (base / "a.txt").Write()
Do
	s.WriteString("x")
End Using

Local items:TPath[] = base.List(True)

For Local p:TPath = EachIn items
	Print p.Name()
Next

' Cleanup
base.DeleteDir(True)
