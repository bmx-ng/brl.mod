' appargs.bmx
' print the command line arguments passed to the program at runtime

SuperStrict

Framework BRL.StandardIO


Print "Number of arguments = "+AppArgs.length

For Local a:String = EachIn AppArgs
	Print a
Next
