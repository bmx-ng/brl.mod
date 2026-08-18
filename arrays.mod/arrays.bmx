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
bbdoc: System/Arrays
End Rem
Module BRL.Arrays

?bmxng2

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson and contributors"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson and contributors"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.Optional

Rem
bbdoc: Eagerly transforms every element of @values using @mapper.
param: The source array.
param: The Closure invoked once for each element.
returns: A newly allocated array of mapped values.
about: The returned array is newly allocated. @mapper is invoked exactly once
for each source element, in index order, and exceptions propagate unchanged.
End Rem
Function Map<T, U>:U[](values:T[], mapper:Closure<U(value:T)>)
	Local result:U[] = New U[values.Length]
	For Local index:Int = 0 Until values.Length
		result[index] = mapper(values[index])
	Next
	Return result
End Function

Rem
bbdoc: Eagerly transforms every element using a non-capturing function.
param: The source array.
param: The function invoked once for each element.
returns: A newly allocated array of mapped values.
End Rem
Function Map<T, U>:U[](values:T[], mapper:U(value:T))
	Local result:U[] = New U[values.Length]
	For Local index:Int = 0 Until values.Length
		result[index] = mapper(values[index])
	Next
	Return result
End Function

Rem
bbdoc: Eagerly retains elements for which @predicate returns True.
param: The source array.
param: The Closure tested once for each element.
returns: A newly allocated array containing accepted elements in source order.
about: The returned array is newly allocated, including when every element is
retained. @predicate is invoked exactly once per source element in index order.
End Rem
Function Filter<T>:T[](values:T[], predicate:Closure<Int(value:T)>)
	Local result:T[] = New T[values.Length]
	Local count:Int
	For Local value:T = EachIn values
		If predicate(value) Then
			result[count] = value
			count :+ 1
		End If
	Next
	If count = result.Length Then Return result
	Return result[..count]
End Function

Rem
bbdoc: Eagerly retains elements accepted by a non-capturing function.
param: The source array.
param: The function tested once for each element.
returns: A newly allocated array containing accepted elements in source order.
End Rem
Function Filter<T>:T[](values:T[], predicate:Int(value:T))
	Local result:T[] = New T[values.Length]
	Local count:Int
	For Local value:T = EachIn values
		If predicate(value) Then
			result[count] = value
			count :+ 1
		End If
	Next
	If count = result.Length Then Return result
	Return result[..count]
End Function

Rem
bbdoc: Combines @values into one value, starting with @seed.
param: The source array.
param: The initial accumulator value.
param: The Closure invoked with the current accumulator and each element.
returns: The final accumulator, or @seed when the array is empty.
End Rem
Function Fold<T, U>:U(values:T[], seed:U, folder:Closure<U(accumulator:U, value:T)>)
	Local accumulator:U = seed
	For Local value:T = EachIn values
		accumulator = folder(accumulator, value)
	Next
	Return accumulator
End Function

Rem
bbdoc: Combines @values using a non-capturing function.
param: The source array.
param: The initial accumulator value.
param: The function invoked with the current accumulator and each element.
returns: The final accumulator, or @seed when the array is empty.
End Rem
Function Fold<T, U>:U(values:T[], seed:U, folder:U(accumulator:U, value:T))
	Local accumulator:U = seed
	For Local value:T = EachIn values
		accumulator = folder(accumulator, value)
	Next
	Return accumulator
End Function

Rem
bbdoc: Counts elements for which @predicate returns True.
param: The source array.
param: The Closure tested once for each element.
returns: The number of accepted elements.
End Rem
Function Count<T>:Int(values:T[], predicate:Closure<Int(value:T)>)
	Local count:Int
	For Local value:T = EachIn values
		If predicate(value) Then count :+ 1
	Next
	Return count
End Function

Rem
bbdoc: Counts elements accepted by a non-capturing function.
param: The source array.
param: The function tested once for each element.
returns: The number of accepted elements.
End Rem
Function Count<T>:Int(values:T[], predicate:Int(value:T))
	Local count:Int
	For Local value:T = EachIn values
		If predicate(value) Then count :+ 1
	Next
	Return count
End Function

Rem
bbdoc: Returns True when @values contains at least one element.
param: The source array.
returns: True when the array is non-empty; otherwise False.
End Rem
Function Any<T>:Int(values:T[])
	Return values.Length <> 0
End Function

Rem
bbdoc: Returns True when any element satisfies @predicate.
param: The source array.
param: The Closure tested until an element is accepted.
returns: True when an element is accepted; otherwise False.
about: Evaluation stops after the first match.
End Rem
Function Any<T>:Int(values:T[], predicate:Closure<Int(value:T)>)
	For Local value:T = EachIn values
		If predicate(value) Then Return True
	Next
	Return False
End Function

Rem
bbdoc: Returns True when any element is accepted by a non-capturing function.
param: The source array.
param: The function tested until an element is accepted.
returns: True when an element is accepted; otherwise False.
about: Evaluation stops after the first match.
End Rem
Function Any<T>:Int(values:T[], predicate:Int(value:T))
	For Local value:T = EachIn values
		If predicate(value) Then Return True
	Next
	Return False
End Function

Rem
bbdoc: Returns True when every element satisfies @predicate.
param: The source array.
param: The Closure tested until an element is rejected.
returns: True when every element is accepted, including an empty array.
about: Returns True for an empty array and stops after the first rejection.
End Rem
Function All<T>:Int(values:T[], predicate:Closure<Int(value:T)>)
	For Local value:T = EachIn values
		If Not predicate(value) Then Return False
	Next
	Return True
End Function

Rem
bbdoc: Returns True when every element is accepted by a non-capturing function.
param: The source array.
param: The function tested until an element is rejected.
returns: True when every element is accepted, including an empty array.
about: Returns True for an empty array and stops after the first rejection.
End Rem
Function All<T>:Int(values:T[], predicate:Int(value:T))
	For Local value:T = EachIn values
		If Not predicate(value) Then Return False
	Next
	Return True
End Function

Rem
bbdoc: Returns the first element, or an undefined Optional for an empty array.
param: The source array.
returns: An Optional containing the first element, or an undefined Optional.
about: A present Null managed value is represented by #Optional.FromValue.
End Rem
Function FirstOrNone<T>:Optional<T>(values:T[])
	If values.Length Then Return Optional<T>.FromValue(values[0])
	Return Optional<T>.Undefined()
End Function

Rem
bbdoc: Returns the first element satisfying @predicate, or an undefined Optional.
param: The source array.
param: The Closure tested until an element is accepted.
returns: An Optional containing the first accepted element, or an undefined Optional.
about: Evaluation stops after the first match.
End Rem
Function FirstOrNone<T>:Optional<T>(values:T[], predicate:Closure<Int(value:T)>)
	For Local value:T = EachIn values
		If predicate(value) Then Return Optional<T>.FromValue(value)
	Next
	Return Optional<T>.Undefined()
End Function

Rem
bbdoc: Returns the first element accepted by a non-capturing function.
param: The source array.
param: The function tested until an element is accepted.
returns: An Optional containing the first accepted element, or an undefined Optional.
about: Evaluation stops after the first match.
End Rem
Function FirstOrNone<T>:Optional<T>(values:T[], predicate:Int(value:T))
	For Local value:T = EachIn values
		If predicate(value) Then Return Optional<T>.FromValue(value)
	Next
	Return Optional<T>.Undefined()
End Function

Rem
bbdoc: Returns the last element, or an undefined Optional for an empty array.
param: The source array.
returns: An Optional containing the last element, or an undefined Optional.
about: A present Null managed value is represented by #Optional.FromValue.
End Rem
Function LastOrNone<T>:Optional<T>(values:T[])
	If values.Length Then Return Optional<T>.FromValue(values[values.Length - 1])
	Return Optional<T>.Undefined()
End Function

Rem
bbdoc: Invokes @action once for each element, in index order.
param: The source array.
param: The Closure invoked for every element.
End Rem
Function ForEach<T>(values:T[], action:Closure<(value:T)>)
	For Local value:T = EachIn values
		action(value)
	Next
End Function

Rem
bbdoc: Invokes a non-capturing function once for each element, in index order.
param: The source array.
param: The function invoked for every element.
End Rem
Function ForEach<T>(values:T[], action:Void(value:T))
	For Local value:T = EachIn values
		action(value)
	Next
End Function

?
