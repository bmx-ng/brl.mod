' Copyright (c) 2014-2019 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Rem
bbdoc: A JSON encoder/decoder.
End Rem
Module BRL.Json

ModuleInfo "Version: 1.03"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: 2014-2019 Bruce A Henderson"

ModuleInfo "History: 1.03"
ModuleInfo "History: Updated to Jansson 2.12"
ModuleInfo "History: 1.02"
ModuleInfo "History: Updated to Jansson 2.10.009ffa3"
ModuleInfo "History: Added errorCode field to TJSONError."
ModuleInfo "History: 1.01"
ModuleInfo "History: Updated to Jansson 2.10"
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

ModuleInfo "CC_OPTS: -DHAVE_CONFIG_H"

Import "common.bmx"

Rem
bbdoc: Base type for JSON objects.
End Rem
Type TJSON

	Field jsonPtr:Byte Ptr
	
	Field key:String

	Function _create:TJSON(jsonPtr:Byte Ptr, jsonType:Int, key:String) { nomangle }
		Local this:TJSON
		Select jsonType
			Case JSON_TYPE_OBJECT
				this = New TJSONObject
			Case JSON_TYPE_ARRAY
				this = New TJSONArray
			Case JSON_TYPE_STRING
				this = New TJSONString
			Case JSON_TYPE_INTEGER
				this = New TJSONInteger
			Case JSON_TYPE_REAL
				this = New TJSONReal
			Case JSON_TYPE_TRUE
				this = New TJSONBool
				TJSONBool(this).isTrue = True
			Case JSON_TYPE_FALSE
				this = New TJSONBool
			Case JSON_TYPE_NULL
				this = New TJSONNull
			Default
				Return Null
		End Select
		
		this.jsonPtr = jsonPtr
		this.key = key
		
		Return this
	End Function
	
	Rem
	bbdoc: Returns the JSON representation of the object as a String, or NULL on error. 
	about: Valid flags include #JSON_COMPACT, #JSON_ENSURE_ASCII, #JSON_SORT_KEYS, #JSON_PRESERVE_ORDER, #JSON_ENCODE_ANY and #JSON_ESCAPE_SLASH.
	End Rem
	Method SaveString:String(flags:Int = 0, indent:Int = 0, precision:Int = 17)
		Return bmx_json_dumps(jsonPtr, flags, indent, precision)
	End Method
	
	Rem
	bbdoc: Writes the JSON representation of the object to the stream output.
	about: The stream should already be open for writing.
	Valid flags include #JSON_COMPACT, #JSON_ENSURE_ASCII, #JSON_SORT_KEYS, #JSON_PRESERVE_ORDER, #JSON_ENCODE_ANY and #JSON_ESCAPE_SLASH.
	End Rem
	Method SaveStream:Int(stream:TStream, flags:Int = 0, indent:Int = 0, precision:Int = 17)
		Return bmx_json_dump_callback(jsonPtr, _dumpCallback, stream, flags, indent, precision)
	End Method
	
	Rem
	bbdoc: Loads JSON text from a String or TStream.
	about: The stream should already be open for reading.
	Valid flags include #JSON_REJECT_DUPLICATES, #JSON_DISABLE_EOF_CHECK, #JSON_DECODE_ANY, #JSON_DECODE_INT_AS_REAL and #JSON_ALLOW_NUL.
	End Rem
	Function Load:TJSON(data:Object, flags:Int = 0, error:TJSONError Var)
	
		Local err:TJSONError
		
		If String(data) Then
			' load as text
			err = TJSONError(bmx_json_loads(String(data), flags))
			
		Else If TStream(data) Then
			' load as stream
			err = TJSONError(bmx_json_load_callback(_loadCallback, TStream(data), flags))
			
		End If

		If err 
			If err._js Then
				Return err._js
			End If
			
			error = err
		
		End If
		
		Return Null
	End Function

?bmxng
	Function _loadCallback:Size_T(buffer:Byte Ptr, buflen:Size_T, data:TStream)
?Not bmxng
	Function _loadCallback:Int(buffer:Byte Ptr, buflen:Int, data:TStream)
?
		Return data.Read(buffer, buflen)
	End Function

?bmxng
	Function _dumpCallback:Size_T(buffer:Byte Ptr, size:Size_T, data:TStream)
?Not bmxng
	Function _dumpCallback:Int(buffer:Byte Ptr, size:Int, data:TStream)
?
		Return data.Write(buffer, size)
	End Function

	Method Delete()
		If jsonPtr Then
			bmx_json_decref(jsonPtr)
			jsonPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: A JSON array is an ordered collection of other JSON values.
End Rem
Type TJSONArray Extends TJSON

	Rem
	bbdoc: Creates a new TJSONArray.
	End Rem
	Method Create:TJSONArray()
		jsonPtr = json_array()
		Return Self
	End Method

	Rem
	bbdoc: Returns the number of elements in array, or 0 if array is NULL
	End Rem
	Method Size:Int()
		Return bmx_json_array_size(jsonPtr)
	End Method
	
	Rem
	bbdoc: Returns the element in array at position index.
	about: The valid range for index is from 0 to the return value of Size() minus 1. If index is out of range, NULL is returned.
	End Rem
	Method Get:TJSON(index:Int)
		Return TJSON(bmx_json_array_get(jsonPtr, index))
	End Method
	
	Rem
	bbdoc: Replaces the element in array at position index with value.
	returns: 0 on success and -1 on error.
	End Rem
	Method Set:Int(index:Int, value:TJSON)
		Return bmx_json_array_set(jsonPtr, index, value.jsonPtr)
	End Method

	Rem
	bbdoc: Appends value to the end of array, growing the size of array by 1.
	returns: 0 on success and -1 on error.
	End Rem
	Method Append:Int(value:TJSON)
		Return bmx_json_array_append(jsonPtr, value.jsonPtr)
	End Method

	Rem
	bbdoc: Inserts @value to array at position @index, shifting the elements at index and after it one position towards the end of the array. 
	returns: 0 on success and -1 on error.
	End Rem
	Method Insert:Int(index:Int, value:TJSON)
		Return bmx_json_array_insert(jsonPtr, index, value.jsonPtr)
	End Method

	Rem
	bbdoc: Removes all elements from array.
	returns: 0 on sucess and -1 on error.
	End Rem
	Method Clear:Int()
		Return json_array_clear(jsonPtr)
	End Method
	
	Rem
	bbdoc: Removes the element in array at position index, shifting the elements after index one position towards the start of the array.
	returns: 0 on success and -1 on error.
	End Rem
	Method Remove:Int(index:Int)
		Return json_array_remove(jsonPtr, index)
	End Method

	Method ObjectEnumerator:TJSONArrayEnum()
		Local enum:TJSONArrayEnum =New TJSONArrayEnum
		enum.array = Self
		Return enum
	End Method

End Type

Type TJSONArrayEnum

	Field array:TJSONArray
	Field index:Int

	Method HasNext:Int()
		Return index < array.Size()
	End Method

	Method NextObject:Object()
		Local value:Object=array.Get(index)
		index:+ 1
		Return value
	End Method

End Type

Rem
bbdoc: A JSON object is a dictionary of key-value pairs, where the key is a Unicode string and the value is any JSON value.
End Rem
Type TJSONObject Extends TJSON

	Rem
	bbdoc: Creates a new TJSONObject.
	End Rem
	Method Create:TJSONObject()
		jsonPtr = json_object()
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the number of elements in the object.
	End Rem
	Method Size:Int()
		Return bmx_json_object_size(jsonPtr)
	End Method
	
	Rem
	bbdoc: Gets a value corresponding to key from the object.
	returns: Null if key is not found or on error.
	End Rem
	Method Get:TJSON(key:String)
		Return TJSON(bmx_json_object_get(jsonPtr, key))
	End Method
	
	Rem
	bbdoc: Sets the value of key to value in the object.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:TJSON)
		Return bmx_json_object_set_nocheck(jsonPtr, key, value.jsonPtr)
	End Method
	
	Rem
	bbdoc: Sets the value of key To the #String value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:String)
		Local v:TJSONString = New TJSONString.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method
	
	Rem
	bbdoc: Sets the value of key to the #Int value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Int)
		Local v:TJSONInteger = New TJSONInteger.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #Short value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Short)
		Local v:TJSONInteger = New TJSONInteger.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #Byte value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Byte)
		Local v:TJSONInteger = New TJSONInteger.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #Long value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Long)
		Local v:TJSONInteger = New TJSONInteger.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #UInt value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:UInt)
		Local v:TJSONInteger = New TJSONInteger.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #ULong value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:ULong)
		Local v:TJSONInteger = New TJSONInteger.Create(Long(value))
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #Size_t value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Size_T)
		Local v:TJSONInteger = New TJSONInteger.Create(Long(value))
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #Float value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Float)
		Local v:TJSONReal = New TJSONReal.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method

	Rem
	bbdoc: Sets the value of key to the #Double value.
	returns: 0 on success and -1 on error.
	about: If there already is a value for key, it is replaced by the new value. 
	End Rem
	Method Set:Int(key:String, value:Double)
		Local v:TJSONReal = New TJSONReal.Create(value)
		Return bmx_json_object_set_nocheck(jsonPtr, key, v.jsonPtr)
	End Method
	
	Rem
	bbdoc: Deletes key from the Object If it exists.
	returns: 0 on success, or -1 if key was not found. 
	End Rem
	Method Del:Int(key:String)
		Return bmx_json_object_del(jsonPtr, key)
	End Method
	
	Rem
	bbdoc: Removes all elements from the object.
	returns: 0 on success, -1 otherwise.
	End Rem
	Method Clear:Int()
		Return json_object_clear(jsonPtr)
	End Method
	
	Rem
	bbdoc: Updates the object with the key-value pairs from @other, overwriting existing keys.
	returns: 0 on success or -1 on error.
	End Rem
	Method Update:Int(other:TJSONObject)
		Return json_object_update(jsonPtr, other.jsonPtr)
	End Method
	
	Rem
	bbdoc: Updates the object with the key-value pairs from @other, but only the values of existing keys are updated.
	returns: 0 on success or -1 on error.
	about: No new keys are created.
	End Rem
	Method UpdateExisting:Int(other:TJSONObject)
		Return json_object_update_existing(jsonPtr, other.jsonPtr)
	End Method

	Rem
	bbdoc: Updates the object with the key-value pairs from @other, but only new keys are created.
	returns: 0 on success or -1 on error.
	about: The value of any existing key is not changed.
	End Rem
	Method UpdateMissing:Int(other:TJSONObject)
		Return json_object_update_missing(jsonPtr, other.jsonPtr)
	End Method

	Method ObjectEnumerator:TJSONObjectEnum()
		Local enum:TJSONObjectEnum =New TJSONObjectEnum
		enum.obj = Self
		enum.objectIter = json_object_iter(jsonPtr)
		Return enum
	End Method
	
	Rem
	bbdoc: Gets a String value corresponding to key from the object.
	returns: Null if key is not found, the value is not a String, or on error.
	End Rem
	Method GetString:String(key:String)
		Local s:TJSONString = TJSONString(bmx_json_object_get(jsonPtr, key))
		If s Then
			Return s.Value()
		End If
	End Method

	Rem
	bbdoc: Gets an Integer (Long) value corresponding to key from the object.
	returns: Null if key is not found, the value is not an Integer, or on error.
	End Rem
	Method GetInteger:Long(key:String)
		Local i:TJSONInteger = TJSONInteger(bmx_json_object_get(jsonPtr, key))
		If i Then
			Return i.Value()
		End If
	End Method

	Rem
	bbdoc: Gets a Real (Double) value corresponding to key from the object.
	returns: Null if key is not found, the value is not a Real, or on error.
	End Rem
	Method GetReal:Double(key:String)
		Local r:TJSONInteger = TJSONInteger(bmx_json_object_get(jsonPtr, key))
		If r Then
			Return r.Value()
		End If
	End Method

End Type

Type TJSONObjectEnum

	Field obj:TJSONObject
	Field objectIter:Byte Ptr

	Method HasNext:Int()
		If objectIter Then
			Return True
		End If
	End Method

	Method NextObject:Object()
		Local value:Object = bmx_json_object_iter_value(objectIter)
		objectIter = json_object_iter_next(obj.jsonPtr, objectIter)
		Return value
	End Method

End Type

Rem
bbdoc: A JSON String.
End Rem
Type TJSONString Extends TJSON

	Rem
	bbdoc: Creates a new TJSONString.
	End Rem
	Method Create:TJSONString(Text:String)
		jsonPtr = bmx_json_string_nocheck(Text)
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the associated value of the string.
	End Rem
	Method Value:String()
		Return bmx_json_string_value(jsonPtr)
	End Method
	
End Type

Rem
bbdoc: Base type for JSON number types.
End Rem
Type TJSONNumber Extends TJSON

End Type

Rem
bbdoc: a JSON integer.
End Rem
Type TJSONInteger Extends TJSONNumber

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:Long)
		jsonPtr = bmx_json_integer(v)
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:Byte)
		jsonPtr = bmx_json_integer(v)
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:Short)
		jsonPtr = bmx_json_integer(v)
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:Int)
		jsonPtr = bmx_json_integer(v)
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:UInt)
		jsonPtr = bmx_json_integer(v)
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:ULong)
		jsonPtr = bmx_json_integer(Long(v))
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONInteger with @v.
	End Rem
	Method Create:TJSONInteger(v:Size_T)
		jsonPtr = bmx_json_integer(Long(v))
		Return Self
	End Method

	Rem
	bbdoc: Returns the associated value of the integer.
	End Rem
	Method Value:Long()
		Local v:Long
		bmx_json_integer_value(jsonPtr, Varptr v)
		Return v
	End Method
	
	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Long)
		Return bmx_json_integer_set(jsonPtr, v)
	End Method

	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Byte)
		Return bmx_json_integer_set(jsonPtr, v)
	End Method

	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Short)
		Return bmx_json_integer_set(jsonPtr, v)
	End Method

	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Int)
		Return bmx_json_integer_set(jsonPtr, v)
	End Method

	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:UInt)
		Return bmx_json_integer_set(jsonPtr, v)
	End Method

	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:ULong)
		Return bmx_json_integer_set(jsonPtr, Long(v))
	End Method

	Rem
	bbdoc: Sets the associated value of integer to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Size_T)
		Return bmx_json_integer_set(jsonPtr, Long(v))
	End Method

End Type

Rem
bbdoc: A JSON real number.
End Rem
Type TJSONReal Extends TJSONNumber

	Rem
	bbdoc: Creates an instance of #TJSONReal with @v.
	End Rem
	Method Create:TJSONReal(v:Double)
		jsonPtr = json_real(v)
		Return Self
	End Method

	Rem
	bbdoc: Creates an instance of #TJSONReal with @v.
	End Rem
	Method Create:TJSONReal(v:Float)
		jsonPtr = json_real(v)
		Return Self
	End Method

	Rem
	bbdoc: Returns the associated value of the real.
	End Rem
	Method Value:Double()
		Return json_real_value(jsonPtr)
	End Method

	Rem
	bbdoc: Sets the associated value of real to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Double)
		Return json_real_set(jsonPtr, v)
	End Method

	Rem
	bbdoc: Sets the associated value of real to @v.
	about: Returns 0 on success, -1 otherwise.
	End Rem
	Method Set:Int(v:Float)
		Return json_real_set(jsonPtr, v)
	End Method

End Type

Rem
bbdoc: A JSON boolean.
End Rem
Type TJSONBool Extends TJSON

	Field isTrue:Int

End Type

Rem
bbdoc: A JSON Null.
End Rem
Type TJSONNull Extends TJSON

End Type

Rem
bbdoc: JSON error information.
End Rem
Type TJSONError
	Rem
	bbdoc: The error message, or an empty string if a message is not available.
	End Rem
	Field Text:String
	Rem
	bbdoc: Source of the error.
	about: This can be (a part of) the file name or a special identifier in angle brackers (e.g. &lt;string&gt;).
	End Rem
	Field source:String
	Rem
	bbdoc: The line number on which the error occurred.
	End Rem
	Field line:Int
	Rem
	bbdoc: The column on which the error occurred.
	about:  Note that this is the character column, not the byte column, i.e. a multibyte UTF-8 character counts as one column.
	End Rem
	Field column:Int
	Rem
	bbdoc: The position in bytes from the start of the input.
	about: This is useful for debugging Unicode encoding problems.
	End Rem
	Field position:Int
	Rem
	bbdoc: The numeric code for the error.
	End Rem
	Field errorCode:Int
	
	Field _js:TJSON
	
	Function _createError:TJSONError(Text:String, source:String, line:Int, column:Int, position:Int, errorCode:Int) { nomangle }
		Local this:TJSONError = New TJSONError
		this.Text = Text
		this.source = source
		this.line = line
		this.column = column
		this.position = position
		this.errorCode = errorCode
		Return this
	End Function

	Function _createNoError:TJSONError(_js:TJSON) { nomangle }
		Local this:TJSONError = New TJSONError
		this._js = _js
		Return this
	End Function

End Type
