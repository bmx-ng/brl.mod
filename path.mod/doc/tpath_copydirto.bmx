SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
Local src:TPath = base / "src"
Local dst:TPath = base / "dst"

(src / "sub").CreateDir(True)

Using
	Local s:TStream = (src / "a.txt").Write()
Do
	s.WriteString("A")
End Using

Using
	Local s:TStream = (src / "sub" / "b.txt").Write()
Do
	s.WriteString("B")
End Using

src.CopyDirTo(dst)

Print (dst / "a.txt").Exists()      ' True
Print (dst / "sub" / "b.txt").Exists() ' True

' Cleanup
base.DeleteDir(True)
