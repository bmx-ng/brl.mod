
SuperStrict

Rem
bbdoc: Streams/Streams
End Rem
Module BRL.Stream

ModuleInfo "Version: 1.11"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.11"
ModuleInfo "History: Streams can now be opened for appending with the new WRITE_MODE_APPEND write mode."
ModuleInfo "History: 1.10"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.09 Release"
ModuleInfo "History: Fixed 'excpetion' typos"
ModuleInfo "History: 1.08 Release"
ModuleInfo "History: Fixed resource leak in CasedFileName"
ModuleInfo "History: 1.07 Release"
ModuleInfo "History: OpenStream protocol:: now case insensitive"
ModuleInfo "History: Fixed ReadString with 0 length strings"
ModuleInfo "History: Removed LoadStream - use LoadByteArray instead"
ModuleInfo "History: Removed AddStreamFactory function"
ModuleInfo "History: Added url parameter to TStreamFactory CreateStream method"
ModuleInfo "History: 1.06 Release"
ModuleInfo "History: Added checks to CStream for reading from write only stream and vice versa"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Eof bug"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: Added LoadString"
ModuleInfo "History: Added LoadByteArray"
ModuleInfo "History: Cleaned up docs a bit"

Import BRL.IO
Import Pub.StdC

Rem
bbdoc: Base exception type thrown by streams
End Rem
Type TStreamException
End Type

Rem
bbdoc: Exception type thrown by streams in the event of read errors
about:
#TStreamReadException is usually thrown when a stream operation failed to read enough
bytes. For example, if the stream ReadInt method fails to read 4 bytes, it will throw
a #TStreamReadException.
End Rem
Type TStreamReadException Extends TStreamException
	Method ToString$() Override
		Return "Error reading from stream"
	End Method
End Type

Rem
bbdoc: Exception type thrown by streams in the event of write errors
about:
#TStreamWriteException is usually thrown when a stream operation failed to write enough
bytes. For example, if the stream WriteInt method fails to write 4 bytes, it will throw
a #TStreamWriteException.
End Rem
Type TStreamWriteException Extends TStreamException
	Method ToString$() Override
		Return "Error writing to stream"
	End Method
End Type

Rem
bbdoc: Base input/output type
about:
To create your own stream types, you should extend TStream and implement
at least these methods.

You should also make sure your stream can handle multiple calls to the Close method.
End Rem
Type TIO
	Rem
	bbdoc: Get stream end of file status
	returns: True for end of file reached, otherwise False
	about:
	For seekable streams such as file streams, Eof generally returns True if the file
	position equals the file size. This means that no more bytes can be read from the
	stream. However, it may still be possible to write bytes, in which case the file will
	 'grow'.
	
	For communication type streams such as socket streams, Eof returns True if the stream
	has been shut down for some reason - either locally or by the remote host. In this case,
	no more bytes can be read from or written to the stream.
	End Rem
	Method Eof:Int()
		Return Pos()=Size()
	End Method

	Rem
	bbdoc: Get position of seekable stream
	returns: Stream position as a byte offset, or -1 if stream is not seekable
	End Rem
	Method Pos:Long()
		Return -1
	End Method

	Rem
	bbdoc: Get size of seekable stream
	returns: Size, in bytes, of seekable stream, or 0 if stream is not seekable
	End Rem
 	Method Size:Long()
		Return 0
	End Method

	Rem
	bbdoc: Seek to position in seekable stream
	returns: New stream position, or -1 if stream is not seekable
	End Rem
	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ )
		Return -1
	End Method

	Rem
	bbdoc: Flush stream
	about:
	Flushes any internal stream buffers.
	End Rem
	Method Flush()
	End Method

	Rem
	bbdoc: Close stream
	about:
	Closes the stream after flushing any internal stream buffers.
	End Rem
	Method Close()
	End Method

	Rem
	bbdoc: Read at least 1 byte from a stream
	returns: Number of bytes successfully read
	about:
	This method may 'block' if it is not possible to read at least one byte due to IO 
	buffering.
	
	If this method returns 0, the stream has reached end of file.
	End Rem
	Method Read:Long( buf:Byte Ptr,count:Long )
		RuntimeError "Stream is not readable"
		Return 0
	End Method

	Rem
	bbdoc: Write at least 1 byte to a stream
	returns: Number of bytes successfully written
	about:
	This method may 'block' if it is not possible to write at least one byte due to IO
	buffering.
	
	If this method returns 0, the stream has reached end of file.
	End Rem
	Method Write:Long( buf:Byte Ptr,count:Long )
		RuntimeError "Stream is not writeable"
		Return 0
	End Method
	
	Rem
	bbdoc: Sets the size of the stream to @size bytes.
	returns: #True if the stream was able to be resized, #False otherwise.
	about: Only a few stream types support resizing.
	End Rem
	Method SetSize:Int(size:Long)
		RuntimeError "Stream does not support resizing"
		Return 0
	End Method

	Method Delete()
		Close
	End Method

End Type

Rem
bbdoc: Data stream type
about:
#TStream extends #TIO to provide methods for reading and writing various types of values
to and from a stream.

Note that methods dealing with strings - ReadLine, WriteLine, ReadString and WriteString -
assume that strings are represented by bytes in the stream. In future, a more powerful
TextStream type will be added capable of decoding text streams in multiple formats.
End Rem
Type TStream Extends TIO

	Rem
	bbdoc: Reads bytes from a stream
	about:
	#ReadBytes reads @count bytes from the stream into the memory block specified by @buf.
	
	If @count bytes were not successfully read, a #TStreamReadException is thrown. This typically
	occurs due to end of file.
	End Rem
	Method ReadBytes:Long( buf:Byte Ptr,count:Long )
		Local t:Long=count
		While count>0
			Local n:Long=Read( buf,count )
			If Not n Throw New TStreamReadException
			count:-n
			buf:+n
		Wend
		Return t
	End Method

	Rem
	bbdoc: Writes bytes to a stream
	about:
	#WriteBytes writes @count bytes from the memory block specified by @buf to the stream.
	
	If @count bytes were not successfully written, a #TStreamWriteException is thrown. This typically
	occurs due to end of file.
	End Rem
	Method WriteBytes:Long( buf:Byte Ptr,count:Long )
		Local t:Long=count
		While count>0
			Local n:Long=Write( buf,count )
			If Not n Throw New TStreamWriteException
			count:-n
			buf:+n
		Wend
		Return t
	End Method

	Rem
	bbdoc: Skip bytes in a stream
	about:
	#SkipBytes read @count bytes from the stream and throws them away.
	
	If @count bytes were not successfully read, a #TStreamReadException is thrown. This typically
	occurs due to end of file.
	End Rem
	Method SkipBytes:Long( count:Long )
		Local t:Long=count
		Local buf:Byte[1024]
		While count>0
			Local n:Long=Read( buf,Min(count,buf.length) )
			If Not n Throw New TStreamReadException
			count:-n
		Wend
		Return t
	End Method

	Rem
	bbdoc: Read a byte from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadByte:Int()
		Local n:Byte
		ReadBytes Varptr n,1
		Return n
	End Method

	Rem
	bbdoc: Write a byte to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteByte( n:Int )
		Local q:Byte=n
		WriteBytes Varptr q,1
	End Method

	Rem
	bbdoc: Read a short (two bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadShort:Int()
		Local n:Short
		ReadBytes Varptr n,2
		Return n
	End Method

	Rem
	bbdoc: Write a short (two bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteShort( n:Int )
		Local q:Short=n
		WriteBytes Varptr q,2
	End Method

	Rem
	bbdoc: Read an int (four bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadInt:Int()
		Local n:Int
		ReadBytes Varptr n,4
		Return n
	End Method
	
	Rem
	bbdoc: Write an int (four bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteInt( n:Int )
		Local q:Int=n
		WriteBytes Varptr q,4
	End Method
	
	Rem
	bbdoc: Read a long (eight bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadLong:Long()
		Local n:Long
		ReadBytes Varptr n,8
		Return n
	End Method
	
	Rem
	bbdoc: Write a long (eight bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteLong( n:Long )
		Local q:Long=n
		WriteBytes Varptr q,8
	End Method
	
	Rem
	bbdoc: Read a float (four bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadFloat#()
		Local n#
		ReadBytes Varptr n,4
		Return n
	End Method

	Rem
	bbdoc: Write a float (four bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteFloat( n# )
		Local q#=n
		WriteBytes Varptr q,4
	End Method

	Rem
	bbdoc: Read a double (eight bytes) from the stream
	returns: The read value
	about:
	If a value could not be read (possibly due to end of file), a #TStreamReadException is thrown.
	End Rem
	Method ReadDouble!()
		Local n!
		ReadBytes Varptr n,8
		Return n
	End Method

	Rem
	bbdoc: Write a double (eight bytes) to the stream
	about:
	If the value could not be written (possibly due to end of file), a #TStreamWriteException is thrown.
	End Rem
	Method WriteDouble( n! )
		Local q!=n
		WriteBytes Varptr q,8
	End Method
	
	Rem
	bbdoc: Read a line of text from the stream
	about: 
	Bytes are read from the stream until a newline character (ascii code 10) or null
	character (ascii code 0) is read, or end of file is detected.
	
	Carriage return characters (ascii code 13) are silently ignored.
	
	The bytes read are returned in the form of a string, excluding any terminating newline
	or null character.
	End Rem
	Method ReadLine$()
		Local buf:Byte[1024],sz:Int
		Repeat
			Local ch:Byte
			If Read( Varptr ch,1 )<>1 Or ch=0 Or ch=10 Exit
			If ch=13 Continue
			If sz=buf.length buf=buf[..sz*2]
			buf[sz]=ch
			sz:+1
		Forever
		Return String.FromBytes( buf,sz )
	End Method

	Rem
	bbdoc: Write a line of text to the stream
	returns: True if line successfully written, else False
	about: A sequence of bytes is written to the stream (one for each character in @str)
	followed by the line terminating sequence "~r~n".
	End Rem
	Method WriteLine:Int( str$ )
		Local buf:Byte Ptr=str.ToCString()
		Local ok:Int=Write( buf,str.length )=str.length And Write( [13:Byte,10:Byte],2 )=2
		MemFree buf
		Return ok
	End Method

	Rem
	bbdoc: Read characters from the stream
	returns: A string composed of @length bytes read from the stream
	about:
	A #TStreamReadException is thrown if not all bytes could be read.
	End Rem
	Method ReadString$( length:Int )
		Assert length>=0 Else "Illegal String length"
		Local buf:Byte[length]
		Readbytes buf,length
		Return String.FromBytes( buf,length )
	End Method
	
	Rem
	bbdoc: Write characters to the stream
	about:
	A #TStreamWriteException is thrown if not all bytes could be written.
	End Rem
	Method WriteString( str$ )
		Local buf:Byte Ptr=str.ToCString()
		WriteBytes buf,str.length
		MemFree buf
	End Method
	
	Method ReadObject:Object()
		Throw "Unable to read object"
	End Method
	
	Method WriteObject( obj:Object )
		Throw "Unable to write object"
	End Method

End Type

Rem
bbdoc: Utility stream wrapper type
about:
#TStreamWrapper 'wraps' an existing stream, redirecting all TIO method calls to the wrapped
stream.

This can be useful for writing stream 'filters' that modify the behaviour of existing
streams.

Note that the Close method causes the underlying stream to be closed, which may not always
be desirable. If necessary, you should override Close with a NOP version.
End Rem
Type TStreamWrapper Extends TStream
	Field _stream:TStream

	Rem
	bbdoc: Set underlying stream
	about:
	Sets the stream to be 'wrapped'. All calls to TIO methods of this stream will be
	redirected to @stream.
	end rem
	Method SetStream( stream:TStream )
		_stream=stream
	End Method

	Method Eof:Int() Override
		Return _stream.Eof()
	End Method

	Method Pos:Long() Override
		Return _stream.Pos()
	End Method

	Method Size:Long() Override
		Return _stream.Size()
	End Method
	
	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ ) Override
		Return _stream.Seek( pos, whence )
	End Method

	Method Flush() Override
		_stream.Flush
	End Method

	Method Close() Override
		If _stream Then
			_stream.Close
			_stream = Null
		End If
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		Return _stream.Read( buf,count )
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		Return _stream.Write( buf,count )
	End Method
	
	Method ReadByte:Int() Override
		Return _stream.ReadByte()
	End Method
	
	Method WriteByte( n:Int ) Override
		_stream.WriteByte n
	End Method
	
	Method ReadShort:Int() Override
		Return _stream.ReadShort()
	End Method
	
	Method WriteShort( n:Int ) Override
		_stream.WriteShort n
	End Method
	
	Method ReadInt:Int() Override
		Return _stream.ReadInt()
	End Method
	
	Method WriteInt( n:Int ) Override
		_stream.WriteInt n
	End Method
	
	Method ReadFloat:Float() Override
		Return _stream.ReadFloat()
	End Method
	
	Method WriteFloat( n:Float ) Override
		_stream.WriteFloat n
	End Method
	
	Method ReadDouble:Double() Override
		Return _stream.ReadDouble()
	End Method
	
	Method WriteDouble( n:Double ) Override
		_stream.WriteDouble n
	End Method
	
	Method ReadLine$() Override
		Return _stream.ReadLine()
	End Method
	
	Method WriteLine:Int( t$ ) Override
		Return _stream.WriteLine( t )
	End Method
	
	Method ReadString$( n:Int ) Override
		Return _stream.ReadString( n )
	End Method
	
	Method WriteString( t$ ) Override
		_stream.WriteString t
	End Method
	
	Method ReadObject:Object() Override
		Return _stream.ReadObject()
	End Method
	
	Method WriteObject( obj:Object ) Override
		_stream.WriteObject obj
	End Method

	Method SetSize:Int(size:Long) Override
		Return _stream.SetSize(size)
	End Method
End Type	

Type TStreamStream Extends TStreamWrapper

	Method Close() Override
		SetStream Null
	End Method

	Function Create:TStreamStream( stream:TStream )
		Local t:TStreamStream=New TStreamStream
		t.SetStream stream
		Return t
	End Function
	
End Type

Type TFileStream Extends TStream

	Const MODE_READ:Int=1
	Const MODE_WRITE:Int=2
	Const MODE_APPEND:Int = 4
	
	Field _pos:Long,_size:Long,_mode:Int
	Field _stream:Byte Ptr

	Method Pos:Long() Override
		Return _pos
	End Method

	Method Size:Long() Override
		Return _size
	End Method
	
	Method Delete()
		Close
	End Method

	Function GetMode:String(readable:Int,writeMode:Int, _mode:Int Var)
		Local Mode$
		If readable And writeMode = WRITE_MODE_OVERWRITE
			Mode="r+b"
			_mode=MODE_READ|MODE_WRITE
		Else If readable And writeMode = WRITE_MODE_APPEND
			Mode="a+b"
			_mode=MODE_READ|MODE_APPEND
		Else If writeMode = WRITE_MODE_OVERWRITE
			Mode="wb"
			_mode=MODE_WRITE
		Else If writeMode = WRITE_MODE_APPEND
			Mode="ab"
			_mode=MODE_APPEND
		Else
			Mode="rb"
			_mode=MODE_READ
		EndIf
		Return Mode
	End Function

End Type

Rem
bbdoc: Standard C file stream type
about:
End Rem
Type TCStream Extends TFileStream

	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ ) Override
		Assert _stream Else "Attempt to seek closed stream"
		fseek_ _stream,pos,whence
		_pos=ftell_( _stream )
		Return _pos
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		Assert _stream Else "Attempt to read from closed stream"
		Assert _mode & MODE_READ Else "Attempt to read from write-only stream"
		count=fread_( buf,1,count,_stream )	
		_pos:+count
		Return count
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		Assert _stream Else "Attempt to write to closed stream"
		Assert _mode & (MODE_WRITE | MODE_APPEND) Else "Attempt to write to read-only stream"
		count=fwrite_( buf,1,count,_stream )
		_pos:+count
		If _pos>_size _size=_pos
		Return count
	End Method

	Method Flush() Override
		If _stream fflush_ _stream
	End Method

	Method Close() Override
		If Not _stream Return
		Flush
		fclose_ _stream
		_pos=0
		_size=0
		_stream=Null
	End Method

	Method SetSize:Int(size:Long) Override
		If Not _stream Return 0
		Flush()
		If _size > size Then
			Seek(size)
		End If
		Local res:Int = ftruncate_(_stream, size)
		Flush()
		If Not res Then
			_size = size
		End If
		Return res = 0
	End Method

	Rem
	bbdoc: Create a TCStream from a 'C' filename
	End Rem
	Function OpenFile:TCStream( path$,readable:Int,writeMode:Int )
		Local Mode$,_mode:Int
		Mode = GetMode(readable, writeMode, _mode)
		path=path.Replace( "\","/" )
		Local cstream:Byte Ptr=fopen_( path,Mode )
?Linux
		If (Not cstream) And (Not writeMode)
			path=CasedFileName(path)
			If path cstream=fopen_( path,Mode )
		EndIf
?
		If cstream Return CreateWithCStream( cstream,_mode )
	End Function

	Rem
	bbdoc: Create a TCStream from a 'C' stream handle
	end rem
	Function CreateWithCStream:TCStream( cstream:Byte Ptr,Mode:Int )
		Local stream:TCStream=New TCStream
		stream._stream=cstream
		stream._pos=ftell_( cstream )
		fseek_ cstream,0,SEEK_END_
		stream._size=ftell_( cstream )
		fseek_ cstream,stream._pos,SEEK_SET_
		stream._mode=Mode
		Return stream
	End Function

End Type

Private
Global stream_factories:TStreamFactory
Public

Rem
bbdoc: Base stream factory type
about:
Stream factories are used by the #OpenStream, #ReadStream and #WriteStream functions
to create streams based on a 'url object'.

Url objects are usually strings, in which case the url is divided into 2 parts - a 
protocol and a path. These are separated by a double colon string - "::".

To create your own stream factories, you should extend the TStreamFactory type and
implement the CreateStream method.

To install your stream factory, simply create an instance of it using 'New'.
End Rem
Type TStreamFactory
	Field _succ:TStreamFactory
	
	Method New()
		_succ=stream_factories
		stream_factories=Self
	End Method

	Rem
	bbdoc: Create a stream based on a url object
	about:
	Types which extends TStreamFactory must implement this method.
	
	@url contains the original url object as supplied to #OpenStream, #ReadStream or 
	#WriteStream.
	
	If @url is a string, @proto contains the url protocol - for example, the "incbin" part
	of "incbin::myfile".
	
	If @url is a string, @path contains the remainder of the url - for example, the "myfile"
	part of "incbin::myfile".
	
	If @url is not a string, both @proto and @path will be Null.
	End Rem
	Method CreateStream:TStream( url:Object,proto$,path$,readable:Int,writeMode:Int ) Abstract

End Type

Rem
bbdoc: Open a stream for reading/writing/appending
returns: A stream object
about: All streams created by #OpenStream, #ReadStream, #WriteStream or #AppendStream should eventually be
closed using #CloseStream.
End Rem
Function OpenStream:TStream( url:Object,readable:Int=True,writeMode:Int=WRITE_MODE_OVERWRITE )

	Local stream:TStream=TStream( url )
	If stream
		Return TStreamStream.Create( stream )
	EndIf

	Local str$=String( url ),proto$,path$
	If str
		Local i:Int=str.Find( "::",0 )
		If i=-1 Then
			If MaxIO.ioInitialized Then
				Return TIOStream.OpenFile(str, readable, writemode)
			Else
				Return TCStream.OpenFile( str,readable,writeMode )
			End If
		End If
		proto$=str[..i].ToLower()
		path$=str[i+2..]
	EndIf

	Local factory:TStreamFactory=stream_factories
	
	While factory
		Local stream:TStream=factory.CreateStream( url,proto,path,readable,writeMode )
		If stream Return stream
		factory=factory._succ
	Wend
End Function

Rem
bbdoc: Open a stream for reading
returns: A stream object
about: All streams created by #OpenStream, #ReadStream or #WriteStream should eventually
be closed using #CloseStream.
End Rem
Function ReadStream:TStream( url:Object )
	Return OpenStream( url,True,False )
End Function

Rem
bbdoc: Open a stream for writing
returns: A stream object
about: All streams created by #OpenStream, #ReadStream, #WriteStream or #AppendStream should eventually
be closed using #CloseStream.
End Rem
Function WriteStream:TStream( url:Object )
	Return OpenStream( url,False,WRITE_MODE_OVERWRITE )
End Function

Rem
bbdoc: Open a stream for appending
returns: A stream object
about: All streams created by #OpenStream, #ReadStream, #WriteStream or #AppendStream should eventually
be closed using #CloseStream.
End Rem
Function AppendStream:TStream( url:Object )
	Return OpenStream( url,False,WRITE_MODE_APPEND )
End Function

Rem
bbdoc: Get stream end of file status
returns: True If stream is at end of file
End Rem
Function Eof:Int( stream:TStream )
	Return stream.Eof()
End Function

Rem
bbdoc: Get current position of seekable stream
returns: Current stream position, or -1 If stream is not seekable
End Rem
Function StreamPos:Long( stream:TStream )
	Return stream.Pos()
End Function

Rem
bbdoc: Get current size of seekable stream
returns: Current stream size in bytes, or -1 If stream is not seekable
End Rem
Function StreamSize:Long( stream:TStream )
	Return stream.Size()
End Function

Rem
bbdoc: Set stream position of seekable stream
returns: New stream position, or -1 If stream is not seekable
End Rem
Function SeekStream:Long( stream:TStream, pos:Long, whence:Int = SEEK_SET_ )
	Return stream.Seek( pos, whence )
End Function

Rem
bbdoc: Flush a stream
about: #FlushStream writes any outstanding buffered data to @stream.
End Rem
Function FlushStream( stream:TStream )
	stream.Flush
End Function

Rem
bbdoc: Close a stream
about: 
All streams should be closed when they are no longer required. 
Closing a stream also flushes the stream before it closes.
End Rem
Function CloseStream( stream:TStream )
	stream.Close
End Function

Rem
bbdoc: Read a Byte from a stream
returns: A Byte value
about: #ReadByte reads a single Byte from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadByte:Int( stream:TStream )
	Return stream.ReadByte()
End Function

Rem
bbdoc: Read a Short from a stream
returns: A Short value
about: #ReadShort reads 2 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadShort:Int( stream:TStream )
	Return stream.ReadShort()
End Function

Rem
bbdoc: Read an Int from a stream
returns: An Int value
about: #ReadInt reads 4 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadInt:Int( stream:TStream )
	Return stream.ReadInt()
End Function

Rem
bbdoc: Read a Long from a stream
returns: A Long value
about: #ReadLong reads 8 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadLong:Long( stream:TStream )
	Return stream.ReadLong()
End Function

Rem
bbdoc: Read a Float from a stream
returns: A Float value
about: #ReadFloat reads 4 bytes from @stream.
A TStreamReadException is thrown If there is not enough data available.
End Rem
Function ReadFloat#( stream:TStream )
	Return stream.ReadFloat()
End Function

Rem
bbdoc: Read a Double from a stream
returns: A Double value
about: #ReadDouble reads 8 bytes from @stream.
A TStreamWriteException is thrown If there is not enough data available.
End Rem
Function ReadDouble!( stream:TStream )
	Return stream.ReadDouble()
End Function

Rem
bbdoc: Write a Byte to a stream
about: #WriteByte writes a single Byte to @stream.
A TStreamWriteException is thrown If the Byte could Not be written
End Rem
Function WriteByte( stream:TStream,n:Int )
	stream.WriteByte n
End Function

Rem
bbdoc: Write a Short to a stream
about: #WriteShort writes 2 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteShort( stream:TStream,n:Int )
	stream.WriteShort n
End Function

Rem
bbdoc: Write an Int to a stream
about: #WriteInt writes 4 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteInt( stream:TStream,n:Int )
	stream.WriteInt n
End Function

Rem
bbdoc: Write a Long to a stream
about: #WriteLong writes 8 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteLong( stream:TStream,n:Long )
	stream.WriteLong n
End Function

Rem
bbdoc: Write a Float to a stream
about: #WriteFloat writes 4 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteFloat( stream:TStream,n# )
	stream.WriteFloat n
End Function

Rem
bbdoc: Write a Double to a stream
about: #WriteDouble writes 8 bytes to @stream.
A TStreamWriteException is thrown if not all bytes could be written
End Rem
Function WriteDouble( stream:TStream,n! )
	stream.WriteDouble n
End Function

Rem
bbdoc: Read a String from a stream
returns: A String of length @length
about:
A #TStreamReadException is thrown if not all bytes could be read.
end rem
Function ReadString$( stream:TStream,length:Int )
	Return stream.ReadString( length )
End Function

Rem
bbdoc: Write a String to a stream
about:
Each character in @str is written to @stream.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function WriteString( stream:TStream,str$ )
	stream.WriteString str
End Function

Rem
bbdoc: Read a line of text from a stream
returns: A string
about: 
Bytes are read from @stream until a newline character (ascii code 10) or null
character (ascii code 0) is read, or end of file is detected.

Carriage Return characters (ascii code 13) are silently ignored.

The bytes read are returned in the form of a string, excluding any terminating newline
or null character.
End Rem
Function ReadLine$( stream:TStream )
	Return stream.ReadLine()
End Function

Rem
bbdoc: Write a line of text to a stream
returns: True if line successfully written, else False
about:
A sequence of bytes is written to the stream (one for each character in @str)
followed by the line terminating sequence "~r~n".
End Rem
Function WriteLine:Int( stream:TStream,str$ )
	Return stream.WriteLine( str )
End Function

Rem
bbdoc: Load a String from a stream
returns: A String
about:
The specified @url is opened for reading, and each byte in the resultant stream 
(until eof of file is reached) is read into a string.

A #TStreamReadException is thrown if the stream could not be read.
End Rem
Function LoadString$( url:Object )
	Local t:Byte[]=LoadByteArray(url)
	Return String.FromBytes( t,t.length )
End Function

Rem
bbdoc: Save a String to a stream
about:
The specified @url is opened For writing, and each character of @str is written to the
resultant stream.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function SaveString( str$,url:Object )
	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	Local t:Byte Ptr=str.ToCString()
	stream.WriteBytes t,str.length	'Should be in a try block...or t is leaked!
	MemFree t
	stream.Close
End Function

Function LoadObject:Object( url:Object )
	Local stream:TStream=ReadStream( url )
	If Not stream Throw New TStreamReadException
	Local obj:Object=stream.ReadObject()
	stream.Close
	Return obj
End Function

Function SaveObject( obj:Object,url:Object )
	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	stream.WriteObject obj
	stream.Close
End Function

Rem
bbdoc: Load a Byte array from a stream
returns: A Byte array
about:
The specified @url is opened for reading, and each byte in the resultant stream 
(until eof of reached) is read into a byte array.
End Rem
Function LoadByteArray:Byte[]( url:Object )
	Local stream:TStream=ReadStream( url )
	If Not stream Throw New TStreamReadException
	Local data:Byte[1024],size:Int
	While Not stream.Eof()
		If size=data.length data=data[..size*3/2]
		size:+stream.Read( (Byte Ptr data)+size,data.length-size )
	Wend
	stream.Close
	Return data[..size]
End Function

Rem
bbdoc: Save a Byte array to a stream
about:
The specified @url is opened For writing, and each element of @byteArray is written to the
resultant stream.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function SaveByteArray( byteArray:Byte[],url:Object )
	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	stream.WriteBytes byteArray,byteArray.length
	stream.Close
End Function

Rem
bbdoc: Copy stream contents to another stream
about: 
#CopyStream copies bytes from @fromStream to @toStream Until @fromStream reaches end
of file.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function CopyStream( fromStream:TStream,toStream:TStream,bufSize:Int=4096 )
	Assert bufSize>0
	Local buf:Byte[bufSize]
	While Not fromStream.Eof()
		toStream.WriteBytes buf,fromStream.Read( buf,bufSize )
	Wend
End Function

Rem
bbdoc: Copy bytes from one stream to another
about:
#CopyBytes copies @count bytes from @fromStream to @toStream.

A #TStreamReadException is thrown if not all bytes could be read, and a
#TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function CopyBytes( fromStream:TStream,toStream:TStream,count:Int,bufSize:Int=4096 )
	Assert count>=0 And bufSize>0
	Local buf:Byte[bufSize]
	While count
		Local n:Int=Min(count,bufSize)
		fromStream.ReadBytes buf,n
		toStream.WriteBytes buf,n
		count:-n
	Wend
End Function

Rem
bbdoc: Returns a case sensitive filename if it exists from a case insensitive file path.
End Rem
Function CasedFileName$(path$)
	Local	dir:Byte Ptr
	Local   sub$,s$,f$,folder$,p:Int
	Local	Mode:Int,size:Long,mtime:Int,ctime:Int
        
	If stat_( path,Mode,size,mtime,ctime )=0
		Mode:&S_IFMT_
		If Mode=S_IFREG_ Or Mode=S_IFDIR_ Return path
	EndIf
	folder$="."
	For p=Len(path)-2 To 0 Step -1
		If path[p]=47 Exit
	Next
	If p>0
		sub=path[0..p]
		sub=CasedFileName(sub)
		If Not sub Then
			Return Null
		End If
		path=path$[Len(sub)+1..]
		folder$=sub
	EndIf
	s=path.ToLower()
	dir=opendir_(folder)
	If dir
		While True
			f=readdir_(dir)
			If Not f Exit
			If s=f.ToLower()
				If sub f=sub+"/"+f
				closedir_(dir)
				Return f
			EndIf
		Wend
		closedir_(dir)
	EndIf
End Function

Rem
bbdoc: Opens a file for output operations.
End Rem
Const WRITE_MODE_OVERWRITE:Int = 1
Rem 
bbdoc: Opens a file for appending with all output operations writing data at the end of the file.
about: Repositioning operations such as #Seek affects the next input operations, but output operations move the position back to the end of file.
End Rem
Const WRITE_MODE_APPEND:Int = 2


Type TIOStream Extends TFileStream

	Method Pos:Long() Override
		Return _pos
	End Method

	Method Size:Long() Override
		Return _size
	End Method

	Method Seek:Long( pos:Long, whence:Int = SEEK_SET_ ) Override
		Assert _stream Else "Attempt to seek closed stream"
		'fseek_ _cstream,pos,whence
		Local newPos:Long = pos
		If whence = SEEK_END_ Then
			newPos = _size
		Else If whence = SEEK_CUR_ Then
			newPos = _pos + pos
		End If
		PHYSFS_seek(_stream, newPos)

		_pos = PHYSFS_tell(_stream)
		Return _pos
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		Assert _stream Else "Attempt to read from closed stream"
		Assert _mode & MODE_READ Else "Attempt to read from write-only stream"
		count=PHYSFS_readBytes(_stream, buf,ULong(count))	
		_pos:+count
		Return count
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		Assert _stream Else "Attempt to write to closed stream"
		Assert _mode & (MODE_WRITE | MODE_APPEND) Else "Attempt to write to read-only stream"
		count=PHYSFS_writeBytes(_stream, buf, ULong(count))
		_pos:+count
		If _pos>_size _size=_pos
		Return count
	End Method

	Method Flush() Override
		If _stream PHYSFS_flush(_stream)
	End Method

	Method Close() Override
		If Not _stream Return
		Flush
		PHYSFS_close(_stream)
		_pos=0
		_size=0
		_stream=Null
	End Method

	Method SetSize:Int(size:Long) Override
		Return 0
	End Method

	Function OpenFile:TIOStream( path$,readable:Int,writeMode:Int )
		Local Mode$,_mode:Int
		Mode = GetMode(readable, writeMode, _mode)
		path=path.Replace( "\","/" )
		
		Local stream:Byte Ptr
		If _mode & MODE_APPEND Then
			stream = bmx_PHYSFS_openAppend(path)
		Else If _mode & MODE_WRITE Then
			stream = bmx_PHYSFS_openWrite(path)
		Else
			stream = bmx_PHYSFS_openRead(path)
			If stream
				PHYSFS_setBuffer(stream, 4096)
			End If
		End If

'?Linux
'		If (Not cstream) And (Not writeMode)
'			path=CasedFileName(path)
'			If path cstream=fopen_( path,Mode )
'		EndIf
'?
		If stream Return CreateWithIOStream( stream,_mode )
	End Function

	Function CreateWithIOStream:TIOStream( _stream:Byte Ptr,Mode:Int )
		Local stream:TIOStream=New TIOStream
		stream._stream=_stream
		stream._pos=PHYSFS_tell( _stream )
		stream._size=PHYSFS_fileLength(_stream)
		stream._mode=Mode
		Return stream
	End Function

End Type
