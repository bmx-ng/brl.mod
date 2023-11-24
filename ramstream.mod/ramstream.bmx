
Strict

Rem
bbdoc: Streams/Ram streams
End Rem
Module BRL.RamStream

ModuleInfo "Version: 1.01"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

Import BRL.Stream

Type TRamStream Extends TStream

	Field _pos:Long,_size:Long,_buf:Byte Ptr,_read,_write

	Method Pos:Long() Override
		Return _pos
	End Method

	Method Size:Long() Override
		Return _size
	End Method

	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ ) Override
		If whence = SEEK_SET_ Then
			If pos<0 pos=0 Else If pos>_size pos=_size
		ElseIf whence = SEEK_END_ Then
			If pos>=0 Then
				pos = _size
			Else
				pos = _size + pos
				If pos < 0 Then
					pos = 0
				End If
			End If
		End If
		_pos=pos
		Return _pos
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		If count<=0 Or _read=False Return 0
		If _pos+count>_size count=_size-_pos
		MemCopy buf,_buf+_pos,Size_T(count)
		_pos:+count
		Return count
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		If count<=0 Or _write=False Return 0
		If _pos+count>_size count=_size-_pos
		MemCopy _buf+_pos,buf,Size_T(count)
		_pos:+count
		Return count
	End Method

	Function Create:TRamStream( buf:Byte Ptr,size:Long,readable,writeMode )
		Local stream:TRamStream=New TRamStream
		stream._pos=0
		stream._size=size
		stream._buf=buf
		stream._read=readable
		stream._write=writeMode
		Return stream
	End Function

End Type

Rem
bbdoc: Create a ram stream
returns: A ram stream object
about: A ram stream allows you to read and/or write data directly from/to memory.
A ram stream extends a stream object so can be used anywhere a stream is expected.

Be careful when working with ram streams, as any attempt to access memory
which has not been allocated to your application can result in a runtime crash.
End Rem
Function CreateRamStream:TRamStream( ram:Byte Ptr,size:Long,readable,writeMode )
	Assert writeMode <> WRITE_MODE_APPEND, "Ram Streams cannot be appended"
	Return TRamStream.Create( ram,size,readable,writeMode )
End Function

Type TRamStreamFactory Extends TStreamFactory
	Method CreateStream:TRamStream( url:Object,proto:String,path:String,readable,writeMode ) Override
		If proto="incbin" And Not writeMode
			Local buf:Byte Ptr=IncbinPtr( path )
			If Not buf Return
			Local size:Long=IncbinLen( path )
			Return TRamStream.Create( buf,size,readable,writeMode )
		EndIf
	End Method
End Type

New TRamStreamFactory
