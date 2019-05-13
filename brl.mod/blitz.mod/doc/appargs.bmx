' appargs.bmx
' print the command line arguments passed to the program at runtime

SuperStrict

Print "Number of arguments = "+AppArgs.length

For Local a:String = EachIn AppArgs
	Print a
Next
