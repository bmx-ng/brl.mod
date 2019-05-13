Rem
Local defines a variable as local to the Method or Function it is defined meaning it is automatically released when the function returns.
End Rem

SuperStrict

Function TestLocal()
	Local a:Int
	a=20
	Print "a="+a
	Return
End Function

TestLocal
Print "a="+a	'prints an error as a is only local to the TestLocal function
