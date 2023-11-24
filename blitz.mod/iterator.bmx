Rem
bbdoc: Iterable interface
EndRem
Interface IIterable<T>

	Method GetIterator:IIterator<T>()

End Interface

Rem
bbdoc: Iterator interface
EndRem
Interface IIterator<T>

	Method Current:T()
	Method MoveNext:Int()

End Interface
