
SuperStrict

Rem
bbdoc: Miscellaneous/Banks
End Rem
Module BRL.Bank

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07"
ModuleInfo "History: Added Window method"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added Lock/Unlock to replace Buf"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Read/Write using ReadBytes/WriteBytes"

Import BRL.Stream

Rem
bbdoc: Memory bank
end rem
Type TBank

	Field _buf:Byte Ptr
	Field _size:Size_T,_capacity:Size_T,_static:Int
	Field _locked:Int
	
	Field _source:TBank
	
	Method _pad()
	End Method
	
	Method Delete()
		Assert Not _locked
		If _capacity>=0 And Not _static MemFree _buf
	End Method

	Rem
	bbdoc: Get a bank's memory pointer
	returns: A byte pointer to the memory block controlled by the bank
	about:
	Please use #Lock and #Unlock instead of this method.
	End Rem
	Method Buf:Byte Ptr()
		Return _buf
	End Method
	
	Rem
	bbdoc: Lock a bank's memory block
	returns: A byte pointer to the memory block controlled by the bank
	about:
	While locked, a bank cannot be resized.

	After you have finished with a bank's memory block, you must use #Unlock
	to return it to the bank.
	End Rem
	Method Lock:Byte Ptr()
		_locked:+1
		Return _buf
	End Method
	
	Rem
	bbdoc: Unlock a bank's memory pointer
	about:
	After you have finished with a bank's memory block, you must use #Unlock
	to return it to the bank.
	End Rem
	Method Unlock()
		_locked:-1
	End Method

	Rem
	bbdoc: Get a bank's size
	returns: The size, in bytes, of the memory block controlled by the bank
	End Rem
	Method Size:Size_T()
		Return _size
	End Method

	Rem
	bbdoc: Get capacity of bank
	returns: The capacity, in bytes, of the bank's internal memory buffer
	End Rem
	Method Capacity:Size_T()
		Return _capacity
	End Method
	
	Rem
	bbdoc: Returns True if the bank is static.
	End Rem
	Method IsStatic:Int()
		Return _static
	End Method

	Rem
	bbdoc: Resize a bank
	End Rem
	Method Resize( size:Int )
		Resize(Size_T(size))
	End Method
	
	Rem
	bbdoc: Resize a bank
	End Rem
	Method Resize( size:Size_T )
		Assert _locked=0 Else "Locked banks cannot be resize"
		Assert _static=0 Else "Static banks cannot be resized"
		If size>_capacity
			Local n:Size_T=_capacity*3/2
			If n<size n=size
			Local tmp:Byte Ptr=MemAlloc(n)
			MemCopy tmp,_buf,_size
			MemFree _buf
			_capacity=n
			_buf=tmp
		EndIf
		_size=size
	End Method
	
	Rem
	bbdoc: Read bytes from a stream into a bank
	end rem
	Method Read:Long( stream:TStream,offset:Long,count:Long )
		Assert offset>=0 And offset<=_size-count Else "Illegal bank offset"
		Return stream.Read( _buf+offset,count )
	End Method
	
	Rem
	bbdoc: Write bytes in a bank to a stream
	end rem
	Method Write:Long( stream:TStream,offset:Long,count:Long )
		Assert offset>=0 And offset<=_size-count Else "Illegal bank offset"
		Return stream.Write( _buf+offset,count )
	End Method

	Rem
	bbdoc: Peek a byte from a bank
	returns: The byte value at the specified byte offset within the bank
	End Rem
	Method PeekByte:Int( offset:Int )
		Return PeekByte(Size_T(offset))
	End Method
	
	Rem
	bbdoc: Peek a byte from a bank
	returns: The byte value at the specified byte offset within the bank
	End Rem
	Method PeekByte:Int( offset:Size_T )
		Assert offset>=0 And offset<_size Else "Illegal bank offset"
		Return _buf[offset]
	End Method

	Rem
	bbdoc: Poke a byte into a bank
	End Rem
	Method PokeByte( offset:Int,value:Int )
		PokeByte(Size_T(offset), value)
	End Method
	
	Rem
	bbdoc: Poke a byte into a bank
	End Rem
	Method PokeByte( offset:Size_T,value:Int )
		Assert offset>=0 And offset<_size Else "Illegal bank offset"
		_buf[offset]=value
	End Method

	Rem
	bbdoc: Peek a short from a bank
	returns: The short value at the specified byte offset within the bank
	End Rem
	Method PeekShort:Int( offset:Int )
		Return PeekShort(Size_T(offset))
	End Method
	
	Rem
	bbdoc: Peek a short from a bank
	returns: The short value at the specified byte offset within the bank
	End Rem
	Method PeekShort:Int( offset:Size_T )
		Assert offset>=0 And offset<_size-1 Else "Illegal bank offset"
		Return (Short Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a short into a bank
	End Rem
	Method PokeShort( offset:Int,value:Int )
		PokeShort(Size_T(offset), value)
	End Method
	
	Rem
	bbdoc: Poke a short into a bank
	End Rem
	Method PokeShort( offset:Size_T,value:Int )
		Assert offset>=0 And offset<_size-1 Else "Illegal bank offset"
		(Short Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Peek an int from a bank
	returns: The int value at the specified byte offset within the bank
	End Rem
	Method PeekInt:Int( offset:Int )
		Return PeekInt(Size_T(offset))
	End Method
	
	Rem
	bbdoc: Peek an int from a bank
	returns: The int value at the specified byte offset within the bank
	End Rem
	Method PeekInt:Int( offset:Size_T )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		Return (Int Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke an int into a bank
	End Rem
	Method PokeInt( offset:Int,value:Int )
		PokeInt(Size_T(offset), value)
	End Method
	
	Rem
	bbdoc: Poke an int into a bank
	End Rem
	Method PokeInt( offset:Size_T,value:Int )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		(Int Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Peek a long from a bank
	returns: The long value at the specified byte offset within the bank
	End Rem
	Method PeekLong:Long( offset:Int )
		Return PeekLong(Size_T(offset))
	End Method
	
	Rem
	bbdoc: Peek a long from a bank
	returns: The long value at the specified byte offset within the bank
	End Rem
	Method PeekLong:Long( offset:Size_T )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		Return (Long Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a long value into a bank
	End Rem
	Method PokeLong( offset:Int,value:Long )
		PokeLong(Size_T(offset), value)
	End Method
	
	Rem
	bbdoc: Poke a long value into a bank
	End Rem
	Method PokeLong( offset:Size_T,value:Long )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		(Long Ptr(_buf+offset))[0]=value
	End Method
	
	Rem
	bbdoc: Peek a float from a bank
	returns: The float value at the specified byte offset within the bank
	End Rem
	Method PeekFloat:Float( offset:Int )
		Return PeekFloat(Size_T(offset))
	End Method
	
	Rem
	bbdoc: Peek a float from a bank
	returns: The float value at the specified byte offset within the bank
	End Rem
	Method PeekFloat:Float( offset:Size_T )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		Return (Float Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a float value into a bank
	End Rem
	Method PokeFloat( offset:Int,value:Float )
		PokeFloat(Size_T(offset), value)
	End Method
	
	Rem
	bbdoc: Poke a float value into a bank
	End Rem
	Method PokeFloat( offset:Size_T,value:Float )
		Assert offset>=0 And offset<_size-3 Else "Illegal bank offset"
		(Float Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Peek a double from a bank
	returns: The double value at the specified byte offset within the bank
	End Rem
	Method PeekDouble:Double( offset:Int )
		Return PeekDouble(Size_T(offset))
	End Method
	
	Rem
	bbdoc: Peek a double from a bank
	returns: The double value at the specified byte offset within the bank
	End Rem
	Method PeekDouble:Double( offset:Size_T )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		Return (Double Ptr(_buf+offset))[0]
	End Method

	Rem
	bbdoc: Poke a double value into a bank
	End Rem
	Method PokeDouble( offset:Int,value:Double )
		PokeDouble(Size_T(offset), value)
	End Method
	
	Rem
	bbdoc: Poke a double value into a bank
	End Rem
	Method PokeDouble( offset:Size_T,value:Double )
		Assert offset>=0 And offset<_size-7 Else "Illegal bank offset"
		(Double Ptr(_buf+offset))[0]=value
	End Method

	Rem
	bbdoc: Creates a virtual window into the bank.
	returns: A static bank that references the specified offset and size.
	End Rem
	Method Window:TBank(offset:Size_T, size:Size_T)
		Assert offset>=0 And offset + size<_size Else "Illegal bank offset"
		Local bank:TBank = CreateStatic(_buf + offset, size)
		bank._source = Self
		Return bank
	End Method

	Rem
	bbdoc: Creates a virtual window into the bank.
	returns: A static bank that references the specified offset and size.
	End Rem
	Method Window:TBank(offset:Int, size:Int)
		Return Window(Size_T(offset), Size_T(size))
	End Method
	
	Rem
	bbdoc: Save a bank to a stream
	about:
	Return True if successful, otherwise False.
	End Rem
	Method Save:Int( url:Object )
		Local stream:TStream=WriteStream( url )
		If Not stream Return False
		Local n:Long=stream.WriteBytes( _buf,_size )
		stream.Close
		Return True
	End Method

	Rem
	bbdoc: Load a bank from a stream
	returns: A new TBank object
	about:
	Returns a new TBank object if successfull, otherwise Null.
	end rem
	Function Load:TBank( url:Object )
		Local stream:TStream=ReadStream( url )
		If Not stream Return Null
		Local data:Byte[]=LoadByteArray( stream )
		Local bank:TBank=Create( Size_T(data.length) )
		MemCopy bank.Buf(),data,Size_T(data.length)
		stream.Close
		Return bank
	End Function

	Rem
	bbdoc: Create a bank
	returns: A new TBank object with an initial size of @size
	End Rem
	Function Create:TBank( size:Size_T )
		Local bank:TBank=New TBank
		bank._buf=MemAlloc( size )
		bank._size=size
		bank._capacity=size
		Return bank
	End Function

	Rem
	bbdoc: Create a bank
	returns: A new TBank object with an initial size of @size
	End Rem
	Function Create:TBank( size:Int )
		Assert size>=0 Else "Illegal bank size"
		Return Create(Size_T(size))
	End Function
	
	Rem
	bbdoc: Create a bank from an existing block of memory
	End Rem
	Function CreateStatic:TBank( buf:Byte Ptr,size:Size_T )
		Local bank:TBank=New TBank
		bank._buf=buf
		bank._size=size
		bank._capacity=size
		bank._static=True
		Return bank
	End Function

	Rem
	bbdoc: Create a bank from an existing block of memory
	End Rem
	Function CreateStatic:TBank( buf:Byte Ptr,size:Int )
		Assert size>=0 Else "Illegal bank size"
		Return CreateStatic(buf, Size_T(size))
	End Function

End Type

Rem
bbdoc: Create a bank
returns: A bank object with an initial size of @size bytes
about:
#CreateBank creates a Bank allocating a specified amount of memory that
can be used for storage of binary data using the various Poke and
Peek commands. 
End Rem
Function CreateBank:TBank( size:Int=0 )
	Return TBank.Create( size )
End Function

Rem
bbdoc: Create a bank with existing data
returns: A bank object that references an existing block of memory
about:
The memory referenced by a static bank is not released when the bank is deleted.
A static bank cannot be resized.
End Rem
Function CreateStaticBank:TBank( buf:Byte Ptr,size:Int )
	Return TBank.CreateStatic( buf,size )
End Function

Rem
bbdoc: Load a bank
returns: A bank containing the binary contents of @url, or null if @url could not be opened
about:
#LoadBank reads the entire contents of a binary file from a specified @url into a newly
created bank with a size matching that of the file.
end rem
Function LoadBank:TBank( url:Object )
	Return TBank.Load( url )
End Function

Rem
bbdoc: Save a bank
returns: True if successful.
about:
#SaveBank writes it's entire contents to a @url. If the @url is a file path a new
file is created.
end rem
Function SaveBank:Int( bank:TBank,url:Object )
	Return bank.Save( url )
End Function

Rem
bbdoc: Get bank's memory buffer
returns: A byte pointer to the bank's internal memory buffer
about:
Please use #LockBank and #UnlockBank instead of this method.
End Rem
Function BankBuf:Byte Ptr( bank:TBank )
	Return bank.Buf()
End Function

Rem
bbdoc: Lock a bank's memory block
returns: A byte pointer to the memory block controlled by the bank.
about:
While locked, a bank cannot be resized.

After you have finished with a bank's memory block, you must use #UnlockBank
to return it to the bank.
End Rem
Function LockBank:Byte Ptr( bank:TBank )
	Return bank.Lock()
End Function

Rem
bbdoc: Unlock a bank's memory block
about:
After you have finished with a bank's memory block, you must use #UnlockBank
to return it to the bank.
End Rem
Function UnlockBank( bank:TBank )
	bank.Unlock
End Function

Rem
bbdoc: Get size of bank
returns: The size, in bytes, of the bank's internal memory buffer
End Rem
Function BankSize:Long( bank:TBank )
	Return bank.Size()
End Function

Rem
bbdoc: Get capacity of bank
returns: The capacity, in bytes, of the bank's internal memory buffer
about:
The capacity of a bank is the size limit before a bank must allocate
more memory due to a resize. Bank capacity may be increased due to a call
to #ResizeBank by either 50% or the requested amount, whichever is greater.
Capacity never decreases.
End Rem
Function BankCapacity:Long( bank:TBank )
	Return bank.Capacity()
End Function

Rem
bbdoc: Resize a bank
about:
#ResizeBank modifies the size limit of a bank. This may cause memory to be
allocated if the requested size is greater than the bank's current capacity,
see #BankCapacity for more information.
End Rem
Function ResizeBank( bank:TBank,size:Size_T )
	bank.Resize size
End Function

Rem
bbdoc: Copy bank contents
about:
#CopyBank copies @count bytes from @src_offset in @src_bank to @dst_offset
in @dst_bank.
End Rem
Function CopyBank( src_bank:TBank,src_offset:Size_T,dst_bank:TBank,dst_offset:Size_T,count:Size_T )
	Assert..
	count>=0 And..
	src_offset>=0 And..
	dst_offset>=0 And..
	src_offset+count<=src_bank.Size() And..
	dst_offset+count<=dst_bank.size() Else "Illegal range for CopyBank"
	MemCopy( dst_bank.Buf()+dst_offset,src_bank.Buf()+src_offset,count )
End Function

Rem
bbdoc: Peek a byte from a bank
returns: The byte value at the specified byte offset within the bank
about:
A byte is an unsigned 8 bit value with a range of 0..255.
End Rem
Function PeekByte:Int( bank:TBank,offset:Int )
	Return PeekByte(bank, Size_T(offset))
End Function

Rem
bbdoc: Peek a byte from a bank
returns: The byte value at the specified byte offset within the bank
about:
A byte is an unsigned 8 bit value with a range of 0..255.
End Rem
Function PeekByte:Int( bank:TBank,offset:Size_T )
	Return bank.PeekByte( offset )
End Function

Rem
bbdoc: Poke a byte into a bank
End Rem
Function PokeByte( bank:TBank,offset:Int,value:Int )
	PokeByte(bank, Size_T(offset), value)
End Function

Rem
bbdoc: Poke a byte into a bank
End Rem
Function PokeByte( bank:TBank,offset:Size_T,value:Int )
	bank.PokeByte offset,value
End Function

Rem
bbdoc: Reads an unsigned short value (2 bytes) from a bank, at a given address.
returns: The short value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A short value should not be read from the last possible byte address of the bank.
End Rem
Function PeekShort:Int( bank:TBank,offset:Int )
	Return PeekShort(bank, Size_T(offset))
End Function

Rem
bbdoc: Reads an unsigned short value (2 bytes) from a bank, at a given address.
returns: The short value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A short value should not be read from the last possible byte address of the bank.
End Rem
Function PeekShort:Int( bank:TBank,offset:Size_T )
	Return bank.PeekShort( offset )
End Function

Rem
bbdoc: Writes an unsigned short value (2 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A short value should not be poked at the last possible byte address of the bank.
End Rem
Function PokeShort( bank:TBank,offset:Int,value:Int )
	PokeShort(bank, Size_T(offset), value)
End Function

Rem
bbdoc: Writes an unsigned short value (2 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A short value should not be poked at the last possible byte address of the bank.
End Rem
Function PokeShort( bank:TBank,offset:Size_T,value:Int )
	bank.PokeShort offset,value
End Function

Rem
bbdoc: Reads a signed int value (4 bytes) from a bank, at a given address.
returns: The int value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> An int value should not be read from the last possible byte or short address of the bank.
End Rem
Function PeekInt:Int( bank:TBank,offset:Int )
	Return PeekInt(bank, Size_T(offset))
End Function

Rem
bbdoc: Reads a signed int value (4 bytes) from a bank, at a given address.
returns: The int value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> An int value should not be read from the last possible byte or short address of the bank.
End Rem
Function PeekInt:Int( bank:TBank,offset:Size_T )
	Return bank.PeekInt( offset )
End Function

Rem
bbdoc: Writes a signed int value (4 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> An int value should not be poked at the last possible byte or short address of the bank.
End Rem
Function PokeInt( bank:TBank,offset:Int,value:Int )
	PokeInt(bank, Size_T(offset), value)
End Function

Rem
bbdoc: Writes a signed int value (4 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> An int value should not be poked at the last possible byte or short address of the bank.
End Rem
Function PokeInt( bank:TBank,offset:Size_T,value:Int )
	bank.PokeInt offset,value
End Function

Rem
bbdoc: Reads a signed long value (8 bytes) from a bank, at a given address.
returns: The long integer value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A long value should not be read from the last possible byte, short or int address of the bank.
End Rem
Function PeekLong:Long( bank:TBank,offset:Int )
	Return PeekLong(bank, Size_T(offset))
End Function

Rem
bbdoc: Reads a signed long value (8 bytes) from a bank, at a given address.
returns: The long integer value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A long value should not be read from the last possible byte, short or int address of the bank.
End Rem
Function PeekLong:Long( bank:TBank,offset:Size_T )
	Return bank.PeekLong( offset )
End Function

Rem
bbdoc: Writes a signed long value (8 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A long value should not be poked at the last possible byte, short or int address of the bank.
End Rem
Function PokeLong( bank:TBank,offset:Int,value:Long )
	PokeLong(bank, Size_T(offset), value)
End Function

Rem
bbdoc: Writes a signed long value (8 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A long value should not be poked at the last possible byte, short or int address of the bank.
End Rem
Function PokeLong( bank:TBank,offset:Size_T,value:Long )
	bank.PokeLong offset,value
End Function

Rem
bbdoc: Reads a signed float value (4 bytes) from a bank, at a given address.
returns: The float value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A float value should not be read from the last possible byte or short address of the bank.
End Rem
Function PeekFloat:Float( bank:TBank,offset:Int )
	Return PeekFloat(bank, Size_T(offset))
End Function

Rem
bbdoc: Reads a signed float value (4 bytes) from a bank, at a given address.
returns: The float value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A float value should not be read from the last possible byte or short address of the bank.
End Rem
Function PeekFloat:Float( bank:TBank,offset:Size_T )
	Return bank.PeekFloat( offset )
End Function

Rem
bbdoc: Writes a signed float value (4 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A float value should not be poked at the last possible byte or short address of the bank.
End Rem
Function PokeFloat( bank:TBank,offset:Int,value:Float )
	PokeFloat(bank, Size_T(offset), value)
End Function

Rem
bbdoc: Writes a signed float value (4 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A float value should not be poked at the last possible byte or short address of the bank.
End Rem
Function PokeFloat( bank:TBank,offset:Size_T,value:Float )
	bank.PokeFloat offset,value
End Function

Rem
bbdoc: Reads a signed double value (8 bytes) from a bank, at a given address.
returns: The double value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A double value should not be read from the last possible byte, short, int or long address of the bank.
End Rem
Function PeekDouble:Double( bank:TBank,offset:Int )
	Return PeekDouble(bank, Size_T(offset))
End Function

Rem
bbdoc: Reads a signed double value (8 bytes) from a bank, at a given address.
returns: The double value at the specified byte offset within the bank
about:
Take notice not to exceed the boundaries of the bank.

> A double value should not be read from the last possible byte, short, int or long address of the bank.
End Rem
Function PeekDouble:Double( bank:TBank,offset:Size_T )
	Return bank.PeekDouble( offset )
End Function

Rem
bbdoc: Writes a signed double value (8 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A double value should not be poked at the last possible byte, short, int or float address of the bank.
End Rem
Function PokeDouble( bank:TBank,offset:Int,value:Double )
	PokeDouble(bank, Size_T(offset), value)
End Function

Rem
bbdoc: Writes a signed double value (8 bytes) into a bank, at a given address.
about:
Take notice not to exceed the boundaries of the bank.

> A double value should not be poked at the last possible byte, short, int or float address of the bank.
End Rem
Function PokeDouble( bank:TBank,offset:Size_T,value:Double )
	bank.PokeDouble offset,value
End Function

Rem
bbdoc: Read bytes from a Stream to a Bank
returns: The number of bytes successfully read from the Stream
End Rem
Function ReadBank:Long( bank:TBank,stream:TStream,offset:Int,count:Long )
	Return ReadBank(bank, stream, Size_T(offset), count)
End Function

Rem
bbdoc: Read bytes from a Stream to a Bank
returns: The number of bytes successfully read from the Stream
End Rem
Function ReadBank:Long( bank:TBank,stream:TStream,offset:Size_T,count:Long )
	Return bank.Read( stream,offset,count )
End Function

Rem
bbdoc: Write bytes from a Bank To a Stream
returns: The number of bytes successfully written to the Stream
end rem
Function WriteBank:Long( bank:TBank,stream:TStream,offset:Int,count:Long )
	Return WriteBank(bank, stream, Size_T(offset), count)
End Function

Rem
bbdoc: Write bytes from a Bank to a Stream
returns: The number of bytes successfully written to the Stream
end rem
Function WriteBank:Long( bank:TBank,stream:TStream,offset:Size_T,count:Long )
	Return bank.Write( stream,offset,count )
End Function
