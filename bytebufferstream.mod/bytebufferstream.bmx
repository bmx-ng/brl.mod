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
bbdoc: Streams/Byte buffer streams
about: Provides a seekable stream over a fixed-size #TByteBuffer window.
End Rem
Module BRL.ByteBufferStream

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2026 Bruce A Henderson"

ModuleInfo "History: 1.00 Initial Release"

Import BRL.ByteBuffer
Import BRL.Stream

Rem
bbdoc: A seekable, fixed-size stream over a byte buffer.
about: The stream covers the bytes between the supplied buffer's current position and limit.
It shares the underlying storage, but has an independent position and does not alter the
supplied buffer's position, limit, or mark.
End Rem
Type TByteBufferStream Extends TStream

	Field _buffer:TByteBuffer
	Field _readOnly:Int

	Rem
	bbdoc: Creates a stream over the remaining bytes in @buffer.
	about: The optional @readOnly parameter controls whether writes are allowed and defaults
	to #True. A writable stream cannot grow beyond the captured byte-buffer window.
	End Rem
	Method New(buffer:TByteBuffer, readOnly:Int = True)
		Assert buffer Else "Byte buffer cannot be Null"
		_buffer = buffer.Slice()
		If readOnly Then
			_buffer = _buffer.AsReadOnly()
		End If
		_readOnly = readOnly
	End Method

	Method Pos:Long() Override
		Return _buffer.Position()
	End Method

	Method Size:Long() Override
		Return _buffer.Limit()
	End Method

	Method Seek:Long(pos:Long, whence:Int = SEEK_SET_) Override
		Local newPos:Long
		Select whence
			Case SEEK_SET_
				newPos = pos
			Case SEEK_CUR_
				newPos = Long(_buffer.Position()) + pos
			Case SEEK_END_
				newPos = Long(_buffer.Limit()) + pos
			Default
				Return -1
		End Select

		If newPos < 0 Then
			newPos = 0
		Else If newPos > _buffer.Limit() Then
			newPos = _buffer.Limit()
		End If

		_buffer.Position(Int(newPos))
		Return newPos
	End Method

	Method Read:Long(buf:Byte Ptr, count:Long) Override
		If count <= 0 Or Not _buffer.HasRemaining() Then
			Return 0
		End If

		If count > _buffer.Remaining() Then
			count = _buffer.Remaining()
		End If
		_buffer.GetBytes(buf, UInt(count))
		Return count
	End Method

	Method Write:Long(buf:Byte Ptr, count:Long) Override
		If _readOnly Or count <= 0 Or Not _buffer.HasRemaining() Then
			Return 0
		End If

		If count > _buffer.Remaining() Then
			count = _buffer.Remaining()
		End If
		_buffer.PutBytes(buf, UInt(count))
		Return count
	End Method

	Rem
	bbdoc: Closes the stream.
	about: This is a no-op; the stream does not own the supplied byte buffer.
	End Rem
	Method Close() Override
	End Method

	Rem
	bbdoc: Attempts to set the stream size.
	returns: #False because byte-buffer streams have a fixed size.
	End Rem
	Method SetSize:Int(size:Long) Override
		Return False
	End Method

End Type

Rem
bbdoc: Creates a seekable stream over the remaining bytes in @buffer.
about: The optional @readOnly parameter controls whether writes are allowed and defaults
to #True. The stream shares storage with @buffer but has an independent position.
End Rem
Function CreateByteBufferStream:TByteBufferStream(buffer:TByteBuffer, readOnly:Int = True)
	Return New TByteBufferStream(buffer, readOnly)
End Function

Type TByteBufferStreamFactory Extends TStreamFactory

	Method CreateStream:TByteBufferStream(url:Object, proto:String, path:String, readable:Int, writeMode:Int) Override
		Local buffer:TByteBuffer = TByteBuffer(url)
		If Not buffer Then
			Return Null
		End If

		Local stream:TByteBufferStream = CreateByteBufferStream(buffer, writeMode = 0)
		If writeMode = WRITE_MODE_APPEND Then
			stream.Seek(0, SEEK_END_)
		End If
		Return stream
	End Method

End Type

New TByteBufferStreamFactory
