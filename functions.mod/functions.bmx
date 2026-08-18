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
bbdoc: System/Functions
End Rem
Module BRL.Functions

?bmxng2

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.Blitz

Rem
bbdoc: Returns @value unchanged.
param: The value to return.
returns: @value, with its exact generic type preserved.
about: An explicit specialization such as `Identity<Int>` can also be used as
a non-capturing function value.
End Rem
Function Identity<T>:T(value:T)
	Return value
End Function

Rem
bbdoc: Creates a function which ignores its argument and returns @constant.
param: The value returned whenever the resulting Closure is invoked.
returns: A Closure which accepts a value of U and returns @constant.
about: The returned Closure captures @constant by value. Managed values retain
their ordinary reference identity.
End Rem
Function Constant<T, U>:Closure<T(value:U)>(constant:T)
	Return Function:T(value:U)
		Return constant
	End Function
End Function

Rem
bbdoc: Composes two Closures into a function which applies @inner and then @outer.
param: The outer Closure, which transforms B into C.
param: The inner Closure, which transforms A into B.
returns: A Closure which transforms A into C.
about: The returned Closure captures both functions and should normally be
constructed once and reused in repeated work. Exceptions propagate unchanged.
End Rem
Function Compose<A, B, C>:Closure<C(value:A)>(outer:Closure<C(value:B)>, inner:Closure<B(value:A)>)
	Return Function:C(value:A)
		Return outer(inner(value))
	End Function
End Function

Rem
bbdoc: Composes two non-capturing functions.
param: The outer function, which transforms B into C.
param: The inner function, which transforms A into B.
returns: A Closure which transforms A into C.
about: The returned Closure captures the function values and should normally be
constructed once and reused in repeated work. Exceptions propagate unchanged.
End Rem
Function Compose<A, B, C>:Closure<C(value:A)>(outer:C(value:B), inner:B(value:A))
	Return Function:C(value:A)
		Return outer(inner(value))
	End Function
End Function

Rem
bbdoc: Composes an outer Closure with an inner non-capturing function.
param: The outer Closure, which transforms B into C.
param: The inner function, which transforms A into B.
returns: A Closure which transforms A into C.
	End Rem
Function Compose<A, B, C>:Closure<C(value:A)>(outer:Closure<C(value:B)>, inner:B(value:A))
	Return Function:C(value:A)
		Return outer(inner(value))
	End Function
End Function

Rem
bbdoc: Composes an outer non-capturing function with an inner Closure.
param: The outer function, which transforms B into C.
param: The inner Closure, which transforms A into B.
returns: A Closure which transforms A into C.
	End Rem
Function Compose<A, B, C>:Closure<C(value:A)>(outer:C(value:B), inner:Closure<B(value:A)>)
	Return Function:C(value:A)
		Return outer(inner(value))
	End Function
End Function

Rem
bbdoc: Applies @mapper to @value using a Closure.
param: The input value.
param: The Closure applied to @value.
returns: The value returned by @mapper.
about: Exceptions raised by @mapper propagate unchanged.
End Rem
Function Pipe<A, B>:B(value:A, mapper:Closure<B(value:A)>)
	Return mapper(value)
End Function

Rem
bbdoc: Applies @mapper to @value using a non-capturing function.
param: The input value.
param: The function applied to @value.
returns: The value returned by @mapper.
about: Exceptions raised by @mapper propagate unchanged.
End Rem
Function Pipe<A, B>:B(value:A, mapper:B(value:A))
	Return mapper(value)
End Function

?
