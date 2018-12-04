' readstream.bmx

' opens a read stream to the blitzbasic.com website and
' dumps the homepage to the console using readline and print

SuperStrict

Local in:TStream = ReadStream("http::blitzmax.org")

If Not in RuntimeError "Failed to open a ReadStream to file http::www.blitzbasic.com"

While Not Eof(in)
	Print ReadLine(in)
Wend
CloseStream in
