SuperStrict

Framework BRL.StandardIO
Import BRL.Path

Local path:TPath = New TPath("example.txt")
Local info:SFileStat
If path.Stat(info) Then
	Print "Size: " + info.size
	Print "Modified: " + info.ModifiedDateTime().ToString()
End If
