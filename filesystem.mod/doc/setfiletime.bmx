' setfiletime.bmx

SuperStrict

Const FILENAME:String = "file.txt"

SaveString("Hello", FILENAME)

Local ft:Long = FileTime(FILENAME)

Print ft

ft :- 3600 ' less 1 hour

SetFileTime(FILENAME, ft)

Print FileTime(FILENAME)
