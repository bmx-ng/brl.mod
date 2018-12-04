' createfile.bmx
SuperStrict

Local success:Int = CreateFile("myfile")
If Not success RuntimeError "error creating file"
