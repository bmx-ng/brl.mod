Rem
bbdoc: Describes a value that can be separated into two component values.
about: Implement this interface when a value has a stable, meaningful pair of
components. #Deconstruct writes both components to its Var parameters.

bcc2 also uses this contract for a two-binding EachIn loop such as
```blitzmax
For Local first:A, second:B = EachIn values
```
The collection still yields one value per iteration; that yielded value must
implement #IDeconstruct2 and is deconstructed once before the loop body runs.
End Rem
Interface IDeconstruct2<A, B>

	Rem
	bbdoc: Writes this value's first and second components.
	param: Receives the first component.
	param: Receives the second component.
	End Rem
	Method Deconstruct(first:A Var, second:B Var)

End Interface

Rem
bbdoc: Provides sequential access to a collection of values.
about: An iterable object can create an #IIterator for traversing its values.
Each call to #GetIterator should return an iterator positioned before the
first value. Call #IIterator.MoveNext before reading #IIterator.Current.
An iterable may be traversed more than once by requesting a new iterator,
although individual implementations may impose additional restrictions.
End Rem
Interface IIterable<T>

	Rem
	bbdoc: Creates an iterator for traversing the values in this object.
	returns: A new #IIterator positioned before the first value.
	about: Call #IIterator.MoveNext to advance the iterator to the first value.
	The returned iterator represents a traversal independent from other
	iterators unless the implementation documents otherwise.
	End Rem
	Method GetIterator:IIterator<T>()

End Interface

Rem
bbdoc: Provides sequential access to a series of values.
about: An iterator maintains a position within a sequence.
A newly created iterator is positioned before the first value. Call
#MoveNext to advance it. If #MoveNext returns #True, #Current contains the
value at the iterator's new position. If it returns #False, the end of the
sequence has been reached.

The value of #Current is undefined before the first successful call to
#MoveNext and after #MoveNext has returned #False.
Iterators are generally forward-only and should not be assumed to support
resetting or repeated traversal.
End Rem
Interface IIterator<T>

	Rem
	bbdoc: Gets the value at the iterator's current position.
	returns: The current value.
	about: #Current is valid only after #MoveNext has returned #True and remains
	valid until the next call to #MoveNext.
	Accessing #Current before iteration begins or after the iterator reaches
	the end of the sequence has undefined results.
	End Rem
	Method Current:T()
	Rem
	bbdoc: Advances the iterator to the next value.
	returns: #True if the iterator advanced to a value, or #False if the end of the sequence was reached.
	about: On the first call, #MoveNext advances the iterator from its initial
	position to the first value.
	When this method returns #True, the value can be read using #Current.
	After it returns #False, the iterator is exhausted and #Current is no
	longer valid.
	End Rem
	Method MoveNext:Int()

End Interface

Rem
bbdoc: Closeable iterator interface
about: Combines the #IIterator and #ICloseable contracts for iterators that own resources which should be
released when iteration finishes or is abandoned.
End Rem
Interface ICloseableIterator<T> Extends IIterator<T>, ICloseable
End Interface
