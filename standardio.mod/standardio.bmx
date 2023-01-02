
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

Import BRL.TextStream

Type TCStandardIO Extends TStream

	Method Eof:Int() Override
		Return feof_( stdin_ )
	End Method
	
	Method Flush() Override
		fflush_ stdout_
	End Method

	Method Read:Long( buf:Byte Ptr,count:Long ) Override
		Return fread_( buf,1,count,stdin_ )
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		Return fwrite_( buf,1,count,stdout_ )
	End Method

End Type

Type TCStandardErrIO Extends TStream

	Method Flush() Override
		fflush_ stderr_
	End Method

	Method Write:Long( buf:Byte Ptr,count:Long ) Override
		Return fwrite_( buf,1,count,stderr_ )
	End Method

End Type

Rem
bbdoc: BlitzMax Stream object used for Print and Input
about: The #Print and #Input commands can be redirected by setting the @StandardIOStream Global to an alternative Stream Object.
End Rem
Global StandardIOStream:TStream=TTextStream.Create( New TCStandardIO,ETextStreamFormat.UTF8 )

Rem
bbdoc: BlitzMax Stream object used for #ErrPrint
End Rem
Global StandardErrIOStream:TStream=TTextStream.Create( New TCStandardErrIO,ETextStreamFormat.UTF8 )

Rem
bbdoc: Write a string to the standard errIO stream
about: A newline character is also written after @str.
End Rem
Function Print( str$="" )
	StandardIOStream.WriteLine str
	StandardIOStream.Flush
End Function

Rem
bbdoc: Write a string to the standard error IO stream
about: A newline character is also written after @str.
End Rem
Function ErrPrint( str$="" )
	StandardErrIOStream.WriteLine str
	StandardErrIOStream.Flush
End Function

Rem
bbdoc: Receive a line of text from the standard IO stream
about: The optional @prompt is displayed before input is returned.
End Rem
Function Input$( prompt$=">" )
	StandardIOStream.WriteString prompt
	StandardIOStream.Flush
    Return StandardIOStream.ReadLine()
End Function
