SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "tmp.txt"
f.CreateFile()

Print f.Exists() ' True
f.DeleteFile()
Print f.Exists() ' False

' Cleanup
base.DeleteDir(True)
