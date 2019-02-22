' setfilemode.bmx
SuperStrict

' the following makes this source file readonly
Local writebits:Int = %010010010

' read the file mode
Local mode:Int = FileMode("setfilemode.bmx")

'mask out the write bits to make readonly
mode = mode & ~writebits

'set the new file mode
SetFileMode("setfilemode.bmx",mode)	
