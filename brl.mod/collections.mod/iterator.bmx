SuperStrict

Rem
bbdoc: A collection iterator.
End Rem
Interface IIterator<E>

	Rem
	bbdoc: Returns True if there are more elements.
	End Rem
	Method HasNext:Int()
	
	Rem
	bbdoc: Gets the next element in the iteration.
	End Rem
	Method NextElement:E()
	
	Method Remove()

End Interface


Rem
bbdoc: Implementing the @IIterable interface allows the object to used with an For/Eachin statement.
End Rem
Interface IIterable<T>

	Method Iterator:IIterator<T>()

End Interface

