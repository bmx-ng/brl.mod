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

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.Optional

Rem
bbdoc: A lazy, typed sequence of values.
about: A Sequence is a reusable query recipe. Each call to #GetIterator asks its
source for a new iterator and applies the pipeline while values are requested.
No intermediate arrays are created.

Sequences retain their source rather than copying it. Changes made to an array
or collection before a later enumeration are therefore visible. Replayability
ultimately follows the source's #IIterable contract: a source that returns the
same one-shot iterator on every call remains one-shot and is not buffered by
Sequence.
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
	bbdoc: Combines the sequence into one value, starting with @seed.
	param: The initial accumulator value.
	param: The Closure invoked with the current accumulator and each source value.
	returns: The final accumulator, or @seed when the sequence is empty.
	End Rem
	Method Fold<U>:U(seed:U, folder:Closure<U(accumulator:U, value:T)>)
		Local accumulator:U = seed
		Local iterable:IIterable<T> = Self
		Local iterator:IIterator<T> = iterable.GetIterator()
		While iterator.MoveNext()
			accumulator = folder(accumulator, iterator.Current())
		Wend
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
		While iterator.MoveNext()
			accumulator = folder(accumulator, iterator.Current())
		Wend
		Return accumulator
	End Method

	Rem
	bbdoc: Counts the values in the sequence.
	returns: The number of values produced by the sequence.
	End Rem
	Method Count:Int()
		Local count:Int
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			count :+ 1
		Wend
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
		While iterator.MoveNext()
			If predicate(iterator.Current()) Then count :+ 1
		Wend
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
		While iterator.MoveNext()
			If predicate(iterator.Current()) Then count :+ 1
		Wend
		Return count
	End Method

	Rem
	bbdoc: Returns True when the sequence contains at least one value.
	returns: True after finding the first value; otherwise False.
	End Rem
	Method Any:Int()
		Return GetIterator().MoveNext()
	End Method

	Rem
	bbdoc: Returns True when any value satisfies @predicate.
	param: The Closure tested until a value is accepted.
	returns: True when a value is accepted; otherwise False.
	End Rem
	Method Any:Int(predicate:Closure<Int(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			If predicate(iterator.Current()) Then Return True
		Wend
		Return False
	End Method

	Rem
	bbdoc: Returns True when any value satisfies a non-capturing function.
	param: The function tested until a value is accepted.
	returns: True when a value is accepted; otherwise False.
	End Rem
	Method Any:Int(predicate:Int(value:T))
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			If predicate(iterator.Current()) Then Return True
		Wend
		Return False
	End Method

	Rem
	bbdoc: Returns True when every value satisfies @predicate.
	param: The Closure tested until a value is rejected.
	returns: True when every value is accepted, including an empty sequence.
	about: Returns True for an empty sequence.
	End Rem
	Method All:Int(predicate:Closure<Int(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			If Not predicate(iterator.Current()) Then Return False
		Wend
		Return True
	End Method

	Rem
	bbdoc: Returns True when every value satisfies a non-capturing function.
	param: The function tested until a value is rejected.
	returns: True when every value is accepted, including an empty sequence.
	End Rem
	Method All:Int(predicate:Int(value:T))
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			If Not predicate(iterator.Current()) Then Return False
		Wend
		Return True
	End Method

	Rem
	bbdoc: Returns the first value, or an undefined Optional when the sequence is empty.
	returns: An Optional containing the first value, or an undefined Optional.
	about: A present element is represented with #Optional.FromValue, including a
	present element whose managed value is Null.
	End Rem
	Method FirstOrNone:Optional<T>()
		Local iterator:IIterator<T> = GetIterator()
		If iterator.MoveNext() Then Return Optional<T>.FromValue(iterator.Current())
		Return Optional<T>.Undefined()
	End Method

	Rem
	bbdoc: Returns the first value satisfying @predicate, or an undefined Optional.
	param: The Closure tested until a value is accepted.
	returns: An Optional containing the first accepted value, or an undefined Optional.
	about: Evaluation stops after the first match.
	End Rem
	Method FirstOrNone:Optional<T>(predicate:Closure<Int(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			Local value:T = iterator.Current()
			If predicate(value) Then Return Optional<T>.FromValue(value)
		Wend
		Return Optional<T>.Undefined()
	End Method

	Rem
	bbdoc: Returns the first value accepted by a non-capturing function.
	param: The function tested until a value is accepted.
	returns: An Optional containing the first accepted value, or an undefined Optional.
	about: Evaluation stops after the first match.
	End Rem
	Method FirstOrNone:Optional<T>(predicate:Int(value:T))
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			Local value:T = iterator.Current()
			If predicate(value) Then Return Optional<T>.FromValue(value)
		Wend
		Return Optional<T>.Undefined()
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
		While iterator.MoveNext()
			result = Optional<T>.FromValue(iterator.Current())
		Wend
		Return result
	End Method

	Rem
	bbdoc: Invokes @action once for each value.
	param: The Closure invoked for every value in sequence order.
	End Rem
	Method ForEach(action:Closure<(value:T)>)
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			action(iterator.Current())
		Wend
	End Method

	Rem
	bbdoc: Invokes a non-capturing function once for each value.
	param: The function invoked for every value in sequence order.
	End Rem
	Method ForEach(action:Void(value:T))
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			action(iterator.Current())
		Wend
	End Method

	Rem
	bbdoc: Materializes the sequence as a new array.
	returns: A newly allocated array containing every produced value in order.
	End Rem
	Method ToArray:T[]()
		Local values:T[] = New T[16]
		Local count:Int
		Local iterator:IIterator<T> = GetIterator()
		While iterator.MoveNext()
			If count = values.Length Then
				values = values[..values.Length * 2]
			End If
			values[count] = iterator.Current()
			count :+ 1
		Wend
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
Type TMapSequenceIterator<T, U> Implements IIterator<U>
	Private
	Field _source:IIterator<T>
	Field _mapper:Closure<U(value:T)>
	Field _current:U

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
		If Not _source.MoveNext() Then Return False
		_current = _mapper(_source.Current())
		Return True
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
Type TFunctionMapSequenceIterator<T, U> Implements IIterator<U>
	Private
	Field _source:IIterator<T>
	Field _mapper:U(value:T)
	Field _current:U

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
		If Not _source.MoveNext() Then Return False
		_current = _mapper(_source.Current())
		Return True
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
Type TFilterSequenceIterator<T> Implements IIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Closure<Int(value:T)>
	Field _current:T

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
		While _source.MoveNext()
			Local value:T = _source.Current()
			If _predicate(value) Then
				_current = value
				Return True
			End If
		Wend
		Return False
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
Type TFunctionFilterSequenceIterator<T> Implements IIterator<T>
	Private
	Field _source:IIterator<T>
	Field _predicate:Int(value:T)
	Field _current:T

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
		While _source.MoveNext()
			Local value:T = _source.Current()
			If _predicate(value) Then
				_current = value
				Return True
			End If
		Wend
		Return False
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
Type TTakeSequenceIterator<T> Implements IIterator<T>
	Private
	Field _source:IIterator<T>
	Field _remaining:Int
	Field _current:T

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
		If _remaining <= 0 Then Return False
		If Not _source.MoveNext() Then
			_remaining = 0
			Return False
		End If
		_remaining :- 1
		_current = _source.Current()
		Return True
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
Type TSkipSequenceIterator<T> Implements IIterator<T>
	Private
	Field _source:IIterator<T>
	Field _remaining:Int
	Field _current:T

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
End Type

?
