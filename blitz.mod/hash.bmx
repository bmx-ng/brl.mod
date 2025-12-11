

Function DefaultComparator_HashCode:UInt(value:Byte) Inline
	Return UInt(value)
End Function

Function DefaultComparator_HashCode:UInt(value:Short) Inline
	Return UInt(value)
End Function

Function DefaultComparator_HashCode:UInt(value:Int) Inline
	Return UInt(value)
End Function

Function DefaultComparator_HashCode:UInt(value:UInt) Inline
	Return value
End Function

Function DefaultComparator_HashCode:UInt(value:Long) Inline
	Local v:ULong = ULong(value)
	Return UInt( (v ~ (v Shr 32)) & $FFFFFFFF )
End Function

Function DefaultComparator_HashCode:UInt(value:ULong) Inline
	Return UInt(value ~ (value Shr 32))
End Function

Function DefaultComparator_HashCode:UInt(value:Size_T) Inline
?ptr32
	Return UInt(value)
?ptr64
	Local v:ULong = ULong(value)
	Return UInt(v ~ (v Shr 32))
?
End Function

Function DefaultComparator_HashCode:UInt(value:LongInt) Inline
?longint4
	Return UInt(value)
?longint8
	Local v:ULong = ULong(value)
	Return UInt( (v ~ (v Shr 32)) & $FFFFFFFF )
?
End Function

Function DefaultComparator_HashCode:UInt(value:ULongInt) Inline
?longint4
	Return UInt(value)
?longint8
	Local v:ULong = ULong(value)
	Return UInt(v ~ (v Shr 32))
?
End Function

Function DefaultComparator_HashCode:UInt(value:Float) Inline
	Local bits:Int = bbFloatToIntBits(value)
	Return UInt(bits)
End Function

Function DefaultComparator_HashCode:UInt(value:Double) Inline
	Local bits:Long = bbDoubleToLongBits(value)
	Return UInt( (bits ~ (bits Shr 32)) & $FFFFFFFF )
End Function

Function DefaultComparator_HashCode:UInt(value:Object) Inline
	Return value.HashCode()
End Function

Function DefaultComparator_HashCode:UInt(value:Byte Ptr) Inline
?ptr32
	Return (UInt Ptr(value))[0]
?ptr64
	Local v:ULong = (ULong Ptr(value))[0]
	Return UInt(v ~ (v Shr 32))
?
End Function

Extern
	Function bbFloatToIntBits:Int(value:Float)
	Function bbDoubleToLongBits:Long(value:Double)
End Extern
