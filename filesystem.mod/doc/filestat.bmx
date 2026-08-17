SuperStrict

Framework BRL.StandardIO
Import BRL.FileSystem

Local info:SFileStat
If FileStat("example.txt", info) Then
	Print "Size: " + info.size
	Print "Modified: " + info.ModifiedDateTime().ToString()
End If
