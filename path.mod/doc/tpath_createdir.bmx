SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())

Local nested:TPath = base / "a" / "b" / "c"
nested.CreateDir(True)

Print nested.Exists() ' True
Print nested.IsDir()  ' True

' Cleanup (remove the whole tree)
base.DeleteDir(True)
