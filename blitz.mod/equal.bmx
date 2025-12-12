
Interface IEqualityComparator<T>
	Method Equals:Int(a:T, b:T)
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
