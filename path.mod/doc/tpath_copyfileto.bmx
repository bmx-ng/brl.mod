SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local src:TPath = base / "src.txt"
Local dst:TPath = base / "dst.txt"

Using
	Local s:TStream = src.Write()
Do
	s.WriteString("copy me")
End Using

src.CopyFileTo(dst)

Print src.Size() ' 7
Print dst.Size() ' 7

' Cleanup
base.DeleteDir(True)
