SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "a.txt"
Using
	Local s:TStream = f.Write()
Do
	s.WriteString("x")
End Using

Print f.ModifiedDateTime().ToString()

' Cleanup
base.DeleteDir(True)
