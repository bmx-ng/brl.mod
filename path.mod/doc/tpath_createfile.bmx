SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "empty.txt"
f.CreateFile()

Print f.Exists() ' True
Print f.Size()   ' 0 (typically)

' Cleanup
f.DeleteFile()
base.DeleteDir(True)
