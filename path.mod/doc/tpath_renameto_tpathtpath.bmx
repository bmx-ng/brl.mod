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
	s.WriteString("data")
End Using

Local moved:TPath
If src.RenameTo(dst, moved) Then
	Print "Moved to: " + moved.ToString()
End If

' Cleanup
base.DeleteDir(True)
