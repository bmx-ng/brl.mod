Rem
SizeOf returns the number of bytes of system memory used to store the variable.
End Rem

SuperStrict

Framework BRL.StandardIO


Type MyType
	Field a:Int,b:Int,c:Int
End Type

Local t:MyType
Print SizeOf t	'prints 12

Local f!
Print SizeOf f	'prints 8

Local i:Int
Print SizeOf i	'prints 4

Local b:Byte
Print SizeOf b	'prints 1

Local a:String="Hello World"
Print SizeOf a	'prints 22 (unicode characters take 2 bytes each)