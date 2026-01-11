SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
(base / "sub").CreateDir(True)

Using
	Local s:TStream = (base / "sub" / "a.txt").Write()
Do
	s.WriteString("x")
End Using

Print base.Exists() ' True
base.DeleteDir(True)
Print base.Exists() ' False
