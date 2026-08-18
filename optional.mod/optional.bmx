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
bbdoc: System/Optional
End Rem
Module BRL.Optional

?bmxng2

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.Blitz

Rem
bbdoc: The state of an #Optional value.
End Rem
Enum EOptionalState:Byte
	Undefined
	NullValue
	Value
End Enum

Rem
bbdoc: Thrown when #Optional.Value is read without a contained value.
End Rem
Type TOptionalValueException Extends TBlitzException
	Rem
	bbdoc: Returns the exception message.
	returns: A description explaining that the Optional has no value.
	End Rem
	Method ToString:String() Override
		Return "Optional does not contain a value"
	End Method
End Type

Rem
bbdoc: A value which explicitly distinguishes undefined, null, and present states.
about: A default-initialized Optional is undefined. Use #FromValue, #NullValue,
or #Undefined when constructing an explicit state.
End Rem
Struct Optional<T>
	Private
	Field _state:EOptionalState
	Field _value:T

	Public
	Rem
	bbdoc: Creates the default undefined Optional.
	End Rem
	Method New()
	End Method

	Private
	Method New(state:EOptionalState, value:T)
		_state = state
		_value = value
	End Method

	Public
	Rem
	bbdoc: Creates an Optional containing @value.
	param: The value to contain, including Null for managed value types.
	returns: An Optional in the #EOptionalState.Value state.
	End Rem
	Function FromValue:Optional<T>(value:T)
		Return New Optional<T>(EOptionalState.Value, value)
	End Function

	Rem
	bbdoc: Creates an Optional whose explicit state is null.
	returns: An Optional in the #EOptionalState.NullValue state.
	End Rem
	Function NullValue:Optional<T>()
		Local value:T
		Return New Optional<T>(EOptionalState.NullValue, value)
	End Function

	Rem
	bbdoc: Creates an undefined Optional.
	returns: An Optional in the #EOptionalState.Undefined state.
	End Rem
	Function Undefined:Optional<T>()
		Local value:T
		Return New Optional<T>(EOptionalState.Undefined, value)
	End Function

	Rem
	bbdoc: Returns this Optional's exact value, explicit null, or undefined state.
	returns: The current #EOptionalState.
	End Rem
	Method State:EOptionalState()
		Return _state
	End Method

	Rem
	bbdoc: Returns True when this Optional contains a value.
	returns: True for the Value state; otherwise False.
	End Rem
	Method HasValue:Int()
		Return _state = EOptionalState.Value
	End Method

	Rem
	bbdoc: Returns True for either a present value or an explicit null state.
	returns: False only when this Optional is undefined.
	End Rem
	Method IsDefined:Int()
		Return _state <> EOptionalState.Undefined
	End Method

	Rem
	bbdoc: Returns True when this Optional is undefined.
	returns: True for the Undefined state; otherwise False.
	End Rem
	Method IsUndefined:Int()
		Return _state = EOptionalState.Undefined
	End Method

	Rem
	bbdoc: Returns True when this Optional is explicitly null.
	returns: True for the NullValue state; otherwise False.
	End Rem
	Method IsNull:Int()
		Return _state = EOptionalState.NullValue
	End Method

	Rem
	bbdoc: Returns the contained value.
	returns: The contained value.
	about: Throws #TOptionalValueException for either absence state.
	End Rem
	Method Value:T()
		If Not HasValue() Then Throw New TOptionalValueException
		Return _value
	End Method

	Rem
	bbdoc: Returns the contained value or eager @fallback for either absence state.
	param: The value to return when this Optional is null or undefined.
	returns: The contained value when present; otherwise @fallback.
	End Rem
	Method ValueOr:T(fallback:T)
		If HasValue() Then Return _value
		Return fallback
	End Method

	Rem
	bbdoc: Transforms a present value, preserving an explicit null or undefined state.
	param: The Closure invoked with the contained value.
	returns: A mapped Optional, or the corresponding preserved absence state.
	End Rem
	Method Map<U>:Optional<U>(mapper:Closure<U(value:T)>)
		Select _state
			Case EOptionalState.Value
				Return Optional<U>.FromValue(mapper(_value))
			Case EOptionalState.NullValue
				Return Optional<U>.NullValue()
			Default
				Return Optional<U>.Undefined()
		End Select
	End Method

	Rem
	bbdoc: Transforms a present value into another Optional, preserving an existing absence state.
	param: The Closure invoked with the contained value to produce another Optional.
	returns: The Optional returned by @mapper, or the corresponding preserved absence state.
	End Rem
	Method FlatMap<U>:Optional<U>(mapper:Closure<Optional<U>(value:T)>)
		Select _state
			Case EOptionalState.Value
				Return mapper(_value)
			Case EOptionalState.NullValue
				Return Optional<U>.NullValue()
			Default
				Return Optional<U>.Undefined()
		End Select
	End Method

	Rem
	bbdoc: Retains a present value when @predicate succeeds.
	param: The predicate invoked with the contained value.
	returns: This Optional when absent or accepted; otherwise an undefined Optional.
	about: A rejected present value becomes undefined. Existing null and undefined
	states are preserved without invoking @predicate.
	End Rem
	Method Filter:Optional<T>(predicate:Closure<Int(value:T)>)
		If Not HasValue() Then Return Self
		If predicate(_value) Then Return Self
		Return Optional<T>.Undefined()
	End Method

	Rem
	bbdoc: Invokes @action only when this Optional contains a value.
	param: The action invoked with the contained value.
	End Rem
	Method IfPresent(action:Closure<(value:T)>)
		If HasValue() Then action(_value)
	End Method

	Rem
	bbdoc: Returns the present value or lazily creates a fallback for either absence state.
	param: The zero-argument Closure invoked only when this Optional has no value.
	returns: The contained value when present; otherwise the value returned by @factory.
	End Rem
	Method ValueOrElse:T(factory:Closure<T()>)
		If HasValue() Then Return _value
		Return factory()
	End Method

	Rem
	bbdoc: Lazily recovers an undefined Optional.
	param: The zero-argument Closure invoked only for an undefined Optional.
	returns: The factory result when undefined; otherwise this Optional.
	End Rem
	Method OrIfUndefined:Optional<T>(factory:Closure<Optional<T>()>)
		If IsUndefined() Then Return factory()
		Return Self
	End Method

	Rem
	bbdoc: Lazily recovers an explicitly null Optional.
	param: The zero-argument Closure invoked only for an explicitly null Optional.
	returns: The factory result when null; otherwise this Optional.
	End Rem
	Method OrIfNull:Optional<T>(factory:Closure<Optional<T>()>)
		If IsNull() Then Return factory()
		Return Self
	End Method

	Rem
	bbdoc: Lazily recovers either an undefined or explicitly null Optional.
	param: The zero-argument Closure invoked only when this Optional has no value.
	returns: The factory result when absent; otherwise this Optional.
	End Rem
	Method OrIfEmpty:Optional<T>(factory:Closure<Optional<T>()>)
		If Not HasValue() Then Return factory()
		Return Self
	End Method

	Rem
	bbdoc: Exhaustively handles the value, explicit null, and undefined states.
	param: The handler invoked with a present value.
	param: The zero-argument handler invoked for explicit null.
	param: The zero-argument handler invoked for undefined.
	returns: The value returned by the selected handler.
	End Rem
	Method Match<U>:U(valueHandler:Closure<U(value:T)>, nullHandler:Closure<U()>, undefinedHandler:Closure<U()>)
		Select _state
			Case EOptionalState.Value
				Return valueHandler(_value)
			Case EOptionalState.NullValue
				Return nullHandler()
			Default
				Return undefinedHandler()
		End Select
	End Method

	Rem
	bbdoc: Exhaustively invokes one side-effecting handler for the value, explicit null, or undefined state.
	param: The handler invoked with a present value.
	param: The zero-argument handler invoked for explicit null.
	param: The zero-argument handler invoked for undefined.
	End Rem
	Method Visit(valueHandler:Closure<(value:T)>, nullHandler:Closure<()>, undefinedHandler:Closure<()>)
		Select _state
			Case EOptionalState.Value
				valueHandler(_value)
			Case EOptionalState.NullValue
				nullHandler()
			Default
				undefinedHandler()
		End Select
	End Method

	Rem
	bbdoc: Writes the contained value to @value and returns True when present.
	param: Receives the contained value, or the default value of T when absent.
	returns: True when a value was written; otherwise False.
	about: For either absence state, resets @value to the default value of T and returns False.
	End Rem
	Method TryGet:Int(value:T Var)
		If HasValue()
			value = _value
			Return True
		End If
		Local empty:T
		value = empty
		Return False
	End Method
End Struct

?
