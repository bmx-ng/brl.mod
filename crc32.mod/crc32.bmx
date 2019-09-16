'
'  Copyright (C) 2019 Bruce A Henderson
'
'  This software is provided 'as-is', without any express or implied
'  warranty.  In no event will the authors be held liable for any damages
'  arising from the use of this software.
'
'  Permission is granted to anyone to use this software for any purpose,
'  including commercial applications, and to alter it and redistribute it
'  freely, subject to the following restrictions:
'
'  1. The origin of this software must not be misrepresented; you must not
'     claim that you wrote the original software. If you use this software
'     in a product, an acknowledgment in the product documentation would be
'     appreciated but is not required.
'  2. Altered source versions must be plainly marked as such, and must not be
'     misrepresented as being the original software.
'  3. This notice may not be removed or altered from any source distribution.
'
SuperStrict

Rem
bbdoc: CRC32 Redundency check
End Rem
Module BRL.CRC32
Import brl.standardio
Import "common.bmx"

New TCRC32Register

Rem
bbdoc: A CRC32 function.
End Rem
Type TCRC32 Extends TMessageDigest

	Method New()
		digestPtr = bmx_digest_crc32_init()
	End Method

	Method OutBytes:Int()
		Return 4
	End Method
	
	Rem
	bbdoc: Updates the calculation with @dataLen bytes of data.
	End Rem
	Method Update:Int(data:Byte Ptr, dataLen:Int)
		bmx_digest_crc32_update(digestPtr, data, dataLen)
	End Method

	Rem
	bbdoc: Calculates the CRC for the given #String, setting the value in @result.
	End Rem
	Method Digest(txt:String, result:Int Var)
		Local buf:Byte Ptr = txt.ToUTF8String()
		Update(buf, Int(strlen_(buf)))
		MemFree(buf)
		Finish(result)
	End Method

	Rem
	bbdoc: Calculates the CRC for the given #TStream, setting the value in @result.
	End Rem
	Method Digest(stream:TStream, result:Int Var)
		Local buf:Byte[8192]
		
		Local bytesRead:Long
		Repeat
			bytesRead = stream.Read(buf, buf.length)
			If bytesRead Then
				Update(buf, Int(bytesRead))
			End If
		Until bytesRead <= 0

		If Not bytesRead Then
			Finish(result)
		End If
	End Method

	Rem
	bbdoc: Finishes calculation and produces the result, filling @result with the calculated bytes.
	about: The state is reset, ready to create a new calculation.
	End Rem
	Method Finish:Int(result:Byte[])
		Assert result.length >= 4, "Byte array must be at least 4 bytes."
		bmx_digest_crc32_finish(digestPtr, result, 4)
	End Method
	
	Rem
	bbdoc: Finishes calculation and produces the result, setting @result with the result.
	about: The state is reset, ready to create a new calculation.
	End Rem
	Method Finish:Int(result:Int Var)
		bmx_digest_crc32_finish_int(digestPtr, result)
	End Method

End Type

Type TCRC32Register Extends TDigestRegister

	Method GetDigest:TMessageDigest( name:String ) Override
		If name.ToUpper() = "CRC32" Then
			Return New TCRC32
		End If
	End Method

End Type
