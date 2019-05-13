
SuperStrict

Rem
bbdoc: Streams/Text streams
about:
The Text Stream module allows you to load and save text in a number
of formats: LATIN1, UTF8 and UTF16.

The LATIN1 format uses a single byte to represent each character, and 
is therefore only capable of manipulating 256 distinct character values.

The UTF8 and UTF16 formats are capable of manipulating up to 1114112
character values, but will generally use greater storage space. In addition,
many text processing applications are unable to handle UTF8 and UTF16 files.
End Rem
Module BRL.TextStream

ModuleInfo "Version: 1.04"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.04"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.03 Release"
ModuleInfo "History: Modified LoadText to handle stream URLs"
ModuleInfo "History: 1.02 Release"
ModuleInfo "History: Added LoadText, SaveText"
ModuleInfo "History: Fixed UTF16LE=4"
ModuleInfo "History: 1.01 Release"
ModuleInfo "History: 1.00 Release"
ModuleInfo "History: Added TextStream module"

Import BRL.Stream

Enum ETextStreamFormat
	LATIN1
	UTF8
	UTF16BE
	UTF16LE
End Enum

Type TTextStream Extends TStreamWrapper

	' deprecated
	Const LATIN1:Int = 1
	Const UTF8:Int = 2
	Const UTF16BE:Int = 3
	Const UTF16LE:Int = 4

	'***** PUBLIC *****

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		For Local i:Long=0 Until count
			If _bufcount=32 _FlushRead
			Local hi:Int=_ReadByte()
			Local lo:Int=_ReadByte()
			hi:-48;If hi>9 hi:-7
			lo:-48;If lo>9 lo:-7
			buf[i]=hi Shl 4 | lo
			_bufcount:+1
		Next
		Return count
	End Method
	
	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		For Local i:Long=0 Until count
			Local hi:Int=buf[i] Shr 4
			Local lo:Int=buf[i] & $f
			hi:+48;If hi>57 hi:+7
			lo:+48;If lo>57 lo:+7
			_WriteByte hi
			_WriteByte lo
			_bufcount:+1
			If _bufcount=32 _FlushWrite
		Next
		Return count
	End Method
	
	Method ReadByte:Int() Override
		_FlushRead
		Return Int( ReadLine() )
	End Method
	
	Method WriteByte( n:Int ) Override
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadShort:Int() Override
		_FlushRead
		Return Int( ReadLine() )
	End Method
	
	Method WriteShort( n:Int ) Override
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadInt:Int() Override
		_FlushRead
		Return Int( ReadLine() )
	End Method
	
	Method WriteInt( n:Int ) Override
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadLong:Long() Override
		_FlushRead
		Return Long( ReadLine() )
	End Method
	
	Method WriteLong( n:Long ) Override
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadFloat:Float() Override
		_FlushRead
		Return Float( ReadLine() )
	End Method
	
	Method WriteFloat( n:Float ) Override
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadDouble:Double() Override
		_FlushRead
		Return Double( ReadLine() )
	End Method
	
	Method WriteDouble( n:Double ) Override
		_FlushWrite
		WriteLine n
	End Method
	
	Method ReadLine$() Override
		_FlushRead
		Local buf:Short[1024],i:Int
		While Not Eof()
			Local n:Int=ReadChar()
			If n=0 Exit
			If n=10 Exit
			If n=13 Continue
			If buf.length=i buf=buf[..i+1024]
			buf[i]=n
			i:+1
		Wend
		Return String.FromShorts(buf,i)
	End Method
	
	Method ReadFile$()
		_FlushRead
		Local buf:Short[1024],i:Int
		While Not Eof()
			Local n:Int=ReadChar()
			If buf.length=i buf=buf[..i+1024]
			buf[i]=n
			i:+1
		Wend
		Return String.FromShorts( buf,i )
	End Method
	
	Method WriteLine:Int( str$ ) Override
		_FlushWrite
		WriteString str
		WriteString "~r~n"
	End Method
	
	Method ReadString$( length:Int ) Override
		_FlushRead
		Local buf:Short[length]
		For Local i:Int=0 Until length
			buf[i]=ReadChar()
		Next
		Return String.FromShorts(buf,length)
	End Method
	
	Method WriteString( str$ ) Override
		_FlushWrite
		For Local i:Int=0 Until str.length
			WriteChar str[i]
		Next
	End Method
	
	Method ReadChar:Int()
		Local c:Int=_ReadByte()
		Select _encoding
		Case ETextStreamFormat.LATIN1
			Return c
		Case ETextStreamFormat.UTF8
			If c<128 Return c
			Local d:Int=_ReadByte()
			If c<224 Return (c-192)*64+(d-128)
			Local e:Int=_ReadByte()
			If c<240 Return (c-224)*4096+(d-128)*64+(e-128)
		Case ETextStreamFormat.UTF16BE
			Local d:Int=_ReadByte()
			Return c Shl 8 | d
		Case ETextStreamFormat.UTF16LE
			Local d:Int=_ReadByte()
			Return d Shl 8 | c
		End Select
	End Method
	
	Method WriteChar( char:Int )
		Assert char>=0 And char<=$ffff
		Select _encoding
		Case ETextStreamFormat.LATIN1
			_WriteByte char
		Case ETextStreamFormat.UTF8
			If char<128
				_WriteByte char
			Else If char<2048
				_WriteByte char/64 | 192
				_WriteByte char Mod 64 | 128
			Else
				_WriteByte char/4096 | 224
				_WriteByte char/64 Mod 64 | 128
				_WriteByte char Mod 64 | 128
			EndIf
		Case ETextStreamFormat.UTF16BE
			_WriteByte char Shr 8
			_WriteByte char
		Case ETextStreamFormat.UTF16LE
			_WriteByte char
			_WriteByte char Shr 8
		End Select
	End Method

	Function Create:TTextStream( stream:TStream,encoding:Int )
		Local enc:ETextStreamFormat
		Select encoding
			Case LATIN1
				enc = ETextStreamFormat.LATIN1
			Case UTF8
				enc = ETextStreamFormat.UTF8
			Case UTF16BE
				enc = ETextStreamFormat.UTF16BE
			Case UTF16LE
				enc = ETextStreamFormat.UTF16LE
		End Select
		Return Create(stream, enc)
	End Function
	
	Function Create:TTextStream( stream:TStream,encoding:ETextStreamFormat )
		Local t:TTextStream=New TTextStream
		t._encoding=encoding
		t.SetStream stream
		Return t
	End Function

	'***** PRIVATE *****
	
	Method _ReadByte:Int()
		Return Super.ReadByte()
	End Method
	
	Method _WriteByte( n:Int )
		Super.WriteByte n
	End Method
	
	Method _FlushRead()
		If Not _bufcount Return
		Local n:Int=_ReadByte()
		If n=13 n=_ReadByte()
		If n<>10 Throw "Malformed line terminator"
		_bufcount=0
	End Method
	
	Method _FlushWrite()
		If Not _bufcount Return
		_WriteByte 13
		_WriteByte 10
		_bufcount=0
	End Method
	
	Field _encoding:ETextStreamFormat
	Field _bufcount:Int
	
End Type
	
Type TTextStreamFactory Extends TStreamFactory

	Method CreateStream:TStream( url:Object,proto$,path$,readable:Int,writeable:Int ) Override
		Local encoding:ETextStreamFormat
		Select proto$
		Case "latin1"
			encoding=ETextStreamFormat.LATIN1
		Case "utf8"
			encoding=ETextStreamFormat.UTF8
		Case "utf16be"
			encoding=ETextStreamFormat.UTF16BE
		Case "utf16le"
			encoding=ETextStreamFormat.UTF16LE
		End Select
		If Not encoding Return Null
		Local stream:TStream=OpenStream( path,readable,writeable )
		If stream Return TTextStream.Create( stream,encoding )
	End Method
End Type

New TTextStreamFactory

Rem
bbdoc: Load text from a stream
returns: A string containing the text
about:
#LoadText loads LATIN1, UTF8 or UTF16 text from @url.

The first bytes read from the stream control the format of the text:
[ &$fe $ff | Text is big endian UTF16
* &$ff $fe | Text is little endian UTF16
* &$ef $bb $bf | Text is UTF8
]

If the first bytes don't match any of the above values, the stream
is assumed to contain LATIN1 text.

A #TStreamReadException is thrown if not all bytes could be read.
End Rem
Function LoadText$( url:Object )

	Local stream:TStream=ReadStream( url )
	If Not stream Throw New TStreamReadException

	Local format:ETextStreamFormat
	Local size:Int,c:Int,d:Int,e:Int

	If Not stream.Eof()
		c=stream.ReadByte()
		size:+1
		If Not stream.Eof()
			d=stream.ReadByte()
			size:+1
			If c=$fe And d=$ff
				format=ETextStreamFormat.UTF16BE
			Else If c=$ff And d=$fe
				format=ETextStreamFormat.UTF16LE
			Else If c=$ef And d=$bb
				If Not stream.Eof()
					e=stream.ReadByte()
					size:+1
					If e=$bf format=ETextStreamFormat.UTF8
				EndIf
			EndIf
		EndIf
	EndIf

	If Not format
		Local data:Byte[1024]
		data[0]=c;data[1]=d;data[2]=e
		While Not stream.Eof()
			If size=data.length data=data[..size*2]
			size:+stream.Read( (Byte Ptr data)+size,data.length-size )
		Wend
		stream.Close
		Return String.FromBytes( data,size )
	EndIf
	
	Local TStream:TTextStream=TTextStream.Create( stream,format )
	Local str$=TStream.ReadFile()
	TStream.Close
	stream.Close
	Return str

End Function

Rem
bbdoc: Save text to a stream
about:
#SaveText saves the characters in @str to @url.

If @str contains any characters with a character code greater than 255,
then @str is saved in UTF16 format. Otherwise, @str is saved in LATIN1 format.

A #TStreamWriteException is thrown if not all bytes could be written.
End Rem
Function SaveText:Int( str$,url:Object, format:ETextStreamFormat = ETextStreamFormat.LATIN1, withBOM:Int = True )

	If format <> ETextStreamFormat.LATIN1 And format <> ETextStreamFormat.UTF8
		For Local i:Int=0 Until str.length
			If str[i]>255
?BigEndian
				format=ETextStreamFormat.UTF16BE
?LittleEndian
				format=ETextStreamFormat.UTF16LE
?
				Exit
			EndIf
		Next
	End If
	
	If format = ETextStreamFormat.LATIN1
		SaveString str,url
		Return True
	EndIf

	Local stream:TStream=WriteStream( url )
	If Not stream Throw New TStreamWriteException
	
	If withBOM Then
		Select format
		Case ETextStreamFormat.UTF8
			stream.WriteByte $ef
			stream.WriteByte $bb
		Case ETextStreamFormat.UTF16BE
			stream.WriteByte $fe
			stream.WriteByte $ff
		Case ETextStreamFormat.UTF16LE
			stream.WriteByte $ff
			stream.WriteByte $fe
		End Select
	End If
	
	Local TStream:TTextStream=TTextStream.Create( stream,format )
	TStream.WriteString str
	TStream.Close
	stream.Close
	Return True

End Function

