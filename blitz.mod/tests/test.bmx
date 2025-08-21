SuperStrict

Framework brl.standardio
Import BRL.MaxUnit

New TTestSuite.run()

Type TStringTest Extends TTest

	Field bigUnicode:UInt[] = [$10300, $10301, $10302, $10303, $10304, $10305, 0]
	Field unicode:Int[] = [1055, 1088, 1080, 1074, 1077, 1090]
	Field utf8:Byte[] = [208, 159, 209, 128, 208, 184, 208, 178, 208, 181, 209, 130, 0]

	Const HELLO_UPPER:String = "HELLO"
	Const HELLO_LOWER:String = "hello"
	Const UMLAUT_UPPER:String = "123ÄÖÜABC"
	Const UMLAUT_LOWER:String = "123äöüabc"
	Const ARABIC_UPPER:String = "123كلمة"
	Const ARABIC_LOWER:String = "123كلمة"
	Const CYRILLIC_UPPER:String = "123БУДИНОК"
	Const CYRILLIC_LOWER:String = "123будинок"
	
	Method setup() { before }
	End Method

	Method testUTF32() { test }
		Local s:String = String.FromUTF32String(bigUnicode);
		assertEquals(12, s.Length)
		
		Local buf:UInt Ptr = s.ToUTF32String()
		For Local i:Int = 0 Until 7
			assertEquals( bigUnicode[i], buf[i] )
		Next
	End Method

	Method testToUTF8StringBuffer() { test }
		Local s:String = "1234567890"
		Local buf:Byte Ptr = StackAlloc(50)

		Local length:size_t = 10
		s.ToUTF8StringBuffer(buf, length)

	End Method

	Method testASCIIToLower() { test }
		Local s:String = HELLO_UPPER
		assertEquals(HELLO_LOWER, s.ToLower())

		Local obj:Object = HELLO_LOWER
		Local obj1:Object = HELLO_LOWER.ToLower()

		assertTrue(obj = obj1, "Already lowercase ASCII strings should return the same object")

	End Method

	Method testASCIIToUpper() { test }
		Local s:String = HELLO_LOWER
		assertEquals(HELLO_UPPER, s.ToUpper())

		Local obj:Object = HELLO_UPPER
		Local obj1:Object = HELLO_UPPER.ToUpper()

		assertTrue(obj = obj1, "Already uppercase ASCII strings should return the same object")

	End Method

	Method testUnicodeToLower() { test }

		Local s:String = UMLAUT_UPPER
		assertEquals(UMLAUT_LOWER, s.ToLower())

		Local obj:Object = UMLAUT_LOWER
		Local obj1:Object = UMLAUT_LOWER.ToLower()

		assertTrue(obj = obj1, "Already lowercase Unicode strings should return the same object")

	End Method

	Method testUnicodeToUpper() { test }

		Local s:String = UMLAUT_LOWER
		assertEquals(UMLAUT_UPPER, s.ToUpper())

		Local obj:Object = UMLAUT_UPPER
		Local obj1:Object = UMLAUT_UPPER.ToUpper()

		assertTrue(obj = obj1, "Already uppercase Unicode strings should return the same object")

	End Method

	Method testArabicToLower() { test }

		Local s:String = ARABIC_UPPER
		assertEquals(ARABIC_LOWER, s.ToLower(), "Arabic lower case")

		Local obj:Object = ARABIC_LOWER
		Local obj1:Object = ARABIC_LOWER.ToLower()

		assertTrue(obj = obj1, "Already lowercase Arabic strings should return the same object")

	End Method

	Method testArabicToUpper() { test }

		Local s:String = ARABIC_LOWER
		assertEquals(ARABIC_UPPER, s.ToUpper(), "Arabic upper case")

		Local obj:Object = ARABIC_UPPER
		Local obj1:Object = ARABIC_UPPER.ToUpper()

		assertTrue(obj = obj1, "Already uppercase Arabic strings should return the same object")

	End Method

	Method testArabicUpperToLower() { test }

		Local s:String = ARABIC_UPPER
		assertEquals(ARABIC_UPPER, s.ToLower(), "Arabic lower case and upper case should be the same")

		Local obj:Object = ARABIC_UPPER
		Local obj1:Object = ARABIC_UPPER.ToLower()

		assertTrue(obj = obj1, "Uppercase Arabic strings should return the same object when lowered")

	End Method

	Method testArabicLowerToUpper() { test }

		Local s:String = ARABIC_LOWER
		assertEquals(ARABIC_LOWER, s.ToUpper(), "Arabic upper case and lower case should be the same")

		Local obj:Object = ARABIC_LOWER
		Local obj1:Object = ARABIC_LOWER.ToUpper()

		assertTrue(obj = obj1, "Lowercase Arabic strings should return the same object when uppered")

	End Method

	Method testCyrillicToLower() { test }

		Local s:String = CYRILLIC_UPPER
		assertEquals(CYRILLIC_LOWER, s.ToLower(), "Cyrillic lower case")

		Local obj:Object = CYRILLIC_LOWER
		Local obj1:Object = CYRILLIC_LOWER.ToLower()

		assertTrue(obj = obj1, "Already lowercase Cyrillic strings should return the same object")

	End Method

	Method testCyrrilicToUpper() { test }

		Local s:String = CYRILLIC_LOWER
		assertEquals(CYRILLIC_UPPER, s.ToUpper(), "Cyrillic upper case")

		Local obj:Object = CYRILLIC_UPPER
		Local obj1:Object = CYRILLIC_UPPER.ToUpper()

		assertTrue(obj = obj1, "Already uppercase Cyrillic strings should return the same object")

	End Method

End Type

Struct STestStruct
	Field a:Int
	Field c:Float
	Field d:Double
	Field b:ULong
End Struct

Type TStructArrayTest Extends TTest

	Method testStructArray() { test }

		Local arr:STestStruct[] = New STestStruct[10]
		
		For Local i:Int = 0 Until 10
			arr[i].a = i
			arr[i].b = i * i
		Next

		For Local i:Int = 0 Until 10
			assertEquals(i, arr[i].a)
			assertEquals(i * i, arr[i].b)
		Next
	End Method

	Method testStructArraySlice() { test }

		Local arr:STestStruct[] = New STestStruct[10]
		
		For Local i:Int = 0 Until 10
			arr[i].a = i
			arr[i].b = i * i
		Next

		Local slice:STestStruct[] = arr[2..5]

		assertEquals(3, slice.Length)
		assertEquals(2, slice[0].a)
		assertEquals(3, slice[1].a)
		assertEquals(4, slice[2].a)
	End Method

End Type

Type TStringToDoubleExTest Extends TTest

	Method testToDoubleEx() { test }
		Local val:Double
		Local s:String = "123.456"
		assertEquals(7, s.ToDoubleEx(val))
		assertEquals(123.456, val, 0.0001)
	End Method

	Method testToDoubleExMulti() { test }
		Local val:Double
		Local s:String = "1,2,3,4,5,6,7,8,9,10"

		Local start:Int = 0
		For Local i:Int = 0 Until 10
			start = s.ToDoubleEx(val, start) + 1

			assertFalse(start = 1)
			assertEquals(i + 1, val, 0.0001)
		Next
	End Method

	Method testToDoubleExMultiTab() { test }
		Local val:Double
		Local s:String = "1~t2~t3~t4~t5~t6~t7~t8~t9~t10"

		Local start:Int = 0
		For Local i:Int = 0 Until 10
			start = s.ToDoubleEx(val, start,,CHARSFORMAT_SKIPWHITESPACE)
			assertFalse(start = 0)
			assertEquals(i + 1, val, 0.0001)
		Next
	End Method

	Method testLeadingWhitespace() { test }
		Local val:Double
		Local s:String = "  ~t123.456"
		assertEquals(10, s.ToDoubleEx(val,,,CHARSFORMAT_SKIPWHITESPACE))
		assertEquals(123.456, val, 0.0001)
	End Method

	Method testToDoubleExCommaSeparator() { test }
		Local val:Double
		Local s:String = "123,456"
		assertEquals(7, s.ToDoubleEx(val,,,,","))
		assertEquals(123.456, val, 0.0001)
	End Method

End Type

Type TStringToFloatExTest Extends TTest

	Method testToFloatEx() { test }
		Local val:Float
		Local s:String = "123.456"
		assertEquals(7, s.ToFloatEx(val))
		assertEquals(123.456, val, 0.0001)
	End Method

	Method testToFloatExMulti() { test }
		Local val:Float
		Local s:String = "1,2,3,4,5,6,7,8,9,10"

		Local start:Int = 0
		For Local i:Int = 0 Until 10
			start = s.ToFloatEx(val, start) + 1

			assertFalse(start = 1)
			assertEquals(i + 1, val, 0.0001)
		Next
	End Method

	Method testLeadingWhitespace() { test }
		Local val:Float
		Local s:String = "  ~t123.456"
		assertEquals(10, s.ToFloatEx(val,,,CHARSFORMAT_SKIPWHITESPACE))
		assertEquals(123.456, val, 0.0001)
	End Method

	Method testToFloatExCommaSeparator() { test }
		Local val:Float
		Local s:String = "123,456"
		assertEquals(7, s.ToFloatEx(val,,,,","))
		assertEquals(123.456, val, 0.0001)
	End Method

End Type

Type TStringToIntExTest Extends TTest

	Method testToIntEx() { test }
		Local val:Int
		Local s:String = "123456"
		assertEquals(6, s.ToIntEx(val))
		assertEquals(123456, val)
	End Method

	Method testToIntExMulti() { test }
		Local val:Int
		Local s:String = "1,2,3,4,5,6,7,8,9,10"

		Local start:Int = 0
		For Local i:Int = 0 Until 10
			start = s.ToIntEx(val, start) + 1

			assertFalse(start = 1)
			assertEquals(i + 1, val)
		Next
	End Method

	Method testLeadingWhitespace() { test }
		Local val:Int
		Local s:String = "  ~t123456"
		assertEquals(9, s.ToIntEx(val,,,CHARSFORMAT_SKIPWHITESPACE))
		assertEquals(123456, val)
	End Method

	Method testHex() { test }
		Local val:Int
		Local s:String = "abc001"
		assertEquals(6, s.ToIntEx(val,,,,16))
		assertEquals(11255809, val)
	End Method

End Type

Type TStringFromUTF8BytesTest Extends TTest

    ' Test valid ASCII conversion.
    Method testASCII() { test }
        Local data:Byte[] = [72, 101, 108, 108, 111] ' "Hello"
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals("Hello", text)
    End Method

    ' Test conversion of a 2-byte UTF-8 sequence (e.g. ©: U+00A9).
    Method testTwoByteSequence() { test }
        ' © U+00A9: UTF-8: $C2, $A9.
        Local data:Byte[] = [$C2, $A9]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals(Chr($00A9), text)
    End Method

    ' Test conversion of a 3-byte UTF-8 sequence (e.g. €: U+20AC).
    Method testThreeByteSequence() { test }
        ' € U+20AC: UTF-8: $E2, $82, $AC.
        Local data:Byte[] = [$E2, $82, $AC]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals(Chr($20AC), text)
    End Method

    ' Test conversion of a 4-byte UTF-8 sequence (e.g. U+1F600: grinning face emoji).
    Method testFourByteSequence() { test }
        ' Grinning Face U+1F600: UTF-8: $F0, $9F, $98, $80.
        Local data:Byte[] = [$F0, $9F, $98, $80]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        ' Expected string in UTF-16: surrogate pair (high: $D83D, low: $DE00).
        Local expected:String = Chr($D83D) + Chr($DE00)
        assertEquals(expected, text)
    End Method

    ' Test an incomplete sequence (missing continuation bytes).
    Method testIncompleteSequence() { test }
        ' Incomplete 3-byte sequence: [$E2, $82] missing the final byte.
        Local data:Byte[] = [$E2, $82]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        ' Expect a replacement character.
        assertEquals(Chr($FFFD), text)
    End Method

    ' Test an invalid continuation byte following a valid starter.
    Method testInvalidContinuation() { test }
        ' [$C2, $20]: $20 is not a valid continuation byte.
        Local data:Byte[] = [$C2, $20]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals(Chr($FFFD), text)
    End Method

    ' Test a stray continuation byte.
    Method testStrayContinuation() { test }
        ' A single continuation byte $80 is invalid.
        Local data:Byte[] = [$80]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals(Chr($FFFD), text)
    End Method

    ' Test a mix of valid and invalid sequences.
    Method testMixedValidInvalid() { test }
        ' "A" ($41), stray continuation ($80), then "B" ($42).
        Local data:Byte[] = [65, $80, 66]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        Local expected:String = Chr(65) + Chr($FFFD) + Chr(66)
        assertEquals(expected, text)
    End Method

    ' Test overlong encoding.
    Method testOverlongEncoding() { test }
        ' Overlong encoding for NUL: [$C0, $80] should be rejected.
        Local data:Byte[] = [$C0, $80]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals(Chr($FFFD), text)
    End Method

    ' Test a UTF-8 sequence encoding a surrogate half (e.g. U+D800).
    Method testSurrogateHalf() { test }
        ' U+D800 encoded in UTF-8: [$ED, $A0, $80].
        Local data:Byte[] = [$ED, $A0, $80]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        assertEquals(Chr($FFFD), text)
    End Method

	' Test conversion of Russian "hello" ("привет").
	Method testRussianHello() { test }
		' "привет": [$D0, $BF, $D1, $80, $D0, $B8, $D0, $B2, $D0, $B5, $D1, $82]
		Local data:Byte[] = [$D0, $BF, $D1, $80, $D0, $B8, $D0, $B2, $D0, $B5, $D1, $82]
		Local text:String = String.FromUTF8Bytes(data, data.Length)
		assertEquals("привет", text)
	End Method

	' Test conversion of Japanese "hello" ("こんにちは").
	Method testJapaneseHello() { test }
		' "こんにちは": [$E3, $81, $93, $E3, $82, $93, $E3, $81, $AB, $E3, $81, $A1, $E3, $81, $AF]
		Local data:Byte[] = [$E3, $81, $93, $E3, $82, $93, $E3, $81, $AB, $E3, $81, $A1, $E3, $81, $AF]
		Local text:String = String.FromUTF8Bytes(data, data.Length)
		assertEquals("こんにちは", text)
	End Method

	' Test conversion of Chinese "hello" ("你好").
	Method testChineseHello() { test }
		' "你好": [$E4, $BD, $A0, $E5, $A5, $BD]
		Local data:Byte[] = [$E4, $BD, $A0, $E5, $A5, $BD]
		Local text:String = String.FromUTF8Bytes(data, data.Length)
		assertEquals("你好", text)
	End Method

	 ' Test an incomplete 4-byte sequence where only the first byte is provided,
    ' followed by valid ASCII ("A").
    Method testIncomplete4ByteSequenceAfterOneByte() { test }
        ' Array: [$F0, 65, 65, 65, 65]
        ' $F0 begins a 4-byte sequence, but $41 (65) is not a valid continuation byte.
        ' Expected output: Replacement character then "A".
        Local data:Byte[] = [$F0, 65, 65, 65, 65]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        Local expected:String = Chr($FFFD) + Chr(65)
        assertEquals(expected, text)
    End Method

    ' Test an incomplete 4-byte sequence with one valid continuation byte,
    ' followed by a valid ASCII ("A").
    Method testIncomplete4ByteSequenceAfterTwoBytes() { test }
        ' Array: [$F0, $9F, 65, 65, 65]
        ' $F0 followed by $9F (a valid continuation candidate), then 65 which is invalid as a continuation.
        ' Expected output: Replacement character then "A".
        Local data:Byte[] = [$F0, $9F, 65, 65, 65]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        Local expected:String = Chr($FFFD) + Chr(65)
        assertEquals(expected, text)
    End Method

    ' Test an incomplete 4-byte sequence with two valid continuation bytes,
    ' followed by a valid ASCII ("A").
    Method testIncomplete4ByteSequenceAfterThreeBytes() { test }
        ' Array: [$F0, $9F, $98, 65, 65]
        ' $F0, $9F, $98 are read as the first three bytes of a 4-byte sequence;
        ' then 65 is encountered instead of a valid continuation byte.
        ' Expected output: Replacement character then "A".
        Local data:Byte[] = [$F0, $9F, $98, 65, 65]
        Local text:String = String.FromUTF8Bytes(data, data.Length)
        Local expected:String = Chr($FFFD) + Chr(65)
        assertEquals(expected, text)
    End Method
	
End Type
