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

Extern
	Function bbStrToInt:Int(s:Short Ptr, length:Int, end_index:Int Ptr)="int bbStrToInt(const BBChar *,int,int*)"
	Function bbStrToLong:Long(s:Short Ptr, length:Int, end_index:Int Ptr)="BBLONG bbStrToLong(const BBChar *,int,int*)"
	Function bbStrToUInt:UInt(s:Short Ptr, length:Int, end_index:Int Ptr)="BBUINT bbStrToUInt(const BBChar *,int,int*)"
	Function bbStrToShort:Short(s:Short Ptr, length:Int, end_index:Int Ptr)="BBSHORT bbStrToShort(const BBChar *,int,int*)"
	Function bbStrToByte:Byte(s:Short Ptr, length:Int, end_index:Int Ptr)="BBBYTE bbStrToByte(const BBChar *,int,int*)"
	Function bbStrToULong:ULong(s:Short Ptr, length:Int, end_index:Int Ptr)="BBULONG bbStrToULong(const BBChar *,int,int*)"
End Extern

Const INT_MAX:Int = 2147483647
Const INT_MIN:Int = -2147483648

' Set this to False if your C parser stops updating end_index on overflow (i.e., leaves it on the last valid digit).
Const OVERFLOW_CONSUMES_ALL_DIGITS:Int = True

Type TIntCase
	Field s:String
	Field expected:Int
	Field consumed:Int
	Field isOverflow:Int  ' 1 if this row expects overflow clamping

	Method New(s:String, expected:Int, consumed:Int, isOverflow:Int = False)
		self.s = s
		self.expected = expected
		self.consumed = consumed
		self.isOverflow = isOverflow
	End Method

	' Adjust consumed for implementations that don't advance end_index across overflow digits.
	Method AdjustConsumed:Int()
		If isOverflow And Not OVERFLOW_CONSUMES_ALL_DIGITS Then Return consumed - 1
		Return consumed
	End Method

	Method ParseWithBBInt:Int(consumed:Int Var)
		' Prepare UTF-16 buffer
		Local n:Size_t = s.Length + 1
		Local buf:Short[] = New Short[n]
		s.ToWStringBuffer(buf, n)
		' Call the native parser
		Local end_index:Int = -1
		Local value:Int = bbStrToInt(buf, Int(n), VarPtr end_index)

		consumed = end_index
		Return value
	End Method
End Type

Const LONG_MAX:Long = (Long(1) Shl 63) - 1
Const LONG_MIN:Long = - (Long(1) Shl 63)

Type TLongCase
	Field s:String
	Field expected:Long
	Field consumed:Int
	Field isOverflow:Int  ' 1 if this row expects overflow clamping

	Method New(s:String, expected:Long, consumed:Int, isOverflow:Int = False)
		Self.s = s
		Self.expected = expected
		Self.consumed = consumed
		Self.isOverflow = isOverflow
	End Method

	' Adjust consumed for implementations that don't advance end_index across overflow digits.
	Method AdjustConsumed:Int()
		If isOverflow And Not OVERFLOW_CONSUMES_ALL_DIGITS Then Return consumed - 1
		Return consumed
	End Method

	Method ParseWithBBLong:Long(consumed:Int Var)
		' Prepare UTF-16 buffer (+1 for NUL)
		Local n:Size_t = s.Length + 1
		Local buf:Short[] = New Short[n]
		s.ToWStringBuffer(buf, n)

		' Call the native parser
		Local end_index:Int = -1
		Local value:Long = bbStrToLong(buf, Int(n), VarPtr end_index)

		consumed = end_index
		Return value
	End Method
End Type

Type TUIntCase
	Field s:String
	Field expected:UInt
	Field consumed:Int
	Field isOverflow:Int  ' treat as overflow/out-of-range (end_index rules may differ)

	Method New(s:String, expected:UInt, consumed:Int, isOverflow:Int = False)
		Self.s = s
		Self.expected = expected
		Self.consumed = consumed
		Self.isOverflow = isOverflow
	End Method

	' Adjust consumed if your C impl stops at last valid digit instead of scanning all digits.
	Method AdjustConsumed:Int()
		If isOverflow And Not OVERFLOW_CONSUMES_ALL_DIGITS Then Return consumed - 1
		Return consumed
	End Method

	Method ParseWithBBUInt:UInt(consumed:Int Var)
		' Prepare UTF-16 buffer (+1 for NUL)
		Local n:Size_t = s.Length + 1
		Local buf:Short[] = New Short[n]
		s.ToWStringBuffer(buf, n)

		' Call the native parser
		Local end_index:Int = -1
		Local value:UInt = bbStrToUInt(buf, Int(n), VarPtr end_index)

		consumed = end_index
		Return value
	End Method
End Type

Type TShortCase
	Field s:String
	Field expected:Short
	Field consumed:Int
	Field isOverflow:Int

	Method New(s:String, expected:Short, consumed:Int, isOverflow:Int = False)
		Self.s = s
		Self.expected = expected
		Self.consumed = consumed
		Self.isOverflow = isOverflow
	End Method

	Method AdjustConsumed:Int()
		If isOverflow And Not OVERFLOW_CONSUMES_ALL_DIGITS Then Return consumed - 1
		Return consumed
	End Method

	Method ParseWithBBShort:Short(consumed:Int Var)
		Local n:Size_t = s.Length + 1
		Local buf:Short[] = New Short[n]
		s.ToWStringBuffer(buf, n)
		Local end_index:Int = -1
		Local value:Short = bbStrToShort(buf, Int(n), VarPtr end_index)
		consumed = end_index
		Return value
	End Method
End Type

Type TByteCase
	Field s:String
	Field expected:Byte
	Field consumed:Int
	Field isOverflow:Int

	Method New(s:String, expected:Byte, consumed:Int, isOverflow:Int = False)
		Self.s = s
		Self.expected = expected
		Self.consumed = consumed
		Self.isOverflow = isOverflow
	End Method

	Method AdjustConsumed:Int()
		If isOverflow And Not OVERFLOW_CONSUMES_ALL_DIGITS Then Return consumed - 1
		Return consumed
	End Method

	Method ParseWithBBByte:Byte(consumed:Int Var)
		Local n:Size_t = s.Length + 1
		Local buf:Short[] = New Short[n]
		s.ToWStringBuffer(buf, n)
		Local end_index:Int = -1
		Local value:Byte = bbStrToByte(buf, Int(n), VarPtr end_index)
		consumed = end_index
		Return value
	End Method
End Type

Const UL64_MAX:ULong = ULong(-1)  ' 0xFFFFFFFFFFFFFFFF

Type TULongCase
	Field s:String
	Field expected:ULong
	Field consumed:Int
	Field isOverflow:Int

	Method New(s:String, expected:ULong, consumed:Int, isOverflow:Int = False)
		Self.s = s
		Self.expected = expected
		Self.consumed = consumed
		Self.isOverflow = isOverflow
	End Method

	Method AdjustConsumed:Int()
		If isOverflow And Not OVERFLOW_CONSUMES_ALL_DIGITS Then Return consumed - 1
		Return consumed
	End Method

	Method ParseWithBBULong:ULong(consumed:Int Var)
		Local n:Size_t = s.Length + 1
		Local buf:Short[] = New Short[n]
		s.ToWStringBuffer(buf, n)
		Local end_index:Int = -1
		Local value:ULong = bbStrToULong(buf, Int(n), VarPtr end_index)
		consumed = end_index
		Return value
	End Method
End Type

Function RepeatChar:String(ch:String, count:Int)
	Local s:String = ""
	For Local i:Int = 0 Until count
		s :+ ch
	Next
	Return s
End Function

Type TStringToNumStrToNumTest Extends TTest

		' Safer equality for ULong without relying on string/overloads.
	Function AssertULongEquals(expected:ULong, actual:ULong, msg:String)
		assertEquals(Int(expected Shr 32), Int(actual Shr 32), msg + " (hi)")
		assertEquals(Int(expected & $FFFFFFFF), Int(actual & $FFFFFFFF), msg + " (lo)")
	End Function

	Method test_ToInt_All() { test }
		Local cases:TIntCase[] = [ ..
			..' --- Decimal (base 10)
			New TIntCase("0",                      0,                  1),
			New TIntCase("123",                    123,                3),
			New TIntCase("-123",                   -123,               4),
			New TIntCase("   +42",                 42,                 6),
			New TIntCase("   -0",                  0,                  5),
			New TIntCase("00123",                  123,                5),
			New TIntCase("123abc",                 123,                3),
			New TIntCase("123   ",                 123,                3),

			' Exact limits
			New TIntCase("2147483647",             INT_MAX,            10),
			New TIntCase("-2147483648",            INT_MIN,            11),

			' Overflows (clamp; mark with isOverflow=1)
			New TIntCase("2147483648",             INT_MAX,            10, True),
			New TIntCase("-2147483649",            INT_MIN,            11, True),

			' Errors (no digits)
			New TIntCase("",                       0,                  0),
			New TIntCase("   ",                    0,                  0),
			New TIntCase("+",                      0,                  0),
			New TIntCase("-",                      0,                  0),
			New TIntCase("abc",                    0,                  0),

			' --- Hex with $ (base 16)
			New TIntCase("$7FFFFFFF",              INT_MAX,            9),
			New TIntCase("-$80000000",             INT_MIN,            10),
			New TIntCase("$80000000",              INT_MAX,            9,  True),     ' +2^31 overflows
			New TIntCase("-$80000001",             INT_MIN,            10, True),     ' -(2^31+1) overflows
			New TIntCase("$7fffffff",              INT_MAX,            9),            ' lowercase
			New TIntCase("   $1a",                 26,                 6),
			New TIntCase("$",                      0,                  0),            ' no digits after prefix
			New TIntCase("$G1",                    0,                  0),            ' first is invalid -> no digits
			New TIntCase("$FFxyz",                 255,                3),            ' stops at first invalid

			' --- Binary with % (base 2)
			New TIntCase("%0",                     0,                  2),
			New TIntCase("%101010",                42,                 7),
			New TIntCase("-%10000000000000000000000000000000", INT_MIN, 34),          ' -2^31
			New TIntCase("%10000000000000000000000000000000",  INT_MAX, 33, True),    ' +2^31 overflows
			New TIntCase("%1002",                  4,                  4),            ' stops at '2'
			New TIntCase("%",                      0,                  0),            ' no digits after prefix
			New TIntCase("   %101",                5,                  7),

			' --- With +sign and prefixes
			New TIntCase("+$7fffffff",             INT_MAX,            10),
			New TIntCase("+%101",                  5,                  5),

			' --- Trailing junk after signed number
			New TIntCase("-42xyz",                 -42,                3)..
		]

		For Local t:TIntCase = EachIn cases
			Local gotConsumed:Int
			Local gotValue:Int = t.ParseWithBBInt(gotConsumed)
			Local expectConsumed:Int = t.AdjustConsumed()

			assertEquals(expectConsumed, gotConsumed, "consumed mismatch for '"+t.s+"'")
			assertEquals(t.expected, gotValue, "value mismatch for '"+t.s+"'")
		Next
	End Method

	Method test_ToLong_All() { test }
		' Build the 64-bit binary limit strings:
		' -%1 + 63 zeros  (=-2^63) and  %1 + 63 zeros (=+2^63, overflow)
		Local z63:String = "0000000000000000000000000000000" + "00000000000000000000000000000000" ' 31 + 32 = 63 zeros
		Local BIN64_MIN:String = "-%1" + z63
		Local BIN64_POS_OVF:String = "%1" + z63

		Local cases:TLongCase[] = [..
			..' --- Decimal (base 10)
			New TLongCase("0",                        0,                    1),
			New TLongCase("123",                      123,                  3),
			New TLongCase("-123",                     -123,                 4),
			New TLongCase("   +42",                   42,                   6),
			New TLongCase("   -0",                    0,                    5),
			New TLongCase("00123",                    123,                  5),
			New TLongCase("123abc",                   123,                  3),
			New TLongCase("123   ",                   123,                  3),

			' Exact 64-bit limits
			New TLongCase("9223372036854775807",      LONG_MAX,             19),
			New TLongCase("-9223372036854775808",     LONG_MIN,             20),

			' Overflows (clamp; mark with isOverflow=1)
			New TLongCase("9223372036854775808",      LONG_MAX,             19, True),
			New TLongCase("-9223372036854775809",     LONG_MIN,             20, True),

			' Errors (no digits)
			New TLongCase("",                         0,                    0),
			New TLongCase("   ",                      0,                    0),
			New TLongCase("+",                        0,                    0),
			New TLongCase("-",                        0,                    0),
			New TLongCase("abc",                      0,                    0),

			' --- Hex with $ (base 16)
			New TLongCase("$7FFFFFFFFFFFFFFF",        LONG_MAX,             17),
			New TLongCase("-$8000000000000000",       LONG_MIN,             18),
			New TLongCase("$8000000000000000",        LONG_MAX,             17, True), ' +2^63 overflows
			New TLongCase("-$8000000000000001",       LONG_MIN,             18, True), ' -(2^63+1) overflows
			New TLongCase("$7fffffffffffffff",        LONG_MAX,             17),       ' lowercase
			New TLongCase("   $1a",                   26,                   6),
			New TLongCase("$",                        0,                    0),        ' no digits after prefix
			New TLongCase("$G1",                      0,                    0),        ' first is invalid -> no digits
			New TLongCase("$FFxyz",                   255,                  3),        ' stops at first invalid

			' --- Binary with % (base 2)
			New TLongCase("%0",                       0,                    2),
			New TLongCase("%101010",                  42,                   7),
			New TLongCase(BIN64_MIN,                  LONG_MIN,             66),       ' -2^63
			New TLongCase(BIN64_POS_OVF,              LONG_MAX,             65, True), ' +2^63 overflows
			New TLongCase("%1002",                    4,                    4),        ' stops at '2'
			New TLongCase("%",                        0,                    0),        ' no digits after prefix
			New TLongCase("   %101",                  5,                    7),

			' --- With +sign and prefixes
			New TLongCase("+$7fffffffffffffff",       LONG_MAX,             18),
			New TLongCase("+%101",                    5,                    5),

			' --- Trailing junk after signed number
			New TLongCase("-42xyz",                   -42,                  3)..
		]

		For Local t:TLongCase = EachIn cases
			Local gotConsumed:Int
			Local gotValue:Long = t.ParseWithBBLong(gotConsumed)
			Local expectConsumed:Int = t.AdjustConsumed()

			assertEquals(expectConsumed, gotConsumed, "consumed mismatch for '"+t.s+"'")
			assertEquals(t.expected, gotValue, "value mismatch for '"+t.s+"'")
		Next
	End Method

	Method test_ToUInt_All() { test }
		' Prebuilt strings for 32-bit edges
		Local BIN32_MAX:String = "%11111111111111111111111111111111" ' 32 ones
		Local zeros32:String = "00000000000000000000000000000000"  ' 32 zeros
		Local BIN32_POS_OVF:String = "%1" + zeros32                   ' 2^32 -> overflow

		Local cases:TUIntCase[] = [..
			..' --- Decimal (base 10)
			New TUIntCase("0",                       UInt(0),                 1),
			New TUIntCase("123",                     UInt(123),               3),
			New TUIntCase("+123",                    UInt(123),               4),
			New TUIntCase("   +42",                  UInt(42),                6),
			New TUIntCase("   -0",                   UInt(0),                 5),     ' -0 is still 0
			New TUIntCase("00123",                   UInt(123),               5),
			New TUIntCase("123abc",                  UInt(123),               3),
			New TUIntCase("123   ",                  UInt(123),               3),

			' Range edges
			New TUIntCase("2147483647",              UInt($7FFFFFFF),         10),    ' INT_MAX fits in UInt
			New TUIntCase("2147483648",              UInt($80000000),         10),    ' 2^31 fits
			New TUIntCase("4294967295",              UInt($FFFFFFFF),         10),    ' UINT_MAX
			New TUIntCase("4294967296",              UInt(0),                 10, True), ' overflow -> 0

			' Negatives are out-of-range (wrapper returns 0) but digits are consumed
			New TUIntCase("-1",                      UInt(0),                 2,  True),
			New TUIntCase("-",                       UInt(0),                 0),
			New TUIntCase("+",                       UInt(0),                 0),

			' Errors (no digits)
			New TUIntCase("",                        UInt(0),                 0),
			New TUIntCase("   ",                     UInt(0),                 0),
			New TUIntCase("abc",                     UInt(0),                 0),

			' --- Hex with $ (base 16)
			New TUIntCase("$0",                      UInt(0),                 2),
			New TUIntCase("$FFFFFFFF",               UInt($FFFFFFFF),         9),
			New TUIntCase("$7FFFFFFF",               UInt($7FFFFFFF),         9),
			New TUIntCase("$80000000",               UInt($80000000),         9),
			New TUIntCase("$100000000",              UInt(0),                 10, True),   ' 0x1_0000_0000 overflow
			New TUIntCase("-$1",                     UInt(0),                 3,  True),   ' negative -> out-of-range
			New TUIntCase("$7fffffff",               UInt($7FFFFFFF),         9),         ' lowercase
			New TUIntCase("   $1a",                  UInt(26),                6),
			New TUIntCase("$",                       UInt(0),                 0),         ' no digits after prefix
			New TUIntCase("$G1",                     UInt(0),                 0),         ' first is invalid -> no digits
			New TUIntCase("$FFxyz",                  UInt(255),               3),         ' stops at first invalid
			New TUIntCase("+$FFFFFFFF",              UInt($FFFFFFFF),         10),

			' --- Binary with % (base 2)
			New TUIntCase("%0",                      UInt(0),                 2),
			New TUIntCase("%101010",                 UInt(42),                7),
			New TUIntCase(BIN32_MAX,                 UInt($FFFFFFFF),         33),       ' 32 ones
			New TUIntCase("%10000000000000000000000000000000", UInt($80000000), 33),     ' 2^31
			New TUIntCase(BIN32_POS_OVF,             UInt(0),                 34, True), ' 2^32 -> overflow
			New TUIntCase("%1002",                   UInt(4),                 4),        ' stops at '2'
			New TUIntCase("%",                       UInt(0),                 0),        ' no digits after prefix
			New TUIntCase("   %101",                 UInt(5),                 7),
			New TUIntCase("+%101",                   UInt(5),                 5),
			New TUIntCase("-%1",                     UInt(0),                 3,  True)..  ' negative -> out-of-range
		]

		For Local t:TUIntCase = EachIn cases
			Local gotConsumed:Int
			Local gotValue:UInt = t.ParseWithBBUInt(gotConsumed)
			Local expectConsumed:Int = t.AdjustConsumed()

			assertEquals(expectConsumed, gotConsumed, "consumed mismatch for '"+t.s+"'")
			' Cast to Long in assertion to avoid any UInt overload ambiguity
			assertEquals(Long(t.expected), Long(gotValue), "value mismatch for '"+t.s+"'")
		Next
	End Method

	Method test_ToShort_All() { test }
		Local BIN16_MAX:String = "%" + RepeatChar("1", 16)
		Local BIN16_POS_OVF:String = "%1" + RepeatChar("0", 16)  ' 2^16

		Local cases:TShortCase[] = [..
			..' Decimal
			New TShortCase("0",           Short(0),       1),
			New TShortCase("65535",       Short(65535),   5),
			New TShortCase("65536",       Short(0),       5, True),
			New TShortCase("123abc",      Short(123),     3),
			New TShortCase("   +42",      Short(42),      6),
			New TShortCase("-1",          Short(0),       2, True),

			' Errors
			New TShortCase("",            Short(0),       0),
			New TShortCase("   ",         Short(0),       0),
			New TShortCase("+",           Short(0),       0),
			New TShortCase("-",           Short(0),       0),
			New TShortCase("abc",         Short(0),       0),

			' Hex ($)
			New TShortCase("$0",          Short(0),       2),
			New TShortCase("$FFFF",       Short(65535),   5),
			New TShortCase("$10000",      Short(0),       6, True),
			New TShortCase("$fffe",       Short(65534),   5),
			New TShortCase("+$00FF",      Short(255),     6),
			New TShortCase("-$1",         Short(0),       3, True),
			New TShortCase("$",           Short(0),       0),
			New TShortCase("$G1",         Short(0),       0),
			New TShortCase("$FFxyz",      Short(255),     3),

			' Binary (%)
			New TShortCase("%0",          Short(0),       2),
			New TShortCase("%1111111111111111", Short(65535), 17),
			New TShortCase(BIN16_POS_OVF, Short(0),       18, True),
			New TShortCase("%1002",       Short(4),       4),
			New TShortCase("%",           Short(0),       0),
			New TShortCase("   %101",     Short(5),       7)..
		]

		For Local t:TShortCase = EachIn cases
			Local gotConsumed:Int
			Local gotValue:Short = t.ParseWithBBShort(gotConsumed)
			assertEquals(t.AdjustConsumed(), gotConsumed, "consumed mismatch for '"+t.s+"'")
			assertEquals(Int(t.expected), Int(gotValue), "value mismatch for '"+t.s+"'")
		Next
	End Method

	Method test_ToByte_All() { test }
		Local BIN8_MAX:String = "%" + RepeatChar("1", 8)
		Local BIN8_POS_OVF:String = "%1" + RepeatChar("0", 8)   ' 2^8

		Local cases:TByteCase[] = [..
			..' Decimal
			New TByteCase("0",        Byte(0),     1),
			New TByteCase("255",      Byte(255),   3),
			New TByteCase("256",      Byte(0),     3, True),
			New TByteCase("123abc",   Byte(123),   3),
			New TByteCase("   +42",   Byte(42),    6),
			New TByteCase("-1",       Byte(0),     2, True),

			' Errors
			New TByteCase("",         Byte(0),     0),
			New TByteCase("   ",      Byte(0),     0),
			New TByteCase("+",        Byte(0),     0),
			New TByteCase("-",        Byte(0),     0),
			New TByteCase("abc",      Byte(0),     0),

			' Hex ($)
			New TByteCase("$0",       Byte(0),     2),
			New TByteCase("$FF",      Byte(255),   3),
			New TByteCase("$100",     Byte(0),     4, True),
			New TByteCase("$7f",      Byte(127),   3),
			New TByteCase("+$0A",     Byte(10),    4),
			New TByteCase("-$1",      Byte(0),     3, True),
			New TByteCase("$",        Byte(0),     0),
			New TByteCase("$G1",      Byte(0),     0),
			New TByteCase("$FFxyz",   Byte(255),   3),

			' Binary (%)
			New TByteCase("%0",       Byte(0),     2),
			New TByteCase(BIN8_MAX,   Byte(255),   9),
			New TByteCase(BIN8_POS_OVF, Byte(0),   10, True),
			New TByteCase("%1002",    Byte(4),     4),
			New TByteCase("%",        Byte(0),     0),
			New TByteCase("   %1010", Byte(10),    8),
			New TByteCase("+%1010",   Byte(10),    6)..
		]

		For Local t:TByteCase = EachIn cases
			Local gotConsumed:Int
			Local gotValue:Byte = t.ParseWithBBByte(gotConsumed)
			assertEquals(t.AdjustConsumed(), gotConsumed, "consumed mismatch for '"+t.s+"'")
			assertEquals(Int(t.expected), Int(gotValue), "value mismatch for '"+t.s+"'")
		Next
	End Method

		Method test_ToULong_All() { test }
		Local decMax:String = "18446744073709551615"      ' 2^64 - 1
		Local decOvf:String = "18446744073709551616"      ' 2^64

		Local BIN64_MAX:String = "%" + RepeatChar("1", 64)
		Local BIN64_POS_OVF:String = "%1" + RepeatChar("0", 64)

		Local cases:TULongCase[] = [..
			..' Decimal
			New TULongCase("0",                 ULong(0),         1),
			New TULongCase("123",               ULong(123),       3),
			New TULongCase("   +42",            ULong(42),        6),
			New TULongCase(decMax,              UL64_MAX,        20),
			New TULongCase(decOvf,              UL64_MAX,        20, True),  ' clamp on overflow

			' Accept leading '-' with wrap (POSIX strtoul style)
			New TULongCase("-1",                UL64_MAX,         2),
			New TULongCase("-0",                ULong(0),         2),

			' Errors
			New TULongCase("",                  ULong(0),         0),
			New TULongCase("   ",               ULong(0),         0),
			New TULongCase("+",                 ULong(0),         0),
			New TULongCase("-",                 ULong(0),         0),
			New TULongCase("abc",               ULong(0),         0),

			' Hex ($)
			New TULongCase("$0",                ULong(0),         2),
			New TULongCase("$FFFFFFFFFFFFFFFF", UL64_MAX,        17),
			New TULongCase("$10000000000000000", UL64_MAX,       18, True),  ' overflow
			New TULongCase("-$1",               UL64_MAX,         3),        ' wrap
			New TULongCase("$FFxyz",            ULong(255),       3),
			New TULongCase("$",                 ULong(0),         0),
			New TULongCase("$G1",               ULong(0),         0),
			New TULongCase("+$FFFFFFFFFFFFFFFF", UL64_MAX,       18),

			' Binary (%)
			New TULongCase("%0",                ULong(0),         2),
			New TULongCase(BIN64_MAX,           UL64_MAX,        65),
			New TULongCase(BIN64_POS_OVF,       UL64_MAX,        66, True),
			New TULongCase("-%1",               UL64_MAX,         3),        ' wrap
			New TULongCase("%1002",             ULong(4),         4),
			New TULongCase("%",                 ULong(0),         0),
			New TULongCase("   %101",           ULong(5),         7)..
		]

		For Local t:TULongCase = EachIn cases
			Local gotConsumed:Int
			Local gotValue:ULong = t.ParseWithBBULong(gotConsumed)
			assertEquals(t.AdjustConsumed(), gotConsumed, "consumed mismatch for '"+t.s+"'")
			AssertULongEquals(t.expected, gotValue, "value mismatch for '"+t.s+"'")
		Next
	End Method

End Type
