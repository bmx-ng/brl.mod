Rem
Len is a BlitzMax operator that returns the number of elements in a container Type.
End Rem

SuperStrict

Local a:String = "BlitzMax Rocks"
Print Len a	'prints 14

Local b:Int[]
Print Len b		'prints 0

b=New Int[20]
Print Len b		'prints 20

