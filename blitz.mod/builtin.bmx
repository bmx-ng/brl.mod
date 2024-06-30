
Rem
bbdoc: Returns the larger of the two #Int arguments.
End Rem
Function Max:Int(a:Int, b:Int) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Long arguments.
End Rem
Function Max:Long(a:Long, b:Long) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Float arguments.
End Rem
Function Max:Float(a:Float, b:Float) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Double arguments.
End Rem
Function Max:Double(a:Double, b:Double) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Byte arguments.
End Rem
Function Max:Byte(a:Byte, b:Byte) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Short arguments.
End Rem
Function Max:Short(a:Short, b:Short) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #UInt arguments.
End Rem
Function Max:UInt(a:UInt, b:UInt) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #ULong arguments.
End Rem
Function Max:ULong(a:ULong, b:ULong) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Size_T arguments.
End Rem
Function Max:Size_T(a:Size_T, b:Size_T) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #LongInt arguments.
End Rem
Function Max:LongInt(a:LongInt, b:LongInt) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #ULongInt arguments.
End Rem
Function Max:ULongInt(a:ULongInt, b:ULongInt) Inline
	If a < b Then
		Return b
	End If
	Return a
End Function


Rem
bbdoc: Returns the lesser of the two #Int arguments.
End Rem
Function Min:Int(a:Int, b:Int) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Long arguments.
End Rem
Function Min:Long(a:Long, b:Long) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Float arguments.
End Rem
Function Min:Float(a:Float, b:Float) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Double arguments.
End Rem
Function Min:Double(a:Double, b:Double) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Byte arguments.
End Rem
Function Min:Byte(a:Byte, b:Byte) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Short arguments.
End Rem
Function Min:Short(a:Short, b:Short) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #UInt arguments.
End Rem
Function Min:UInt(a:UInt, b:UInt) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #ULong arguments.
End Rem
Function Min:ULong(a:ULong, b:ULong) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Size_T arguments.
End Rem
Function Min:Size_T(a:Size_T, b:Size_T) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #LongInt arguments.
End Rem
Function Min:LongInt(a:LongInt, b:LongInt) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #ULongInt arguments.
End Rem
Function Min:ULongInt(a:ULongInt, b:ULongInt) Inline
	If a > b Then
		Return b
	End If
	Return a
End Function

Extern
	Function bbIntAbs:Int(a:Int)="int bbIntAbs(int)!"
	Function bbFloatAbs:Double(a:Double)="double bbFloatAbs(double)!"
	Function bbLongAbs:Long(a:Long)="BBInt64 bbLongAbs(BBInt64)!"
	Function bbIntSgn:Int(a:Int)="int bbIntSgn(int)!"
	Function bbFloatSgn:Int(a:Double)="double bbFloatSgn(double)!"
	Function bbLongSgn:Int(a:Long)="BBInt64 bbLongSgn(BBInt64)!"
End Extern

Rem
bbdoc: Returns the absolute value of the #Int argument.
End Rem
Function Abs:Int(a:Int) Inline
	Return bbIntAbs(a)
End Function

Rem
bbdoc: Returns the absolute value of the #Float argument.
End Rem
Function Abs:Float(a:Float) Inline
	Return bbFloatAbs(Double(a))
End Function

Rem
bbdoc: Returns the absolute value of the #Double argument.
End Rem
Function Abs:Double(a:Double) Inline
	Return bbFloatAbs(a)
End Function

Rem
bbdoc: Returns the absolute value of the #Long argument.
End Rem
Function Abs:Long(a:Long) Inline
	Return bbLongAbs(a)
End Function

Rem
bbdoc: Returns the sign of the #Int argument.
End Rem
Function Sgn:Int(a:Int) Inline
	Return bbIntSgn(a)
End Function

Rem
bbdoc: Returns the sign of the #Float argument.
End Rem
Function Sgn:Float(a:Float) Inline
	Return bbFloatSgn(Double(a))
End Function

Rem
bbdoc: Returns the sign of the #Double argument.
End Rem
Function Sgn:Double(a:Double) Inline
	Return bbFloatSgn(a)
End Function

Rem
bbdoc: Returns the sign of the #Long argument.
End Rem
Function Sgn:Long(a:Long) Inline
	Return bbLongSgn(a)
End Function
