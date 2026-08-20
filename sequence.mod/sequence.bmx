' Copyright (c) 2026 Bruce A Henderson and contributors
' 
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.
'
SuperStrict

Rem
bbdoc: System/Sequence
End Rem
Module BRL.Sequence

?bmxng2

ModuleInfo "Version: 1.02"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.02"
ModuleInfo "History: Added automatic closeable-iterator cleanup throughout lazy pipelines and terminal operations."
ModuleInfo "History: 1.01"
ModuleInfo "History: Added FlatMap, Concat, TakeWhile, SkipWhile, Append, Prepend, predicate overloads, additional Optional terminals, and expanded compiler pipeline fusion."
ModuleInfo "History: 1.00 Initial Release"

Import BRL.Optional

Private

Function CloseSequenceIterator(iterator:Object)
	If Not iterator Then Return
	Local closeable:ICloseable = ICloseable(iterator)
	If Not closeable Then Return
	Try
		closeable.Close()
	Catch ignored:Object
	End Try
End Function

Public

Rem
bbdoc: A lazy, typed sequence of values.
about: A Sequence is a reusable query recipe. Each call to #GetIterator asks its
source for a new iterator and applies the pipeline while values are requested.
No intermediate arrays are created.

Sequences retain their source rather than copying it. Changes made to an array
or collection before a later enumeration are therefore visible. Replayability
ultimately follows the source's #IIterable contract: a source that returns the
same one-shot iterator on every call remains one-shot and is not buffered by
Sequence. An iterator which implements #ICloseable is closed when enumeration
finishes, stops early, returns from its enclosing function, or fails.
End Rem
Type Sequence<T> Implements IIterable<T>
	Private
	Field _array:T[]
	Field _iterable:IIterable<T>
	Field _isArray:Int

	Public

	Rem
	bbdoc: Creates an empty sequence.
	End Rem
	Method New()
		_array = New T[0]
		_isArray = True
	End Method

	Rem
	bbdoc: Creates a sequence view over @array without copying it.
	param: The source array retained by the sequence.
	End Rem
	Method New(array:T[])
		_array = array
		_isArray = True
	End Method

	Rem
	bbdoc: Creates a sequence view over @iterable without enumerating it.
	param: The iterable source retained by the sequence.
	about: Each enumeration calls @iterable.GetIterator() once.
	End Rem
	Method New(iterable:IIterable<T>)
		_iterable = iterable
	End Method

	Rem
	bbdoc: Creates a lazy sequence view over @array without copying it.
	param: The source array retained by the sequence.
	returns: A replayable Sequence view over @array.
	End Rem
	Function FromArray:Sequence<T>(array:T[])
		Return New Sequence<T>(array)
	End Function

	Rem
	bbdoc: Creates a lazy sequence view over @iterable without enumerating it.
	param: The iterable source retained by the sequence.
	returns: A Sequence whose replayability follows @iterable.
	End Rem
	Function FromIterable:Sequence<T>(iterable:IIterable<T>)
		Return New Sequence<T>(iterable)
	End Function

	Rem
	bbdoc: Returns a new iterator for this pipeline.
	returns: An iterator positioned before the first value.
	End Rem
	Method GetIterator:IIterator<T>()
		If _isArray Then Return New TArraySequenceIterator<T>(_array)
		Return _iterable.GetIterator()
	End Method

	Rem
	bbdoc: Lazily transforms each value with @mapper.
	param: The Closure invoked when each source value is requested.
	returns: A lazy Sequence of mapped values.
	End Rem
	Method Map<U>:Sequence<U>(mapper:Closure<U(value:T)>)
		Return New TMapSequence<T, U>(Self, mapper)
	End Method

	Rem
	bbdoc: Lazily transforms each value with a non-capturing function.
	param: The function invoked when each source value is requested.
	returns: A lazy Sequence of mapped values.
	End Rem
	Method Map<U>:Sequence<U>(mapper:U(value:T))
		Return New TFunctionMapSequence<T, U>(Self, mapper)
	End Method

	Rem
	bbdoc: Lazily retains values for which @predicate returns True.
	param: The Closure tested as source values are requested.
	returns: A lazy Sequence containing only accepted values.
	End Rem
	Method Filter:Sequence<T>(predicate:Closure<Int(value:T)>)
		Return New TFilterSequence<T>(Self, predicate)
	End Method

	Rem
	bbdoc: Lazily retains values accepted by a non-capturing function.
	param: The function tested as source values are requested.
	returns: A lazy Sequence containing only accepted values.
	End Rem
	Method Filter:Sequence<T>(predicate:Int(value:T))
		Return New TFunctionFilterSequence<T>(Self, predicate)
	End Method

	Rem
	bbdoc: Lazily yields at most @count values.
	param: The maximum number of values to yield.
	returns: A lazy Sequence limited to @count values.
	about: A non-positive count produces an empty sequence.
	End Rem
	Method Take:Sequence<T>(count:Int)
		If count < 0 Then count = 0
		Return New TTakeSequence<T>(Self, count)
	End Method

	Rem
	bbdoc: Lazily omits the first @count values.
	param: The number of source values to omit.
	returns: A lazy Sequence beginning after the omitted values.
	about: A non-positive count omits no values.
	End Rem
	Method Skip:Sequence<T>(count:Int)
		If count < 0 Then count = 0
		Return New TSkipSequence<T>(Self, count)
	End Method

	Rem
	bbdoc: Lazily maps each value to a sequence and yields all inner values in order.
	param: The Closure invoked once for each outer value as its inner sequence is needed.
	returns: A lazy flattened Sequence.
	about: Inner sequences are enumerated one at a time. An inner sequence is not
	requested until all values from the preceding inner sequence have been consumed.
	End Rem
	Method FlatMap<U>:Sequence<U>(mapper:Closure<Sequence<U>(value:T)>)
		Return New TFlatMapSequence<T, U>(Self, mapper)
	End Method

	Rem
	bbdoc: Lazily maps each value to a sequence using a non-capturing function and yields all inner values in order.
	param: The function invoked once for each outer value as its inner sequence is needed.
	returns: A lazy flattened Sequence.
	End Rem
	Method FlatMap<U>:Sequence<U>(mapper:Sequence<U>(value:T))
		Return New TFunctionFlatMapSequence<T, U>(Self, mapper)
	End Method

	Rem
	bbdoc: Lazily yields this sequence followed by @other.
	param: The sequence to enumerate after this sequence is exhausted.
	returns: A lazy concatenated Sequence.
	about: @other does not receive an iterator until this sequence is exhausted.
	End Rem
	Method Concat:Sequence<T>(other:Sequence<T>)
		Return New TConcatSequence<T>(Self, other)
	End Method

	Rem
	bbdoc: Lazily yields values while @predicate returns True.
	param: The Closure tested for each value until the first rejection.
	returns: A lazy prefix Sequence.
	about: The rejecting value is consumed but not yielded. No later value is requested.
	End Rem
	Method TakeWhile:Sequence<T>(predicate:Closure<Int(value:T)>)
		Return New TTakeWhileSequence<T>(Self, predicate)
	End Method

	Rem
	bbdoc: Lazily yields values while a non-capturing function returns True.
	param: The function tested for each value until the first rejection.
	returns: A lazy prefix Sequence.
	End Rem
	Method TakeWhile:Sequence<T>(predicate:Int(value:T))
		Return New TFunctionTakeWhileSequence<T>(Self, predicate)
	End Method

	Rem
	bbdoc: Lazily omits values while @predicate returns True.
	param: The Closure tested until the first value is rejected.
	returns: A lazy Sequence beginning with the first rejected value.
	about: After the first rejection, later values are yielded without invoking @predicate.
	End Rem
	Method SkipWhile:Sequence<T>(predicate:Closure<Int(value:T)>)
		Return New TSkipWhileSequence<T>(Self, predicate)
	End Method

	Rem
	bbdoc: Lazily omits values while a non-capturing function returns True.
	param: The function tested until the first value is rejected.
	returns: A lazy Sequence beginning with the first rejected value.
	End Rem
	Method SkipWhile:Sequence<T>(predicate:Int(value:T))
		Return New TFunctionSkipWhileSequence<T>(Self, predicate)
	End Method

	Rem
	bbdoc: Lazily yields this sequence followed by @value.
	param: The value to yield after the source is exhausted.
	returns: A lazy Sequence with one trailing value.
	End Rem
	Method Append:Sequence<T>(value:T)
		Return New TAppendSequence<T>(Self, value)
	End Method

	Rem
	bbdoc: Lazily yields @value followed by this sequence.
	param: The value to yield before the source is requested.
	returns: A lazy Sequence with one leading value.
	End Rem
	Method Prepend:Sequence<T>(value:T)
		Return New TPrependSequence<T>(Self, value)
	End Method

	Rem
	bbdoc: Combines the sequence into one value, starting with @seed.
	param: The initial accumulator value.
	param: The Closure invoked with the current accumulator and each source value.
	returns: The final accumulator, or @seed when the sequence is empty.
	End Rem
	Method Fold<U>:U(seed:U, folder:Closure<U(accumulator:U, value:T)>)
		Local accumulator:U = seed
		Local iterable:IIterable<T> = Self
		Local iterator:IIterator<T> = iterable.GetIterator()
		Try
			While iterator.MoveNext()
				accumulator = folder(accumulator, iterator.Current())
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return accumulator
	End Method

	Rem
	bbdoc: Combines the sequence using a non-capturing function.
	param: The initial accumulator value.
	param: The function invoked with the current accumulator and each source value.
	returns: The final accumulator, or @seed when the sequence is empty.
	End Rem
	Method Fold<U>:U(seed:U, folder:U(accumulator:U, value:T))
		Local accumulator:U = seed
		Local iterable:IIterable<T> = Self
		Local iterator:IIterator<T> = iterable.GetIterator()
		Try
			While iterator.MoveNext()
				accumulator = folder(accumulator, iterator.Current())
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return accumulator
	End Method

	Rem
	bbdoc: Counts the values in the sequence.
	returns: The number of values produced by the sequence.
	End Rem
	Method Count:Int()
		Local count:Int
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				count :+ 1
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return count
	End Method

	Rem
	bbdoc: Counts values for which @predicate returns True.
	param: The Closure tested for each source value.
	returns: The number of accepted values.
	End Rem
	Method Count:Int(predicate:Closure<Int(value:T)>)
		Local count:Int
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If predicate(iterator.Current()) Then count :+ 1
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return count
	End Method

	Rem
	bbdoc: Counts values accepted by a non-capturing function.
	param: The function tested for each source value.
	returns: The number of accepted values.
	End Rem
	Method Count:Int(predicate:Int(value:T))
		Local count:Int
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If predicate(iterator.Current()) Then count :+ 1
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return count
	End Method

	Rem
	bbdoc: Returns True when the sequence contains at least one value.
	returns: True after finding the first value; otherwise False.
	End Rem
	Method Any:Int()
		Local iterator:IIterator<T> = GetIterator()
		Try
			Return iterator.MoveNext()
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns True when any value satisfies @predicate.
	param: The Closure tested until a value is accepted.
	returns: True when a value is accepted; otherwise False.
	End Rem
	Method Any:Int(predicate:Closure<Int(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If predicate(iterator.Current()) Then Return True
			Wend
			Return False
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns True when any value satisfies a non-capturing function.
	param: The function tested until a value is accepted.
	returns: True when a value is accepted; otherwise False.
	End Rem
	Method Any:Int(predicate:Int(value:T))
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If predicate(iterator.Current()) Then Return True
			Wend
			Return False
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns True when every value satisfies @predicate.
	param: The Closure tested until a value is rejected.
	returns: True when every value is accepted, including an empty sequence.
	about: Returns True for an empty sequence.
	End Rem
	Method All:Int(predicate:Closure<Int(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If Not predicate(iterator.Current()) Then Return False
			Wend
			Return True
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns True when every value satisfies a non-capturing function.
	param: The function tested until a value is rejected.
	returns: True when every value is accepted, including an empty sequence.
	End Rem
	Method All:Int(predicate:Int(value:T))
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If Not predicate(iterator.Current()) Then Return False
			Wend
			Return True
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns the first value, or an undefined Optional when the sequence is empty.
	returns: An Optional containing the first value, or an undefined Optional.
	about: A present element is represented with #Optional.FromValue, including a
	present element whose managed value is Null.
	End Rem
	Method FirstOrNone:Optional<T>()
		Local iterator:IIterator<T> = GetIterator()
		Try
			If iterator.MoveNext() Then Return Optional<T>.FromValue(iterator.Current())
			Return Optional<T>.Undefined()
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns the first value satisfying @predicate, or an undefined Optional.
	param: The Closure tested until a value is accepted.
	returns: An Optional containing the first accepted value, or an undefined Optional.
	about: Evaluation stops after the first match.
	End Rem
	Method FirstOrNone:Optional<T>(predicate:Closure<Int(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				Local value:T = iterator.Current()
				If predicate(value) Then Return Optional<T>.FromValue(value)
			Wend
			Return Optional<T>.Undefined()
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns the first value accepted by a non-capturing function.
	param: The function tested until a value is accepted.
	returns: An Optional containing the first accepted value, or an undefined Optional.
	about: Evaluation stops after the first match.
	End Rem
	Method FirstOrNone:Optional<T>(predicate:Int(value:T))
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				Local value:T = iterator.Current()
				If predicate(value) Then Return Optional<T>.FromValue(value)
			Wend
			Return Optional<T>.Undefined()
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns the last value, or an undefined Optional when the sequence is empty.
	returns: An Optional containing the last value, or an undefined Optional.
	about: The complete sequence is enumerated. A present Null managed value is
	represented by #Optional.FromValue.
	End Rem
	Method LastOrNone:Optional<T>()
		Local result:Optional<T> = Optional<T>.Undefined()
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				result = Optional<T>.FromValue(iterator.Current())
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return result
	End Method

	Rem
	bbdoc: Returns the value at zero-based @index, or an undefined Optional when no such value exists.
	param: The zero-based index of the requested value.
	returns: An Optional containing the requested value, or an undefined Optional.
	about: A negative index returns an undefined Optional without requesting an iterator.
	Enumeration stops as soon as the requested value is found.
	End Rem
	Method ElementAtOrNone:Optional<T>(index:Int)
		If index < 0 Then Return Optional<T>.Undefined()
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If index = 0 Then Return Optional<T>.FromValue(iterator.Current())
				index :- 1
			Wend
			Return Optional<T>.Undefined()
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Returns the only value, or an undefined Optional unless the sequence contains exactly one value.
	returns: An Optional containing the sole value, or an undefined Optional for an empty or multiple-value sequence.
	about: Enumeration stops after a second value is found.
	End Rem
	Method SingleOrNone:Optional<T>()
		Local iterator:IIterator<T> = GetIterator()
		Try
			If Not iterator.MoveNext() Then Return Optional<T>.Undefined()
			Local value:T = iterator.Current()
			If iterator.MoveNext() Then Return Optional<T>.Undefined()
			Return Optional<T>.FromValue(value)
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Invokes @action once for each value.
	param: The Closure invoked for every value in sequence order.
	End Rem
	Method ForEach(action:Closure<(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				action(iterator.Current())
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Invokes a non-capturing function once for each value.
	param: The function invoked for every value in sequence order.
	End Rem
	Method ForEach(action:Void(value:T))
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				action(iterator.Current())
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
	End Method

	Rem
	bbdoc: Materializes the sequence as a new array.
	returns: A newly allocated array containing every produced value in order.
	End Rem
	Method ToArray:T[]()
		Local values:T[] = New T[16]
		Local count:Int
		Local iterator:IIterator<T> = GetIterator()
		Try
			While iterator.MoveNext()
				If count = values.Length Then
					values = values[..values.Length * 2]
				End If
				values[count] = iterator.Current()
				count :+ 1
			Wend
		Finally
			CloseSequenceIterator(iterator)
		End Try
		Return values[..count]
	End Method
End Type

Public

Rem
bbdoc: Array iterator used internally by #Sequence.
about: Most programs should construct a #Sequence rather than this implementation type directly.
End Rem
Type TArraySequenceIterator<T> Implements IIterator<T>
	Private
	Field _array:T[]
	Field _index:Int = -1

	Public
	Rem
	bbdoc: Creates an iterator over @array.
	param: The array to enumerate.
	End Rem
	Method New(array:T[])
		_array = array
	End Method

	Rem
	bbdoc: Returns the current array value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _array[_index]
	End Method

	Rem
	bbdoc: Advances to the next array value.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		_index :+ 1
		Return _index < _array.Length
	End Method
End Type

Rem
bbdoc: Closure-backed mapping pipeline used internally by #Sequence.Map.
End Rem
Type TMapSequence<T, U> Extends Sequence<U>
	Private
	Field _source:Sequence<T>
	Field _mapper:Closure<U(value:T)>

	Public
	Rem
	bbdoc: Creates a mapping pipeline.
	param: The source sequence.
	param: The mapping Closure.
	End Rem
	Method New(source:Sequence<T>, mapper:Closure<U(value:T)>)
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Creates an iterator for this mapping pipeline.
	returns: A new lazy mapping iterator.
	End Rem
	Method GetIterator:IIterator<U>() Override
		Return New TMapSequenceIterator<T, U>(_source.GetIterator(), _mapper)
	End Method
End Type

Rem
bbdoc: Closure-backed mapping iterator used internally by #TMapSequence.
End Rem
Type TMapSequenceIterator<T, U> Implements ICloseableIterator<U>
	Private
	Field _source:IIterator<T>
	Field _mapper:Closure<U(value:T)>
	Field _current:U
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a mapping iterator.
	param: The source iterator.
	param: The mapping Closure.
	End Rem
	Method New(source:IIterator<T>, mapper:Closure<U(value:T)>)
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Returns the current mapped value.
	returns: The value produced by the most recent successful #MoveNext call.
	End Rem
	Method Current:U()
		Return _current
	End Method

	Rem
	bbdoc: Advances and maps the next source value.
	returns: True when a mapped value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If Not _source.MoveNext() Then Return False
		_current = _mapper(_source.Current())
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Non-capturing function mapping pipeline used internally by #Sequence.Map.
End Rem
Type TFunctionMapSequence<T, U> Extends Sequence<U>
	Private
	Field _source:Sequence<T>
	Field _mapper:U(value:T)

	Public
	Rem
	bbdoc: Creates a non-capturing mapping pipeline.
	param: The source sequence.
	param: The mapping function.
	End Rem
	Method New(source:Sequence<T>, mapper:U(value:T))
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Creates an iterator for this mapping pipeline.
	returns: A new lazy mapping iterator.
	End Rem
	Method GetIterator:IIterator<U>() Override
		Return New TFunctionMapSequenceIterator<T, U>(_source.GetIterator(), _mapper)
	End Method
End Type

Rem
bbdoc: Non-capturing function mapping iterator used internally by #TFunctionMapSequence.
End Rem
Type TFunctionMapSequenceIterator<T, U> Implements ICloseableIterator<U>
	Private
	Field _source:IIterator<T>
	Field _mapper:U(value:T)
	Field _current:U
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a non-capturing mapping iterator.
	param: The source iterator.
	param: The mapping function.
	End Rem
	Method New(source:IIterator<T>, mapper:U(value:T))
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Returns the current mapped value.
	returns: The value produced by the most recent successful #MoveNext call.
	End Rem
	Method Current:U()
		Return _current
	End Method

	Rem
	bbdoc: Advances and maps the next source value.
	returns: True when a mapped value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If Not _source.MoveNext() Then Return False
		_current = _mapper(_source.Current())
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Closure-backed filtering pipeline used internally by #Sequence.Filter.
End Rem
Type TFilterSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _predicate:Closure<Int(value:T)>

	Public
	Rem
	bbdoc: Creates a filtering pipeline.
	param: The source sequence.
	param: The filtering Closure.
	End Rem
	Method New(source:Sequence<T>, predicate:Closure<Int(value:T)>)
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Creates an iterator for this filtering pipeline.
	returns: A new lazy filtering iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TFilterSequenceIterator<T>(_source.GetIterator(), _predicate)
	End Method
End Type

Rem
bbdoc: Closure-backed filtering iterator used internally by #TFilterSequence.
End Rem
Type TFilterSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Closure<Int(value:T)>
	Field _current:T
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a filtering iterator.
	param: The source iterator.
	param: The filtering Closure.
	End Rem
	Method New(source:IIterator<T>, predicate:Closure<Int(value:T)>)
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Returns the current accepted value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances until the predicate accepts a source value.
	returns: True when an accepted value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While _source.MoveNext()
			Local value:T = _source.Current()
			If _predicate(value) Then
				_current = value
				Return True
			End If
		Wend
		Return False
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Non-capturing function filtering pipeline used internally by #Sequence.Filter.
End Rem
Type TFunctionFilterSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _predicate:Int(value:T)

	Public
	Rem
	bbdoc: Creates a non-capturing filtering pipeline.
	param: The source sequence.
	param: The filtering function.
	End Rem
	Method New(source:Sequence<T>, predicate:Int(value:T))
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Creates an iterator for this filtering pipeline.
	returns: A new lazy filtering iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TFunctionFilterSequenceIterator<T>(_source.GetIterator(), _predicate)
	End Method
End Type

Rem
bbdoc: Non-capturing function filtering iterator used internally by #TFunctionFilterSequence.
End Rem
Type TFunctionFilterSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Int(value:T)
	Field _current:T
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a non-capturing filtering iterator.
	param: The source iterator.
	param: The filtering function.
	End Rem
	Method New(source:IIterator<T>, predicate:Int(value:T))
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Returns the current accepted value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances until the predicate accepts a source value.
	returns: True when an accepted value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While _source.MoveNext()
			Local value:T = _source.Current()
			If _predicate(value) Then
				_current = value
				Return True
			End If
		Wend
		Return False
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Limiting pipeline used internally by #Sequence.Take.
End Rem
Type TTakeSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _count:Int

	Public
	Rem
	bbdoc: Creates a limiting pipeline.
	param: The source sequence.
	param: The maximum number of values to produce.
	End Rem
	Method New(source:Sequence<T>, count:Int)
		_source = source
		_count = count
	End Method

	Rem
	bbdoc: Creates an iterator for this limiting pipeline.
	returns: A new lazy limiting iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TTakeSequenceIterator<T>(_source.GetIterator(), _count)
	End Method
End Type

Rem
bbdoc: Limiting iterator used internally by #TTakeSequence.
End Rem
Type TTakeSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _remaining:Int
	Field _current:T
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a limiting iterator.
	param: The source iterator.
	param: The maximum number of values to produce.
	End Rem
	Method New(source:IIterator<T>, count:Int)
		_source = source
		_remaining = count
	End Method

	Rem
	bbdoc: Returns the current value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances while the requested number of values remains.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If _remaining <= 0 Then Return False
		If Not _source.MoveNext() Then
			_remaining = 0
			Return False
		End If
		_remaining :- 1
		_current = _source.Current()
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Omitting pipeline used internally by #Sequence.Skip.
End Rem
Type TSkipSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _count:Int

	Public
	Rem
	bbdoc: Creates an omitting pipeline.
	param: The source sequence.
	param: The number of initial values to omit.
	End Rem
	Method New(source:Sequence<T>, count:Int)
		_source = source
		_count = count
	End Method

	Rem
	bbdoc: Creates an iterator for this omitting pipeline.
	returns: A new lazy omitting iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TSkipSequenceIterator<T>(_source.GetIterator(), _count)
	End Method
End Type

Rem
bbdoc: Omitting iterator used internally by #TSkipSequence.
End Rem
Type TSkipSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _remaining:Int
	Field _current:T
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates an omitting iterator.
	param: The source iterator.
	param: The number of initial values to omit.
	End Rem
	Method New(source:IIterator<T>, count:Int)
		_source = source
		_remaining = count
	End Method

	Rem
	bbdoc: Returns the current value after the initial values have been omitted.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Omits the requested values, then advances the source iterator.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While _remaining > 0
			If Not _source.MoveNext() Then
				_remaining = 0
				Return False
			End If
			_remaining :- 1
		Wend
		If Not _source.MoveNext() Then Return False
		_current = _source.Current()
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Closure-backed flattening pipeline used internally by #Sequence.FlatMap.
End Rem
Type TFlatMapSequence<T, U> Extends Sequence<U>
	Private
	Field _source:Sequence<T>
	Field _mapper:Closure<Sequence<U>(value:T)>

	Public
	Rem
	bbdoc: Creates a flattening pipeline.
	param: The outer source sequence.
	param: The Closure which creates an inner sequence for an outer value.
	End Rem
	Method New(source:Sequence<T>, mapper:Closure<Sequence<U>(value:T)>)
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Creates an iterator for this flattening pipeline.
	returns: A new lazy flattening iterator.
	End Rem
	Method GetIterator:IIterator<U>() Override
		Return New TFlatMapSequenceIterator<T, U>(_source.GetIterator(), _mapper)
	End Method
End Type

Rem
bbdoc: Closure-backed flattening iterator used internally by #TFlatMapSequence.
End Rem
Type TFlatMapSequenceIterator<T, U> Implements ICloseableIterator<U>
	Private
	Field _source:IIterator<T>
	Field _mapper:Closure<Sequence<U>(value:T)>
	Field _inner:IIterator<U>
	Field _hasInner:Int
	Field _current:U
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a flattening iterator.
	param: The outer source iterator.
	param: The Closure which creates an inner sequence for an outer value.
	End Rem
	Method New(source:IIterator<T>, mapper:Closure<Sequence<U>(value:T)>)
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Returns the current inner value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:U()
		Return _current
	End Method

	Rem
	bbdoc: Advances through the current inner sequence, requesting another only when needed.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While True
			If _hasInner And _inner.MoveNext() Then
				_current = _inner.Current()
				Return True
			End If
			If _hasInner Then
				CloseSequenceIterator(_inner)
				_hasInner = False
			End If
			If Not _source.MoveNext() Then Return False
			Local inner:Sequence<U> = _mapper(_source.Current())
			_inner = inner.GetIterator()
			_hasInner = True
		Wend
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		If _hasInner Then CloseSequenceIterator(_inner)
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Non-capturing function flattening pipeline used internally by #Sequence.FlatMap.
End Rem
Type TFunctionFlatMapSequence<T, U> Extends Sequence<U>
	Private
	Field _source:Sequence<T>
	Field _mapper:Sequence<U>(value:T)

	Public
	Rem
	bbdoc: Creates a non-capturing flattening pipeline.
	param: The outer source sequence.
	param: The function which creates an inner sequence for an outer value.
	End Rem
	Method New(source:Sequence<T>, mapper:Sequence<U>(value:T))
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Creates an iterator for this flattening pipeline.
	returns: A new lazy flattening iterator.
	End Rem
	Method GetIterator:IIterator<U>() Override
		Return New TFunctionFlatMapSequenceIterator<T, U>(_source.GetIterator(), _mapper)
	End Method
End Type

Rem
bbdoc: Non-capturing function flattening iterator used internally by #TFunctionFlatMapSequence.
End Rem
Type TFunctionFlatMapSequenceIterator<T, U> Implements ICloseableIterator<U>
	Private
	Field _source:IIterator<T>
	Field _mapper:Sequence<U>(value:T)
	Field _inner:IIterator<U>
	Field _hasInner:Int
	Field _current:U
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a non-capturing flattening iterator.
	param: The outer source iterator.
	param: The function which creates an inner sequence for an outer value.
	End Rem
	Method New(source:IIterator<T>, mapper:Sequence<U>(value:T))
		_source = source
		_mapper = mapper
	End Method

	Rem
	bbdoc: Returns the current inner value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:U()
		Return _current
	End Method

	Rem
	bbdoc: Advances through the current inner sequence, requesting another only when needed.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While True
			If _hasInner And _inner.MoveNext() Then
				_current = _inner.Current()
				Return True
			End If
			If _hasInner Then
				CloseSequenceIterator(_inner)
				_hasInner = False
			End If
			If Not _source.MoveNext() Then Return False
			Local inner:Sequence<U> = _mapper(_source.Current())
			_inner = inner.GetIterator()
			_hasInner = True
		Wend
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		If _hasInner Then CloseSequenceIterator(_inner)
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Concatenating pipeline used internally by #Sequence.Concat.
End Rem
Type TConcatSequence<T> Extends Sequence<T>
	Private
	Field _first:Sequence<T>
	Field _second:Sequence<T>

	Public
	Rem
	bbdoc: Creates a concatenating pipeline.
	param: The first sequence.
	param: The second sequence.
	End Rem
	Method New(first:Sequence<T>, second:Sequence<T>)
		_first = first
		_second = second
	End Method

	Rem
	bbdoc: Creates an iterator for this concatenating pipeline.
	returns: A new lazy concatenating iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TConcatSequenceIterator<T>(_first.GetIterator(), _second)
	End Method
End Type

Rem
bbdoc: Concatenating iterator used internally by #TConcatSequence.
End Rem
Type TConcatSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _first:IIterator<T>
	Field _secondSource:Sequence<T>
	Field _second:IIterator<T>
	Field _inSecond:Int
	Field _current:T
	Field _closed:Int
	Field _firstClosed:Int

	Public
	Rem
	bbdoc: Creates a concatenating iterator.
	param: The first iterator.
	param: The second sequence, retained until the first iterator is exhausted.
	End Rem
	Method New(first:IIterator<T>, second:Sequence<T>)
		_first = first
		_secondSource = second
	End Method

	Rem
	bbdoc: Returns the current value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances the first iterator and then the second iterator.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If Not _inSecond Then
			If _first.MoveNext() Then
				_current = _first.Current()
				Return True
			End If
			CloseSequenceIterator(_first)
			_firstClosed = True
			_second = _secondSource.GetIterator()
			_inSecond = True
		End If
		If Not _second.MoveNext() Then Return False
		_current = _second.Current()
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		If _inSecond Then CloseSequenceIterator(_second)
		If Not _firstClosed Then CloseSequenceIterator(_first)
	End Method
End Type

Rem
bbdoc: Closure-backed prefix pipeline used internally by #Sequence.TakeWhile.
End Rem
Type TTakeWhileSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _predicate:Closure<Int(value:T)>

	Public
	Rem
	bbdoc: Creates a Closure-backed prefix pipeline.
	param: The source sequence.
	param: The prefix predicate.
	End Rem
	Method New(source:Sequence<T>, predicate:Closure<Int(value:T)>)
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Creates an iterator for this prefix pipeline.
	returns: A new lazy prefix iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TTakeWhileSequenceIterator<T>(_source.GetIterator(), _predicate)
	End Method
End Type

Rem
bbdoc: Closure-backed prefix iterator used internally by #TTakeWhileSequence.
End Rem
Type TTakeWhileSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Closure<Int(value:T)>
	Field _current:T
	Field _done:Int
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a Closure-backed prefix iterator.
	param: The source iterator.
	param: The prefix predicate.
	End Rem
	Method New(source:IIterator<T>, predicate:Closure<Int(value:T)>)
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Returns the current accepted prefix value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances while the predicate accepts source values.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If _done Or Not _source.MoveNext() Then Return False
		Local value:T = _source.Current()
		If Not _predicate(value) Then
			_done = True
			Return False
		End If
		_current = value
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Non-capturing function prefix pipeline used internally by #Sequence.TakeWhile.
End Rem
Type TFunctionTakeWhileSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _predicate:Int(value:T)

	Public
	Rem
	bbdoc: Creates a non-capturing function prefix pipeline.
	param: The source sequence.
	param: The prefix predicate.
	End Rem
	Method New(source:Sequence<T>, predicate:Int(value:T))
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Creates an iterator for this prefix pipeline.
	returns: A new lazy prefix iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TFunctionTakeWhileSequenceIterator<T>(_source.GetIterator(), _predicate)
	End Method
End Type

Rem
bbdoc: Non-capturing function prefix iterator used internally by #TFunctionTakeWhileSequence.
End Rem
Type TFunctionTakeWhileSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Int(value:T)
	Field _current:T
	Field _done:Int
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a non-capturing function prefix iterator.
	param: The source iterator.
	param: The prefix predicate.
	End Rem
	Method New(source:IIterator<T>, predicate:Int(value:T))
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Returns the current accepted prefix value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances while the predicate accepts source values.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If _done Or Not _source.MoveNext() Then Return False
		Local value:T = _source.Current()
		If Not _predicate(value) Then
			_done = True
			Return False
		End If
		_current = value
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Closure-backed prefix-skipping pipeline used internally by #Sequence.SkipWhile.
End Rem
Type TSkipWhileSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _predicate:Closure<Int(value:T)>

	Public
	Rem
	bbdoc: Creates a Closure-backed prefix-skipping pipeline.
	param: The source sequence.
	param: The prefix predicate.
	End Rem
	Method New(source:Sequence<T>, predicate:Closure<Int(value:T)>)
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Creates an iterator for this prefix-skipping pipeline.
	returns: A new lazy prefix-skipping iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TSkipWhileSequenceIterator<T>(_source.GetIterator(), _predicate)
	End Method
End Type

Rem
bbdoc: Closure-backed prefix-skipping iterator used internally by #TSkipWhileSequence.
End Rem
Type TSkipWhileSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Closure<Int(value:T)>
	Field _current:T
	Field _skipping:Int = True
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a Closure-backed prefix-skipping iterator.
	param: The source iterator.
	param: The prefix predicate.
	End Rem
	Method New(source:IIterator<T>, predicate:Closure<Int(value:T)>)
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Returns the current value after prefix skipping has completed.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Skips the accepted prefix and then advances normally.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While _source.MoveNext()
			Local value:T = _source.Current()
			If _skipping And _predicate(value) Then Continue
			_skipping = False
			_current = value
			Return True
		Wend
		Return False
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Non-capturing function prefix-skipping pipeline used internally by #Sequence.SkipWhile.
End Rem
Type TFunctionSkipWhileSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _predicate:Int(value:T)

	Public
	Rem
	bbdoc: Creates a non-capturing function prefix-skipping pipeline.
	param: The source sequence.
	param: The prefix predicate.
	End Rem
	Method New(source:Sequence<T>, predicate:Int(value:T))
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Creates an iterator for this prefix-skipping pipeline.
	returns: A new lazy prefix-skipping iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TFunctionSkipWhileSequenceIterator<T>(_source.GetIterator(), _predicate)
	End Method
End Type

Rem
bbdoc: Non-capturing function prefix-skipping iterator used internally by #TFunctionSkipWhileSequence.
End Rem
Type TFunctionSkipWhileSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Int(value:T)
	Field _current:T
	Field _skipping:Int = True
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a non-capturing function prefix-skipping iterator.
	param: The source iterator.
	param: The prefix predicate.
	End Rem
	Method New(source:IIterator<T>, predicate:Int(value:T))
		_source = source
		_predicate = predicate
	End Method

	Rem
	bbdoc: Returns the current value after prefix skipping has completed.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Skips the accepted prefix and then advances normally.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		While _source.MoveNext()
			Local value:T = _source.Current()
			If _skipping And _predicate(value) Then Continue
			_skipping = False
			_current = value
			Return True
		Wend
		Return False
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Trailing-value pipeline used internally by #Sequence.Append.
End Rem
Type TAppendSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _value:T

	Public
	Rem
	bbdoc: Creates a trailing-value pipeline.
	param: The source sequence.
	param: The trailing value.
	End Rem
	Method New(source:Sequence<T>, value:T)
		_source = source
		_value = value
	End Method

	Rem
	bbdoc: Creates an iterator for this trailing-value pipeline.
	returns: A new lazy trailing-value iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TAppendSequenceIterator<T>(_source.GetIterator(), _value)
	End Method
End Type

Rem
bbdoc: Trailing-value iterator used internally by #TAppendSequence.
End Rem
Type TAppendSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _value:T
	Field _current:T
	Field _sourceDone:Int
	Field _appended:Int
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a trailing-value iterator.
	param: The source iterator.
	param: The trailing value.
	End Rem
	Method New(source:IIterator<T>, value:T)
		_source = source
		_value = value
	End Method

	Rem
	bbdoc: Returns the current source or trailing value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Advances the source and then yields the trailing value once.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If Not _sourceDone And _source.MoveNext() Then
			_current = _source.Current()
			Return True
		End If
		If Not _sourceDone Then CloseSequenceIterator(_source)
		_sourceDone = True
		If _appended Then Return False
		_appended = True
		_current = _value
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		If Not _sourceDone Then CloseSequenceIterator(_source)
	End Method
End Type

Rem
bbdoc: Leading-value pipeline used internally by #Sequence.Prepend.
End Rem
Type TPrependSequence<T> Extends Sequence<T>
	Private
	Field _source:Sequence<T>
	Field _value:T

	Public
	Rem
	bbdoc: Creates a leading-value pipeline.
	param: The source sequence.
	param: The leading value.
	End Rem
	Method New(source:Sequence<T>, value:T)
		_source = source
		_value = value
	End Method

	Rem
	bbdoc: Creates an iterator for this leading-value pipeline.
	returns: A new lazy leading-value iterator.
	End Rem
	Method GetIterator:IIterator<T>() Override
		Return New TPrependSequenceIterator<T>(_source.GetIterator(), _value)
	End Method
End Type

Rem
bbdoc: Leading-value iterator used internally by #TPrependSequence.
End Rem
Type TPrependSequenceIterator<T> Implements ICloseableIterator<T>
	Private
	Field _source:IIterator<T>
	Field _value:T
	Field _current:T
	Field _prepended:Int
	Field _closed:Int

	Public
	Rem
	bbdoc: Creates a leading-value iterator.
	param: The source iterator.
	param: The leading value.
	End Rem
	Method New(source:IIterator<T>, value:T)
		_source = source
		_value = value
	End Method

	Rem
	bbdoc: Returns the current leading or source value.
	returns: The value selected by the most recent successful #MoveNext call.
	End Rem
	Method Current:T()
		Return _current
	End Method

	Rem
	bbdoc: Yields the leading value once and then advances the source.
	returns: True when a current value is available; otherwise False.
	End Rem
	Method MoveNext:Int()
		If _closed Then Return False
		If Not _prepended Then
			_prepended = True
			_current = _value
			Return True
		End If
		If Not _source.MoveNext() Then Return False
		_current = _source.Current()
		Return True
	End Method

	Method Close() Override
		If _closed Then Return
		_closed = True
		CloseSequenceIterator(_source)
	End Method
End Type

?
