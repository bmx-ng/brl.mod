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
bbdoc: Message Digests and hashes.
End Rem
Module BRL.Digest

Import "common.bmx"

Rem
bbdoc: Gets a digest of the specified @name.
about: A #TNoSuchAlgorithmException is thrown if the requested digest is not available.
End Rem
Function GeTMessageDigest:TMessageDigest(name:String)
	Local d:TMessageDigest
	Local register:TDigestRegister=digest_registry

	While register
		d=register.GetDigest(name)
		If d Exit
		register = register._succ
	Wend

	If Not d Then
		Throw New TNoSuchAlgorithmException("Digest not available : " + name)
	End If
	Return d
End Function

Rem
bbdoc: This exception is thrown when a particular cryptographic algorithm is requested but is not available in the environment.
End Rem
Type TNoSuchAlgorithmException Extends TBlitzException

	Field message:String

	Method New(message:String)
		Self.message = message
	End Method

	Method ToString:String()
		Return message
	End Method

End Type

Rem
bbdoc: An abstract base type for message digest implementations.
End Rem
Type TMessageDigest

	Field digestPtr:Byte Ptr
	
	Method Update:Int(data:Byte Ptr, dataLen:Int) Abstract
	Method Finish:Int(digest:Byte[]) Abstract
	Method OutBytes:Int() Abstract

	Rem
	bbdoc: Calculates a digest for the given #String input @data.
	returns: A #String representation of the digest.
	End Rem
	Method Digest:String(data:String)
		Return BytesToHex(DigestBytes(data))
	End Method

	Rem
	bbdoc: Calculates a digest for the given #TStream input @stream.
	returns: A #String representation of the digest.
	End Rem
	Method Digest:String(stream:TStream)
		Return BytesToHex(DigestBytes(stream))
	End Method
	
	Rem
	bbdoc: Calculates a digest for the given #String input @data.
	returns: A byte array representation of the digest.
	End Rem
	Method DigestBytes:Byte[](data:String)
		Local buf:Byte Ptr = data.ToUTF8String()
		Update(buf, Int(strlen_(buf)))
		Local res:Byte[OutBytes()]
		Finish(res)
		MemFree(buf)
		Return res
	End Method

	Rem
	bbdoc: Calculates a digest for the given #TStream input @stream.
	returns: A bytes array representation of the digest.
	End Rem
	Method DigestBytes:Byte[](stream:TStream)
		Local buf:Byte[8192]
		
		Local bytesRead:Long
		Repeat
			bytesRead = stream.Read(buf, buf.length)
			If bytesRead Then
				Update(buf, Int(bytesRead))
			End If
		Until bytesRead <= 0

		If Not bytesRead Then
			Local res:Byte[OutBytes()]
			Finish(res)
			Return res
		End If
		
		Return Null
	End Method

	Method Delete()
		If digestPtr Then
			bmx_digest_free(digestPtr)
			digestPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Returns a hex representation of #Byte array @bytes.
End Rem
Function BytesToHex:String(bytes:Byte[], uppercase:Int = False)
	Return bmx_digest_bytes_to_hex(bytes, bytes.length, uppercase)
End Function

Rem
bbdoc: Returns a hex representation of @size @bytes.
End Rem
Function BytesToHex:String(bytes:Byte Ptr, size:Int, uppercase:Int = False)
	Return bmx_digest_bytes_to_hex(bytes, size, uppercase)
End Function

Private

Global digest_registry:TDigestRegister

Public

Rem
bbdoc: A register of available message digests and cryptographic functions.
about: This can be extended to add new digests to the register.
End Rem
Type TDigestRegister
	Field _succ:TDigestRegister
	
	Method New()
		_succ=digest_registry
		digest_registry=Self
	End Method
	
	Rem
	bbdoc: Gets an instance of a messages digest.
	returns: The message digest or #Null if one of the given name does not exist.
	about: This method must be implemented by extending types.
	End Rem
	Method GeTDigest:TMessageDigest( name:String ) Abstract
	
End Type
