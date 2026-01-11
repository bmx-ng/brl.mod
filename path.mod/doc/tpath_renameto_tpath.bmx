SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local a:TPath = base / "a.txt"
Local b:TPath = base / "b.txt"

Using
	Local s:TStream = a.Write()
Do
	s.WriteString("hello")
End Using

Print a.Exists() ' True
Print b.Exists() ' False

a.RenameTo(b)

Print a.Exists() ' False
Print b.Exists() ' True

' Cleanup
base.DeleteDir(True)
