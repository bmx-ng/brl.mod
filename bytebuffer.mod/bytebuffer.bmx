' Copyright (c) 2020 Bruce A Henderson
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
bbdoc: Byte Buffer
End Rem
Module BRL.ByteBuffer

ModuleInfo "Version: 1.01"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: 2020 Bruce A Henderson"

ModuleInfo "History: 1.01"
ModuleInfo "History: Added GetBytes() and PutBytes()"
ModuleInfo "History: 1.00 Initial Release"


Import "glue.c"

Rem
bbdoc: The byte order.
End Rem
Enum EByteOrder
	BigEndian
	LittleEndian
End Enum

Rem
bbdoc: A buffer is a list of elements of a specific type.
End Rem
Type TBuffer Abstract
	
Protected
	Field ReadOnly _size:Int
	Field _limit:Int
	Field _mark:Int = -1
	Field _position:Int
	
	Method New(size:Int)
		_size = size
		_limit = size
	End Method
	
Public
	Rem
	bbdoc: Clears the buffer.
	about: Does not change the the content of the buffer, other than to set the position to zero, the mark is cleared, and the limit is set to buffer size.
	End Rem
	Method Clear:TBuffer()
		_position = 0
		_limit = _size
		_mark = -1
		Return Self
	End Method
	
	Rem
	bbdoc: Flips the buffer.
	about: The limit is set to the current position, position set to zero, and the mark is cleared.
	End Rem
	Method Flip:TBuffer()
		_limit = _position
		_position = 0
		_mark = -1
		Return Self
	End Method
	
	Rem
	bbdoc: Return the buffer limit.
	End Rem
	Method Limit:Int()
		Return _limit
	End Method
	
	Rem
	bbdoc: Sets the buffer limit.
	End Rem
	Method Limit:TBuffer(newLimit:Int)
		If newLimit < 0 Or newLimit > _size Then
			Throw "Bad limit"
		End If
		
		_limit = newLimit
		If _position > newLimit Then
			_position = newLimit
		End If
		
		If _mark <> -1 And _mark > newLimit Then
			_mark = -1
		End If
		
		Return Self
	End Method
	
	Rem
	bbdoc: Marks the current position that can be returned to later with a call to #Reset.
	End Rem
	Method Mark:TBuffer()
		_mark = _position
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the current position of the buffer.
	End Rem
	Method Position:Int()
		Return _position
	End Method
	
	Rem
	bbdoc: Sets the position of the buffer.
	End Rem
	Method Position:TBuffer(newPos:Int)
		DoSetPosition(newPos)
		Return Self
	End Method
	
Protected
	Method DoSetPosition(newPos:Int)
		If newPos < 0 Or newPos > _limit Then
			Throw "Bad position"
		End If
		
		_position = newPos
		If _mark <> -1 And _mark > _position Then
			_mark = -1
		End If
	End Method
Public
	
	Rem
	bbdoc: Returns whether there are any bytes remaining in the buffer.
	End Rem
	Method HasRemaining:Int()
		Return _position < _limit
	End Method
	
	Rem
	bbdoc: Returns the number of bytes remaining in the buffer.
	End Rem
	Method Remaining:Int()
		Return _limit - _position
	End Method
	
	Rem
	bbdoc: Resets the current position to that of the last mark.
	about: If mark is not set, this method will throw.
	End Rem
	Method Reset:TBuffer()
		If _mark = -1 Then
			Throw "Mark not set"
		End If
		_position = _mark
		Return Self
	End Method
	
	Rem
	bbdoc: Rewinds the the position back to the start of the buffer.
	End Rem
	Method Rewind:TBuffer()
		_position = 0
		_mark = -1
		Return Self
	End Method
	
End Type

Rem
bbdoc: A #TBuffer for bytes.
End Rem
Type TByteBuffer Extends TBuffer

	Field _order:EByteOrder = EByteOrder.BigEndian
	
	Rem
	bbdoc: Allocates a new #TByteBuffer of the specific @size number of bytes.
	End Rem
	Function Allocate:TByteBuffer(size:Int)
		Assert size >= 0 Else "Size < 0 : " + size
		
		Return New TByteArrayBuffer(New Byte[size])
	End Function
	
	Rem
	bbdoc: Creates a new #TByteBuffer by wrapping the provided #Byte array.
	End Rem
	Function Wrap:TByteBuffer(data:Byte[])
		Return New TByteArrayBuffer(data)
	End Function
	
	Rem
	bbdoc: Creates a new #TByteBuffer by wrapping the provided Byte Ptr.
	about: Note that the Byte Ptr is expected to remain valid throughout the use of the #TByteBuffer.
	Freeing the associated memory early may result in undefined behaviour.
	End Rem
	Function Wrap:TByteBuffer(data:Byte Ptr, size:Int)
		Return New TBytePtrBuffer(data, size)
	End Function
	
	Rem
	bbdoc: Gets the byte order used by the #TByteBuffer when doing #Byte conversions.
	End Rem
	Method Order:EByteOrder()
		Return _order
	End Method
	
	Rem
	bbdoc: Sets the byte order to use by the #TByteBuffer when doing #Byte conversions.
	End Rem
	Method Order:TByteBuffer(byteOrder:EByteOrder)
		_order = byteOrder
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the #Byte at the current position, and increments the position by 1.
	End Rem
	Method Get:Byte() Abstract

	Rem
	bbdoc: Returns the #Short at the current position, and increments the position by 2.
	End Rem
	Method GetShort:Short() Abstract

	Rem
	bbdoc: Returns the #Int at the current position, and increments the position by 4.
	End Rem
	Method GetInt:Int() Abstract

	Rem
	bbdoc: Returns the #UInt at the current position, and increments the position by 4.
	End Rem
	Method GetUInt:UInt() Abstract

	Rem
	bbdoc: Returns the #Long at the current position, and increments the position by 8.
	End Rem
	Method GetLong:Long() Abstract

	Rem
	bbdoc: Returns the #ULong at the current position, and increments the position by 8.
	End Rem
	Method GetULong:ULong() Abstract

	Rem
	bbdoc: Returns the #Size_T at the current position, and increments the position by 8 (64-bit) or 4 (32-bit).
	End Rem
	Method GetSizeT:Size_T() Abstract

	Rem
	bbdoc: Returns the #Float at the current position, and increments the position by 4.
	End Rem
	Method GetFloat:Float() Abstract

	Rem
	bbdoc: Returns the #Double at the current position, and increments the position by 8.
	End Rem
	Method GetDouble:Double() Abstract
	
	Rem
	bbdoc: Copies @length bytes into @dst at the curent position, and increments the position by @length.
	End Rem
	Method GetBytes(dst:Byte Ptr, length:UInt) Abstract
	
	Rem
	bbdoc: Writes the specified #Byte to the current position and increments the position by 1.
	End Rem
	Method Put:TByteBuffer(value:Byte) Abstract

	Rem
	bbdoc: Writes the specified #Short to the current position and increments the position by 2.
	End Rem
	Method PutShort:TByteBuffer(value:Short) Abstract

	Rem
	bbdoc: Writes the specified #Int to the current position and increments the position by 4.
	End Rem
	Method PutInt:TByteBuffer(value:Int) Abstract

	Rem
	bbdoc: Writes the specified #UInt to the current position and increments the position by 4.
	End Rem
	Method PutUInt:TByteBuffer(value:UInt) Abstract

	Rem
	bbdoc: Writes the specified #Long to the current position and increments the position by 8.
	End Rem
	Method PutLong:TByteBuffer(value:Long) Abstract

	Rem
	bbdoc: Writes the specified #ULong to the current position and increments the position by 8.
	End Rem
	Method PutULong:TByteBuffer(value:ULong) Abstract

	Rem
	bbdoc: Writes the specified #Size_T to the current position and increments the position by 8 (64-bit) or 4 (32-bit).
	End Rem
	Method PutSizeT:TByteBuffer(value:Size_T) Abstract

	Rem
	bbdoc: Writes the specified #Float to the current position and increments the position by 4.
	End Rem
	Method PutFloat:TByteBuffer(value:Float) Abstract

	Rem
	bbdoc: Writes the specified #Double to the current position and increments the position by 8.
	End Rem
	Method PutDouble:TByteBuffer(value:Double) Abstract
	
	Rem
	bbdoc: Writes the specified number of bytes to the current position.
	End Rem
	Method PutBytes:TByteBuffer(bytes:Byte Ptr, length:UInt) Abstract

	Rem
	bbdoc: Returns a sliced #TByteBuffer that shares its content with this one.
	about: TODO
	End Rem
	Method Slice:TByteBuffer() Abstract
	
	Rem
	bbdoc: Creates a duplicate #TByteBuffer that shares its content with this one.
	End Rem
	Method Duplicate:TByteBuffer() Abstract
	
End Type

Rem
bbdoc: A #TBuffer whose data comes from a Byte Ptr.
End Rem
Type TBytePtrBuffer Extends TByteBuffer
	
	Field _readOnly:Int
	Field _data:Byte Ptr
	Field _offset:Int

	Method New(data:Byte Ptr, size:Int, offset:Int = 0, isReadOnly:Int = False)
		Super.New(size)
		Self._data = data
		Self._offset = offset
		Self._readOnly = isReadOnly
	End Method
	
	Method Get:Byte() Override
		If _position = _limit Then
			Throw New TBufferUnderflowException
		End If
		
		Local result:Byte = _data[_position]
		_position :+ 1
		Return result
	End Method
	
	Method GetShort:Short() Override
		Local newPosition:Int = _position + 2
		If newPosition > _limit Then
			Throw New TBufferUnderflowException
		End If

		Local result:Short
		Local pos:Int = _position + _offset
		If _order = EByteOrder.BigEndian Then
			result = (_data[pos] Shl 8) | (_data[pos + 1] & $ff)
		Else
			result = (_data[pos + 1] Shl 8) | (_data[pos] & $ff)
		End If
		
		_position = newPosition
		Return result
	End Method
	
	Method GetFloat:Float() Override
		Return bmx_bytebuffer_intbitstofloat(GetInt())
	End Method

	Method GetDouble:Double() Override
		Return bmx_bytebuffer_longbitstodouble(GetLong())
	End Method
		
	Method GetInt:Int() Override
		Local newPosition:Int = _position + 4
		If newPosition > _limit Then
			Throw New TBufferUnderflowException
		End If
		
		Local result:Int
		Local pos:Int = _position + _offset
		If _order = EByteOrder.BigEndian Then
			result = ((_data[pos] & $ff) Shl 24) | ((_data[pos + 1] & $ff) Shl 16) | ((_data[pos + 2] & $ff) Shl 8) | (_data[pos + 3] & $ff)
		Else
			result = (_data[pos] & $ff) | ((_data[pos + 1] & $ff) Shl 8) | ((_data[pos + 2] & $ff) Shl 16) | ((_data[pos + 3] & $ff) Shl 24)
		End If
		
		_position = newPosition
		Return result
	End Method

	Method GetUInt:UInt() Override
		Local newPosition:Int = _position + 4
		If newPosition > _limit Then
			Throw New TBufferUnderflowException
		End If
		
		Local result:UInt
		Local pos:Int = _position + _offset
		If _order = EByteOrder.BigEndian Then
			result = ((_data[pos] & $ff:UInt) Shl 24) | ((_data[pos + 1] & $ff:UInt) Shl 16) | ((_data[pos + 2] & $ff:UInt) Shl 8) | (_data[pos + 3] & $ff:UInt)
		Else
			result = (_data[pos] & $ff:UInt) | ((_data[pos + 1] & $ff:UInt) Shl 8) | ((_data[pos + 2] & $ff:UInt) Shl 16) | ((_data[pos + 3] & $ff:UInt) Shl 24)
		End If
		
		_position = newPosition
		Return result
	End Method

	Method GetLong:Long() Override
		Local newPosition:Int = _position + 8
		If newPosition > _limit Then
			Throw New TBufferUnderflowException
		End If
		
		Local result:Long
		Local pos:Int = _position + _offset
		If _order = EByteOrder.BigEndian Then
			Local high:Int = ((_data[pos] & $ff) Shl 24) | ((_data[pos + 1] & $ff) Shl 16) | ((_data[pos + 2] & $ff) Shl 8) | (_data[pos + 3] & $ff)
			Local low:Int = ((_data[pos + 4] & $ff) Shl 24) | ((_data[pos + 5] & $ff) Shl 16) | ((_data[pos + 6] & $ff) Shl 8) | (_data[pos + 7] & $ff)
			result = (Long(high) Shl 32) | (Long(low) & $ffffffff:Long)
		Else
			Local low:Int = (_data[pos] & $ff) | ((_data[pos + 1] & $ff) Shl 8) | ((_data[pos + 2] & $ff) Shl 16) | ((_data[pos + 3] & $ff) Shl 24)
			Local high:Int = (_data[pos + 4] & $ff) | ((_data[pos + 5] & $ff) Shl 8) | ((_data[pos + 6] & $ff) Shl 16) | ((_data[pos + 7] & $ff) Shl 24)
			result = (Long(high) Shl 32) | (Long(low) & $ffffffff:Long)
		End If

		_position = newPosition
		Return result
	End Method
	
	Method GetULong:ULong() Override
		Local newPosition:Int = _position + 8
		If newPosition > _limit Then
			Throw New TBufferUnderflowException
		End If
		
		Local result:ULong
		Local pos:Int = _position + _offset
		If _order = EByteOrder.BigEndian Then
			Local high:UInt = ((_data[pos] & $ff:UInt) Shl 24) | ((_data[pos + 1] & $ff:UInt) Shl 16) | ((_data[pos + 2] & $ff:UInt) Shl 8) | (_data[pos + 3] & $ff:UInt)
			Local low:UInt = ((_data[pos + 4] & $ff:UInt) Shl 24) | ((_data[pos + 5] & $ff:UInt) Shl 16) | ((_data[pos + 6] & $ff) Shl 8) | (_data[pos + 7] & $ff)
			result = (ULong(high) Shl 32) | (Long(low) & $ffffffff:ULong)
		Else
			Local low:UInt = (_data[pos] & $ff:UInt) | ((_data[pos + 1] & $ff:UInt) Shl 8) | ((_data[pos + 2] & $ff:UInt) Shl 16) | ((_data[pos + 3] & $ff:UInt) Shl 24)
			Local high:UInt = (_data[pos + 4] & $ff:UInt) | ((_data[pos + 5] & $ff:UInt) Shl 8) | ((_data[pos + 6] & $ff:UInt) Shl 16) | ((_data[pos + 7] & $ff:UInt) Shl 24)
			result = (ULong(high) Shl 32) | (ULong(low) & $ffffffff:ULong)
		End If

		_position = newPosition
		Return result
	End Method

	Method GetSizeT:Size_T() Override
?ptr64
		Return Size_T(GetULong())
?Not ptr64
		Return Size_T(GetUInt())
?
	End Method
	
	Method GetBytes(dst:Byte Ptr, length:UInt)
		Local newPosition:Int = _position + length
		If newPosition > _limit Then
			Throw New TBufferUnderflowException
		End If
		
		Local pos:Int = _position + _offset
		MemCopy(dst, _data + pos, Size_T(length))
		
		_position = newPosition
	End Method

	Method Put:TByteBuffer(value:Byte) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If
		
		If _position = _limit Then
			Throw New TBufferOverflowException
		End If
		
		_data[_position] = value
		_position :+ 1
		Return Self
	End Method
	
	Method PutShort:TByteBuffer(value:Short) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If

		Local newPosition:Int = _position + 2
		If newPosition > _limit Then
			Throw New TBufferOverflowException
		End If
		
		Local pos:Int = _offset + _position
		If _order = EByteOrder.BigEndian Then
			_data[pos] = Byte((value Shr 8) & $ff)
			_data[pos + 1] = Byte(value & $ff)
		Else
			_data[pos] = Byte(value  & $ff)
			_data[pos + 1] = Byte((value Shr 8) & $ff)
		End If
		
		_position = newPosition
		Return Self
	End Method

	Method PutInt:TByteBuffer(value:Int) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If

		Local newPosition:Int = _position + 4
		If newPosition > _limit Then
			Throw New TBufferOverflowException
		End If

		Local pos:Int = _offset + _position
		If _order = EByteOrder.BigEndian Then
			_data[pos] = Byte((value Shr 24) & $ff)
			_data[pos + 1] = Byte((value Shr 16) & $ff)
			_data[pos + 2] = Byte((value Shr 8) & $ff)
			_data[pos + 3] = Byte(value & $ff)
		Else
			_data[pos] = Byte(value & $ff)
			_data[pos + 1] = Byte((value Shr 8) & $ff)
			_data[pos + 2] = Byte((value Shr 16) & $ff)
			_data[pos + 3] = Byte((value Shr 24) & $ff)
		End If

		_position = newPosition
		Return Self
	End Method

	Method PutUInt:TByteBuffer(value:UInt) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If

		Local newPosition:Int = _position + 4
		If newPosition > _limit Then
			Throw New TBufferOverflowException
		End If

		Local pos:Int = _offset + _position
		If _order = EByteOrder.BigEndian Then
			_data[pos] = Byte((value Shr 24) & $ff)
			_data[pos + 1] = Byte((value Shr 16) & $ff)
			_data[pos + 2] = Byte((value Shr 8) & $ff)
			_data[pos + 3] = Byte(value & $ff)
		Else
			_data[pos] = Byte(value & $ff)
			_data[pos + 1] = Byte((value Shr 8) & $ff)
			_data[pos + 2] = Byte((value Shr 16) & $ff)
			_data[pos + 3] = Byte((value Shr 24) & $ff)
		End If

		_position = newPosition
		Return Self
	End Method

	Method PutLong:TByteBuffer(value:Long) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If

		Local newPosition:Int = _position + 8
		If newPosition > _limit Then
			Throw New TBufferOverflowException
		End If

		Local pos:Int = _offset + _position
		If _order = EByteOrder.BigEndian Then
			Local i:Int = Int(value Shr 32)
			_data[pos] = Byte((i Shr 24) & $ff)
			_data[pos + 1] = Byte((i Shr 16) & $ff)
			_data[pos + 2] = Byte((i Shr 8) & $ff)
			_data[pos + 3] = Byte(i & $ff)
			i = Int(value)
			_data[pos + 4] = Byte((i Shr 24) & $ff)
			_data[pos + 5] = Byte((i Shr 16) & $ff)
			_data[pos + 6] = Byte((i Shr 8) & $ff)
			_data[pos + 7] = Byte(i & $ff)
		Else
			Local i:Int = Int(value)
			_data[pos] = Byte(i & $ff)
			_data[pos + 1] = Byte((i Shr 8) & $ff)
			_data[pos + 2] = Byte((i Shr 16) & $ff)
			_data[pos + 3] = Byte((i Shr 24) & $ff)
			i = Int(value Shr 32)
			_data[pos + 4] = Byte(i & $ff)
			_data[pos + 5] = Byte((i Shr 8) & $ff)
			_data[pos + 6] = Byte((i Shr 16) & $ff)
			_data[pos + 7] = Byte((i Shr 24) & $ff)
		End If
		
		_position = newPosition
		Return Self
	End Method

	Method PutULong:TByteBuffer(value:ULong) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If

		Local newPosition:Int = _position + 8
		If newPosition > _limit Then
			Throw New TBufferOverflowException
		End If

		Local pos:Int = _offset + _position
		If _order = EByteOrder.BigEndian Then
			Local i:UInt = UInt(value Shr 32)
			_data[pos] = Byte((i Shr 24) & $ff)
			_data[pos + 1] = Byte((i Shr 16) & $ff)
			_data[pos + 2] = Byte((i Shr 8) & $ff)
			_data[pos + 3] = Byte(i & $ff)
			i = UInt(value)
			_data[pos + 4] = Byte((i Shr 24) & $ff)
			_data[pos + 5] = Byte((i Shr 16) & $ff)
			_data[pos + 6] = Byte((i Shr 8) & $ff)
			_data[pos + 7] = Byte(i & $ff)
		Else
			Local i:UInt = UInt(value)
			_data[pos] = Byte(i & $ff)
			_data[pos + 1] = Byte((i Shr 8) & $ff)
			_data[pos + 2] = Byte((i Shr 16) & $ff)
			_data[pos + 3] = Byte((i Shr 24) & $ff)
			i = UInt(value Shr 32)
			_data[pos + 4] = Byte(i & $ff)
			_data[pos + 5] = Byte((i Shr 8) & $ff)
			_data[pos + 6] = Byte((i Shr 16) & $ff)
			_data[pos + 7] = Byte((i Shr 24) & $ff)
		End If
		
		_position = newPosition
		Return Self
	End Method

	Method PutSizeT:TByteBuffer(value:Size_T) Override
?ptr64
		Return PutULong(ULong(value))
?Not ptr64
		Return PutUInt(UInt(value))
?
	End Method

	Method PutFloat:TByteBuffer(value:Float) Override
		Return PutInt(bmx_bytebuffer_floattointbits(value))
	End Method

	Method PutDouble:TByteBuffer(value:Double) Override
		Return PutLong(bmx_bytebuffer_doubletolongbits(value))
	End Method

	Method PutBytes:TByteBuffer(bytes:Byte Ptr, length:UInt) Override
		If _readOnly Then
			Throw New TReadOnlyBufferException
		End If

		Local newPosition:Int = _position + length
		If newPosition > _limit Then
			Throw New TBufferOverflowException
		End If
		
		Local pos:Int = _offset + _position
		MemCopy(_data + pos, bytes, Size_T(length))
		
		_position = newPosition
		Return Self
	End Method

	Method Slice:TByteBuffer() Override
		Return New TBytePtrBuffer(_data, remaining(), _offset + _position, _readOnly)
	End Method

	Method Duplicate:TByteBuffer() Override
		Return Copy(Self, _mark, _readOnly)
	End Method

Private
	Function Copy:TBytePtrBuffer(buffer:TBytePtrBuffer, mark:Int, isReadOnly:Int)
		Local bufCopy:TBytePtrBuffer = New TBytePtrBuffer(buffer._data, buffer._size, buffer._offset, isReadOnly)
		bufCopy._limit = buffer._limit
		bufCopy._position = buffer.Position()
		bufCopy._mark = mark
		Return bufCopy
	End Function
End Type

Rem
bbdoc: A #TBuffer whose data comes from a #Byte array.
End Rem
Type TByteArrayBuffer Extends TBytePtrBuffer

	Field _array:Byte[]

	Method New(data:Byte[])
		Super.New(data, data.length)
		Self._array = data
	End Method
Private
	Method New(data:Byte[], size:Int, offset:Int, isReadOnly:Int)
		Super.New(data, size)
		Self._array = data
		Self._offset = offset
		Self._readOnly = isReadOnly

		If offset + size > data.length Then
			Throw New TArrayBoundsException
		End If
	End Method

	Function Copy:TByteArrayBuffer(buffer:TByteArrayBuffer, mark:Int, isReadOnly:Int)
		Local bufCopy:TByteArrayBuffer = New TByteArrayBuffer(buffer._array, buffer._size, buffer._offset, isReadOnly)
		bufCopy._limit = buffer._limit
		bufCopy._position = buffer.Position()
		bufCopy._mark = mark
		Return bufCopy
	End Function

Public
	Method Slice:TByteBuffer() Override
		Return New TByteArrayBuffer(_data, remaining(), _offset + _position, _readOnly)
	End Method

	Method Duplicate:TByteBuffer() Override
		Return Copy(Self, _mark, _readOnly)
	End Method

Private

End Type


Type TBufferUnderflowException Extends TBlitzException
End Type

Type TBufferOverflowException Extends TBlitzException
End Type

Type TReadOnlyBufferException Extends TBlitzException
End Type

Extern
	Function bmx_bytebuffer_intbitstofloat:Float(value:Int)
	Function bmx_bytebuffer_floattointbits:Int(value:Float)
	Function bmx_bytebuffer_longbitstodouble:Double(value:Long)
	Function bmx_bytebuffer_doubletolongbits:Long(value:Double)
End Extern
