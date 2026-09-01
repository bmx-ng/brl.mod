
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

?pico
Import BRL.Stream

Extern "C"
	Function PicoStandardIOInit:Int() = "bmx_pico_stdio_init_all"
	Function PicoStandardIORead:Long(buffer:Byte Ptr, count:Long) = "bmx_pico_stdio_read"
	Function PicoStandardIOWrite:Long(buffer:Byte Ptr, count:Long) = "bmx_pico_stdio_write"
	Function PicoStandardIOFlush() = "bmx_pico_stdio_flush"
End Extern
?Not pico
Import BRL.TextStream
?

Type TCStandardIO Extends TStream

	Method Eof:Int() Override
?pico
		Return False
?Not pico
		Return feof_( stdin_ )
?
	End Method
	
	Method Flush() Override
?pico
		PicoStandardIOFlush()
?Not pico
		fflush_ stdout_
?
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
?pico
		Return PicoStandardIORead(buf, count)
?Not pico
		Return fread_( buf,1,Size_T(count),stdin_ )
?
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
?pico
		Return PicoStandardIOWrite(buf, count)
?Not pico
		Return fwrite_( buf,1,Size_T(count),stdout_ )
?
	End Method

?pico
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
?pico
		PicoStandardIOFlush()
?Not pico
		fflush_ stderr_
?
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
?pico
		Return PicoStandardIOWrite(buf, count)
?Not pico
		Return fwrite_( buf,1,Size_T(count),stderr_ )
?
	End Method

?pico
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
?pico
Private
Global picoStandardIOInitialized:Int = PicoStandardIOInit()
Public
Global StandardIOStream:TStream = New TCStandardIO
?Not pico
Global StandardIOStream:TStream=TTextStream.Create( New TCStandardIO,ETextStreamFormat.UTF8 )
?

Rem
bbdoc: BlitzMax Stream object used for #ErrPrint
End Rem
?pico
Global StandardErrIOStream:TStream = New TCStandardErrIO
?Not pico
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
