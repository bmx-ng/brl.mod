Rem
Null is a BlitzMax Constant representing an empty Object reference.
End Rem

SuperStrict

Framework BRL.StandardIO


Type mytype
	Field atypevariable:Int
End Type

Global a:mytype

If a=Null Print "a is uninitialized"
a=New mytype
If a<>Null Print "a is initialized"