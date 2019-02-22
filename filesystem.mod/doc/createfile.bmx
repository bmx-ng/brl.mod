' createfile.bmx
SuperStrict

Local success:Int = CreateFile("myfile")
If Not success Then
	RuntimeError "error creating file"
End If
