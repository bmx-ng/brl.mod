SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "a.txt"
f.CreateFile()

Print f.IsFile() ' True
Print f.IsDir()  ' False

' Cleanup
base.DeleteDir(True)
