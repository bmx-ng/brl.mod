' readfile.bmx
' the following prints the contents of this source file 

SuperStrict

Local file:TStream = ReadFile("readfile.bmx")

If Not file RuntimeError "could not open file openfile.bmx"

While Not Eof(file)
	Print ReadLine(file)
Wend

CloseStream file
