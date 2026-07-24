
Rem
bbdoc: Defines equality and hashing for values.
about: An equality comparator determines whether two values should be considered
equal independently of their implementation.

Hash-based collections use both equality and hash codes when locating
values.

If #Equals returns #True for two values, #HashCode must return the same
hash code for both values. Unequal values may still produce the same hash
code.
End Rem
Interface IEqualityComparator<T>

	Rem
	bbdoc: Determines whether two values are equal.
	param: The first value to compare.
	param: The second value to compare.
	returns: #True if the values are considered equal; otherwise #False.
	about: Equality should be reflexive, symmetric and transitive.

	If this method returns #True, both values must produce the same hash code
	when passed to #HashCode.
	End Rem
	Method Equals:Int(a:T, b:T)

	Rem
	bbdoc: Returns the hash code for a value.
	param: The value to hash.
	returns: A hash code for the specified value.
	about:
	Equal values must always produce the same hash code.

	Hash codes are not required to be unique, and different values may
	produce the same hash code.
	End Rem
	Method HashCode:UInt(a:T)

End Interface

Function DefaultComparator_Equals:Int(v1:Byte, v2:Byte) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Short, v2:Short) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Int, v2:Int) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:UInt, v2:UInt) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Long, v2:Long) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:ULong, v2:ULong) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Size_T, v2:Size_T) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:LongInt, v2:LongInt) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:ULongInt, v2:ULongInt) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Float, v2:Float) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Double, v2:Double) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:String, v2:String) Inline
	Return v1 = v2
End Function

Function DefaultComparator_Equals:Int(v1:Object, v2:Object) Inline
	If v1 = Null And v2 = Null Then
		Return True
	ElseIf v1 = Null Or v2 = Null Then
		Return False
	End If

	Return v1.Equals(v2)
End Function

Function DefaultComparator_Equals:Int(v1:Byte Ptr, v2:Byte Ptr) Inline
	Return v1 = v2
End Function
