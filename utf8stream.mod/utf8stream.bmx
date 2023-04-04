' Copyright (c) 2023 Bruce A Henderson
'
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
'    1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
' 
'    2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
' 
'    3. This notice may not be removed or altered from any source
'    distribution.
' 
SuperStrict

Rem
bbdoc: Converts a stream of one encoding to a stream of UTF8 bytes.
End Rem
Module BRL.UTF8Stream

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: 2023 Bruce A Henderson"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release"

Import BRL.Stream

Rem
bbdoc: Supported encodings.
about: Only a few of the most common encodings are provided in BRL.UTF8Stream.
More encodings are available in the Text.Encoding module.
End Rem
Enum EStreamEncoding
    UTF16
    WINDOWS_1252
	CP1252=WINDOWS_1252
	ISO_8859_1
	LATIN1=ISO_8859_1
	
	WINDOWS_1250
	CP1250=WINDOWS_1250
	WINDOWS_1251
	CP1251=WINDOWS_1251
	WINDOWS_1253
	CP1253=WINDOWS_1253
	WINDOWS_1254
	CP1254=WINDOWS_1254
	WINDOWS_1255
	CP1255=WINDOWS_1255
	WINDOWS_1256
	CP1256=WINDOWS_1256
	WINDOWS_1257
	CP1257=WINDOWS_1257
    ISO_8859_2
    ISO_8859_5
    ISO_8859_6
    ISO_8859_7
    ISO_8859_8
    ISO_8859_9
    ISO_8859_15
End Enum

Rem
bbdoc: This class wraps a stream and converts its contents to UTF8.
```blitzmax
	' Create a stream that reads from a file and converts its contents to UTF8.
	Local stream:TStream = New TEncodingToUTF8Stream(ReadStream("test.txt"), EStreamEncoding.LATIN1)
	' Read the first 10 bytes from the stream.
	Local StaticArray buf:Byte[10]
	stream.ReadBytes(buf, 10)
	' Print the bytes to the console.
	Print buf
```
End Rem
Type TEncodingToUTF8Stream Extends TStreamWrapper
	Field encodingStrategy:IEncodingStrategy
	Field remainingUTF8Char:SUTF8Char ' Store remaining bytes and their count

	Method New(stream:TStream, encoding:EStreamEncoding)
		_stream = stream
	
		Local loader:TEncodingStrategyLoader=utf8stream_strategies
	
		While loader
			If loader.Encoding()=encoding Then
				encodingStrategy=loader.Load(stream)
				Return
			End If
			
			loader=loader._succ
		Wend

		Throw New TEncodingNotAvailableException(encoding)

	End Method
	
	Method Read:Long(buf:Byte Ptr, count:Long) Override

		Local bytesRead:Long = 0

		' Process remaining bytes from the previous call (if any)
		While remainingUTF8Char.count > 0 And bytesRead < count
			buf[0] = remainingUTF8Char.bytes[0]
			buf :+ 1
			bytesRead :+ 1
			remainingUTF8Char.bytes[0] = remainingUTF8Char.bytes[1]

			If remainingUTF8Char.count > 1 Then
				remainingUTF8Char.bytes[1] = remainingUTF8Char.bytes[2]

				If remainingUTF8Char.count > 2 Then
					remainingUTF8Char.bytes[2] = remainingUTF8Char.bytes[3]
				End if
			End if

			remainingUTF8Char.count :- 1
		Wend

		' Local utf8Char:SUTF8Char
	
		While bytesRead < count
			encodingStrategy.ReadEncodedChar(remainingUTF8Char)
	
			If remainingUTF8Char.count = 0 Then Exit ' End of input reached
	
			If bytesRead + remainingUTF8Char.count <= count Then
				For Local i:Int = 0 Until remainingUTF8Char.count
					buf[0] = remainingUTF8Char.bytes[i]
					buf :+ 1
					bytesRead :+ 1
				Next
				remainingUTF8Char.count = 0 ' Reset remainingUTF8Char count
			Else
				' Store the remaining bytes and their count
                Exit
			End If
		Wend
	
		Return bytesRead
	End Method
End Type



Struct SUTF8Char
    Field StaticArray bytes:Byte[4]
    Field count:Int
End Struct

Interface IEncodingStrategy
    Method ReadEncodedChar(utf8Char:SUTF8Char Var)
End Interface

Interface IEncodingStrategyLoader
	Method Encoding:EStreamEncoding()
	Method Load:IEncodingStrategy(stream:TStream)
End Interface

Private

Global utf8stream_strategies:TEncodingStrategyLoader

Public

Type TEncodingStrategyLoader Implements IEncodingStrategyLoader Abstract
	Field _succ:TEncodingStrategyLoader
	
	Method New()
		_succ=utf8stream_strategies
		utf8stream_strategies=Self
	End Method
End Type

Type TEncodingStrategyLoaderUTF16 Extends TEncodingStrategyLoader
	Method Encoding:EStreamEncoding()
		Return EStreamEncoding.UTF16
	End Method

	Method Load:IEncodingStrategy(stream:TStream)
		Return New TUTF16EncodingStrategy(stream)
	End Method
End Type

New TEncodingStrategyLoaderUTF16


Type TUTF16EncodingStrategy Implements IEncodingStrategy
    Field stream:TStream

    Method New(sourceStream:TStream)
        stream = sourceStream
    End Method

    Method ReadEncodedChar(utf8Char:SUTF8Char Var)
        Local StaticArray buf:Short[1]
        If stream.ReadShort(buf) = 0 Then
            utf8Char.count = 0
            Return
        End If

        Local unicodeChar:Int = buf[0]

        If unicodeChar < 128 Then
            utf8Char.bytes[0] = Byte(unicodeChar)
            utf8Char.count = 1
        ElseIf unicodeChar < 2048 Then
            utf8Char.bytes[0] = Byte(192 | (unicodeChar Shr 6))
            utf8Char.bytes[1] = Byte(128 | (unicodeChar & 63))
            utf8Char.count = 2
        Else
            utf8Char.bytes[0] = Byte(224 | (unicodeChar Shr 12))
            utf8Char.bytes[1] = Byte(128 | ((unicodeChar Shr 6) & 63))
            utf8Char.bytes[2] = Byte(128 | (unicodeChar & 63))
            utf8Char.count = 3
        End If
    End Method
End Type

Rem
bbdoc: Thrown when an encoding is not available.
End Rem
Type TEncodingNotAvailableException Extends TBlitzException

	Field encoding:EStreamEncoding

	Method New(encoding:EStreamEncoding)
		Self.encoding = encoding
	End Method

	Method ToString:String()
		Return "Support for encoding " + encoding.ToString() + " has not been imported."
	End Method
End Type

Rem
bbdoc: Base class for encoding strategies that use a single byte to represent a character.
End Rem
Type TBaseSingleByteEncodingStrategy Implements IEncodingStrategy Abstract
    Field stream:TStream
	Field StaticArray encodingTable:Short[128]

    Method New(sourceStream:TStream)
        stream = sourceStream
    End Method

	Method LoadTable(table:Short Ptr) Abstract

	Method LoadMapping()
		LoadTable(encodingTable)
	End Method

	Method ReadEncodedChar(utf8Char:SUTF8Char Var) Override

		Local StaticArray buf:Byte[1]
        If stream.Read(buf, 1) = 0 Then
            utf8Char.count = 0
            Return
        End If

        Local unicodeChar:Int = buf[0]

        If unicodeChar < 128
			utf8Char.bytes[0] = unicodeChar
			utf8Char.count = 1
		Else
			EncodeSingleByteToUTF8(utf8Char, encodingTable[unicodeChar - 128])
		End If

    End Method

    Method EncodeSingleByteToUTF8(utf8Char:SUTF8Char Var, c:Short)

		If c = 0 Then
			utf8Char.count = 0
		Else If c < 128
			utf8Char.bytes[0] = c
			utf8Char.count = 1
		Else If c < 2048 Then
            utf8Char.bytes[0] = ((c Shr 6) & 31) | 192
            utf8Char.bytes[1] = (c & 63) | 128
			utf8Char.count = 2
        Else
            utf8Char.bytes[0] = ((c Shr 12) & 15) | 224
            utf8Char.bytes[1] = ((c Shr 6) & 63) | 128
            utf8Char.bytes[2] = (c & 63) | 128
			utf8Char.count = 3
        End If

    End Method

End Type


Type TEncodingStrategyLoaderWindows1252 Extends TEncodingStrategyLoader
	Method Encoding:EStreamEncoding()
		Return EStreamEncoding.WINDOWS_1252
	End Method

	Method Load:IEncodingStrategy(stream:TStream)
		Return New TWindows1252EncodingStrategy(stream)
	End Method
End Type

New TEncodingStrategyLoaderWindows1252

Rem
bbdoc: An encoding strategy for Windows-1252.
End Rem
Type TWindows1252EncodingStrategy Extends TBaseSingleByteEncodingStrategy
    Method New(sourceStream:TStream)
        stream = sourceStream
        LoadMapping()
    End Method

	Method LoadTable(table:Short Ptr)
		Global encodingTable:Short[]
		If Not encodingTable Then
            encodingTable = [..
				$20AC:Short, $FFFD:Short, $201A:Short, $0192:Short, $201E:Short, $2026:Short, $2020:Short, $2021:Short, $02C6:Short, $2030:Short, $0160:Short, $2039:Short, $0152:Short, $FFFD:Short, $017D:Short, $FFFD:Short,..
				$FFFD:Short, $2018:Short, $2019:Short, $201C:Short, $201D:Short, $2022:Short, $2013:Short, $2014:Short, $02DC:Short, $2122:Short, $0161:Short, $203A:Short, $0153:Short, $FFFD:Short, $017E:Short, $0178:Short,..
				$00A0:Short, $00A1:Short, $00A2:Short, $00A3:Short, $00A4:Short, $00A5:Short, $00A6:Short, $00A7:Short, $00A8:Short, $00A9:Short, $00AA:Short, $00AB:Short, $00AC:Short, $00AD:Short, $00AE:Short, $00AF:Short,..
				$00B0:Short, $00B1:Short, $00B2:Short, $00B3:Short, $00B4:Short, $00B5:Short, $00B6:Short, $00B7:Short, $00B8:Short, $00B9:Short, $00BA:Short, $00BB:Short, $00BC:Short, $00BD:Short, $00BE:Short, $00BF:Short,..
				$00C0:Short, $00C1:Short, $00C2:Short, $00C3:Short, $00C4:Short, $00C5:Short, $00C6:Short, $00C7:Short, $00C8:Short, $00C9:Short, $00CA:Short, $00CB:Short, $00CC:Short, $00CD:Short, $00CE:Short, $00CF:Short,..
				$00D0:Short, $00D1:Short, $00D2:Short, $00D3:Short, $00D4:Short, $00D5:Short, $00D6:Short, $00D7:Short, $00D8:Short, $00D9:Short, $00DA:Short, $00DB:Short, $00DC:Short, $00DD:Short, $00DE:Short, $00DF:Short,..
				$00E0:Short, $00E1:Short, $00E2:Short, $00E3:Short, $00E4:Short, $00E5:Short, $00E6:Short, $00E7:Short, $00E8:Short, $00E9:Short, $00EA:Short, $00EB:Short, $00EC:Short, $00ED:Short, $00EE:Short, $00EF:Short,..
				$00F0:Short, $00F1:Short, $00F2:Short, $00F3:Short, $00F4:Short, $00F5:Short, $00F6:Short, $00F7:Short, $00F8:Short, $00F9:Short, $00FA:Short, $00FB:Short, $00FC:Short, $00FD:Short, $00FE:Short, $00FF:Short]			
		End If

		For Local i:Int = 0 To 127
			table[i] = encodingTable[i]
		Next
	End Method
End Type

Type TEncodingStrategyLoaderISO_8859_1 Extends TEncodingStrategyLoader
	Method Encoding:EStreamEncoding()
		Return EStreamEncoding.ISO_8859_1
	End Method

	Method Load:IEncodingStrategy(stream:TStream)
		Return New TISO_8859_1_EncodingStrategy(stream)
	End Method
End Type

New TEncodingStrategyLoaderISO_8859_1

Rem
bbdoc: An encoding strategy for ISO-8859-1.
End Rem
Type TISO_8859_1_EncodingStrategy Extends TBaseSingleByteEncodingStrategy
    Method New(sourceStream:TStream)
        stream = sourceStream
        LoadMapping()
    End Method

	Method LoadTable(table:Short Ptr)
		For Local i:Int = 0 To 127
			table[i] = i + 128
		Next
	End Method
End Type
