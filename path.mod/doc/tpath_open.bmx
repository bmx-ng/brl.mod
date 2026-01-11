SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "rw.txt"
f.CreateFile()

Using
	Local s:TStream = f.Open(True, True)
Do
	s.WriteString("abc")
	s.Seek(0)
	Print s.ReadString(3) ' abc
End Using

' Cleanup
f.DeleteFile()
base.DeleteDir(True)
