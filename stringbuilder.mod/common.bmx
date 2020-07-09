' Copyright (c) 2018-2019 Bruce A Henderson
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

Import "glue.c"

Extern
	Function bmx_stringbuilder_new:Byte Ptr(initial:Int)
	Function bmx_stringbuilder_free(buffer:Byte Ptr)

	Function bmx_stringbuilder_count:Int(buffer:Byte Ptr)
	Function bmx_stringbuilder_capacity:Int(buffer:Byte Ptr)
	Function bmx_stringbuilder_setlength(buffer:Byte Ptr, length:Int)
	Function bmx_stringbuilder_tostring:String(buffer:Byte Ptr)
	Function bmx_stringbuilder_append_string(buffer:Byte Ptr, value:String)
	Function bmx_stringbuilder_remove(buffer:Byte Ptr, startIndex:Int, endIndex:Int)
	Function bmx_stringbuilder_insert(buffer:Byte Ptr, offset:Int, value:String)
	Function bmx_stringbuilder_reverse(buffer:Byte Ptr)
	Function bmx_stringbuilder_substring:String(buffer:Byte Ptr, beginIndex:Int, endIndex:Int)
	Function bmx_stringbuilder_append_stringbuffer(buffer:Byte Ptr, buffer2:Byte Ptr)
	Function bmx_stringbuilder_startswith:Int(buffer:Byte Ptr, subString:String)
	Function bmx_stringbuilder_endswith:Int(buffer:Byte Ptr, subString:String)
	Function bmx_stringbuilder_find:Int(buffer:Byte Ptr, subString:String, startIndex:Int)
	Function bmx_stringbuilder_findlast:Int(buffer:Byte Ptr, subString:String, startIndex:Int)
	Function bmx_stringbuilder_tolower(buffer:Byte Ptr)
	Function bmx_stringbuilder_toupper(buffer:Byte Ptr)
	Function bmx_stringbuilder_trim(buffer:Byte Ptr)
	Function bmx_stringbuilder_replace(buffer:Byte Ptr, subString:String, withString:String)
	Function bmx_stringbuilder_join(buffer:Byte Ptr, bits:String[], newBuffer:Byte Ptr)
	Function bmx_stringbuilder_split:Byte Ptr(buffer:Byte Ptr, separator:String)
	Function bmx_stringbuilder_setcharat(buffer:Byte Ptr, index:Int, char:Int)
	Function bmx_stringbuilder_charat:Int(buffer:Byte Ptr, index:Int)
	Function bmx_stringbuilder_removecharat(buffer:Byte Ptr, index:Int)
	Function bmx_stringbuilder_append_cstring(buffer:Byte Ptr, chars:Byte Ptr)
	Function bmx_stringbuilder_append_utf8string(buffer:Byte Ptr, chars:Byte Ptr)
	Function bmx_stringbuilder_append_double(buffer:Byte Ptr, value:Double)
	Function bmx_stringbuilder_append_float(buffer:Byte Ptr, value:Float)
	Function bmx_stringbuilder_append_int(buffer:Byte Ptr, value:Int)
	Function bmx_stringbuilder_append_long(buffer:Byte Ptr, value:Long)
	Function bmx_stringbuilder_append_short(buffer:Byte Ptr, value:Short)
	Function bmx_stringbuilder_append_byte(buffer:Byte Ptr, value:Byte)
	Function bmx_stringbuilder_append_uint(buffer:Byte Ptr, value:UInt)
	Function bmx_stringbuilder_append_ulong(buffer:Byte Ptr, value:ULong)
	Function bmx_stringbuilder_append_sizet(buffer:Byte Ptr, value:Size_T)
	Function bmx_stringbuilder_append_shorts(buffer:Byte Ptr, shorts:Short Ptr, length:Int)
	Function bmx_stringbuilder_append_char(buffer:Byte Ptr, value:Int)
	Function bmx_stringbuilder_left:String(buffer:Byte Ptr, length:Int)
	Function bmx_stringbuilder_right:String(buffer:Byte Ptr, length:Int)
	Function bmx_stringbuilder_compare:Int(buffer:Byte Ptr, buffer2:Byte Ptr)
	Function bmx_stringbuilder_leftalign(buffer:Byte Ptr, length:Int)
	Function bmx_stringbuilder_rightalign(buffer:Byte Ptr, length:Int)
	Function bmx_stringbuilder_toutf8string:Byte Ptr(buffer:Byte Ptr)
	Function bmx_stringbuilder_towstring:Short Ptr(buffer:Byte Ptr)
	Function bmx_stringbuilder_join_strings(buffer:Byte Ptr, bits:String[], joiner:String)
	Function bmx_stringbuilder_format_string(buffer:Byte Ptr, formatText:String, value:String)
	Function bmx_stringbuilder_format_byte(buffer:Byte Ptr, formatText:String, value:Byte)
	Function bmx_stringbuilder_format_short(buffer:Byte Ptr, formatText:String, value:Short)
	Function bmx_stringbuilder_format_int(buffer:Byte Ptr, formatText:String, value:Int)
	Function bmx_stringbuilder_format_uint(buffer:Byte Ptr, formatText:String, value:UInt)
	Function bmx_stringbuilder_format_long(buffer:Byte Ptr, formatText:String, value:Long)
	Function bmx_stringbuilder_format_ulong(buffer:Byte Ptr, formatText:String, value:ULong)
	Function bmx_stringbuilder_format_sizet(buffer:Byte Ptr, formatText:String, value:Size_T)
	Function bmx_stringbuilder_format_float(buffer:Byte Ptr, formatText:String, value:Float)
	Function bmx_stringbuilder_format_double(buffer:Byte Ptr, formatText:String, value:Double)
	Function bmx_stringbuilder_equals:Int(buffer:Byte Ptr, other:Byte Ptr)
	Function bmx_stringbuilder_hash:ULong(buffer:Byte Ptr)

	Function bmx_stringbuilder_splitbuffer_length:Int(splitPtr:Byte Ptr)
	Function bmx_stringbuilder_splitbuffer_text:String(splitPtr:Byte Ptr, index:Int)
	Function bmx_stringbuilder_splitbuffer_free(splitPtr:Byte Ptr)
	Function bmx_stringbuilder_splitbuffer_toarray:String[](splitPtr:Byte Ptr)

End Extern

