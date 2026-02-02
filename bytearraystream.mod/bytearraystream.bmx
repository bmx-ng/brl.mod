' Copyright (c) 2026 Bruce A Henderson
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
bbdoc: Streams/ByteArrayStream
about: Provides a stream that reads/writes from/to a byte array.
End Rem
Module BRL.ByteArrayStream

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.Stream

Rem
bbdoc: A stream that reads/writes from/to a byte array.
End Rem
Type TByteArrayStream Extends TStream

	Field _data:Byte[]
	Field _pos:Long
	Field _readOnly:Int

	Rem
	bbdoc: Creates a new ByteArrayStream from a string.
	about: The optional @_readOnly parameter specifies whether the stream is read-only.
	If @_readOnly is #True (default), write operations will be ignored.
	End Rem
	Method New(txt:String, _readOnly:Int = True)
		Local length:Size_T
		Local t:Byte Ptr = txt.ToUTF8String(length)
		_data = New Byte[length]
		MemCopy( _data, t, length )
		MemFree(t)

		Self._readOnly = _readOnly
	End Method

	Rem
	bbdoc: Creates a new ByteArrayStream from a byte array.
	about: The optional @copy parameter specifies whether to copy the provided data array.
	If @copy is #True (default), a copy of the provided data array is made.
	If @copy is #False, the provided data array is used directly (no copy made).
	The optional @_readOnly parameter specifies whether the stream is read-only.
	If @_readOnly is #True (default), write operations will be ignored.
	End Rem
	Method New(data:Byte[], copy:Int = True, _readOnly:Int = True)
		If copy Then
			Self._data = data[..]
		Else
			Self._data = data
		End If

		Self._readOnly = _readOnly
	End Method

	Rem
	bbdoc: Creates a new ByteArrayStream from a pointer to byte data.
	about: The @data parameter is a pointer to the byte data.
	The @length parameter specifies the length of the data in bytes.
	The optional @_readOnly parameter specifies whether the stream is read-only.
	If @_readOnly is #True (default), write operations will be ignored.
	End Rem
	Method New(data:Byte Ptr, length:Size_T, _readOnly:Int = True)
		Self._data = New Byte[length]
		MemCopy( _data, data, length )
		Self._readOnly = _readOnly
	End Method

	Rem
	bbdoc: Gets the current position in the stream.
	End Rem
	Method Pos:Long() Override
		Return _pos
	End Method

	Rem
	bbdoc: Gets the size of the stream (in bytes).
	End Rem
	Method Size:Long() Override
		Return _data.Length
	End Method

	Rem
	bbdoc: Seeks to a new position in the stream.
	about: The @pos parameter specifies the position to seek to.
	The @whence parameter specifies the reference point for the position.
	It can be one of the following values:

	- SEEK_SET_: The position is set to @pos.
	- SEEK_CUR_: The position is set to the current position plus @pos.
	- SEEK_END_: The position is set to the end of the stream plus @pos.

	The method returns the new position in the stream.

	Read only streams will clamp the position to the end of the stream.
	End Rem
	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ ) Override
		Local size:Long = Long(_data.Length)
		Local newPos:Long

		Select whence
			Case SEEK_SET_
				newPos = pos
			Case SEEK_CUR_
				newPos = _pos + pos
			Case SEEK_END_
				newPos = size + pos
			Default
				Return -1
		End Select

		If newPos < 0 Then
			newPos = 0
		End If

		' If read-only, clamp to end
		If _readOnly And newPos > size Then
			newPos = size
		End If

		_pos = newPos
		Return _pos
	End Method

	Rem
	bbdoc: Reads data from the stream into a buffer.
	about: The @buf parameter is a pointer to the buffer to read data into.
	The @count parameter specifies the number of bytes to read.
	The method returns the number of bytes actually read.
	End Rem
	Method Read:Long( buf:Byte Ptr, count:Long ) Override
		Local size:Long = Long(_data.Length)
		If count <= 0 Or _pos >= size Then
			Return 0
		End If

		If _pos + count > size Then
			count = size - _pos
		End If

		Local bptr:Byte Ptr = _data
		MemCopy( buf, bptr + _pos, Size_T(count) )

		_pos :+ count
		Return count
	End Method

	Rem
	bbdoc: Writes data from a buffer to the stream.
	about: The @buf parameter is a pointer to the buffer to write data from.
	The @count parameter specifies the number of bytes to write.
	The method returns the number of bytes actually written.
	End Rem
	Method Write:Long( buf:Byte Ptr, count:Long ) Override
		If _readOnly Or count <= 0 Then
			Return 0
		End If

		Local size:Long = Long(_data.Length)
		Local endPos:Long = _pos + count

		' Grow to endPos if needed
		If endPos > size Then
			Local oldLen:Int = _data.Length
			Local newLen:Int = Int(endPos)
			_data = _data[..newLen]
		End If

		Local bptr:Byte Ptr = _data
		MemCopy( bptr + _pos, buf, Size_T(count) )

		_pos :+ count
		Return count
	End Method

	Rem
	bbdoc: Closes the stream.
	about: This is a no-op for ByteArrayStream.
	End Rem
	Method Close() Override
		' no-op
	End Method

	Rem
	bbdoc: Sets the size of the stream (in bytes).
	about: If the new size is smaller than the current size, the stream is truncated.
	If the new size is larger than the current size, the stream is expanded and the new bytes are uninitialized.
	The method returns #1 on success, #0 on failure (e.g. negative size).
	End Rem
	Method SetSize:Int(size:Long) Override
		If _readOnly Or size < 0 Then
			Return False
		End If

		Local oldLen:Int = _data.Length
		Local newLen:Int = Int(size)
		_data = _data[..newLen]

		If _pos > size Then
			_pos = size
		End If

		Return True
	End Method

	Rem
	bbdoc: Gets the internal byte array data.
	about: If @copy is #True (default), a copy of the internal data is returned.
	If @copy is #False, a reference to the internal data array is returned.
	End Rem
	Method GetData:Byte[]( copy:Int = True ) 
		If copy Then
			Return _data[..]
		Else
			Return _data
		End If
	End Method

End Type
