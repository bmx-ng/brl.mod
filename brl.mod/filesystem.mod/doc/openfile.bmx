' openfile.bmx
SuperStrict

' the following prints the contents of this source file 

Local file:TStream = OpenFile("openfile.bmx")

If Not file RuntimeError "could not open file openfile.bmx"

While Not Eof(file)
	Print ReadLine(file)
Wend
CloseStream file
