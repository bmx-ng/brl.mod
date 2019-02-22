SuperStrict

Local in:TStream = OpenFile(BlitzMaxPath() + "\versions.txt")
Local line:String

While Not Eof(in)
	line = ReadLine(in)
	Print line
Wend

CloseFile(in) ' can also use CloseStream(in)
