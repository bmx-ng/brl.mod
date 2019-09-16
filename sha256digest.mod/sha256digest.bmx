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
bbdoc: SHA-256 Digest
End Rem
Module BRL.SHA256Digest

Import "common.bmx"

New TSHA256DigestRegister

Rem
bbdoc: An SHA-256 message digest.
End Rem
Type TSHA256 Extends TMessageDigest

	Method New()
		digestPtr = bmx_digest_sha256_init()
	End Method

	Method OutBytes:Int()
		Return 32
	End Method
	
	Rem
	bbdoc: Updates the hash with @dataLen bytes of data.
	End Rem
	Method Update:Int(data:Byte Ptr, dataLen:Int)
		Return bmx_digest_sha256_process(digestPtr, data, dataLen)
	End Method
	
	Rem
	bbdoc: Finishes hashing and produces the digest, filling @digest with the hashed bytes.
	about: The hashing state is reset, ready to create a new digest.
	End Rem
	Method Finish:Int(digest:Byte[])
		Assert digest.length >= 32, "Byte array must be at least 32 bytes."
		Return bmx_digest_sha256_done(digestPtr, digest)
	End Method

End Type

Type TSHA256DigestRegister Extends TDigestRegister

	Method GetDigest:TMessageDigest( name:String ) Override
		name = name.ToUpper()
		If name = "SHA256" Or name = "SHA-256" Then
			Return New TSHA256
		End If
	End Method

End Type
