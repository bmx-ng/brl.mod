' Copyright (c) 2018-2020 Bruce A Henderson
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
bbdoc: A string builder.
End Rem	
Module BRL.StringBuilder

ModuleInfo "Version: 1.14"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2018-2020 Bruce A Henderson"

ModuleInfo "History: 1.14"
ModuleInfo "History: Added Hash() method."
ModuleInfo "History: 1.13"
ModuleInfo "History: Changes for low-level external use - header, exposing buffer."
ModuleInfo "History: 1.12"
ModuleInfo "History: Improved equality checks."
ModuleInfo "History: 1.11"
ModuleInfo "History: Added Format() methods."
ModuleInfo "History: 1.10"
ModuleInfo "History: Added JoinStrings() method."
ModuleInfo "History: 1.09"
ModuleInfo "History: Added ToUTF8String() and ToWString() methods."
ModuleInfo "History: 1.08"
ModuleInfo "History: Added LeftAlign() and RightAlign() methods."
ModuleInfo "History: 1.07"
ModuleInfo "History: Fixed AppendByte and AppendShort not using unsigned variants."
ModuleInfo "History: 1.06"
ModuleInfo "History: Implemented Compare(), and added overloads for = and <>."
ModuleInfo "History: 1.05"
ModuleInfo "History: NG Refactoring."
ModuleInfo "History: Added overloaded Append() methods."
ModuleInfo "History: 1.04"
ModuleInfo "History: Added shorts appender."
ModuleInfo "History: 1.03"
ModuleInfo "History: Added overloaded constructor for providing instance specific initial capacity."
ModuleInfo "History: 1.02"
ModuleInfo "History: Added AppendCString() and AppendUTF8String() methods."
ModuleInfo "History: 1.01"
ModuleInfo "History: Added CharAt(), SetCharAt() and RemoveCharAt() methods."
ModuleInfo "History: 1.00 Initial Release"

Import "common.bmx"

Rem
bbdoc: A modifiable String.
about: A string builder provides functionality to efficiently insert, replace, remove, append and reverse.
It is an order of magnitude faster to append Strings to a TStringBuilder than it is to append Strings to Strings.
End Rem	
Type TStringBuilder

	' the char buffer
	Field buffer:Byte Ptr
Private
	
	Field newLine:String
	Field nullText:String
	
	Global initialCapacity:Int = 16
	
?win32
	Const NEW_LINE:String = "~r~n"
?Not win32
	Const NEW_LINE:String = "~n"
?

Public
	Rem
	bbdoc: Constructs a #TStringBuilder with the default capacity.
	End Rem
	Method New()
		buffer = bmx_stringbuilder_new(initialCapacity)
	End Method

	Rem
	bbdoc: Constructs a #TStringBuilder with a specified @initialCapacity.
	End Rem
	Method New(initialCapacity:Int)
		buffer = bmx_stringbuilder_new(initialCapacity)
	End Method

	Rem
	bbdoc: Constructs a #TStringBuilder initialized to the contents of @Text.
	End Rem
	Method New(Text:String)
		If Text.length > initialCapacity Then
			buffer = bmx_stringbuilder_new(Text.Length)
		Else
			buffer = bmx_stringbuilder_new(initialCapacity)
		End If
		
		bmx_stringbuilder_append_string(buffer, Text)
	End Method

	Rem
	bbdoc: Constructs a #TStringBuilder initialized to the contents of the specified string.
	End Rem	
	Function Create:TStringBuilder(Text:String)
		Return New TStringBuilder(Text)
	End Function

	Rem
	bbdoc: Returns the length of the string the string builder would create.
	End Rem	
	Method Length:Int()
		Return bmx_stringbuilder_count(buffer)
	End Method
	
	Rem
	bbdoc: Returns the total number of characters that the string builder can accommodate before needing to grow.
	End Rem	
	Method Capacity:Int()
		Return bmx_stringbuilder_capacity(buffer)
	End Method
	
	Rem
	bbdoc: Sets the length of the string builder.
	about: If the length is less than the current length, the current text will be truncated. Otherwise,
	the capacity will be increased as necessary, although the actual length of text will remain the same.
	End Rem	
	Method SetLength(length:Int)
		bmx_stringbuilder_setlength(buffer, length)
	End Method
	
	Rem
	bbdoc: Appends a #String onto the string builder.
	End Rem	
	Method Append:TStringBuilder(value:String)
		bmx_stringbuilder_append_string(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Byte value to the string builder.
	End Rem
	Method AppendByte:TStringBuilder(value:Byte)
		bmx_stringbuilder_append_byte(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Byte value onto the string builder.
	End Rem	
	Method Append:TStringBuilder(value:Byte)
		bmx_stringbuilder_append_byte(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends an object onto the string builder.
	about: This generally calls the object's ToString() method.
	TStringBuilder objects are simply mem-copied.
	End Rem
	Method AppendObject:TStringBuilder(obj:Object)
		If TStringBuilder(obj) Then
			bmx_stringbuilder_append_stringbuffer(buffer, TStringBuilder(obj).buffer)
		Else
			If obj Then
				bmx_stringbuilder_append_string(buffer, obj.ToString())
			Else
				Return AppendNull()
			End If
		End If
		Return Self
	End Method

	Rem
	bbdoc: Appends an object onto the string builder.
	about: This generally calls the object's ToString() method.
	TStringBuilder objects are simply mem-copied.
	End Rem
	Method Append:TStringBuilder(obj:Object)
		If obj Then
			bmx_stringbuilder_append_string(buffer, obj.ToString())
		Else
			Return AppendNull()
		End If
		Return Self
	End Method

	Rem
	bbdoc: Appends a #TStringBuilder onto the string builder.
	End Rem
	Method Append:TStringBuilder(sb:TStringBuilder)
		bmx_stringbuilder_append_stringbuffer(buffer, sb.buffer)
		Return Self
	End Method
	
	Rem
	bbdoc: Appends a null-terminated C string onto the string builder.
	End Rem
	Method AppendCString:TStringBuilder(chars:Byte Ptr)
		bmx_stringbuilder_append_cstring(buffer, chars)
		Return Self
	End Method
	
	Rem
	bbdoc: Appends a #Double value to the string builder.
	End Rem
	Method AppendDouble:TStringBuilder(value:Double)
		bmx_stringbuilder_append_double(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Double value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:Double)
		bmx_stringbuilder_append_double(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Float value to the string builder.
	End Rem
	Method AppendFloat:TStringBuilder(value:Float)
		bmx_stringbuilder_append_float(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Float value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:Float)
		bmx_stringbuilder_append_float(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends an #Int value to the string builder.
	End Rem
	Method AppendInt:TStringBuilder(value:Int)
		bmx_stringbuilder_append_int(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends an #Int value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:Int)
		bmx_stringbuilder_append_int(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Long value to the string builder.
	End Rem
	Method AppendLong:TStringBuilder(value:Long)
		bmx_stringbuilder_append_long(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Long value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:Long)
		bmx_stringbuilder_append_long(buffer, value)
		Return Self
	End Method
	
	Rem
	bbdoc: Appends the new line string to the string builder.
	about: The new line string can be altered using #SetNewLineText. This might be used to force the output to always
	use Unix line endings even when on Windows.
	End Rem
	Method AppendNewLine:TStringBuilder()
		If newLine Then
			bmx_stringbuilder_append_string(buffer, newLine)
		Else
			bmx_stringbuilder_append_string(buffer, NEW_LINE)
		End If
		Return Self
	End Method

	Rem
	bbdoc: Appends the text representing null to the string builder.
	End Rem
	Method AppendNull:TStringBuilder()
		If nullText Then
			bmx_stringbuilder_append_string(buffer, nullText)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Appends a Short value to the string builder.
	End Rem
	Method AppendShort:TStringBuilder(value:Short)
		bmx_stringbuilder_append_short(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Short value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:Short)
		bmx_stringbuilder_append_short(buffer, value)
		Return Self
	End Method
	
	Rem
	bbdoc: Appends a #UInt value to the string builder.
	End Rem
	Method AppendUInt:TStringBuilder(value:UInt)
		bmx_stringbuilder_append_uint(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #UInt value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:UInt)
		bmx_stringbuilder_append_uint(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Ulong value to the string builder.
	End Rem
	Method AppendULong:TStringBuilder(value:ULong)
		bmx_stringbuilder_append_ulong(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Ulong value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:ULong)
		bmx_stringbuilder_append_ulong(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Size_T value to the string builder.
	End Rem
	Method AppendSizet:TStringBuilder(value:Size_T)
		bmx_stringbuilder_append_sizet(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Size_T value to the string builder.
	End Rem
	Method Append:TStringBuilder(value:Size_T)
		bmx_stringbuilder_append_sizet(buffer, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a null-terminated UTF-8 string onto the string builder.
	End Rem
	Method AppendUTF8String:TStringBuilder(chars:Byte Ptr)
		bmx_stringbuilder_append_utf8string(buffer, chars)
		Return Self
	End Method

	Rem
	bbdoc: Appends an array of shorts onto the string builder.
	End Rem
	Method AppendShorts:TStringBuilder(shorts:Short Ptr, length:Int)
		bmx_stringbuilder_append_shorts(buffer, shorts, length)
		Return Self
	End Method
	
	Rem
	bbdoc: Appends a character of the given @char code point to the string builder.
	End Rem
	Method AppendChar:TStringBuilder(char:Int)
		bmx_stringbuilder_append_char(buffer, char)
		Return Self
	End Method

	Rem
	bbdoc: Compares the string builder with another object.
	about: If the other object is a string builder then, the contents of two are compared lexicographically, as
	determined by the unicode value of each character in order.
	If there is no difference, then the shorter of the two contents precedes the longer.
	
	If the other object is not a string builder, the standard object comparison is made.
	End Rem
	Method Compare:Int(o:Object) Override
		If TStringBuilder(o) Then
			Return bmx_stringbuilder_compare(buffer, TStringBuilder(o).buffer)
		End If
		
		Return Super.Compare(o)
	End Method
	
	Rem
	bbdoc: Finds first occurance of a sub string.
	returns: -1 if @subString not found.
	End Rem
	Method Find:Int(subString:String, startIndex:Int = 0)
		Return bmx_stringbuilder_find(buffer, subString, startIndex)
	End Method
	
	Rem
	bbdoc: Finds last occurance of a sub string.
	returns: -1 if @subString not found.
	End Rem
	Method FindLast:Int(subString:String, startIndex:Int = 0)
		Return bmx_stringbuilder_findlast(buffer, subString, startIndex)
	End Method

	Rem
	bbdoc: Appends a #String value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:String)
		bmx_stringbuilder_format_string(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Byte value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Byte)
		bmx_stringbuilder_format_byte(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Short value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Short)
		bmx_stringbuilder_format_short(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Int value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Int)
		bmx_stringbuilder_format_int(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #UInt value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:UInt)
		bmx_stringbuilder_format_uint(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Long value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Long)
		bmx_stringbuilder_format_long(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #ULong value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:ULong)
		bmx_stringbuilder_format_ulong(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Size_T value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Size_T)
		bmx_stringbuilder_format_sizet(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Float value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Float)
		bmx_stringbuilder_format_float(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Double value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method Format:TStringBuilder(formatText:String, value:Double)
		bmx_stringbuilder_format_double(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #String value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatString:TStringBuilder(formatText:String, value:String)
		bmx_stringbuilder_format_string(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Byte value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatByte:TStringBuilder(formatText:String, value:Byte)
		bmx_stringbuilder_format_byte(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Short value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatShort:TStringBuilder(formatText:String, value:Short)
		bmx_stringbuilder_format_short(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Int value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatInt:TStringBuilder(formatText:String, value:Int)
		bmx_stringbuilder_format_int(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #UInt value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatUInt:TStringBuilder(formatText:String, value:UInt)
		bmx_stringbuilder_format_uint(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Long value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatLong:TStringBuilder(formatText:String, value:Long)
		bmx_stringbuilder_format_long(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #ULong value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatULong:TStringBuilder(formatText:String, value:ULong)
		bmx_stringbuilder_format_ulong(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Size_T value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatSizeT:TStringBuilder(formatText:String, value:Size_T)
		bmx_stringbuilder_format_sizet(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Float value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatFloat:TStringBuilder(formatText:String, value:Float)
		bmx_stringbuilder_format_float(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Appends a #Double value to the string builder using the specified printf style @formatText.
	about: @formatText is limited to 256 character bytes. Formatted text is limited to 2048 character bytes.
	End Rem
	Method FormatDouble:TStringBuilder(formatText:String, value:Double)
		bmx_stringbuilder_format_double(buffer, formatText, value)
		Return Self
	End Method

	Rem
	bbdoc: Returns the calculated hash for the content of the string builder.
	End Rem
	Method Hash:ULong()
		Return bmx_stringbuilder_hash(buffer)
	End Method
	
	Rem
	bbdoc: Extracts the leftmost characters from the string builder.
	about: This method extracts the left @length characters from the builder. If this many characters are not available, the whole builder is returned.
	Thus the returned string may be shorter than the length requested.
	End Rem
	Method Left:String(length:Int)
		Return bmx_stringbuilder_left(buffer, length)
	End Method
	
	Rem
	bbdoc: Removes leading and trailing non-printable characters from the string builder.
	End Rem
	Method Trim:TStringBuilder()
		bmx_stringbuilder_trim(buffer)
		Return Self
	End Method
	
	Rem
	bbdoc: Replaces all occurances of @subString with @withString.
	End Rem
	Method Replace:TStringBuilder(subString:String, withString:String)
		bmx_stringbuilder_replace(buffer, subString, withString)
		Return Self
	End Method
	
	Rem
	bbdoc: Returns true if string starts with @subString.
	End Rem
	Method StartsWith:Int(subString:String)
		Return bmx_stringbuilder_startswith(buffer, subString)
	End Method
	
	Rem
	bbdoc: Returns true if string ends with @subString.
	End Rem
	Method EndsWith:Int(subString:String)
		Return bmx_stringbuilder_endswith(buffer, subString)
	End Method
	
	Rem
	bbdoc: Returns the char value in the buffer at the specified index.
	about: The first char value is at index 0, the next at index 1, and so on, as in array indexing.
	@index must be greater than or equal to 0, and less than the length of the buffer.
	End Rem
	Method CharAt:Int(index:Int)
		Return bmx_stringbuilder_charat(buffer, index)
	End Method
	
	Rem
	bbdoc: Returns the char value in the buffer at the specified index.
	about: The first char value is at index 0, the next at index 1, and so on, as in array indexing.
	@index must be greater than or equal to 0, and less than the length of the buffer.
	End Rem
	Method Operator[]:Int(index:Int)
?debug
		If index < 0 Or index >= Length() Throw New TArrayBoundsException
?
		Return bmx_stringbuilder_charat(buffer, index)
	End Method
	
	Rem
	bbdoc: Returns true if string contains @subString.
	End Rem
	Method Contains:Int(subString:String)
		Return Find(subString) >= 0
	End Method
	
	Rem
	bbdoc: Joins @bits together by inserting this string builder between each bit.
	returns: @buf or a new TStringBuilder object of @buf is #Null.
	about: Optionally accepts a preassigned string builder for populating with the result of the join.
	End Rem
	Method Join:TStringBuilder(bits:String[], buf:TStringBuilder = Null)
		If Not buf Then
			buf = New TStringBuilder
		End If
		bmx_stringbuilder_join(buffer, bits, buf.buffer)
		Return buf
	End Method

	Rem
	bbdoc: Joins @bits together by inserting @joiner between each bit, appending to the end of this string builder.
	End Rem
	Method JoinStrings:TStringBuilder(bits:String[], joiner:String)
		bmx_stringbuilder_join_strings(buffer, bits, joiner)
		Return Self
	End Method

	Rem
	bbdoc: Converts all of the characters in the buffer to lower case.
	End Rem	
	Method ToLower:TStringBuilder()
		bmx_stringbuilder_tolower(buffer)
		Return Self
	End Method
	
	Rem
	bbdoc: Converts all of the characters in the buffer to upper case.
	End Rem	
	Method ToUpper:TStringBuilder()
		bmx_stringbuilder_toupper(buffer)
		Return Self
	End Method
	
	Rem
	bbdoc: Left aligns the buffer, adjusted to the specified @length.
	about: If buffer is longer than the specified length, the buffer is shortened to the specified length.
	If the buffer is shorter than the specified length, spaces are added to the right end of the buffer to produce the appropriate length.
	End Rem
	Method LeftAlign:TStringBuilder(length:Int)
		bmx_stringbuilder_leftalign(buffer, length)
		Return Self
	End Method
	
	Rem
	bbdoc: Right aligns the buffer, adjusted to the specified @length.
	about: If buffer is longer than the specified length, the buffer is shortened to the specified length.
	If the buffer is shorter than the specified length, spaces are added to the left end of the buffer to produce the appropriate length.
	End Rem
	Method RightAlign:TStringBuilder(length:Int)
		bmx_stringbuilder_rightalign(buffer, length)
		Return Self
	End Method

	Rem
	bbdoc: Removes a range of characters from the string builder.
	about: @startIndex is the first character to remove. @endIndex is the index after the last character to remove.
	End Rem
	Method Remove:TStringBuilder(startIndex:Int, endIndex:Int)
		bmx_stringbuilder_remove(buffer, startIndex, endIndex)
		Return Self
	End Method

	Rem
	bbdoc: Removes the character at the specified position in the buffer.
	about: The buffer is shortened by one character.
	End Rem
	Method RemoveCharAt:TStringBuilder(index:Int)
		bmx_stringbuilder_removecharat(buffer, index)
		Return Self
	End Method
	
	Rem
	bbdoc: Inserts text into the string builder at the specified offset.
	End Rem
	Method Insert:TStringBuilder(offset:Int, value:String)
		bmx_stringbuilder_insert(buffer, offset, value)
		Return Self
	End Method
	
	Rem
	bbdoc: Reverses the characters of the string builder.
	End Rem
	Method Reverse:TStringBuilder()
		bmx_stringbuilder_reverse(buffer)
		Return Self
	End Method
	
	Rem
	bbdoc: Extracts the rightmost characters from the string builder.
	about: This method extracts the right @length characters from the builder. If this many characters are not available, the whole builder is returned.
	Thus the returned string may be shorter than the length requested.
	End Rem
	Method Right:String(length:Int)
		Return bmx_stringbuilder_right(buffer, length)
	End Method
	
	Rem
	bbdoc: The character at the specified index is set to @char.
	about: @index must be greater than or equal to 0, and less than the length of the buffer.
	End Rem
	Method SetCharAt(index:Int, char:Int)
		bmx_stringbuilder_setcharat(buffer, index, char)
	End Method
	
	Rem
	bbdoc: The character at the specified index is set to @char.
	about: @index must be greater than or equal to 0, and less than the length of the buffer.
	End Rem
	Method Operator []= (index:Int, char:Int)
?debug
		If index < 0 Or index >= Length() Throw New TArrayBoundsException
?
		bmx_stringbuilder_setcharat(buffer, index, char)
	End Method
	
	Rem
	bbdoc: Sets the text to be appended when a new line is added.
	End Rem
	Method SetNewLineText:TStringBuilder(newLine:String)
		Self.newLine = newLine
		Return Self
	End Method
	
	Rem
	bbdoc: Sets the text to be appended when null is added.
	End Rem
	Method SetNullText:TStringBuilder(nullText:String)
		Self.nullText = nullText
		Return Self
	End Method
	
	Rem
	bbdoc: Returns a substring of the string builder given the specified indexes.
	about: @beginIndex is the first character of the substring.
	@endIndex is the index after the last character of the substring. If @endIndex is zero,
	will return everything from @beginIndex until the end of the string builder.
	End Rem
	Method Substring:String(beginIndex:Int, endIndex:Int = 0)
		Return bmx_stringbuilder_substring(buffer, beginIndex, endIndex)
	End Method
	
	Rem
	bbdoc: Creates a split buffer using the specified separator.
	about: The #TSplitBuffer can be used to iterate over the split text.
	End Rem
	Method Split:TSplitBuffer(separator:String)
		Local buf:TSplitBuffer = New TSplitBuffer
		buf.buffer = Self
		buf.splitPtr = bmx_stringbuilder_split(buffer, separator)
		Return buf
	End Method
	
	Rem
	bbdoc: Converts the string builder to a String.
	End Rem	
	Method ToString:String() Override
		Return bmx_stringbuilder_tostring(buffer)
	End Method

	Rem
	bbdoc: Converts the value of the string builder to a UTF-8 formatted #Byte sequence.
	returns: A pointer to a sequence of Bytes, or #Null if the string builder is empty.
	about: The resulting Byte Ptr must be freed with #MemFree.
	End Rem
	Method ToUTF8String:Byte Ptr()
		Return bmx_stringbuilder_toutf8string(buffer)
	End Method

	Rem
	bbdoc: Converts the value of the string builder to a sequence of Shorts.
	returns: A pointer to a sequence of Shorts, or #Null if the string builder is empty.
	about: The resulting Short Ptr must be freed with #MemFree.
	End Rem
	Method ToWString:Short Ptr()
		Return bmx_stringbuilder_towstring(buffer)
	End Method
	
	Rem
	bbdoc: Returns #True if @obj is equal to this string builder.
	End Rem
	Method Operator =:Int (obj:Object)
		Return Compare(obj) = 0
	End Method

	Rem
	bbdoc: Returns #True if @sb is lexicographically equal to this string builder.
	End Rem
	Method Operator =:Int (sb:TStringBuilder)
		Return bmx_stringbuilder_equals(buffer, sb.buffer)
	End Method

	Rem
	bbdoc: Returns #True if @obj is not equal to this string builder.
	End Rem
	Method Operator <>:Int (obj:Object)
		Return Compare(obj) <> 0
	End Method

	Rem
	bbdoc: Returns #True if @sb is not lexicographically equal to this string builder.
	End Rem
	Method Operator <>:Int (sb:TStringBuilder)
		Return Not bmx_stringbuilder_equals(buffer, sb.buffer)
	End Method

	Method Delete()
		If buffer Then
			bmx_stringbuilder_free(buffer)
			buffer = Null
		End If
	End Method

End Type

Rem
bbdoc: An array of split text from a TStringBuilder.
about: Note that the #TSplitBuffer is only valid while its parent #TStringBuilder is unchanged.
Once you modify the #TSplitBuffer you should call Split() again.
End Rem
Type TSplitBuffer
Private
	Field buffer:TStringBuilder
	Field splitPtr:Byte Ptr
Public
	Rem
	bbdoc: The number of split elements.
	End Rem
	Method Length:Int()
		Return bmx_stringbuilder_splitbuffer_length(splitPtr)
	End Method
	
	Rem
	bbdoc: Returns the text for the given index in the split buffer.
	End Rem
	Method Text:String(index:Int)
		Return bmx_stringbuilder_splitbuffer_text(splitPtr, index)
	End Method
	
	Rem
	bbdoc: Creates a new string array of all the split elements.
	End Rem
	Method ToArray:String[]()
		Return bmx_stringbuilder_splitbuffer_toarray(splitPtr)
	End Method

	Method ObjectEnumerator:TSplitBufferEnum()
		Local enumeration:TSplitBufferEnum = New TSplitBufferEnum
		enumeration.buffer = Self
		enumeration.length = Length()
		Return enumeration
	End Method

	Method Delete()
		If splitPtr Then
			buffer = Null
			bmx_stringbuilder_splitbuffer_free(splitPtr)
			splitPtr = Null
		End If
	End Method
	
End Type

Type TSplitBufferEnum

	Field index:Int
	Field length:Int
	Field buffer:TSplitBuffer

	Method HasNext:Int()
		Return index < length
	End Method

	Method NextObject:Object()
		Local s:String = buffer.Text(index)
		index :+ 1
		Return s
	End Method

End Type
