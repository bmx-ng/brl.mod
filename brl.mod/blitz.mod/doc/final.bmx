Rem
Final stops methods from being redefined in super classes.
End Rem

SuperStrict

Type T1
	Method ToString:String() Final
		Return "T1"
	End Method
End Type

Type T2 Extends T1
	Method ToString:String()	'compile time error "Final methods cannot be overridden"
		Return "T2"
	End Method
End Type
