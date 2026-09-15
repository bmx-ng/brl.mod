
SuperStrict

Rem
bbdoc: System/StandardIO
End Rem
Module BRL.StandardIO

ModuleInfo "Version: 1.07"
ModuleInfo "Author: Mark Sibly"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.07"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.06"
ModuleInfo "History: Added Eof() method to TCStandardIO"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: 1.04 Release"
ModuleInfo "History: CStandardIO now goes through a UTF8 textstream"

?embedded
Import BRL.Stream

Extern "C"
?pico
	Function EmbeddedStandardIOInit:Int() = "bmx_pico_stdio_init_all"
	Function EmbeddedStandardIORead:Long(buffer:Byte Ptr, count:Long) = "bmx_pico_stdio_read"
	Function EmbeddedStandardIOWrite:Long(buffer:Byte Ptr, count:Long) = "bmx_pico_stdio_write"
	Function EmbeddedStandardIOFlush() = "bmx_pico_stdio_flush"
?esp32
	Function EmbeddedStandardIOInit:Int() = "bmx_esp32_stdio_init_all"
	Function EmbeddedStandardIORead:Long(buffer:Byte Ptr, count:Long) = "bmx_esp32_stdio_read"
	Function EmbeddedStandardIOWrite:Long(buffer:Byte Ptr, count:Long) = "bmx_esp32_stdio_write"
	Function EmbeddedStandardIOFlush() = "bmx_esp32_stdio_flush"
?embedded
End Extern
?Not embedded
Import BRL.TextStream
?

Type TCStandardIO Extends TStream

	Method Eof:Int() Override
?embedded
		Return False
?Not embedded
		Return feof_( stdin_ )
?
	End Method
	
	Method Flush() Override
?embedded
		EmbeddedStandardIOFlush()
?Not embedded
		fflush_ stdout_
?
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
?embedded
		Return EmbeddedStandardIORead(buf, count)
?Not embedded
		Return fread_( buf,1,Size_T(count),stdin_ )
?
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
?embedded
		Return EmbeddedStandardIOWrite(buf, count)
?Not embedded
		Return fwrite_( buf,1,Size_T(count),stdout_ )
?
	End Method

?embedded
	Method ReadLine:String() Override
		Return Super.ReadLine(True)
	End Method

	Method WriteLine:Int(str:String) Override
		Return Super.WriteLine(str, True)
	End Method

	Method WriteString(str:String) Override
		Super.WriteString(str, True)
	End Method
?

End Type

Type TCStandardErrIO Extends TStream

	Method Flush() Override
?embedded
		EmbeddedStandardIOFlush()
?Not embedded
		fflush_ stderr_
?
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
?embedded
		Return EmbeddedStandardIOWrite(buf, count)
?Not embedded
		Return fwrite_( buf,1,Size_T(count),stderr_ )
?
	End Method

?embedded
	Method WriteLine:Int(str:String) Override
		Return Super.WriteLine(str, True)
	End Method

	Method WriteString(str:String) Override
		Super.WriteString(str, True)
	End Method
?

End Type

Rem
bbdoc: BlitzMax Stream object used for Print and Input
about: The #Print and #Input commands can be redirected by setting the @StandardIOStream Global to an alternative Stream Object.
End Rem
?embedded
Private
Global embeddedStandardIOInitialized:Int = EmbeddedStandardIOInit()
Public
Global StandardIOStream:TStream = New TCStandardIO
?Not embedded
Global StandardIOStream:TStream=TTextStream.Create( New TCStandardIO,ETextStreamFormat.UTF8 )
?

Rem
bbdoc: BlitzMax Stream object used for #ErrPrint
End Rem
?embedded
Global StandardErrIOStream:TStream = New TCStandardErrIO
?Not embedded
Global StandardErrIOStream:TStream=TTextStream.Create( New TCStandardErrIO,ETextStreamFormat.UTF8 )
?

Rem
bbdoc: Write a string to the standard errIO stream
about: A newline character is also written after @str.
End Rem
Function Print( str:String="" )
	StandardIOStream.WriteLine str
	StandardIOStream.Flush
End Function

Rem
bbdoc: Write a string to the standard error IO stream
about: A newline character is also written after @str.
End Rem
Function ErrPrint( str:String="" )
	StandardErrIOStream.WriteLine str
	StandardErrIOStream.Flush
End Function

Rem
bbdoc: Receive a line of text from the standard IO stream
about: The optional @prompt is displayed before input is returned.
End Rem
Function Input:String( prompt:String=">" )
	StandardIOStream.WriteString prompt
	StandardIOStream.Flush
    Return StandardIOStream.ReadLine()
End Function
