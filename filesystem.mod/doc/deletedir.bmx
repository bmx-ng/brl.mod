' deletedir.bmx
SuperStrict

Local success:Int = DeleteDir("myfolder")
If Not success Then
	RuntimeError "error deleting directory"
End If
