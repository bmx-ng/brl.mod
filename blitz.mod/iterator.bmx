
Interface IIterable<T>

	Method GetIterator:IIterator<T>()

End Interface

Interface IIterator<T>

	Method Current:T()
	Method MoveNext:Int()

End Interface
