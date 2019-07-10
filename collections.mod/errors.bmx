SuperStrict

Type TIndexOutOfBoundsException Extends TBlitzException

	Method ToString:String() Override
		Return "Attempt to index element out of bounds."
	End Method

End Type

Type TNoSuchElementException Extends TBlitzException

	Method ToString:String() Override
		Return "No such Element."
	End Method

End Type

Type TInvalidOperationException Extends TBlitzException

	Field message:String
	
	Method New(message:String)
		Self.message = message
	End Method

	Method ToString:String() Override
		Return message
	End Method

End Type

Type TArgumentOutOfRangeException Extends TBlitzException

	Method ToString:String() Override
		Return "Argument out of range."
	End Method

End Type

Type TArgumentException Extends TBlitzException

	Field message:String
	
	Method New(message:String)
		Self.message = message
	End Method

	Method ToString:String() Override
		Return message
	End Method

End Type
