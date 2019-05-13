
Rem
bbdoc: Returns the larger of the two #Int arguments.
End Rem
Function Max:Int(a:Int, b:Int)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Long arguments.
End Rem
Function Max:Long(a:Long, b:Long)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Float arguments.
End Rem
Function Max:Float(a:Float, b:Float)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Double arguments.
End Rem
Function Max:Double(a:Double, b:Double)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Byte arguments.
End Rem
Function Max:Byte(a:Byte, b:Byte)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Short arguments.
End Rem
Function Max:Short(a:Short, b:Short)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #UInt arguments.
End Rem
Function Max:UInt(a:UInt, b:UInt)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #ULong arguments.
End Rem
Function Max:ULong(a:ULong, b:ULong)
	If a < b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the larger of the two #Size_T arguments.
End Rem
Function Max:Size_T(a:Size_T, b:Size_T)
	If a < b Then
		Return b
	End If
	Return a
End Function



Rem
bbdoc: Returns the lesser of the two #Int arguments.
End Rem
Function Min:Int(a:Int, b:Int)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Long arguments.
End Rem
Function Min:Long(a:Long, b:Long)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Float arguments.
End Rem
Function Min:Float(a:Float, b:Float)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Double arguments.
End Rem
Function Min:Double(a:Double, b:Double)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Byte arguments.
End Rem
Function Min:Byte(a:Byte, b:Byte)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Short arguments.
End Rem
Function Min:Short(a:Short, b:Short)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #UInt arguments.
End Rem
Function Min:UInt(a:UInt, b:UInt)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #ULong arguments.
End Rem
Function Min:ULong(a:ULong, b:ULong)
	If a > b Then
		Return b
	End If
	Return a
End Function

Rem
bbdoc: Returns the lesser of the two #Size_T arguments.
End Rem
Function Min:Size_T(a:Size_T, b:Size_T)
	If a > b Then
		Return b
	End If
	Return a
End Function

Extern
	Function bbIntAbs:Int(a:Int)
	Function bbFloatAbs:Double(a:Double)
	Function bbLongAbs:Long(a:Long)
	Function bbIntSgn:Int(a:Int)
	Function bbFloatSgn:Int(a:Double)="double bbFloatSgn(double)!"
	Function bbLongSgn:Int(a:Long)="BBInt64 bbLongSgn(BBInt64)!"
End Extern

Rem
bbdoc: Returns the absolute value of the #Int argument.
End Rem
Function Abs:Int(a:Int)
	Return bbIntAbs(a)
End Function

Rem
bbdoc: Returns the absolute value of the #Float argument.
End Rem
Function Abs:Float(a:Float)
	Return bbFloatAbs(Double(a))
End Function

Rem
bbdoc: Returns the absolute value of the #Double argument.
End Rem
Function Abs:Double(a:Double)
	Return bbFloatAbs(a)
End Function

Rem
bbdoc: Returns the absolute value of the #Long argument.
End Rem
Function Abs:Long(a:Long)
	Return bbLongAbs(a)
End Function

Rem
bbdoc: Returns the sign of the #Int argument.
End Rem
Function Sgn:Int(a:Int)
	Return bbIntSgn(a)
End Function

Rem
bbdoc: Returns the sign of the #Float argument.
End Rem
Function Sgn:Float(a:Float)
	Return bbFloatSgn(Double(a))
End Function

Rem
bbdoc: Returns the sign of the #Double argument.
End Rem
Function Sgn:Double(a:Double)
	Return bbFloatSgn(a)
End Function

Rem
bbdoc: Returns the sign of the #Long argument.
End Rem
Function Sgn:Long(a:Long)
	Return bbLongSgn(a)
End Function
