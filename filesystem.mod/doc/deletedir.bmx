' deletedir.bmx
SuperStrict
Local success:Int = DeleteDir("myfolder")
If Not success RuntimeError "error deleting directory"
