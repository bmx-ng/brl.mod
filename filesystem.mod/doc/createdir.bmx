' createdir.bmx
SuperStrict

Local success:Int = CreateDir("myfolder")
If Not success Then
	RuntimeError "error creating directory"
End If
