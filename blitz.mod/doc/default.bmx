Rem
Default is used in a Select block to mark a code section that is executed if all prior Case statements fail.
End Rem

SuperStrict

Framework BRL.StandardIO


Local a:String = Input("What is your favorite color?")
a=Lower(a)	'make sure the answer is lower case

Select a
	Case "yellow" Print "You a bright and breezy"
	Case "blue" Print "You are a typical boy"
	Case "pink" Print "You are a typical girl"
	Default Print "You are quite unique!"
End Select
