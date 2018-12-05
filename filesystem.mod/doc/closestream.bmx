SuperStrict

Local in:TStream = OpenFile(BlitzMaxPath() + "\versions.txt")
Local line:String

While Not Eof(in)
	line = ReadLine(in)
	Print line
Wend

CloseStream(in) ' can also use CloseFile(in)
