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
bbdoc: System/Result
End Rem
Module BRL.Result

?bmxng2

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.Blitz

Rem
bbdoc: The state of a #Result value.
End Rem
Enum EResultState:Byte
	Uninitialized
	Ok
	Err
End Enum

Rem
bbdoc: Thrown when an operation requires an initialized #Result.
End Rem
Type TResultStateException Extends TBlitzException
	Rem
	bbdoc: Returns the exception message.
	returns: A description explaining that the Result is uninitialized.
	End Rem
	Method ToString:String() Override
		Return "Result is uninitialized"
	End Method
End Type

Rem
bbdoc: Thrown when #Result.Value is read from an Err Result.
End Rem
Type TResultValueException Extends TBlitzException
	Rem
	bbdoc: Returns the exception message.
	returns: A description explaining that the Result has no Ok value.
	End Rem
	Method ToString:String() Override
		Return "Result does not contain an Ok value"
	End Method
End Type

Rem
bbdoc: Thrown when #Result.Error is read from an Ok Result.
End Rem
Type TResultErrorException Extends TBlitzException
	Rem
	bbdoc: Returns the exception message.
	returns: A description explaining that the Result has no Err value.
	End Rem
	Method ToString:String() Override
		Return "Result does not contain an Err value"
	End Method
End Type

Rem
bbdoc: A value which contains either an Ok value or an Err value.
about: A default-initialized Result is uninitialized rather than implicitly Ok
or Err. Use #Ok or #Err to create an initialized Result. Operations which must
select a branch throw #TResultStateException for an uninitialized Result.

Result is a value Struct. Assigning or returning it copies its state and both
generic storage fields. Managed values stored in those fields retain their
ordinary reference identity.
End Rem
Struct Result<T, E>
	Private
	Field _state:EResultState
	Field _value:T
	Field _error:E

	Public
	Rem
	bbdoc: Creates the default uninitialized Result.
	End Rem
	Method New()
	End Method

	Private
	Method New(state:EResultState, value:T, error:E)
		_state = state
		_value = value
		_error = error
	End Method

	Public
	Rem
	bbdoc: Creates an Ok Result containing @value.
	param: The successful value to contain.
	returns: An initialized Result in the #EResultState.Ok state.
	End Rem
	Function Ok:Result<T, E>(value:T)
		Local error:E
		Return New Result<T, E>(EResultState.Ok, value, error)
	End Function

	Rem
	bbdoc: Creates an Err Result containing @error.
	param: The error value to contain.
	returns: An initialized Result in the #EResultState.Err state.
	End Rem
	Function Err:Result<T, E>(error:E)
		Local value:T
		Return New Result<T, E>(EResultState.Err, value, error)
	End Function

	Rem
	bbdoc: Returns this Result's exact state.
	returns: The current #EResultState.
	End Rem
	Method State:EResultState()
		Return _state
	End Method

	Rem
	bbdoc: Returns True when this Result was explicitly constructed as Ok or Err.
	returns: True when initialized; otherwise False.
	End Rem
	Method IsInitialized:Int()
		Return _state <> EResultState.Uninitialized
	End Method

	Rem
	bbdoc: Returns True when this Result is uninitialized.
	returns: True when uninitialized; otherwise False.
	End Rem
	Method IsUninitialized:Int()
		Return _state = EResultState.Uninitialized
	End Method

	Rem
	bbdoc: Returns True when this Result contains an Ok value.
	returns: True for the Ok state; otherwise False.
	End Rem
	Method IsOk:Int()
		Return _state = EResultState.Ok
	End Method

	Rem
	bbdoc: Returns True when this Result contains an Err value.
	returns: True for the Err state; otherwise False.
	End Rem
	Method IsErr:Int()
		Return _state = EResultState.Err
	End Method

	Rem
	bbdoc: Returns the contained Ok value.
	returns: The contained Ok value.
	about: Throws #TResultStateException when uninitialized and
#TResultValueException when this Result is Err.
	End Rem
	Method Value:T()
		RequireInitialized()
		If IsErr() Then Throw New TResultValueException
		Return _value
	End Method

	Rem
	bbdoc: Returns the contained Err value.
	returns: The contained Err value.
	about: Throws #TResultStateException when uninitialized and
#TResultErrorException when this Result is Ok.
	End Rem
	Method Error:E()
		RequireInitialized()
		If IsOk() Then Throw New TResultErrorException
		Return _error
	End Method

	Rem
	bbdoc: Returns the Ok value, or eager @fallback for Err.
	param: The value returned when this Result is Err.
	returns: The Ok value, or @fallback for Err.
	about: Throws #TResultStateException when uninitialized.
	End Rem
	Method ValueOr:T(fallback:T)
		RequireInitialized()
		If IsOk() Then Return _value
		Return fallback
	End Method

	Rem
	bbdoc: Returns the Err value, or eager @fallback for Ok.
	param: The error returned when this Result is Ok.
	returns: The Err value, or @fallback for Ok.
	about: Throws #TResultStateException when uninitialized.
	End Rem
	Method ErrorOr:E(fallback:E)
		RequireInitialized()
		If IsErr() Then Return _error
		Return fallback
	End Method

	Rem
	bbdoc: Writes the Ok value to @value and returns True when this Result is Ok.
	param: Receives the contained Ok value when present.
	returns: True when an Ok value was written; otherwise False.
	about: Returns False without changing @value for Err or uninitialized states.
	End Rem
	Method TryValue:Int(value:T Var)
		If Not IsOk() Then Return False
		value = _value
		Return True
	End Method

	Rem
	bbdoc: Writes the Err value to @error and returns True when this Result is Err.
	param: Receives the contained Err value when present.
	returns: True when an Err value was written; otherwise False.
	about: Returns False without changing @error for Ok or uninitialized states.
	End Rem
	Method TryError:Int(error:E Var)
		If Not IsErr() Then Return False
		error = _error
		Return True
	End Method

	Rem
	bbdoc: Transforms an Ok value with @mapper and preserves Err.
	param: The Closure invoked with the Ok value.
	returns: A Result containing the mapped Ok value or the preserved Err value.
	about: Throws #TResultStateException when uninitialized. Exceptions raised by
@mapper propagate unchanged.
	End Rem
	Method Map<U>:Result<U, E>(mapper:Closure<U(value:T)>)
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Ok Then Return Result<U, E>.Ok(mapper(_value))
		Return Result<U, E>.Err(_error)
	End Method

	Rem
	bbdoc: Transforms an Ok value with a non-capturing function and preserves Err.
	param: The function invoked with the Ok value.
	returns: A Result containing the mapped Ok value or the preserved Err value.
	End Rem
	Method Map<U>:Result<U, E>(mapper:U(value:T))
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Ok Then Return Result<U, E>.Ok(mapper(_value))
		Return Result<U, E>.Err(_error)
	End Method

	Rem
	bbdoc: Transforms an Err value with @mapper and preserves Ok.
	param: The Closure invoked with the Err value.
	returns: A Result containing the preserved Ok value or mapped Err value.
	about: Throws #TResultStateException when uninitialized. Exceptions raised by
@mapper propagate unchanged.
	End Rem
	Method MapError<F>:Result<T, F>(mapper:Closure<F(error:E)>)
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Err Then Return Result<T, F>.Err(mapper(_error))
		Return Result<T, F>.Ok(_value)
	End Method

	Rem
	bbdoc: Transforms an Err value with a non-capturing function and preserves Ok.
	param: The function invoked with the Err value.
	returns: A Result containing the preserved Ok value or mapped Err value.
	End Rem
	Method MapError<F>:Result<T, F>(mapper:F(error:E))
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Err Then Return Result<T, F>.Err(mapper(_error))
		Return Result<T, F>.Ok(_value)
	End Method

	Rem
	bbdoc: Transforms an Ok value into another Result and preserves Err.
	param: The Closure invoked with the Ok value to produce the next Result.
	returns: The Result returned by @mapper, or the preserved Err value.
	about: Throws #TResultStateException when uninitialized. Exceptions raised by
@mapper propagate unchanged.
	End Rem
	Method AndThen<U>:Result<U, E>(mapper:Closure<Result<U, E>(value:T)>)
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Ok Then Return mapper(_value)
		Return Result<U, E>.Err(_error)
	End Method

	Rem
	bbdoc: Transforms an Ok value into another Result with a non-capturing function and preserves Err.
	param: The function invoked with the Ok value to produce the next Result.
	returns: The Result returned by @mapper, or the preserved Err value.
	End Rem
	Method AndThen<U>:Result<U, E>(mapper:Result<U, E>(value:T))
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Ok Then Return mapper(_value)
		Return Result<U, E>.Err(_error)
	End Method

	Rem
	bbdoc: Recovers an Err value into a Result with a possibly different error type.
	param: The Closure invoked with the Err value to produce a recovery Result.
	returns: The recovery Result, or the preserved Ok value.
	about: Throws #TResultStateException when uninitialized. Exceptions raised by
@mapper propagate unchanged.
	End Rem
	Method OrElse<F>:Result<T, F>(mapper:Closure<Result<T, F>(error:E)>)
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Err Then Return mapper(_error)
		Return Result<T, F>.Ok(_value)
	End Method

	Rem
	bbdoc: Recovers an Err value with a non-capturing function.
	param: The function invoked with the Err value to produce a recovery Result.
	returns: The recovery Result, or the preserved Ok value.
	End Rem
	Method OrElse<F>:Result<T, F>(mapper:Result<T, F>(error:E))
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Err Then Return mapper(_error)
		Return Result<T, F>.Ok(_value)
	End Method

	Rem
	bbdoc: Exhaustively transforms an initialized Result by invoking exactly one handler.
	param: The Closure invoked with an Ok value.
	param: The Closure invoked with an Err value.
	returns: The value returned by the selected handler.
	about: Throws #TResultStateException when uninitialized. Handler exceptions
propagate unchanged.
	End Rem
	Method Fold<U>:U(okHandler:Closure<U(value:T)>, errorHandler:Closure<U(error:E)>)
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Ok Then Return okHandler(_value)
		Return errorHandler(_error)
	End Method

	Rem
	bbdoc: Exhaustively transforms an initialized Result with non-capturing functions.
	param: The function invoked with an Ok value.
	param: The function invoked with an Err value.
	returns: The value returned by the selected handler.
	End Rem
	Method Fold<U>:U(okHandler:U(value:T), errorHandler:U(error:E))
		If _state = EResultState.Uninitialized Then Throw New TResultStateException
		If _state = EResultState.Ok Then Return okHandler(_value)
		Return errorHandler(_error)
	End Method

	Private
	Method RequireInitialized()
		If IsUninitialized() Then Throw New TResultStateException
	End Method
End Struct

?
