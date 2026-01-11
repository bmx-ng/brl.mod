SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
Local dir:TPath = base / "sub"

dir.CreateDir(True)

Print dir.IsDir()  ' True
Print dir.IsFile() ' False

' Cleanup
base.DeleteDir(True)
