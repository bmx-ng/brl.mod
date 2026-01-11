SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "a.txt"
Using
	Local s:TStream = f.Write()
Do
	s.WriteString("hello")
End Using

Print f.Size() ' 5

' Cleanup
base.DeleteDir(True)
