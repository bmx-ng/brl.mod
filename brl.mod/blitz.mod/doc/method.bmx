Rem
Method marks the beginning of a BlitzMax custom type member function.
End Rem

SuperStrict

Type TPoint
	Field x:Int,y:Int

	Method ToString:String()
		Return x+","+y
	End Method
End Type

Local a:TPoint=New TPoint
Print a.ToString()
	