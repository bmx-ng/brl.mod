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

Type TUnsupportedOperationException Extends TBlitzException

	Method ToString:String() Override
		Return "Unsupported operation."
	End Method

End Type

Type TIllegalStateException Extends TBlitzException

	Field message:String

	Method New(message:String)
		Self.message = message
	End Method

	Method ToString:String() Override
		If message Then
			Return message
		End If
		
		Return "Illegal state."
	End Method

End Type

