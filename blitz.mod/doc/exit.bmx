Rem
Exit causes program flow to exit the enclosing While, Repeat or For loop.
End Rem

SuperStrict

Framework BRL.StandardIO


Local n:Int
Repeat
	Print n
	n:+1
	If n=5 Exit
Forever
