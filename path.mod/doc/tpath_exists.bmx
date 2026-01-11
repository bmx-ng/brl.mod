SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "hello.txt"
f.CreateFile()

Print f.Exists()  ' True
Print f.IsFile()  ' True
Print base.IsDir() ' True

' Cleanup
f.DeleteFile()
base.DeleteDir(True)
