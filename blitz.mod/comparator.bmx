
Interface IComparator<T>

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
	Return o1 - o2
End Function
