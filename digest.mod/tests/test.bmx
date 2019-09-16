SuperStrict

Framework brl.standardio
Import brl.md5digest
Import brl.sha1digest
Import brl.sha256digest
Import brl.sha512digest
Import brl.crc32
Import BRL.MaxUnit

New TTestSuite.run()

Type TDigestTest Extends TTest

	Const TEST_PHRASE:String = "The quick brown fox jumps over the lazy dog"

	Const MD5_HASH_STRING:String = "9e107d9d372bb6826bd81d3542a419d6"
	Global MD5_HASH_ARRAY:Byte[] = [158, 16, 125, 157, 55, 43, 182, 130, 107, 216, 29, 53, 66, 164, 25, 214]

	Const SHA1_HASH_STRING:String = "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
	Global SHA1_HASH_ARRAY:Byte[] = [47, 212, 225, 198, 122, 45, 40, 252, 237, 132, 158, 225, 187, 118, 231, 57, 27, 147, 235, 18]
	
	Const SHA256_HASH_STRING:String = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
	Global SHA256_HASH_ARRAY:Byte[] = [215, 168, 251, 179, 7, 215, 128, 148, 105, 202, 154, 188, 176, 8, 46, 79, 141, 86, 81, 228, 109, 60, 219, 118, 45, 2, 208, 191, 55, 201, 229, 146]
	
	Const SHA512_HASH_STRING:String = "07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6"
	Global SHA512_HASH_ARRAY:Byte[] = [7, 229, 71, 217, 88, 111, 106, 115, 247, 63, 186, 192, 67, 94, 215, 105, 81, 33, 143, 183, 208, 200, 215, ..
									136, 163, 9, 215, 133, 67, 107, 187, 100, 46, 147, 162, 82, 169, 84, 242, 57, 18, 84, 125, 30, 138, 59, 94, ..
									214, 225, 191, 215, 9, 120, 33, 35, 63, 160, 83, 143, 61, 184, 84, 254, 230]

	Const CRC32_HASH_STRING:String = "414fa339"
	Global CRC32_HASH_ARRAY:Byte[] = [65, 79, 163, 57]
	Const CRC32_INT:Int = 1095738169
	
	Method testMD5() { test }
	
		Local digest:TMessageDigest = GetMessageDigest("MD5")
	
		assertEquals(MD5_HASH_STRING, digest.Digest(TEST_PHRASE))
	
		Local bytes:Byte[] = digest.DigestBytes(TEST_PHRASE)

		assertEquals(MD5_HASH_ARRAY.length, bytes.length)
		
		For Local i:Int = 0 Until MD5_HASH_ARRAY.length
			assertEquals(MD5_HASH_ARRAY[i], bytes[i])
		Next
	
	End Method

	Method testSHA1() { test }
	
		Local digest:TMessageDigest = GetMessageDigest("SHA1")
	
		assertEquals(SHA1_HASH_STRING, digest.Digest(TEST_PHRASE))
	
		Local bytes:Byte[] = digest.DigestBytes(TEST_PHRASE)

		assertEquals(SHA1_HASH_ARRAY.length, bytes.length)
		
		For Local i:Int = 0 Until SHA1_HASH_ARRAY.length
			assertEquals(SHA1_HASH_ARRAY[i], bytes[i])
		Next
	
	End Method

	Method testSHA256() { test }
	
		Local digest:TMessageDigest = GetMessageDigest("SHA256")
	
		assertEquals(SHA256_HASH_STRING, digest.Digest(TEST_PHRASE))
	
		Local bytes:Byte[] = digest.DigestBytes(TEST_PHRASE)

		assertEquals(SHA256_HASH_ARRAY.length, bytes.length)
		
		For Local i:Int = 0 Until SHA256_HASH_ARRAY.length
			assertEquals(SHA256_HASH_ARRAY[i], bytes[i])
		Next
	
	End Method

	Method testSHA512() { test }
	
		Local digest:TMessageDigest = GetMessageDigest("SHA512")
	
		assertEquals(SHA512_HASH_STRING, digest.Digest(TEST_PHRASE))
	
		Local bytes:Byte[] = digest.DigestBytes(TEST_PHRASE)

		assertEquals(SHA512_HASH_ARRAY.length, bytes.length)
		
		For Local i:Int = 0 Until SHA512_HASH_ARRAY.length
			assertEquals(SHA512_HASH_ARRAY[i], bytes[i])
		Next
	
	End Method

	Method testCRC32() { test }
	
		Local digest:TMessageDigest = GetMessageDigest("CRC32")
	
		assertEquals(CRC32_HASH_STRING, digest.Digest(TEST_PHRASE))
	
		Local bytes:Byte[] = digest.DigestBytes(TEST_PHRASE)

		assertEquals(CRC32_HASH_ARRAY.length, bytes.length)
		
		For Local i:Int = 0 Until CRC32_HASH_ARRAY.length
			assertEquals(CRC32_HASH_ARRAY[i], bytes[i])
		Next
		
		Local crc32:TCRC32 = TCRC32(digest)
		Local result:Int
		crc32.Digest(TEST_PHRASE, result)
		
		assertEquals(CRC32_INT, result)
	
	End Method

End Type
