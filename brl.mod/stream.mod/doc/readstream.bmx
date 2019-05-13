' readstream.bmx

' opens a read stream to the blitzmax.org website and
' dumps the content to the console using readline and print

SuperStrict

Local in:TStream = ReadStream("http::blitzmax.org")

If Not in RuntimeError "Failed to open a ReadStream to file http::blitzmax.org"

While Not Eof(in)
	Print ReadLine(in)
Wend
CloseStream in
