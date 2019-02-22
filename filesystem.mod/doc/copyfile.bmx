SuperStrict

Local result:Int = CopyFile(BlitzMaxPath() + "\versions.txt",  BlitzMaxPath() + "\versions2.txt")

If result = 0 Then	
	RuntimeError "CopyFile not successful..."
End If

result = RenameFile(BlitzMaxPath() + "\versions.txt", BlitzMaxPath() + "\versions2.txt")

If result = 0 Then
	RuntimeError "Rename not successful..." ' as file already exists
End If
