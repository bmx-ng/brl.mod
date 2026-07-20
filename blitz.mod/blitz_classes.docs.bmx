' Documentation-only declarations for the compiler-provided BlitzMax classes.
' This file is parsed by language tools through the @docs directive in the
' core class interfaces. It is not compiled or imported as program source.

SuperStrict

Rem
bbdoc: The root reference type from which all BlitzMax Types derive.
about: Object provides the common identity, comparison, hashing and string representation operations available to every object.
End Rem
Type Object

	Rem
	bbdoc: Creates an Object instance.
	End Rem
	Method New()
	End Method

	Rem
	bbdoc: Returns a textual representation of this object.
	End Rem
	Method ToString:String()
	End Method

	Rem
	bbdoc: Compares this object with @otherObject.
	returns: A negative value, zero, or a positive value when this object sorts before, equals, or sorts after @otherObject.
	param: The object to compare with this object.
	End Rem
	Method Compare:Int(otherObject:Object)
	End Method

	Rem
	bbdoc: Returns a hash code for this object.
	returns: A hash value suitable for hashed collections.
	End Rem
	Method HashCode:UInt()
	End Method

	Rem
	bbdoc: Tests whether this object is equal to @otherObject.
	param: The object to compare with this object.
	End Rem
	Method Equals:Int(otherObject:Object)
	End Method

End Type

Rem
bbdoc: An immutable sequence of Unicode characters.
about: Strings support searching, comparison, slicing, conversion and encoding operations.
String indexing returns a character code, while slicing returns another String.
End Rem
Type String

	Rem
	bbdoc: The number of characters in this String.
	End Rem
	Field length:Int

	Rem
	bbdoc: Compares this String with @otherString, optionally in a case-sensitive manner.
	returns: A negative value, zero, or a positive value when this String sorts before, equals, or sorts after @otherString.
	param: The String to compare with this String.
	param: If #True, the comparison is case-sensitive; if #False, the comparison is case-insensitive.
	End Rem
	Method Compare:Int(otherString:String, caseSensitive:Int)
	End Method

	Rem
	bbdoc: Returns a hash code for this String, optionally in a case-sensitive manner.
	returns: A hash value suitable for hashed collections.
	param: If #True, the hash is case-sensitive; if #False, the hash is case-insensitive.
	End Rem
	Method HashCode:UInt( caseSensitive:Int )
	End Method

	Rem
	bbdoc: Tests whether this String is equal to @otherString, optionally in a case-sensitive manner.
	returns: #True if this String is equal to @otherString, otherwise #False.
	param: The String to compare with this String.
	param: If #True, the comparison is case-sensitive; if #False, the comparison is case-insensitive.
	End Rem
	Method Equals:Int(otherString:String, caseSensitive:Int)
	End Method

	Rem
	bbdoc: Finds the first occurrence of @subString.
	returns: The character index of the match, or -1 if no match is found.
	param: The text to locate.
	param: The character index at which to begin searching.
	End Rem
	Method Find:Int(subString:String, startIndex:Int = 0)
	End Method

	Rem
	bbdoc: Finds the final occurrence of @subString.
	returns: The character index of the match, or -1 if no match is found.
	param: The text to locate.
	param: The character index from which to search backwards.
	End Rem
	Method FindLast:Int(subString:String, startIndex:Int = 0)
	End Method

	Rem
	bbdoc: Removes whitespace from both ends of this String.
	returns: The trimmed String.
	End Rem
	Method Trim:String()
	End Method

	Rem
	bbdoc: Replaces every occurrence of @substring with @withString.
	param: The text to replace.
	param: The replacement text.
	End Rem
	Method Replace:String(substring:String, withString:String)
	End Method

	Rem
	bbdoc: Returns a lower-case copy of this String.
	End Rem
	Method ToLower:String()
	End Method

	Rem
	bbdoc: Returns an upper-case copy of this String.
	End Rem
	Method ToUpper:String()
	End Method

	Rem
	bbdoc: Converts this String to an #Int value.
	returns: The #Int value represented by this String, or 0 if the String is not a valid #Int.
	End Rem
	Method ToInt:Int()
	End Method

	Rem
	bbdoc: Converts this String to a #Long value.
	returns: The #Long value represented by this String, or 0 if the String is not a valid #Long.
	End Rem
	Method ToLong:Long()
	End Method

	Rem
	bbdoc: Converts this String to a #Float value.
	returns: The #Float value represented by this String, or 0.0 if the String is not a valid #Float.
	End Rem
	Method ToFloat:Float()
	End Method

	Rem
	bbdoc: Converts this String to a #Double value.
	returns: The #Double value represented by this String, or 0.0 if the String is not a valid #Double.
	End Rem
	Method ToDouble:Double()
	End Method

	Rem
	bbdoc: Converts this String to a #UInt value.
	returns: The #UInt value represented by this String, or 0 if the String is not a valid #UInt.
	End Rem
	Method ToUInt:UInt()
	End Method

	Rem
	bbdoc: Converts this String to a #ULong value.
	returns: The #ULong value represented by this String, or 0 if the String is not a valid #ULong.
	End Rem
	Method ToULong:ULong()
	End Method

	Rem
	bbdoc: Converts this String to a #LongInt value.
	returns: The #LongInt value represented by this String, or 0 if the String is not a valid #LongInt.
	End Rem
	Method ToLongInt:LongInt()
	End Method

	Rem
	bbdoc: Converts this String to a #ULongInt value.
	returns: The #ULongInt value represented by this String, or 0 if the String is not a valid #ULongInt.
	End Rem
	Method ToULongInt:ULongInt()
	End Method

	Rem
	bbdoc: Converts this String to a #Size_T value.
	returns: The #Size_T value represented by this String, or 0 if the String is not a valid #Size_T.
	End Rem
	Method ToSizet:Size_T()
	End Method

	Rem
	bbdoc: Creates a String representation of @intValue.
	param: The #Int value to convert.
	End Rem
	Function FromInt:String(intValue:Int)
	End Function

	Rem
	bbdoc: Creates a String representation of @uintValue.
	param: The #UInt value to convert.
	End Rem
	Function FromUInt:String(uintValue:UInt)
	End Function

	Rem
	bbdoc: Creates a String representation of @longValue.
	param: The #Long value to convert.
	End Rem
	Function FromLong:String(longValue:Long)
	End Function

	Rem
	bbdoc: Creates a String representation of @ulongValue.
	param: The #ULong value to convert.
	End Rem
	Function FromULong:String(ulongValue:ULong)
	End Function

	Rem
	bbdoc: Creates a String representation of @sizeTValue.
	param: The #Size_T value to convert.
	End Rem
	Function FromFloat:String(floatValue:Float)
	End Function

	Rem
	bbdoc: Creates a String representation of @doubleValue.
	param: The #Double value to convert.
	End Rem
	Function FromDouble:String(doubleValue:Double)
	End Function

	Rem
	bbdoc: Creates a String representation of @longIntValue.
	param: The #LongInt value to convert.
	End Rem
	Function FromLongInt:String(longIntValue:LongInt)
	End Function

	Rem
	bbdoc: Creates a String representation of @ulongIntValue.
	param: The #ULongInt value to convert.
	End Rem
	Function FromULongInt:String(ulongIntValue:ULongInt)
	End Function

	Rem
	bbdoc: Creates a String representation of @sizeTValue.
	param: The #Size_T value to convert.
	End Rem
	Function FromSizet:String(sizeTValue:Size_T)
	End Function

	Rem
	bbdoc: Creates a String from a sequence of bytes in @bytes.
	returns: A String containing the characters represented by the bytes in @bytes.
	param: A pointer to a buffer containing the bytes to convert.
	param: The number of bytes to convert.
	End Rem
	Function FromBytes:String(bytes:Byte Ptr, count:Int)
	End Function

	Rem
	bbdoc: Creates a String from a sequence of wide characters in @shorts.
	returns: A String containing the characters represented by the wide characters in @shorts.
	param: A pointer to a buffer containing the wide characters to convert.
	param: The number of wide characters to convert.
	End Rem
	Function FromShorts:String(shorts:Short Ptr, count:Int)
	End Function

	Rem
	bbdoc: Tests whether this String begins with @subString.
	returns: #True if this String begins with @subString, otherwise #False.
	param: The prefix to test.
	End Rem
	Method StartsWith:Int(subString:String)
	End Method

	Rem
	bbdoc: Tests whether this String ends with @subString.
	returns: #True if this String ends with @subString, otherwise #False.
	param: The suffix to test.
	End Rem
	Method EndsWith:Int(subString:String)
	End Method

	Rem
	bbdoc: Tests whether this String contains @subString.
	returns: #True if this String contains @subString, otherwise #False.
	param: The text to locate.
	End Rem
	Method Contains:Int(subString:String)
	End Method

	Rem
	bbdoc: Splits this String around occurrences of @separator.
	returns: An array containing the separated parts.
	param: The separator text.
	End Rem
	Method Split:String[](separator:String)
	End Method

	Rem
	bbdoc: Joins String @bits using this String as the separator.
	returns: The joined String.
	param: The String values to join.
	End Rem
	Method Join:String(bits:String[])
	End Method

	Rem
	bbdoc: Joins #Byte @bits using this String as the separator.
	returns: The joined String.
	param: The #Byte values to join.
	End Rem
	Method Join:String( bits:Byte[] )
	End Method

	Rem
	bbdoc: Joins #Short @bits using this String as the separator.
	returns: The joined String.
	param: The #Short values to join.
	End Rem
	Method Join:String( bits:Short[] )
	End Method

	Rem
	bbdoc: Joins #Int @bits using this String as the separator.
	returns: The joined String.
	param: The #Int values to join.
	End Rem
	Method Join:String( bits:Int[] )
	End Method

	Rem
	bbdoc: Joins #Long @bits using this String as the separator.
	returns: The joined String.
	param: The #Long values to join.
	End Rem
	Method Join:String( bits:Long[] )
	End Method

	Rem
	bbdoc: Joins #UInt @bits using this String as the separator.
	returns: The joined String.
	param: The #UInt values to join.
	End Rem
	Method Join:String( bits:UInt[] )
	End Method

	Rem
	bbdoc: Joins #ULong @bits using this String as the separator.
	returns: The joined String.
	param: The #ULong values to join.
	End Rem
	Method Join:String( bits:ULong[] )
	End Method

	Rem
	bbdoc: Joins #Size_T @bits using this String as the separator.
	returns: The joined String.
	param: The #Size_T values to join.
	End Rem
	Method Join:String( bits:Size_T[] )
	End Method

	Rem
	bbdoc: Joins #LongInt @bits using this String as the separator.
	returns: The joined String.
	param: The #LongInt values to join.
	End Rem
	Method Join:String( bits:LongInt[] )
	End Method

	Rem
	bbdoc: Joins #ULongInt @bits using this String as the separator.
	returns: The joined String.
	param: The #ULongInt values to join.
	End Rem
	Method Join:String( bits:ULongInt[] )
	End Method

	Rem
	bbdoc: Joins #Float @bits using this String as the separator.
	returns: The joined String.
	param: The #Float values to join.
	param: If @fixed is #True, the #Float values will be formatted with a fixed number of decimal places. Otherwise, the #Float values will be formatted with a variable number of decimal places.
	End Rem
	Method Join:String( bits:Float[], fixed:Int=False )
	End Method

	Rem
	bbdoc: Joins #Double @bits using this String as the separator.
	returns: The joined String.
	param: The #Double values to join.
	param: If @fixed is #True, the #Double values will be formatted with a fixed number of decimal places. Otherwise, the #Double values will be formatted with a variable number of decimal places.
	End Rem
	Method Join:String( bits:Double[], fixed:Int=0 )
	End Method

	Rem
	bbdoc: Produces a new String of @count repetitions of this String.
	returns: A new String consisting of this String repeated @count times.
	param: The number of repetitions.
	End Rem
	Method Replicate:String(count:Int)
	End Method

	Rem
	bbdoc: Creates a null-terminated C string representation of this String.
	returns: A pointer to the C string.
	about: The returned pointer must be freed with #MemFree() when no longer needed.
	End Rem
	Method ToCString:Byte Ptr()
	End Method

	Rem
	bbdoc: Creates a null-terminated wide-character (16-bit) C string representation of this String.
	returns: A pointer to the wide-character C string.
	about: The returned pointer must be freed with #MemFree() when no longer needed.
	End Rem
	Method ToWString:Short Ptr()
	End Method

	Rem
	bbdoc: Creates a UTF-8 encoded C string representation of this String.
	returns: A pointer to the UTF-8 encoded C string.
	about: The returned pointer must be freed with #MemFree() when no longer needed.
	End Rem
	Method ToUTF8String:Byte Ptr()
	End Method

	Rem
	bbdoc: Creates a UTF-8 encoded C string representation of this String, and returns its length in @length.
	returns: A pointer to the UTF-8 encoded C string.
	param: A variable to receive the length of the UTF-8 encoded string.
	about: The returned pointer must be freed with #MemFree() when no longer needed.

	Having the length available with conversion can save a call to strlen.
	End Rem
	Method ToUTF8String:Byte Ptr(length:Size_T Var)
	End Method

	Rem
	bbdoc: Creates a UTF-8 encoded C string representation of this String, and copies it into @buf.
	returns: A pointer to the UTF-8 encoded C string.
	param: A pointer to a buffer to receive the UTF-8 encoded string.
	param: A variable that initially contains the size of the buffer, and will receive the length of the UTF-8 encoded string.
	about: The buffer must be large enough to hold the UTF-8 encoded string, including the null terminator.
	End Rem
	Method ToUTF8StringBuffer:Byte Ptr(buf:Byte Ptr, length:Size_T Var)
	End Method

	Rem
	bbdoc: Creates a wide-character (16-bit) C string representation of this String, and copies it into @buf.
	returns: A pointer to the wide-character C string.
	param: A pointer to a buffer to receive the wide-character string.
	param: A variable that initially contains the size of the buffer, and will receive the length of the wide-character string.
	about: The buffer must be large enough to hold the wide-character string, including the null terminator.
	End Rem
	Method ToWStringBuffer:Short Ptr(buf:Short Ptr, length:Size_T Var)
	End Method

	Rem
	bbdoc: Creates a String from a sequence of bytes in @buf, as a hexadecimal representation of the bytes.
	returns: A String containing the hexadecimal representation of the bytes in @buf.
	param: A pointer to a buffer containing the bytes to convert.
	param: The number of bytes to convert.
	param: If #True, the hexadecimal digits will be uppercase; if #False, they will be lowercase.
	End Rem
	Function FromBytesAsHex:String(buf:Byte Ptr, length:Int, upperCase:Int=True)
	End Function

	Rem
	bbdoc: Converts this String to a sequence of bytes in @bytes, interpreting the String as hexadecimal digits.
	returns: The number of bytes written to @bytes, or -1 if the buffer is not large enough to hold all the bytes represented by this String.
	param: A pointer to a buffer to receive the bytes.
	param: The number of bytes to write to @bytes.
	about: Processing stops at the first non-hexadecimal character in this String.
	End Rem
	Method ToBytesFromHex:Int( bytes:Byte Ptr, length:Int )
	End Method

	Rem
	bbdoc: Converts this String to a sequence of bytes in @bytes, interpreting the String as hexadecimal digits, starting at @offset and processing @count characters.
	returns: The number of bytes written to @bytes, or -1 if the buffer is not large enough to hold all the bytes represented by this String.
	param: The character index at which to start processing this String.
	param: The number of characters to process in this String.
	param: A pointer to a buffer to receive the bytes.
	param: The number of bytes to write to @bytes.
	about: Processing stops at the first non-hexadecimal character in this String.
	End Rem
	Method ToBytesFromHex:Int( offset:Int, count:Int, bytes:Byte Ptr, length:Int )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Byte values, using @separator as the delimiter.
	returns: An array of #Byte values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitBytes:Byte[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Short values, using @separator as the delimiter.
	returns: An array of #Short values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitShorts:Short[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Int values, using @separator as the delimiter.
	returns: An array of #Int values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitInts:Int[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Uint values, using @separator as the delimiter.
	returns: An array of #Uint values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitUInts:UInt[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Long values, using @separator as the delimiter.
	returns: An array of #Long values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitLongs:Long[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #ULong values, using @separator as the delimiter.
	returns: An array of #ULong values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitULongs:ULong[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Size_T values, using @separator as the delimiter.
	returns: An array of #Size_T values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitSizeTs:Size_T[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #LongInt values, using @separator as the delimiter.
	returns: An array of #LongInt values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitLongInts:LongInt[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #ULongInt values, using @separator as the delimiter.
	returns: An array of #ULongInt values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitULongInts:ULongInt[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Float values, using @separator as the delimiter.
	returns: An array of #Float values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitFloats:Float[]( separator:String )
	End Method

	Rem
	bbdoc: Splits this String into an array of #Double values, using @separator as the delimiter.
	returns: An array of #Double values representing the parts of this String between occurrences of @separator.
	param: The separator text.
	End Rem
	Method SplitDoubles:Double[]( separator:String )
	End Method

	Rem
	bbdoc: Converts this String to a #Double value, using the specified format and decimal separator.
	returns: 0 if the String is not a valid #Double, or the position of the first character after the #Double otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The decimal separator to use for the conversion.
	about: The format and decimal separator parameters allow for parsing of localized numeric strings.
	End Rem
	Method ToDoubleEx:Int( val:Double Var,startPos:Int=0,endPos:Int=-1,format:ULong=CHARSFORMAT_GENERAL,sep:String="." )
	End Method

	Rem
	bbdoc: Converts this String to a #Float value, using the specified format and decimal separator.
	returns: 0 if the String is not a valid #Float, or the position of the first character after the #Float otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The decimal separator to use for the conversion.
	about: The format and decimal separator parameters allow for parsing of localized numeric strings.
	End Rem
	Method ToFloatEx:Int( val:Float Var,startPos:Int=0,endPos:Int=-1,format:ULong=CHARSFORMAT_GENERAL,sep:String="." )
	End Method

	Rem
	bbdoc: Converts this String to a #Int value, using the specified format and base.
	returns: 0 if the String is not a valid #Int, or the position of the first character after the #Int otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToIntEx:Int( val:Int Var,startPos:Int=0,endPos:Int=-1,format:ULong=CHARSFORMAT_GENERAL,base:Int=10 )
	End Method

	Rem
	bbdoc: Converts this String to a #UInt value, using the specified format and base.
	returns: 0 if the String is not a valid #UInt, or the position of the first character after the #UInt otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToUIntEx:Int( val:UInt Var,startPos:Int=0,endPos:Int=-1,format:ULong=CHARSFORMAT_GENERAL,base:Int=10 )
	End Method

	Rem
	bbdoc: Converts this String to a #Long value, using the specified format and base.
	returns: 0 if the String is not a valid #Long, or the position of the first character after the #Long otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToLongEx:Int( val:Long Var,startPos:Int=0,endPos:Int=-1,format:ULong=CHARSFORMAT_GENERAL,base:Int=10 )
	End Method

	Rem
	bbdoc: Converts this String to a #ULong value, using the specified format and base.
	returns: 0 if the String is not a valid #ULong, or the position of the first character after the #ULong otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToULongEx:Int( val:ULong Var,startPos:Int=0,endPos:Int=-1,format:ULong=CHARSFORMAT_GENERAL,base:Int=10 )
	End Method

	Rem
	bbdoc: Converts this String to a #Size_T value, using the specified format and base.
	returns: 0 if the String is not a valid #Size_T, or the position of the first character after the #Size_T otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToSizeTEx:Int( val:Size_T Var,startPos:Int=0,endPos:Int=-1,format:ULong=5,base:Int=10 )
	End Method

	Rem
	bbdoc: Converts this String to a #LongInt value, using the specified format and base.
	returns: 0 if the String is not a valid #LongInt, or the position of the first character after the #LongInt otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToLongIntEx:Int( val:LongInt Var,startPos:Int=0,endPos:Int=-1,format:ULong=5,base:Int=10 )
	End Method

	Rem
	bbdoc: Converts this String to a #ULongInt value, using the specified format and base.
	returns: 0 if the String is not a valid #ULongInt, or the position of the first character after the #ULongInt otherwise
	param: The variable to receive the converted value.
	param: The starting character index for the conversion.
	param: The ending character index for the conversion, or -1 to use the end of the String.
	param: The format to use for the conversion. Defaults to #CHARSFORMAT_GENERAL
	param: The base to use for the conversion. Defaults to 10.
	End Rem
	Method ToULongIntEx:Int( val:ULongInt Var,startPos:Int=0,endPos:Int=-1,format:ULong=5,base:Int=10 )
	End Method

End Type

Rem
bbdoc: Runtime information and common operations for BlitzMax arrays.
about: Source-level array types use this compiler-provided runtime class for shared members such as Length, Dimensions and Sort.
End Rem
Type ___Array

	Rem
	bbdoc: The number of elements in this array.
	End Rem
	Field length:Int

	Rem
	bbdoc: Sorts the elements of this array in place.
	param: True for ascending order or False for descending order.
	End Rem
	Method Sort(ascending:Int = True)
	End Method

	Rem
	bbdoc: Returns the length of each dimension in this array.
	End Rem
	Method Dimensions:Int[]()
	End Method

End Type
