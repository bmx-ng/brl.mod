' deletefile.bmx
SuperStrict

Local success:Int = DeleteFile("myfile")
If Not success RuntimeError "error deleting file"
