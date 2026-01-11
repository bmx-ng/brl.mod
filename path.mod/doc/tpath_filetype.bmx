SuperStrict

Framework brl.standardio
Import BRL.Path

Local base:TPath = New TPath(CurrentDir()) / ("tpath_example_" + MilliSecs())
base.CreateDir(True)

Local f:TPath = base / "a.txt"
f.CreateFile()

Print base.FileType() ' FILETYPE_DIR (2)
Print f.FileType()    ' FILETYPE_FILE (1)

Print base.IsDir()    ' True
Print f.IsFile()      ' True

' Cleanup
base.DeleteDir(True)
