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
bbdoc: SHA-512 Digest
End Rem
Module BRL.SHA512Digest

Import "common.bmx"

New TSHA512DigestRegister

Rem
bbdoc: An SHA-512 message digest.
End Rem
Type TSHA512 Extends TMessageDigest

	Method New()
		digestPtr = bmx_digest_SHA512_init()
	End Method

	Method OutBytes:Int()
		Return 64
	End Method
	
	Rem
	bbdoc: Updates the hash with @dataLen bytes of data.
	End Rem
	Method Update:Int(data:Byte Ptr, dataLen:Int)
		Return bmx_digest_SHA512_process(digestPtr, data, dataLen)
	End Method
	
	Rem
	bbdoc: Finishes hashing and produces the digest, filling @digest with the hashed bytes.
	about: The hashing state is reset, ready to create a new digest.
	End Rem
	Method Finish:Int(digest:Byte[])
		Assert digest.length >= 64, "Byte array must be at least 64 bytes."
		Return bmx_digest_SHA512_done(digestPtr, digest)
	End Method

End Type

Type TSHA512DigestRegister Extends TDigestRegister

	Method GetDigest:TMessageDigest( name:String ) Override
		name = name.ToUpper()
		If name = "SHA512" Or name = "SHA-512" Then
			Return New TSHA512
		End If
	End Method

End Type
