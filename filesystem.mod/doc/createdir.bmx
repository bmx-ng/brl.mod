' createdir.bmx
SuperStrict

Local success:Int = CreateDir("myfolder")
If Not success RuntimeError "error creating directory"
