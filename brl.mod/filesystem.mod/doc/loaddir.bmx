' loaddir.bmx
SuperStrict

' declare a string array
Local files:String[] 
files = LoadDir(CurrentDir())

For Local t:String = EachIn files
	Print t	
Next
