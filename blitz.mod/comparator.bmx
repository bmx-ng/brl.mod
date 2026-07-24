Rem
bbdoc: Defines the ordering of two values.
about: A comparator determines the relative ordering of values without requiring
the values themselves to implement comparison operations.

Comparators are commonly used by sorting algorithms and ordered
collections.

Implementations should provide a consistent ordering. Comparing the same
two values should always produce the same result unless the values
themselves have changed.
End Rem
Interface IComparator<T>

	Rem
	bbdoc: Compares two values.
	param: The first value to compare.
	param: The second value to compare.
	returns: A value less than zero if #o1 is ordered before #o2; zero if the values compare as equal; or a value greater than zero if #o1 is ordered after #o2.
	about: The magnitude of the returned value is not significant; only whether it
	is negative, zero, or positive.

	A comparator should define a consistent ordering suitable for sorting and
	searching algorithms.
	End Rem
	Method Compare:Int(o1:T, o2:T)

End Interface


Function DefaultComparator_Compare:Int(o1:Byte, o2:Byte)
	Return o1 - o2
End Function

Function DefaultComparator_Compare:Int(o1:Short, o2:Short)
	Return o1 - o2
End Function

Function DefaultComparator_Compare:Int(o1:Int, o2:Int)
	Return o1 - o2
End Function

Function DefaultComparator_Compare:Int(o1:UInt, o2:UInt)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:Long, o2:Long)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:ULong, o2:ULong)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:Size_T, o2:Size_T)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:Float, o2:Float)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:Double, o2:Double)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:String, o2:String)
	If Not o1 And Not o2 Then
		Return 0
	End If
	If o1 And o2 Then
		Return o1.Compare(o2)
	End If
	Return -1
End Function

Function DefaultComparator_Compare:Int(o1:Object, o2:Object)
	If Not o1 And Not o2 Then
		Return 0
	End If
	If o1 And o2 Then
		Return o1.Compare(o2)
	End If
	Return -1
End Function

Function DefaultComparator_Compare:Int(o1:Byte Ptr, o2:Byte Ptr)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:LongInt, o2:LongInt)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function

Function DefaultComparator_Compare:Int(o1:ULongInt, o2:ULongInt)
	If o1 < o2 Then
		Return -1
	Else If o2 < o1 Then
		Return 1
	End If
	Return 0
End Function
