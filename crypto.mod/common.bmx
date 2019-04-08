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

Import pub.libhydrogen
Import brl.base64

?win32
Import "-ladvapi32"
?

Import "../../pub.mod/libhydrogen.mod/libhydrogen/*.h"
Import "glue.c"

Extern

	Function hydro_init:Int()
	
	Function hydro_random_u32:UInt()
	Function hydro_random_uniform:UInt(upperBound:UInt)
	Function hydro_random_buf(buf:Byte Ptr, outLen:Size_T)
	Function hydro_random_ratchet()
	Function hydro_random_reseed()

	Function bmx_hydro_hash_keygen(key:Byte Ptr)
	Function bmx_hydro_hash_hash:Int(out:Byte Ptr, outLen:Size_T, in:Byte Ptr, inLen:Size_T, context:String, key:Byte Ptr)
	Function bmx_hydro_hash_init:Byte Ptr(context:String, key:Byte Ptr)
	Function bmx_hydro_hash_state_free(handle:Byte Ptr)
	Function bmx_hydro_hash_update:Int(handle:Byte Ptr, in:Byte Ptr, inLen:Size_T)
	Function bmx_hydro_hash_final:Int(handle:Byte Ptr, out:Byte Ptr, outLen:Size_T)
	
	Function bmx_hydro_secretbox_keygen(key:Byte Ptr)
	Function bmx_hydro_secretbox_encrypt:Int(c:Byte Ptr, m:Byte Ptr, mLen:Size_T, msgId:ULong, context:String, key:Byte Ptr)
	Function bmx_hydro_secretbox_decrypt:Int(m:Byte Ptr, c:Byte Ptr, cLen:Size_T, msgId:ULong, context:String, key:Byte Ptr)
	Function bmx_hydro_secretbox_probe_create(probe:Byte Ptr, c:Byte Ptr, cLen:Size_T, context:String, key:Byte Ptr)
	Function bmx_hydro_secretbox_probe_verify:Int(probe:Byte Ptr, c:Byte Ptr, cLen:Size_T, context:String, key:Byte Ptr)

	Function bmx_hydro_pwhash_keygen(key:Byte Ptr)
	Function bmx_hydro_pwhash_create:Int(stored:Byte Ptr, password:String, masterKey:Byte Ptr, opsLimit:ULong, memLimit:Size_T, threads:Int)
	Function bmx_hydro_pwhash_verify:Int(stored:Byte Ptr, password:String, masterKey:Byte Ptr, opsLimitMax:ULong, memLimitMax:Size_T, threadsMax:Int)
	Function bmx_hydro_pwhash_derive_static_key:Int(staticKey:Byte Ptr, staticKeyLen:Size_T, stored:Byte Ptr, password:String, context:String, masterKey:Byte Ptr, opsLimit:ULong, memLimit:Size_T, threads:Int)
	Function bmx_hydro_pwhash_reencrypt:Int(stored:Byte Ptr, masterKey:Byte Ptr, newMasterKey:Byte Ptr)
	Function bmx_hydro_pwhash_upgrade:Int(stored:Byte Ptr, masterKey:Byte Ptr, opsLimit:ULong, memLimit:Size_T, threads:Int)
	Function bmx_hydro_pwhash_deterministic:Int(h:Byte Ptr, hLen:Size_T, password:String, context:String, masterKey:Byte Ptr, opsLimit:ULong, memLimit:Size_T, threads:Int)

	Function bmx_hydro_sign_keygen(secretKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_sign_create:Int(csig:Byte Ptr, m:Byte Ptr, mLen:Size_T, context:String, sk:Byte Ptr)
	Function bmx_hydro_sign_verify:Int(csig:Byte Ptr, m:Byte Ptr, mLen:Size_T, context:String, pk:Byte Ptr)
	Function bmx_hydro_sign_init:Byte Ptr(context:String)
	Function bmx_hydro_sign_state_free(state:Byte Ptr)
	Function bmx_hydro_sign_update:Int(state:Byte Ptr, m:Byte Ptr, mLen:Size_T)
	Function bmx_hydro_sign_final_create:Int(state:Byte Ptr, csig:Byte Ptr, sk:Byte Ptr)
	Function bmx_hydro_sign_final_verify:Int(state:Byte Ptr, csig:Byte Ptr, pk:Byte Ptr)

	Function bmx_hydro_kx_keygen(secretKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_kx_n_1:Int(rx:Byte Ptr, tx:Byte Ptr, packet1:Byte Ptr, preSharedKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_kx_n_2:Int(rx:Byte Ptr, tx:Byte Ptr, packet1:Byte Ptr, preSharedKey:Byte Ptr, secretKey:Byte Ptr, publicKey:Byte Ptr)

	Function bmx_hydro_kx_state_new:Byte Ptr()
	Function bmx_hydro_kx_state_free(state:Byte Ptr)

	Function bmx_hydro_kx_kk_1:Int(state:Byte Ptr, packet1:Byte Ptr, peerPublicKey:Byte Ptr, secretKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_kx_kk_2:Int(rx:Byte Ptr, tx:Byte Ptr, packet2:Byte Ptr, packet1:Byte Ptr, peerPublicKey:Byte Ptr, secretKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_kx_kk_3:Int(state:Byte Ptr, rx:Byte Ptr, tx:Byte Ptr, packet2:Byte Ptr, secretKey:Byte Ptr, publicKey:Byte Ptr)

	Function bmx_hydro_kx_xx_1:Int(state:Byte Ptr, packet1:Byte Ptr, preSharedKey:Byte Ptr)
	Function bmx_hydro_kx_xx_2:Int(state:Byte Ptr, packet2:Byte Ptr, packet1:Byte Ptr, preSharedKey:Byte Ptr, secretKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_kx_xx_3:Int(state:Byte Ptr, rx:Byte Ptr, tx:Byte Ptr, packet3:Byte Ptr, peerPublicKey:Byte Ptr, packet2:Byte Ptr, preSharedKey:Byte Ptr, secretKey:Byte Ptr, publicKey:Byte Ptr)
	Function bmx_hydro_kx_xx_4:Int(state:Byte Ptr, rx:Byte Ptr, tx:Byte Ptr, peerPublicKey:Byte Ptr, packet3:Byte Ptr, preSharedKey:Byte Ptr)

End Extern


Const CRYPTO_HASH_BYTES:Int = 32
Const CRYPTO_HASH_BYTES_MAX:Int = 65535
Const CRYPTO_HASH_BYTES_MIN:Int = 16
Const CRYPTO_HASH_CONTEXTBYTES:Int = 8
Const CRYPTO_HASH_KEYBYTES:Int = 32

Const CRYPTO_SECRETBOX_CONTEXTBYTES:Int = 8
Const CRYPTO_SECRETBOX_HEADERBYTES:Int = 20 + 16
Const CRYPTO_SECRETBOX_KEYBYTES:Int = 32
Const CRYPTO_SECRETBOX_PROBEBYTES:Int = 16

Const CRYPTO_PWHASH_CONTEXTBYTES:Int = 8
Const CRYPTO_PWHASH_MASTERKEYBYTES:Int = 32
Const CRYPTO_PWHASH_STOREDBYTES:Int = 128

Const CRYPTO_SIGN_BYTES:Int = 64
Const CRYPTO_SIGN_CONTEXTBYTES:Int = 8
Const CRYPTO_SIGN_PUBLICKEYBYTES:Int = 32
Const CRYPTO_SIGN_SECRETKEYBYTES:Int = 64
Const CRYPTO_SIGN_SEEDBYTES:Int = 32

Const CRYPTO_KX_SESSIONKEYBYTES:Int = 32
Const CRYPTO_KX_PUBLICKEYBYTES:Int = 32
Const CRYPTO_KX_SECRETKEYBYTES:Int = 32
Const CRYPTO_KX_PSKBYTES:Int = 32
Const CRYPTO_KX_SEEDBYTES:Int = 32

Const CRYPTO_KX_N_PACKET1BYTES:Int = 32

Const CRYPTO_KX_KK_PACKET1BYTES:Int = 32
Const CRYPTO_KX_KK_PACKET2BYTES:Int = 32

Const CRYPTO_KX_XX_PACKET1BYTES:Int = 32
Const CRYPTO_KX_XX_PACKET2BYTES:Int = 80
Const CRYPTO_KX_XX_PACKET3BYTES:Int = 48
