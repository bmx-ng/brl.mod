'File System Example

SuperStrict

Local dir:Byte Ptr = ReadDir(BlitzMaxPath() )

If Not dir Then
	RuntimeError "Cannot open folder"
End If

Local file:String
Repeat
	
	file = NextFile(Dir) ' Get the filenames in folder
	Print file
	
Until file = ""

CloseDir(dir)
