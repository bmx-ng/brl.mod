Rem
Global defines a variable as Global allowing it be accessed from within Methods and Functions.
End Rem

SuperStrict

Global a:Int = 20

Function TestGlobal()
	Print "a="+a
End Function

TestGlobal
Print "a="+a
