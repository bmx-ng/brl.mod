SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "msg.txt"

Using
	Local s:TStream = f.Write()
Do
	s.WriteString("hello")
End Using

Using
	Local r:TStream = f.Read()
Do
	Print r.ReadString(Int(r.Size())) ' hello
End Using

' Cleanup
f.DeleteFile()
base.DeleteDir(True)
