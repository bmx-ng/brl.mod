'
' Copyright (c) 2019 Bruce A Henderson
'
' Permission to use, copy, modify, and/or distribute this software for any
' purpose with or without fee is hereby granted, provided that the above
' copyright notice and this permission notice appear in all copies.
'
' THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
' WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
' MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
' ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
' WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
' ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
' OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
'
SuperStrict

Rem
bbdoc: Cryptographic Utils
End Rem
Module BRL.Crypto

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Bruce A Henderson."
ModuleInfo "License: ISC"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import "common.bmx"


hydro_init()

Rem
bbdoc: Generate unpredictable data, suitable for creating secret keys.
about:
> If this is used in an application inside a VM, and the VM is snapshotted and restored, then the above functions will produce the same output.
End Rem
Type TCryptoRandom

	Rem
	bbdoc: Returns an unpredictable value between 0 and $ffffffff (inclusive).
	End Rem
	Function Random:UInt()
		Return hydro_random_u32()
	End Function
	
	Rem
	bbdoc: Returns an unpredictable value between 0 and @upperBound (excluded).
	about: Unlike `Random() Mod upperBound`, it does its best to guarantee a uniform distribution of the possible
	output values even when @upperBound is not a power of 2.
	End Rem
	Function Uniform:UInt(upperBound:UInt)
		Return hydro_random_uniform(upperBound)
	End Function
	
	Rem
	bbdoc: Fills @size bytes starting at @buf with an unpredictable sequence of bytes, derived from a secret seed.
	End Rem
	Function FillBuffer(buf:Byte Ptr, size:Size_T)
		hydro_random_buf(buf, size)
	End Function

	Rem
	bbdoc: Fills an array of bytes with an unpredictable sequence of bytes, derived from a secret seed.
	End Rem
	Function FillBuffer(buf:Byte[])
		hydro_random_buf(buf, Size_T(buf.length))
	End Function
	
	Rem
	bbdoc: Fills a key with an unpredictable sequence of @bytes in length, derived from a secret seed.
	End Rem
	Function FillKey(key:TCryptoKey Var, bytes:Size_T = 32)
		If key = Null Then
			key = New TCryptoKey
		End If
		
		If Not key.key Or key.key.length <> bytes Then
			key.key = New Byte[bytes]
		End If
		
		FillBuffer(key.key)
	End Function
	
	Rem
	bbdoc: Erases part of the state and replaces the secret key, making it impossible to recover the previous states in case the current one ever gets exposed due to a vulnerability.
	End Rem
	Function Ratchet()
		hydro_random_ratchet()
	End Function
	
	Rem
	bbdoc: Reseeds the random number generator.
	about: Must be called after a `fork()` call.
	End Rem
	Function Reseed()
		hydro_random_reseed()
	End Function

End Type

Rem
bbdoc: A base for key implementations.
End Rem
Type TCryptoKey

	Field key:Byte[]

	Rem
	bbdoc: Returns a String representation of the key.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(key)
	End Method
	
	Rem
	bbdoc: Retrieves a key from its String representation.
	End Rem
	Function FromString:TCryptoKey(k:String)
		Local key:TCryptoKey = New TCryptoKey
		key.key = TBase64.Decode(k)
		Return key
	End Function
	
End Type

Rem
bbdoc: A secret key suitable for use with the #TCryptoHash functions.
End Rem
Type TCryptoHashKey Extends TCryptoKey

	Method New()
		key = New Byte[CRYPTO_HASH_KEYBYTES]
	End Method
	
	Rem
	bbdoc: Retrieves a key from its String representation.
	End Rem
	Function FromString:TCryptoHashKey(key:String)
		Local hashKey:TCryptoHashKey = New TCryptoHashKey
		hashKey.key = TBase64.Decode(key)

		If hashKey.key.length <> CRYPTO_HASH_KEYBYTES Then
			Throw "Unexpected key size of " + hashKey.key.length + " bytes. Expected " + CRYPTO_HASH_KEYBYTES + " bytes"
		End If

		Return hashKey
	End Function
	
End Type

Rem
bbdoc: Transforms an arbitrary-long input into a fixed length fingerprint
about: This API requires a context.
Similar to a type, a context is a 8 characters string describing what the function is going to be used for.

Its purpose is to mitigate accidental bugs by separating domains. The same function used with the same key but
in two distinct contexts is likely to generate two different outputs.

Therefore, a key designed to encrypt data used in a specific context will not be able to decrypt data if
accidentally used in another context.

Contexts don't have to be secret and can have a low entropy. Examples of contexts include `UserName`, `__auth__`, `pictures` and `userdata`.

If more convenient, it is also fine to use a single global context for a whole application. This will still prevent
the same key from being mistakenly used by another application.
End Rem
Type TCryptoHash

	Field statePtr:Byte Ptr
	
	Rem
	bbdoc: Creates a secret key suitable for use with the #TCryptoHash functions.
	End Rem
	Function KeyGen:TCryptoHashKey()
		Local key:TCryptoHashKey = New TCryptoHashKey
		bmx_hydro_hash_keygen(key.key)
		Return key
	End Function

	Rem
	bbdoc: Puts a fingerprint of the message @in whose length is @inLen bytes into @out.
	about: The output size can be chosen by the application.
	The minimum recommended output size is #CRYPTO_HASH_BYTES. This size makes it practically impossible for
	two messages to produce the same fingerprint.

	But for specific use cases, the size can be any value between #CRYPTO_HASH_BYTES_MIN (included) and #CRYPTO_HASH_BYTES_MAX (included).

	@key can be NULL. In this case, a message will always have the same fingerprint, similar to the MD5 or SHA-1 functions for which
	#Hash() is a faster and more secure alternative.

	But a key can also be specified. A message will always have the same fingerprint for a given key, but different keys used
	to hash the same message are very likely to produce distinct fingerprints.

	In particular, the key can be used to make sure that different applications generate different fingerprints even if they process the same data.

	The key size is #CRYPTO_HASH_KEYBYTES bytes.
	End Rem
	Function Hash:Int(out:Byte Ptr, outLen:Size_T, in:Byte Ptr, inLen:Size_T, context:String, key:TCryptoHashKey)
		If key Then
			Return bmx_hydro_hash_hash(out, outLen, in, inLen, context, key.key)
		Else
			Return bmx_hydro_hash_hash(out, outLen, in, inLen, context, Null)
		End If
	End Function

	Rem
	Rem
	bbdoc: Puts a fingerprint of the message @in into @out.
	about: The output size can be chosen by the application.
	The minimum recommended output size is #CRYPTO_HASH_BYTES. This size makes it practically impossible for
	two messages to produce the same fingerprint.

	But for specific use cases, the size can be any value between #CRYPTO_HASH_BYTES_MIN (included) and #CRYPTO_HASH_BYTES_MAX (included).

	@key can be NULL. In this case, a message will always have the same fingerprint, similar to the MD5 or SHA-1 functions for which
	#Hash() is a faster and more secure alternative.

	But a key can also be specified. A message will always have the same fingerprint for a given key, but different keys used
	to hash the same message are very likely to produce distinct fingerprints.

	In particular, the key can be used to make sure that different applications generate different fingerprints even if they process the same data.

	The key size is #CRYPTO_HASH_KEYBYTES bytes.
	End Rem
	Function Hash:Int(out:Byte[], in:Byte[], context:String, key:TCryptoHashKey)
		If key Then
			Return bmx_hydro_hash_hash(out, Size_T(out.length), in, Size_T(in.length), context, key.key)
		Else
			Return bmx_hydro_hash_hash(out, Size_T(out.length), in, Size_T(in.length), context, Null)
		End If
	End Function
	
	Rem
	bbdoc: Initializes a state state with a key @key (that can be NULL), in order to eventually produce output.
	End Rem
	Method Create:TCryptoHash(context:String, key:TCryptoHashKey)
		If key Then
			statePtr = bmx_hydro_hash_init(context, key.key)
		Else
			statePtr = bmx_hydro_hash_init(context, Null)
		End If
		Return Self
	End Method
	
	Rem
	bbdoc: Sequentially processes a chunk @in of @inLen bytes in length.
	End Rem
	Method Update:Int(in:Byte Ptr, inLen:Size_T)
		Return bmx_hydro_hash_update(statePtr, in, inLen)
	End Method

	Rem
	bbdoc: Sequentially processes a chunk @in.
	End Rem
	Method Update:Int(in:Byte[])
		Return bmx_hydro_hash_update(statePtr, in, Size_T(in.length))
	End Method
	
	Rem
	bbdoc: Completes the operation and puts the final fingerprint into @out as @outlen bytes.
	End Rem
	Method Finish(out:Byte Ptr, outLen:Size_T)
		bmx_hydro_hash_final(statePtr, out, outLen)
	End Method

	Rem
	bbdoc: Completes the operation and puts the final fingerprint into @out.
	End Rem
	Method Finish(out:Byte[])
		bmx_hydro_hash_final(statePtr, out, Size_T(out.length))
	End Method
	
	Method Free()
		If statePtr Then
			bmx_hydro_hash_state_free(statePtr)
			statePtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method

End Type

Rem
bbdoc: A secret key suitable for use with #TCryptoSecretBox.
End Rem
Type TCryptoSecretBoxKey Extends TCryptoKey

	Method New()
		key = New Byte[CRYPTO_SECRETBOX_KEYBYTES]
	End Method

	Rem
	bbdoc: Retrieves a key from its String representation.
	End Rem
	Function FromString:TCryptoSecretBoxKey(key:String)
		Local sbKey:TCryptoSecretBoxKey = New TCryptoSecretBoxKey
		sbKey.key = TBase64.Decode(key)

		If sbKey.key.length <> CRYPTO_SECRETBOX_KEYBYTES Then
			Throw "Unexpected key size of " + sbKey.key.length + " bytes. Expected " + CRYPTO_SECRETBOX_KEYBYTES + " bytes"
		End If

		Return sbKey
	End Function
	
End Type

Rem
bbdoc: Encrypts a message with a secret key to keep it confidential.
about: Computes a nonce and an authentication tag. This tag is used to make sure that the message hasn't been tampered with before decrypting it.

A single key is used both to encrypt/sign and verify/decrypt messages. For this reason, it is critical to keep the key confidential.
End Rem
Type TCryptoSecretBox

	Rem
	bbdoc: Generates a secret key suitable for use with #TCryptoSecretBox.
	End Rem
	Function KeyGen:TCryptoSecretBoxKey()
		Local key:TCryptoSecretBoxKey = New TCryptoSecretBoxKey
		bmx_hydro_secretbox_keygen(key.key)
		Return key
	End Function
	
	Rem
	bbdoc: Encrypts a message @m of length @mLen bytes using a @context, a secret @key and a message counter @msgId.
	about: It puts the ciphertext whose length is #CRYPTO_SECRETBOX_HEADERBYTES + mlen into @c.

	The header includes an automatically-generated 160-bit nonce as well as a 128-bit authentication tag.

	A nonce doesn't have to be provided: it is automatically computed using the output of the PRNG and a keyed hash of the message
	and its metadata. This prevents catastrophic failures even if the PRNG cannot be trusted.

	@msgId is an optional message tag. For example, if 3 messages are sent to the same recipient using the same key, these messages
	can sequentially use 0, 1 and 2 as identifiers.

	If the recipient expects message 2, but receives a message with a different identifier, it will not decrypt it even if it was
	encrypted with the correct key.

	This can be used to discard duplicate or old messages.

	A @msgId doesn't have to be secret and it doesn't have to be sequential either. Some applications might prefer a coarse timestamp instead.
	Any value up to 2^64-1 is acceptable.

	If this mechanism is not required by an application, using a constant @msgId such as 0 is also totally fine. Message identifiers are
	optional and do not have to be unique.
	End Rem
	Function Encrypt:Int(c:Byte Ptr, cLen:Size_T, m:Byte Ptr, mLen:Size_T, msgId:ULong, context:String, key:TCryptoKey)
		If cLen <> (mLen + CRYPTO_SECRETBOX_HEADERBYTES) Then
			Throw "'c' must be " + mLen + " + " + CRYPTO_SECRETBOX_HEADERBYTES + " bytes"
		End If
		Return bmx_hydro_secretbox_encrypt(c, m, mLen, msgId, context, key.key)
	End Function
	
	Rem
	Rem
	bbdoc: Encrypts a message @m using a @context, a secret @key and a message counter @msgId.
	about: It puts the ciphertext whose length is @CRYPTO_SECRETBOX_HEADERBYTES + m.length into c.

	The header includes an automatically-generated 160-bit nonce as well as a 128-bit authentication tag.

	A nonce doesn't have to be provided: it is automatically computed using the output of the PRNG and a keyed hash of the message
	and its metadata. This prevents catastrophic failures even if the PRNG cannot be trusted.

	@msgId is an optional message tag. For example, if 3 messages are sent to the same recipient using the same key, these messages
	can sequentially use 0, 1 and 2 as identifiers.

	If the recipient expects message 2, but receives a message with a different identifier, it will not decrypt it even if it was
	encrypted with the correct key.

	This can be used to discard duplicate or old messages.

	A @msgId doesn't have to be secret and it doesn't have to be sequential either. Some applications might prefer a coarse timestamp instead.
	Any value up to 2^64-1 is acceptable.

	If this mechanism is not required by an application, using a constant @msgId such as 0 is also totally fine. Message identifiers are
	optional and do not have to be unique.
	End Rem
	Function Encrypt:Int(c:Byte[], m:Byte[], msgId:ULong, context:String, key:TCryptoKey)
		If c.length <> m.length + CRYPTO_SECRETBOX_HEADERBYTES Then
			Throw "'c' must be " + m.length + " + " + CRYPTO_SECRETBOX_HEADERBYTES + " bytes"
		End If
		Return bmx_hydro_secretbox_encrypt(c, m, Size_T(m.length), msgId, context, key.key)
	End Function

	Rem
	bbdoc: Decrypts the ciphertext @c of length @cLen (which includes the @CRYPTO_SECRETBOX_HEADERBYTES bytes header) using the secret key @key, the @context and the message identifier @msgId.
	about: If the authentication tag can be verified using these parameters, the function stores the decrypted message into @m.
	The length of this decrypted message is cLen - CRYPTO_SECRETBOX_KEYBYTES. It then returns #True.

	If the authentication tag doesn't appear to be valid for these parameters, the function returns #False.
	End Rem
	Function Decrypt:Int(m:Byte Ptr, mLen:Size_T, c:Byte Ptr, cLen:Size_T, msgId:ULong, context:String, key:TCryptoKey)
		If mLen <> (cLen - CRYPTO_SECRETBOX_HEADERBYTES) Then
			Throw "'m' must be " + cLen + " - " + CRYPTO_SECRETBOX_HEADERBYTES + " bytes"
		End If
		Return bmx_hydro_secretbox_decrypt(m, c, cLen, msgId, context, key.key)
	End Function

	Rem
	bbdoc: Decrypts the ciphertext @c (which includes the #CRYPTO_SECRETBOX_HEADERBYTES bytes header) using the secret key @key, the @context and the message identifier @msgId.
	about: If the authentication tag can be verified using these parameters, the function stores the decrypted message into @m.
	The length of this decrypted message is c.length - CRYPTO_SECRETBOX_KEYBYTES. It then returns #True.

	If the authentication tag doesn't appear to be valid for these parameters, the function returns #False.
	End Rem
	Function Decrypt:Int(m:Byte[], c:Byte[], msgId:ULong, context:String, key:TCryptoKey)
		If m.length <> (c.length - CRYPTO_SECRETBOX_HEADERBYTES) Then
			Throw "'m' must be " + c.length + " - " + CRYPTO_SECRETBOX_HEADERBYTES + " bytes"
		End If
		Return bmx_hydro_secretbox_decrypt(m, c, Size_T(c.length), msgId, context, key.key)
	End Function

	Rem
	bbdoc: Computes a probe for the ciphertext @c whose length is @cLen, using the @context and a shared secret key @key.
	about:  The probe is put into probe whose size is #CRYPTO_SECRETBOX_PROBEBYTES bytes.
	End Rem
	Function ProbeCreate(probe:Byte Ptr, probeLen:Size_T, c:Byte Ptr, cLen:Size_T, context:String, key:TCryptoKey)
		If probeLen <> CRYPTO_SECRETBOX_PROBEBYTES Then
			Throw "'probe' must be " + CRYPTO_SECRETBOX_PROBEBYTES + " bytes"
		End If
		bmx_hydro_secretbox_probe_create(probe, c, cLen, context, key.key)
	End Function

	Rem
	bbdoc: Computes a probe for the ciphertext @c, using the @context and a shared secret key @key.
	about:  The probe is put into @probe whose size is #CRYPTO_SECRETBOX_PROBEBYTES bytes.
	End Rem
	Function ProbeCreate(probe:Byte[], c:Byte[], context:String, key:TCryptoKey)
		If probe.length <> CRYPTO_SECRETBOX_PROBEBYTES Then
			Throw "'probe' must be " + CRYPTO_SECRETBOX_PROBEBYTES + " bytes"
		End If
		bmx_hydro_secretbox_probe_create(probe, c, Size_T(c.length), context, key.key)
	End Function
	
	Rem
	bbdoc: Verifies that a received probe @probe is valid for the ciphertext @c whose length is @cLen, using the @context and the shared secret key @key that was initially used to compute the probe.
	about: It returns #True on success, and #False if the probe didn't pass verification.
	End Rem
	Function ProbeVerify:Int(probe:Byte Ptr, probeLen:Size_T, c:Byte Ptr, cLen:Size_T, context:String, key:TCryptoKey)
		If probeLen <> CRYPTO_SECRETBOX_PROBEBYTES Then
			Throw "'probe' must be " + CRYPTO_SECRETBOX_PROBEBYTES + " bytes"
		End If
		Return bmx_hydro_secretbox_probe_verify(probe, c, cLen, context, key.key)
	End Function

	Rem
	bbdoc: Verifies that a received probe @probe is valid for the ciphertext @c, using the @context and the shared secret key @key that was initially used to compute the probe.
	about: It returns #True on success, and #False if the probe didn't pass verification.
	End Rem
	Function ProbeVerify:Int(probe:Byte[], c:Byte[], context:String, key:TCryptoKey)
		If probe.length <> CRYPTO_SECRETBOX_PROBEBYTES Then
			Throw "'probe' must be " + CRYPTO_SECRETBOX_PROBEBYTES + " bytes"
		End If
		Return bmx_hydro_secretbox_probe_verify(probe, c, Size_T(c.length), context, key.key)
	End Function
	
End Type

Rem
bbdoc: A secret key and a corresponding public key.
End Rem
Type TCryptoSignKeyPair

	Rem
	bbdoc: A secret key, that will be used to sign any number of messages
	End Rem
	Field secretKey:Byte[CRYPTO_SIGN_SECRETKEYBYTES]

	Rem
	bbdoc: A public key, that anybody can use to verify that the signature for a message was actually issued by the creator of the public key.
	End Rem
	Field publicKey:Byte[CRYPTO_SIGN_PUBLICKEYBYTES]
	
	Rem
	bbdoc: Returns a String representation of the key pair.
	End Rem
	Method ToString:String()
		Return PublicKeyToString() + "." + SecretKeyToString()
	End Method
	
	Rem
	bbdoc: Returns a String representation of the public key.
	End Rem
	Method PublicKeyToString:String()
		Return TBase64.Encode(publicKey, 0, EBase64Options.DontBreakLines)
	End Method
	
	Rem
	bbdoc: Returns a String representation of the secret key.
	End Rem
	Method SecretKeyToString:String()
		Return TBase64.Encode(secretKey, 0, EBase64Options.DontBreakLines)
	End Method
	
	Rem
	bbdoc: Retrieves the key pair from its String representation.
	End Rem
	Function FromString:TCryptoSignKeyPair(keys:String)
		Local parts:String[] = keys.Split(".")
		If parts.length <> 2 Then
			Throw "Expected 2 key parts, but was " + parts.length
		End If
		
		Local kp:TCryptoSignKeyPair = New TCryptoSignKeyPair
		kp.publicKey = TBase64.Decode(parts[0])
		kp.secretKey = TBase64.Decode(parts[1])
		
		If kp.publicKey.length <> CRYPTO_SIGN_PUBLICKEYBYTES Then
			Throw "Unexpected public key size of " + kp.publicKey.length + " bytes. Expected " + CRYPTO_SIGN_PUBLICKEYBYTES + " bytes"
		End If

		If kp.secretKey.length <> CRYPTO_SIGN_SECRETKEYBYTES Then
			Throw "Unexpected secret key size of " + kp.secretKey.length + " bytes. Expected " + CRYPTO_SIGN_SECRETKEYBYTES + " bytes"
		End If
		
		Return kp
	End Function
	
	Rem
	bbdoc: Retrieves the secret key from its String representation.
	End Rem
	Function FromSecretKey:TCryptoSignKeyPair(sk:String)
		Local kp:TCryptoSignKeyPair = New TCryptoSignKeyPair
		kp.secretKey = TBase64.Decode(sk)

		If kp.secretKey.length <> CRYPTO_SIGN_SECRETKEYBYTES Then
			Throw "Unexpected secret key size of " + kp.secretKey.length + " bytes. Expected " + CRYPTO_SIGN_SECRETKEYBYTES + " bytes"
		End If

		Return kp
	End Function
	
	Rem
	bbdoc: Retrieves the public key from its String representation.
	End Rem
	Function FromPublicKey:TCryptoSignKeyPair(pk:String)
		Local kp:TCryptoSignKeyPair = New TCryptoSignKeyPair
		kp.publicKey = TBase64.Decode(pk)

		If kp.publicKey.length <> CRYPTO_SIGN_PUBLICKEYBYTES Then
			Throw "Unexpected public key size of " + kp.publicKey.length + " bytes. Expected " + CRYPTO_SIGN_PUBLICKEYBYTES + " bytes"
		End If

		Return kp
	End Function
End Type

Rem
bbdoc: The signature for a message signed by a #TCryptoSignKeyPair.secretKey.
End Rem
Type TCryptoSignature

	Field signature:Byte[CRYPTO_SIGN_BYTES]
	
	Rem
	bbdoc: Returns a String representation of the signature.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(signature, 0, EBase64Options.DontBreakLines)
	End Method
	
	Rem
	bbdoc: Retrieves the signature from its String representation.
	End Rem
	Function FromString:TCryptoSignature(signature:String)
		Local sig:TCryptoSignature = New TCryptoSignature
		sig.signature = TBase64.Decode(signature)

		If sig.signature.length <> CRYPTO_SIGN_BYTES Then
			Throw "Unexpected signature size of " + sig.signature.length + " bytes. Expected " + CRYPTO_SIGN_BYTES + " bytes"
		End If

		Return sig
	End Function

End Type

Rem
bbdoc: Message signing.
about: The nonces are non-deterministic. They are computed using the output of the CSPRNG as well as a hash of the
message to be signed. As a result, signing the same message multiple times can produce different, all valid signatures.
However, only the owner of the secret key can compute a valid signature.
End Rem
Type TCryptoSign

	Field statePtr:Byte Ptr

	Rem
	bbdoc: Generates a secret key and a corresponding public key.
	End Rem
	Function KeyGen:TCryptoSignKeyPair()
		Local kp:TCryptoSignKeyPair = New TCryptoSignKeyPair
		bmx_hydro_sign_keygen(kp.secretKey, kp.publicKey)
		Return kp
	End Function

	Rem
	bbdoc: Computes a signature for a message @m whose length is @mLen bytes, using the secret key from @kp and a @context.
	End Rem
	Function Sign:Int(csig:TCryptoSignature Var, m:Byte Ptr, mLen:Size_T, context:String, kp:TCryptoSignKeyPair)
		If Not csig Then
			csig = New TCryptoSignature
		End If
		Return bmx_hydro_sign_create(csig.signature, m, mLen, context, kp.secretKey)
	End Function

	Rem
	bbdoc: Computes a signature for a message @m, using the secret key from @kp and a @context.
	End Rem
	Function Sign:Int(csig:TCryptoSignature Var, m:Byte[], context:String, kp:TCryptoSignKeyPair)
		If Not csig Then
			csig = New TCryptoSignature
		End If
		Return bmx_hydro_sign_create(csig.signature, m, Size_T(m.length), context, kp.secretKey)
	End Function
	
	Rem
	bbdoc: Checks that the signed message @m whose length is @mLen bytes has a valid signature for the public key @pk and the @context.
	about: If the signature is doesn't appear to be valid, the function returns #False. On success, it returns #True.
	End Rem
	Function Verify:Int(csig:TCryptoSignature, m:Byte Ptr, mLen:Size_T, context:String, kp:TCryptoSignKeyPair)
		Return bmx_hydro_sign_verify(csig.signature, m, mLen, context, kp.publicKey)
	End Function

	Rem
	bbdoc: Checks that the signed message @m has a valid signature for the public key @pk and the @context.
	about: If the signature is doesn't appear to be valid, the function returns #False. On success, it returns #True.
	End Rem
	Function Verify:Int(csig:TCryptoSignature, m:Byte[], context:String, kp:TCryptoSignKeyPair)
		Return bmx_hydro_sign_verify(csig.signature, m, Size_T(m.length), context, kp.publicKey)
	End Function

	Rem
	bbdoc: Initializes a state state using the @context.
	End Rem
	Method Create:TCryptoSign(context:String)
		statePtr = bmx_hydro_sign_init(context)
		Return Self
	End Method
	
	Rem
	bbdoc: Hashes chunk @m of @mLen bytes.
	End Rem
	Method Update:Int(m:Byte Ptr, mLen:Size_T)
		Return bmx_hydro_sign_update(statePtr, m, mLen)
	End Method

	Rem
	bbdoc: Hashes chunk @m.
	End Rem
	Method Update:Int(m:Byte[])
		Return bmx_hydro_sign_update(statePtr, m, Size_T(m.length))
	End Method
	
	Rem
	bbdoc: Computes the signature into @csig using the secret key from @kp.
	End Rem
	Method FinishCreate:Int(csig:TCryptoSignature Var, kp:TCryptoSignKeyPair)
		If Not csig Then
			csig = New TCryptoSignature
		End If
		Return bmx_hydro_sign_final_create(statePtr, csig.signature, kp.secretKey)
	End Method
	
	Rem
	bbdoc: Verifies the signature into @csig using the public key from @kp.
	about: Returns #False if the signature doesn't appear to be valid for the given message, context and public key, or #True if it could be successfully verified.
	End Rem
	Method FinishVerify:Int(csig:TCryptoSignature, kp:TCryptoSignKeyPair)
		Return bmx_hydro_sign_final_verify(statePtr, csig.signature, kp.publicKey)
	End Method

	Method Free()
		If statePtr Then
			bmx_hydro_sign_state_free(statePtr)
			statePtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method

End Type

Rem
bbdoc: A long-term key pair.
about: These long-term keys can be reused indefinitely, even though rotating them from time to time is highly recommended in case
the secret key ever gets leaked.
End Rem
Type TCryptoExchangeKeyPair

	Field secretKey:Byte[CRYPTO_KX_SECRETKEYBYTES]
	Field publicKey:Byte[CRYPTO_KX_PUBLICKEYBYTES]

	Rem
	bbdoc: Returns a String representation of the key pair.
	End Rem
	Method ToString:String()
		Return PublicKeyToString() + "." + SecretKeyToString()
	End Method
	
	Rem
	bbdoc: Returns a String representation of the public key.
	End Rem
	Method PublicKeyToString:String()
		Return TBase64.Encode(publicKey)
	End Method
	
	Rem
	bbdoc: Returns a String representation of the secret key.
	End Rem
	Method SecretKeyToString:String()
		Return TBase64.Encode(secretKey, 0, EBase64Options.DontBreakLines)
	End Method
	
	Rem
	bbdoc: Retrieves the key pair from its String representation.
	End Rem
	Function FromString:TCryptoExchangeKeyPair(keys:String)
		Local parts:String[] = keys.Split(".")
		If parts.length <> 2 Then
			Throw "Expected 2 key parts, but was " + parts.length
		End If
		
		Local kp:TCryptoExchangeKeyPair = New TCryptoExchangeKeyPair
		kp.publicKey = TBase64.Decode(parts[0])
		kp.secretKey = TBase64.Decode(parts[1])
		
		If kp.publicKey.length <> CRYPTO_KX_PUBLICKEYBYTES Then
			Throw "Unexpected public key size of " + kp.publicKey.length + " bytes. Expected " + CRYPTO_KX_PUBLICKEYBYTES + " bytes"
		End If

		If kp.secretKey.length <> CRYPTO_KX_SECRETKEYBYTES Then
			Throw "Unexpected secret key size of " + kp.secretKey.length + " bytes. Expected " + CRYPTO_KX_SECRETKEYBYTES + " bytes"
		End If
		
		Return kp
	End Function
	
	Rem
	bbdoc: Retrieves the public key from its String representation.
	End Rem
	Function PublicKeyFromString:TCryptoExchangeKeyPair(key:String)
		Local kp:TCryptoExchangeKeyPair = New TCryptoExchangeKeyPair
		kp.publicKey = TBase64.Decode(key)

		If kp.publicKey.length <> CRYPTO_KX_PUBLICKEYBYTES Then
			Throw "Unexpected public key size of " + kp.publicKey.length + " bytes. Expected " + CRYPTO_KX_PUBLICKEYBYTES + " bytes"
		End If

		Return kp
	End Function
	
	Rem
	bbdoc: Retrieves the secret key from its String representation.
	End Rem
	Function SecretKeyFromString:TCryptoExchangeKeyPair(key:String)
		Local kp:TCryptoExchangeKeyPair = New TCryptoExchangeKeyPair
		kp.secretKey = TBase64.Decode(key)

		If kp.secretKey.length <> CRYPTO_KX_SECRETKEYBYTES Then
			Throw "Unexpected secret key size of " + kp.secretKey.length + " bytes. Expected " + CRYPTO_KX_SECRETKEYBYTES + " bytes"
		End If

		Return kp
	End Function

End Type

Rem
bbdoc: A session key pair.
about: The #tx key is used to encrypt outgoing messages.
The #rx key is used to decrypt incoming messages.
End Rem
Type TCryptoSessionKeyPair

	Field rx:TCryptoKey
	Field tx:TCryptoKey
	
	Method New(initKeys:Int = True)
		If initKeys Then
			rx = New TCryptoKey
			rx.key = New Byte[CRYPTO_KX_SESSIONKEYBYTES]
			tx = New TCryptoKey
			tx.key = New Byte[CRYPTO_KX_SESSIONKEYBYTES]
		End If
	End Method
	
	Rem
	bbdoc: Returns a String representation of the key pair.
	End Rem
	Method ToString:String()
		Return RxToString() + "." + TxToString()
	End Method
	
	Rem
	bbdoc: Returns a String representation of the #rx key.
	End Rem
	Method RxToString:String()
		Return rx.ToString()
	End Method
	
	Rem
	bbdoc: Returns a String representation of the #tx key.
	End Rem
	Method TxToString:String()
		Return tx.ToString()
	End Method

	Rem
	bbdoc: Retrieves the key pair from its String representation.
	End Rem
	Function FromString:TCryptoSessionKeyPair(keys:String)
		Local parts:String[] = keys.Split(".")
		If parts.length <> 2 Then
			Throw "Expected 2 key parts, but was " + parts.length
		End If
		
		Local kp:TCryptoSessionKeyPair = New TCryptoSessionKeyPair(False)
		kp.rx = TCryptoKey.FromString(parts[0])
		kp.tx = TCryptoKey.FromString(parts[1])
		
		If kp.rx.key.length <> CRYPTO_KX_SESSIONKEYBYTES Then
			Throw "Unexpected rx key size of " + kp.rx.key.length + " bytes. Expected " + CRYPTO_KX_SESSIONKEYBYTES + " bytes"
		End If

		If kp.tx.key.length <> CRYPTO_KX_SESSIONKEYBYTES Then
			Throw "Unexpected tx key size of " + kp.tx.key.length + " bytes. Expected " + CRYPTO_KX_SESSIONKEYBYTES + " bytes"
		End If
		
		Return kp
	End Function
	
	Rem
	bbdoc: Retrieves the #rx key from its String representation.
	End Rem
	Function RxFromString:TCryptoSessionKeyPair(key:String)
		Local kp:TCryptoSessionKeyPair = New TCryptoSessionKeyPair(False)
		kp.rx = TCryptoKey.FromString(key)

		If kp.rx.key.length <> CRYPTO_KX_SESSIONKEYBYTES Then
			Throw "Unexpected rx key size of " + kp.rx.key.length + " bytes. Expected " + CRYPTO_KX_SESSIONKEYBYTES + " bytes"
		End If

		Return kp
	End Function

	Rem
	bbdoc: Retrieves the #tx key from its String representation.
	End Rem
	Function TxFromString:TCryptoSessionKeyPair(key:String)
		Local kp:TCryptoSessionKeyPair = New TCryptoSessionKeyPair(False)
		kp.tx = TCryptoKey.FromString(key)

		If kp.tx.key.length <> CRYPTO_KX_SESSIONKEYBYTES Then
			Throw "Unexpected tx key size of " + kp.tx.key.length + " bytes. Expected " + CRYPTO_KX_SESSIONKEYBYTES + " bytes"
		End If

		Return kp
	End Function
	
End Type

Rem
bbdoc: Packet in N variant key exchange.
End Rem
Type TCryptoNPacket

	Field packet:Byte[CRYPTO_KX_N_PACKET1BYTES]

	Rem
	bbdoc: Returns a string representation of the packet.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(packet)
	End Method
	
	Rem
	bbdoc: Retrieves the packet from its String representation.
	End Rem
	Function FromString:TCryptoNPacket(packet:String)
		Local pack:TCryptoNPacket = New TCryptoNPacket
		pack.packet = TBase64.Decode(packet)

		If pack.packet.length <> CRYPTO_KX_N_PACKET1BYTES Then
			Throw "Unexpected packet size of " + pack.packet.length + " bytes. Expected " + CRYPTO_KX_N_PACKET1BYTES + " bytes"
		End If

		Return pack
	End Function
	
End Type

Rem
bbdoc: Packet 1 in KK variant key exchange.
End Rem
Type TCryptoKK1Packet

	Field packet:Byte[CRYPTO_KX_KK_PACKET1BYTES]

	Rem
	bbdoc: Returns a string representation of the packet.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(packet)
	End Method
	
	Rem
	bbdoc: Retrieves the packet from its String representation.
	End Rem
	Function FromString:TCryptoKK1Packet(packet:String)
		Local pack:TCryptoKK1Packet = New TCryptoKK1Packet
		pack.packet = TBase64.Decode(packet)

		If pack.packet.length <> CRYPTO_KX_KK_PACKET1BYTES Then
			Throw "Unexpected packet size of " + pack.packet.length + " bytes. Expected " + CRYPTO_KX_KK_PACKET1BYTES + " bytes"
		End If

		Return pack
	End Function
	
End Type

Rem
bbdoc: Packet 2 in KK variant key exchange.
End Rem
Type TCryptoKK2Packet

	Field packet:Byte[CRYPTO_KX_KK_PACKET2BYTES]

	Rem
	bbdoc: Returns a string representation of the packet.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(packet)
	End Method
	
	Rem
	bbdoc: Retrieves the packet from its String representation.
	End Rem
	Function FromString:TCryptoKK2Packet(packet:String)
		Local pack:TCryptoKK2Packet = New TCryptoKK2Packet
		pack.packet = TBase64.Decode(packet)

		If pack.packet.length <> CRYPTO_KX_KK_PACKET2BYTES Then
			Throw "Unexpected packet size of " + pack.packet.length + " bytes. Expected " + CRYPTO_KX_KK_PACKET2BYTES + " bytes"
		End If

		Return pack
	End Function
	
End Type

Rem
bbdoc: Packet 1 in XX variant key exchange.
End Rem
Type TCryptoXX1Packet

	Field packet:Byte[CRYPTO_KX_XX_PACKET1BYTES]

	Rem
	bbdoc: Returns a string representation of the packet.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(packet)
	End Method
	
	Rem
	bbdoc: Retrieves the packet from its String representation.
	End Rem
	Function FromString:TCryptoXX1Packet(packet:String)
		Local pack:TCryptoXX1Packet = New TCryptoXX1Packet
		pack.packet = TBase64.Decode(packet)

		If pack.packet.length <> CRYPTO_KX_XX_PACKET1BYTES Then
			Throw "Unexpected packet size of " + pack.packet.length + " bytes. Expected " + CRYPTO_KX_XX_PACKET1BYTES + " bytes"
		End If

		Return pack
	End Function
	
End Type

Rem
bbdoc: Packet 2 in XX variant key exchange.
End Rem
Type TCryptoXX2Packet

	Field packet:Byte[CRYPTO_KX_XX_PACKET2BYTES]

	Rem
	bbdoc: Returns a string representation of the packet.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(packet)
	End Method
	
	Rem
	bbdoc: Retrieves the packet from its String representation.
	End Rem
	Function FromString:TCryptoXX2Packet(packet:String)
		Local pack:TCryptoXX2Packet = New TCryptoXX2Packet
		pack.packet = TBase64.Decode(packet)

		If pack.packet.length <> CRYPTO_KX_XX_PACKET2BYTES Then
			Throw "Unexpected packet size of " + pack.packet.length + " bytes. Expected " + CRYPTO_KX_XX_PACKET2BYTES + " bytes"
		End If

		Return pack
	End Function
	
End Type

Rem
bbdoc: Packet 3 in XX variant key exchange.
End Rem
Type TCryptoXX3Packet

	Field packet:Byte[CRYPTO_KX_XX_PACKET3BYTES]

	Rem
	bbdoc: Returns a string representation of the packet.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(packet)
	End Method
	
	Rem
	bbdoc: Retrieves the packet from its String representation.
	End Rem
	Function FromString:TCryptoXX3Packet(packet:String)
		Local pack:TCryptoXX3Packet = New TCryptoXX3Packet
		pack.packet = TBase64.Decode(packet)

		If pack.packet.length <> CRYPTO_KX_XX_PACKET3BYTES Then
			Throw "Unexpected packet size of " + pack.packet.length + " bytes. Expected " + CRYPTO_KX_XX_PACKET3BYTES + " bytes"
		End If

		Return pack
	End Function
	
End Type

Rem
bbdoc: Key exchange state.
End Rem
Type TCryptoExchangeState

	Field statePtr:Byte Ptr
	
	Method New()
		statePtr = bmx_hydro_kx_state_new()
	End Method
	
	Method Free()
		If statePtr Then
			bmx_hydro_kx_state_free(statePtr)
			statePtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method
	
End Type

Rem
bbdoc: Secure message exchange
about: Using key exchange, two parties can securely compute a set of ephemeral, shared secret keys, that can be used to securely exchange messages.

The general pattern two build a secure channel is:

* Pick the variant that fits your application needs
* Use the functions from that variant to build and parse packets to be exchanged between parties
* Eventually, both parties will compute a shared secret, that can be used with #TCryptoSecretbox.
End Rem
Type TCryptoKeyExchange

	Rem
	bbdoc: Generates a long-term key pair.
	about: These long-term keys can be reused indefinitely, even though rotating them from time to time is highly recommended
	in case the secret key ever gets leaked.
	End Rem
	Function KeyGen:TCryptoExchangeKeyPair()
		Local kp:TCryptoExchangeKeyPair = New TCryptoExchangeKeyPair
		bmx_hydro_kx_keygen(kp.secretKey, kp.publicKey)
		Return kp
	End Function

	Rem
	bbdoc: Computes a session key pair @sessionKeyPair using the server's public key @publicKey, and builds a packet @packet1 that has to be sent to the server.
	returns: #True on success, and #False on error.
	about: This variant is designed to anonymously send messages to a recipient using its public key.
	* What the client needs to know about the server: <b>the server's public key</b>
	* What the server needs to know about the client: <b>nothing</b>
	End Remw
	Function N1:Int(sessionKeyPair:TCryptoSessionKeyPair Var, packet:TCryptoNPacket Var, preSharedKey:TCryptoKey, serverKeyPair:TCryptoExchangeKeyPair)
		If Not sessionKeyPair Then
			sessionKeyPair = New TCryptoSessionKeyPair
		End If
		If Not packet Then
			packet = New TCryptoNPacket
		End If
		If preSharedKey Then
			Return bmx_hydro_kx_n_1(sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet.packet, preSharedKey.key, serverKeyPair.publicKey)
		Else
			Return bmx_hydro_kx_n_1(sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet.packet, Null, serverKeyPair.publicKey)
		End If
	End Function

	Rem
	bbdoc: Computes a session key pair @sessionKeyPair using the packet @packet1 received from the client.
	returns: #True on success, and #False on error.
	End Rem
	Function N2:Int(sessionKeyPair:TCryptoSessionKeyPair Var, packet:TCryptoNPacket, preSharedKey:TCryptoKey, keyPair:TCryptoExchangeKeyPair)
		If Not sessionKeyPair Then
			sessionKeyPair = New TCryptoSessionKeyPair
		End If
		If preSharedKey Then
			Return bmx_hydro_kx_n_2(sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet.packet, preSharedKey.key, keyPair.secretKey, keyPair.publicKey)
		Else
			Return bmx_hydro_kx_n_2(sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet.packet, Null, keyPair.secretKey, keyPair.publicKey)
		End If
	End Function

	Rem
	bbdoc: Initializes the local state @state, computes an ephemeral key pair, and puts the first packet to send to the server into @packet1.
	returns: #True on success, and #False on error.
	End Rem
	Function KK1:Int(state:TCryptoExchangeState Var, packet1:TCryptoKK1Packet Var, peerKeyPair:TCryptoExchangeKeyPair, keyPair:TCryptoExchangeKeyPair)
		If Not state Then
			state = New TCryptoExchangeState
		End If
		If Not packet1 Then
			packet1 = New TCryptoKK1Packet
		End If
		Return bmx_hydro_kx_kk_1(state.statePtr, packet1.packet, peerKeyPair.publicKey, keyPair.secretKey, keyPair.publicKey)
	End Function
	
	Rem
	bbdoc: Validates the request, computes an ephemeral key pair, puts it into @sessionKeyPair, and stores the packet to send to the client into @packet2.
	returns: #True on success, and #False on error.
	End Rem
	Function KK2:Int(sessionKeyPair:TCryptoSessionKeyPair Var, packet2:TCryptoKK2Packet Var, packet1:TCryptoKK1Packet, peerKeyPair:TCryptoExchangeKeyPair, keyPair:TCryptoExchangeKeyPair)
		If Not sessionKeyPair Then
			sessionKeyPair = New TCryptoSessionKeyPair
		End If
		If Not packet2 Then
			packet2 = New TCryptoKK2Packet
		End If
		Return bmx_hydro_kx_kk_2(sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet2.packet, packet1.packet, peerKeyPair.publicKey, keyPair.secretKey, keyPair.publicKey)
	End Function
	
	Rem
	bbdoc: Validates the packet, computes the shared session key and puts it into @sessionKeyPair.
	returns: #True on success, and #False on error.
	End Rem
	Function KK3:Int(state:TCryptoExchangeState, sessionKeyPair:TCryptoSessionKeyPair Var, packet2:TCryptoKK2Packet, keyPair:TCryptoExchangeKeyPair)
		If Not sessionKeyPair Then
			sessionKeyPair = New TCryptoSessionKeyPair
		End If
		Return bmx_hydro_kx_kk_3(state.statePtr, sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet2.packet, keyPair.secretKey, keyPair.publicKey)
	End Function

	Rem
	bbdoc: Initializes the local state @state, computes an ephemeral key pair, and puts the first packet to send to the server into @packet1.
	returns: #True on success, and #False on error.
	about: Using this API, a client and a server can securely generate and exchange session keys.

	This API is designed for online protocols, and requires two round trips:

	* The initiator (client) sends a key exchange request.
	* The listener (server) receives the request, validates it, and sends a packet to the client.
	* The client validates the packet, compute the session keys, and sends a last packet to the server. The client learns the server public key as well, and can drop the connection if it doesn't match an expected public key.
	* The server use this packet and previous data in order to compute the same session keys. The server learns the client public key as well.
	
	Two sessions keys are eventually computed. The former can be used to encrypt data sent from the client to the server, the later can be used
	in the other direction.
	
	If the the pre-shared secret @preSharedKey is set, the server can detect a suspicious request after the first packet is received.
	Without a pre-shared secret, an additional round trip is required.
	End Rem
	Function XX1:Int(state:TCryptoExchangeState Var, packet1:TCryptoXX1Packet Var, preSharedKey:TCryptoKey)
		If Not state Then
			state = New TCryptoExchangeState
		End If
		If Not packet1 Then
			packet1 = New TCryptoXX1Packet
		End If
		If preSharedKey Then
			Return bmx_hydro_kx_xx_1(state.statePtr, packet1.packet, preSharedKey.key)
		Else
			Return bmx_hydro_kx_xx_1(state.statePtr, packet1.packet, Null)
		End If
	End Function

	Rem
	bbdoc: Validates the request, computes an ephemeral key pair, and puts the packet to send to the client into @packet2.
	returns: #True on success, and #False if the received packet doesn't appear to be valid.
	End Rem
	Function XX2:Int(state:TCryptoExchangeState Var, packet2:TCryptoXX2Packet Var, packet1:TCryptoXX1Packet, preSharedKey:TCryptoKey, keyPair:TCryptoExchangeKeyPair)
		If Not state Then
			state = New TCryptoExchangeState
		End If
		If Not packet2 Then
			packet2 = New TCryptoXX2Packet
		End If
		If preSharedKey Then
			Return bmx_hydro_kx_xx_2(state.statePtr, packet2.packet, packet1.packet, preSharedKey.key, keyPair.secretKey, keyPair.publicKey)
		Else
			Return bmx_hydro_kx_xx_2(state.statePtr, packet2.packet, packet1.packet, Null, keyPair.secretKey, keyPair.publicKey)
		End If
	End Function

	Rem
	bbdoc: Validates the packet, computes a session key and puts it into @sessionKeyPair.
	returns: #True on success, and #False if the received packet doesn't appear to be valid.
	about: @sessionKeyPair contains the final session key at this point.
	A payload can already be sent by the client without waiting for the server to compute the session keys on its end.
	End Rem
	Function XX3:Int(state:TCryptoExchangeState, sessionKeyPair:TCryptoSessionKeyPair Var, packet3:TCryptoXX3Packet Var, peerKeyPair:TCryptoExchangeKeyPair Var, packet2:TCryptoXX2Packet, preSharedKey:TCryptoKey, keyPair:TCryptoExchangeKeyPair)
		If Not sessionKeyPair Then
			sessionKeyPair = New TCryptoSessionKeyPair
		End If
		If Not packet3 Then
			packet3 = New TCryptoXX3Packet
		End If
		If Not peerKeyPair Then
			peerKeyPair = New TCryptoExchangeKeyPair
		End If
		If preSharedKey Then
			Return bmx_hydro_kx_xx_3(state.statePtr, sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet3.packet, peerKeyPair.publicKey, packet2.packet, preSharedKey.key, keyPair.secretKey, keyPair.publicKey)
		Else
			Return bmx_hydro_kx_xx_3(state.statePtr, sessionKeyPair.rx.key, sessionKeyPair.tx.key, packet3.packet, peerKeyPair.publicKey, packet2.packet, Null, keyPair.secretKey, keyPair.publicKey)
		End If
	End Function

	Rem
	bbdoc: Validates the packet, computes the session key (identical to the one computed by the client) and puts it into @sessionKeyPair.
	returns: #True on success, and #False if the received packet doesn't appear to be valid.
	End Rem
	Function XX4:Int(state:TCryptoExchangeState, sessionKeyPair:TCryptoSessionKeyPair Var, peerKeyPair:TCryptoExchangeKeyPair Var, packet3:TCryptoXX3Packet, preSharedKey:TCryptoKey)
		If Not sessionKeyPair Then
			sessionKeyPair = New TCryptoSessionKeyPair
		End If
		If Not peerKeyPair Then
			peerKeyPair = New TCryptoExchangeKeyPair
		End If
		If preSharedKey Then
			Return bmx_hydro_kx_xx_4(state.statePtr, sessionKeyPair.rx.key, sessionKeyPair.tx.key, peerKeyPair.publicKey, packet3.packet, preSharedKey.key)
		Else
			Return bmx_hydro_kx_xx_4(state.statePtr, sessionKeyPair.rx.key, sessionKeyPair.tx.key, peerKeyPair.publicKey, packet3.packet, Null)
		End If
	End Function

End Type

Rem
bbdoc: A secret key suitable for use with the #TCryptoHash functions.
End Rem
Type TCryptoPWHashMasterKey

	Field key:Byte[CRYPTO_PWHASH_MASTERKEYBYTES]

	Rem
	bbdoc: Returns a String representation of the key.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(key)
	End Method
	
	Rem
	bbdoc: Retrieves a key from its String representation.
	End Rem
	Function FromString:TCryptoPWHashMasterKey(key:String)
		Local hashKey:TCryptoPWHashMasterKey = New TCryptoPWHashMasterKey
		hashKey.key = TBase64.Decode(key)

		If hashKey.key.length <> CRYPTO_PWHASH_MASTERKEYBYTES Then
			Throw "Unexpected key size of " + hashKey.key.length + " bytes. Expected " + CRYPTO_PWHASH_MASTERKEYBYTES + " bytes"
		End If

		Return hashKey
	End Function
	
End Type


Rem
bbdoc: A fixed-length, hashed, encrypted, authenticated representative of a password, that can be safely stored in a database.
about: This representative can be used to later check if a user provided password is likely to be the original one, without ever
storing the password in the database.
End Rem
Type TCryptoPWHashStoredKey

	Field key:Byte[CRYPTO_PWHASH_STOREDBYTES]

	Rem
	bbdoc: Returns a String representation of the key.
	End Rem
	Method ToString:String()
		Return TBase64.Encode(key, 0, EBase64Options.DontBreakLines)
	End Method
	
	Rem
	bbdoc: Retrieves a key from its String representation.
	End Rem
	Function FromString:TCryptoPWHashStoredKey(key:String)
		Local storedKey:TCryptoPWHashStoredKey = New TCryptoPWHashStoredKey
		storedKey.key = TBase64.Decode(key)

		If storedKey.key.length <> CRYPTO_PWHASH_STOREDBYTES Then
			Throw "Unexpected key size of " + storedKey.key.length + " bytes. Expected " + CRYPTO_PWHASH_STOREDBYTES + " bytes"
		End If

		Return storedKey
	End Function

End Type

Rem
bbdoc: Password Hashing
about: Secret keys used to encrypt or sign confidential data have to be chosen from a very large keyspace.

However, passwords are usually short, human-generated strings, making dictionary attacks practical.

Password hashing functions derive a high-entropy secret key of any size from a password.

The generated key will have the size defined by the application, no matter what the password length is.
* The same password hashed with same parameters will always produce the same output.
* The function deriving a key from a password is CPU intensive, to mitigate brute-force attacks by requiring a significant effort to verify each password.

Common use cases:
* Password storage, or rather: storing what it takes to verify a password without having to store the actual password.
* Deriving a secret key from a password, for example for disk encryption
End Rem
Type TCryptoPasswordHash

	Rem
	bbdoc: Generates a key used to encrypt all hashed passwords, along with their parameters.
	about: Hashed passwords and master keys should be stored in different places: hashed passwords are typically
	stored in a database, whereas the master key can be statically loaded or hardcoded in the application.
	
	If the database ever gets breached, the list of hashed passwords will be completely useless without the master password.

	The storage format supports reencryption and algorithm upgrades.
	End Rem
	Function KeyGen:TCryptoPWHashMasterKey()
		Local key:TCryptoPWHashMasterKey = New TCryptoPWHashMasterKey
		bmx_hydro_pwhash_keygen(key.key)
		Return key
	End Function

	Rem
	bbdoc: Derives a deterministic high-entropy key of any length (@hLen bytes) from a @password, a @context, a master key @masterKey and a set of parameters for the hash function.
	about: The resulting key is put into @h.
* @opslimit is the number of iterations. The higher the number, the slower the function will be, and the more secure the end result will be against brute-force attacks. This should be adjusted according to the hardware, and to application constraints.
* @memlimit is the maximum amount of memory to use. The current function use a fixed amount of memory, and ignores this parameter. It can be unconditionally set to 0.
* @threads is the number of threads. The current function ignores this parameter. It can be unconditionally set to 1.

	This function can be used to derive a key from a password if no other information has been stored. For example, it can be used to
	encrypt/decrypt a file using nothing but a password.
	End Rem
	Function Deterministic:Int(h:Byte Ptr, hLen:Size_T, password:String, context:String, masterKey:TCryptoPWHashMasterKey, opsLimit:ULong, memLimit:Size_T, threads:Int = 1)
		Return bmx_hydro_pwhash_deterministic(h, hLen, password, context, masterKey.key, opsLimit, memLimit, threads)
	End Function

	Rem
	bbdoc: Derives a deterministic high-entropy key of any length from a @password, a @context, a master key @masterKey and a set of parameters for the hash function.
	about: The resulting key is put into @h.
* @opslimit is the number of iterations. The higher the number, the slower the function will be, and the more secure the end result will be against brute-force attacks. This should be adjusted according to the hardware, and to application constraints.
* @memlimit is the maximum amount of memory to use. The current function use a fixed amount of memory, and ignores this parameter. It can be unconditionally set to 0.
* @threads is the number of threads. The current function ignores this parameter. It can be unconditionally set to 1.

	This function can be used to derive a key from a password if no other information has been stored. For example, it can be used to
	encrypt/decrypt a file using nothing but a password.
	End Rem
	Function Deterministic:Int(h:Byte[], password:String, context:String, masterKey:TCryptoPWHashMasterKey, opsLimit:ULong, memLimit:Size_T, threads:Int = 1)
		Return bmx_hydro_pwhash_deterministic(h, Size_T(h.length), password, context, masterKey.key, opsLimit, memLimit, threads)
	End Function

	Rem
	bbdoc: Computes a fixed-length (#CRYPTO_PWHASH_STOREDBYTES bytes), hashed, encrypted, authenticated representative of the @password, that can be safely stored in a database.
	about: This representative can be used to later check if a user provided password is likely to be the original one,
	without ever storing the password in the database.

	The function encrypts and authenticates the representative and the parameters using the master key @masterKey. All passwords can safely
	be encrypted using the same, long-term master key. Applications can also choose to derive @masterKey from a master-master key, and a
	unique user identifier.

	The representative includes @opsLimit, @memLimit and @threads: these do not have to be stored separately.

	Note that the representative is not a string: this is binary data, that must be stored as a blob in a database, or encoded
	as a string (for example as a hex value or using a safe base64 variant).
	End Rem
	Function Create:Int(stored:TCryptoPWHashStoredKey Var, password:String, masterKey:TCryptoPWHashMasterKey, opsLimit:ULong, memLimit:Size_T, threads:Int = 1)
		If Not stored Then
			stored = New TCryptoPWHashStoredKey
		End If
		Return bmx_hydro_pwhash_create(stored.key, password, masterKey.key, opsLimit, memLimit, threads)
	End Function

	Rem
	bbdoc: Verifies that the @password is valid for the stored representative stored, decrypted using @masterKey.
	about: @opslimitMax, @memlimitMax and @threadsMax are maximum values, designed to prevent DoS attacks against applications if the input
	is untrusted. They should be set to the maximum values ever used in the #Create() function.

	If the encoded parameters in the representative exceed these values, the function returns #False.

	If the representative cannot be decrypted, the function returns #False without even trying to hash the password.

	If the password doesn't appear to be valid for the stored representative, the function returns #False.
	If the password passes all the checks, the function returns #True.
	End Rem
	Function Verify:Int(stored:TCryptoPWHashStoredKey, password:String, masterKey:TCryptoPWHashMasterKey, opsLimitMax:ULong, memLimitMax:Size_T, threadsMax:Int = 1)
		Return bmx_hydro_pwhash_verify(stored.key, password, masterKey.key, opsLimitMax, memLimitMax, threadsMax)
	End Function
	
	Rem
	bbdoc: Fills @staticKey with @staticKeyLen bytes derived from the representative for @password.
	about: Verifies that @password is valid for the representative. If this is the case, it fills @staticKey with @staticKeyLen bytes derived
	from that representative, and returns #True.

	If the password doesn't appear to be valid for what was stored, the function returns #False.

	This function can be used to derive a deterministic, high-entropy key from a password and user-specific data stored in a database.
	End Rem
	Function DeriveStaticKey:Int(staticKey:Byte Ptr, staticKeyLen:Size_T, stored:TCryptoPWHashStoredKey, password:String, context:String, masterKey:TCryptoPWHashMasterKey, opsLimit:ULong, memLimit:Size_T, threads:Int = 1)
		Return bmx_hydro_pwhash_derive_static_key(staticKey, staticKeyLen, stored.key, password, context, masterKey.key, opsLimit, memLimit, threads)
	End Function

	Rem
	bbdoc: Fills @staticKey with bytes derived from the representative for @password.
	about: Verifies that @password is valid for the representative. If this is the case, it fills @staticKey with bytes derived
	from that representative, and returns #True.

	If the password doesn't appear to be valid for what was stored, the function returns #False.

	This function can be used to derive a deterministic, high-entropy key from a password and user-specific data stored in a database.
	End Rem
	Function DeriveStaticKey:Int(staticKey:Byte[], stored:TCryptoPWHashStoredKey, password:String, context:String, masterKey:TCryptoPWHashMasterKey, opsLimit:ULong, memLimit:Size_T, threads:Int = 1)
		Return bmx_hydro_pwhash_derive_static_key(staticKey, Size_T(staticKey.length), stored.key, password, context, masterKey.key, opsLimit, memLimit, threads)
	End Function
	
	Rem
	bbdoc: Reencrypts a representative stored using the current master key @masterKey and a new master key @newMasterKey.
	about: It updates stored in-place and returns #True on success. If the representative couldn't be decrypted using @masterKey, the function returns #False.
	End Rem
	Function Reencrypt:Int(stored:TCryptoPWHashStoredKey, masterKey:TCryptoPWHashMasterKey, newMasterKey:TCryptoPWHashMasterKey)
		Return bmx_hydro_pwhash_reencrypt(stored.key, masterKey.key, newMasterKey.key)
	End Function
	
	Rem
	bbdoc: Upgrades in-place a previously computed representative stored encrypted using the master key @masterKey, to the new parameters @opslimit, @memlimit and @threads.
	returns: #True on success, or #False if the data couldn't be decrypted using the provided master password.
	about: If previously passwords become too fast to verify after a hardware upgrade, stored representatives can be upgraded with new
	parameters without requiring the original passwords.
	
	Note that parameters can only be increased. Trying to reduce the value of an existing parameter will not change the original value.
	End Rem
	Function Upgrade:Int(stored:TCryptoPWHashStoredKey, masterKey:TCryptoPWHashMasterKey, opsLimit:ULong, memLimit:Size_T, threads:Int = 1)
		Return bmx_hydro_pwhash_upgrade(stored.key, masterKey.key, opsLimit, memLimit, threads)
	End Function
	
End Type

