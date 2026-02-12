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
			assertEquals( bigUnicode[i], buf[i], "UTF32 conversion failed at index " + i)
		Next
		MemFree(buf)
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

	Method testToUTF8StringWithLength() { test }
		Local length:Size_T
		Local buf:Byte Ptr = "Hello World".ToUTF8String(length)
		assertEquals(11, length)
		MemFree(buf)

		length = 0
		buf = CYRILLIC_UPPER.ToUTF8String(length)
		assertEquals(17, length)
		MemFree(buf)

		length = 0
		Local s:String = String.FromUTF32String(bigUnicode)
		buf = s.ToUTF8String(length)
		assertEquals(24, length)
		MemFree(buf)
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

	' Helper: expect success
	Method assertParse(expectedPos:Int, expectedVal:Int, s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:Int = -123456789 ' sentinel
		Local p:Int = s.ToIntEx(v, startPos, endPos, format, base)
		assertEquals(expectedPos, p)
		assertEquals(expectedVal, v)
	End Method

	' Helper: expect failure; optionally assert val unchanged
	Method assertFail(s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:Int = 42
		Local p:Int = s.ToIntEx(v, startPos, endPos, format, base)
		assertEquals(0, p, "Expected failure but got position " + p)
		assertEquals(42, v) ' val should remain unchanged on failure
	End Method

	' -------------------------
	' Basic parsing + offsets
	' -------------------------
	Method testBasicSuccess() { test }
		assertParse(3, 123, "123")
		assertParse(2, 12, "12abc") ' partial parse
		assertParse(5, 123, "xx123yy", 2) ' startPos
	End Method

	Method testEmptyAndGarbage() { test }
		assertFail("")
		assertFail(" ")
		assertFail("~t~n")
		assertFail("abc")
		assertFail(" abc ")
	End Method

	' -------------------------
	' Whitespace handling
	' -------------------------
	Method testSkipWhitespace() { test }
		assertFail("  ~t123") ' no flag
		assertParse(6, 123, "  ~t123", 0, -1, CHARSFORMAT_SKIPWHITESPACE) ' 2 spaces + tab + 3 digits = pos 6
	End Method

	' -------------------------
	' Sign handling
	' -------------------------
	Method testLeadingPlus() { test }
		assertFail("+123")
		assertParse(4, 123, "+123", 0, -1, CHARSFORMAT_ALLOWLEADINGPLUS | CHARSFORMAT_GENERAL)

		assertFail("+")      ' sign only
		assertFail("-")      ' sign only
		assertParse(4, -123, "-123") ' minus should normally work
	End Method

	' -------------------------
	' endPos windowing
	' -------------------------
	Method testEndPosWindow() { test }
		assertParse(3, 123, "12345", 0, 3) ' only "123"
		assertParse(1, 1, "12", 0, 1)

		assertFail("123", 0, 0) ' no room
		assertFail("123", 2, 1) ' endPos < startPos
		assertFail("123", 99, -1) ' startPos beyond length
	End Method

	' -------------------------
	' Base parsing
	' -------------------------
	Method testBases() { test }
		assertParse(4, 11, "1011", 0, -1, CHARSFORMAT_GENERAL, 2)
		assertParse(2, 15, "17",   0, -1, CHARSFORMAT_GENERAL, 8)
		assertParse(6, 11255809, "abc001", 0, -1, CHARSFORMAT_GENERAL, 16)

		' invalid digit stops parse but succeeds if at least one digit
		assertParse(2, 12, "12x",  0, -1, CHARSFORMAT_GENERAL, 10)
		assertParse(2, 2,  "102",  0, -1, CHARSFORMAT_GENERAL, 2)

		' no digits => fail
		assertFail("x12", 0, -1, CHARSFORMAT_GENERAL, 10)
	End Method

	' -------------------------
	' Overflow / underflow
	' -------------------------
	Method testOverflow() { test }
		assertFail("999999999999999999999999999999")
		assertFail("-999999999999999999999999999999")
	End Method

	' -------------------------
	' Fixed / Scientific / Fortran
	' -------------------------
	Method testFixedAndScientific() { test }

		' If ToIntEx accepts float syntax only when integral:
		assertParse(1, 1, "1.0", 0, -1, CHARSFORMAT_FIXED)
		assertParse(1, 1, "1.2", 0, -1, CHARSFORMAT_FIXED)

		assertParse(1, 1, "1e3", 0, -1, CHARSFORMAT_SCIENTIFIC)
		assertParse(1, 1, "1e-1", 0, -1, CHARSFORMAT_SCIENTIFIC)

		' Fortran-style exponent (D)
		assertParse(1, 1, "1D3", 0, -1, CHARSFORMAT_FORTRAN)
	End Method

	' -------------------------
	' JSON format
	' -------------------------
	Method testJsonFormat() { test }
		' JSON disallows leading whitespace
		assertFail(" 1", 0, -1, CHARSFORMAT_JSON)

		' JSON disallows leading plus
		assertFail("+1", 0, -1, CHARSFORMAT_JSON)

		' JSON disallows leading zeros except "0"
		assertParse(1, 0, "0", 0, -1, CHARSFORMAT_JSON)
	End Method

End Type

Type TStringToLongExTest Extends TTest

	' Helper: expect success
	Method assertParse(expectedPos:Long, expectedVal:Long, s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:Long = -123456789 ' sentinel
		Local p:Int = s.ToLongEx(v, startPos, endPos, format, base)
		assertEquals(expectedPos, p)
		assertEquals(expectedVal, v)
	End Method

	' Helper: expect failure; optionally assert val unchanged
	Method assertFail(s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:Long = 42
		Local p:Int = s.ToLongEx(v, startPos, endPos, format, base)
		assertEquals(0, p, "Expected failure but got position " + p)
		assertEquals(42, v) ' val should remain unchanged on failure
	End Method

	' -------------------------
	' Basic parsing + offsets
	' -------------------------
	Method testBasicSuccess() { test }
		assertParse(3, 123, "123")
		assertParse(2, 12, "12abc") ' partial parse
		assertParse(5, 123, "xx123yy", 2) ' startPos
	End Method

	Method testEmptyAndGarbage() { test }
		assertFail("")
		assertFail(" ")
		assertFail("~t~n")
		assertFail("abc")
		assertFail(" abc ")
	End Method

	' -------------------------
	' Whitespace handling
	' -------------------------
	Method testSkipWhitespace() { test }
		assertFail("  ~t123") ' no flag
		assertParse(6, 123, "  ~t123", 0, -1, CHARSFORMAT_SKIPWHITESPACE) ' 2 spaces + tab + 3 digits = pos 6
	End Method

	' -------------------------
	' Sign handling
	' -------------------------
	Method testLeadingPlus() { test }
		assertFail("+123")
		assertParse(4, 123, "+123", 0, -1, CHARSFORMAT_ALLOWLEADINGPLUS | CHARSFORMAT_GENERAL)

		assertFail("+")      ' sign only
		assertFail("-")      ' sign only
		assertParse(4, -123, "-123") ' minus should normally work
	End Method

	' -------------------------
	' endPos windowing
	' -------------------------
	Method testEndPosWindow() { test }
		assertParse(3, 123, "12345", 0, 3) ' only "123"
		assertParse(1, 1, "12", 0, 1)

		assertFail("123", 0, 0) ' no room
		assertFail("123", 2, 1) ' endPos < startPos
		assertFail("123", 99, -1) ' startPos beyond length
	End Method

	' -------------------------
	' Base parsing
	' -------------------------
	Method testBases() { test }
		assertParse(4, 11, "1011", 0, -1, CHARSFORMAT_GENERAL, 2)
		assertParse(2, 15, "17",   0, -1, CHARSFORMAT_GENERAL, 8)
		assertParse(6, 11255809, "abc001", 0, -1, CHARSFORMAT_GENERAL, 16)

		' invalid digit stops parse but succeeds if at least one digit
		assertParse(2, 12, "12x",  0, -1, CHARSFORMAT_GENERAL, 10)
		assertParse(2, 2,  "102",  0, -1, CHARSFORMAT_GENERAL, 2)

		' no digits => fail
		assertFail("x12", 0, -1, CHARSFORMAT_GENERAL, 10)
	End Method

	' -------------------------
	' Overflow / underflow
	' -------------------------
	Method testOverflow() { test }
		assertFail("999999999999999999999999999999")
		assertFail("-999999999999999999999999999999")
	End Method

	' -------------------------
	' Fixed / Scientific / Fortran
	' -------------------------
	Method testFixedAndScientific() { test }

		' If ToIntEx accepts float syntax only when integral:
		assertParse(1, 1, "1.0", 0, -1, CHARSFORMAT_FIXED)
		assertParse(1, 1, "1.2", 0, -1, CHARSFORMAT_FIXED)

		assertParse(1, 1, "1e3", 0, -1, CHARSFORMAT_SCIENTIFIC)
		assertParse(1, 1, "1e-1", 0, -1, CHARSFORMAT_SCIENTIFIC)

		' Fortran-style exponent (D)
		assertParse(1, 1, "1D3", 0, -1, CHARSFORMAT_FORTRAN)
	End Method

	' -------------------------
	' JSON format
	' -------------------------
	Method testJsonFormat() { test }
		' JSON disallows leading whitespace
		assertFail(" 1", 0, -1, CHARSFORMAT_JSON)

		' JSON disallows leading plus
		assertFail("+1", 0, -1, CHARSFORMAT_JSON)

		' JSON disallows leading zeros except "0"
		assertParse(1, 0, "0", 0, -1, CHARSFORMAT_JSON)
	End Method

End Type

Type TStringToLongIntExTest Extends TTest

	' Helper: expect success
	Method assertParse(expectedPos:LongInt, expectedVal:LongInt, s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:LongInt = -123456789 ' sentinel
		Local p:Int = s.ToLongIntEx(v, startPos, endPos, format, base)
		assertEquals(expectedPos, p)
		assertEquals(expectedVal, v)
	End Method

	' Helper: expect failure; optionally assert val unchanged
	Method assertFail(s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:LongInt = 42
		Local p:Int = s.ToLongIntEx(v, startPos, endPos, format, base)
		assertEquals(0, p, "Expected failure but got position " + p)
		assertEquals(42, v) ' val should remain unchanged on failure
	End Method

	' -------------------------
	' Basic parsing + offsets
	' -------------------------
	Method testBasicSuccess() { test }
		assertParse(3, 123, "123")
		assertParse(2, 12, "12abc") ' partial parse
		assertParse(5, 123, "xx123yy", 2) ' startPos
	End Method

	Method testEmptyAndGarbage() { test }
		assertFail("")
		assertFail(" ")
		assertFail("~t~n")
		assertFail("abc")
		assertFail(" abc ")
	End Method

	' -------------------------
	' Whitespace handling
	' -------------------------
	Method testSkipWhitespace() { test }
		assertFail("  ~t123") ' no flag
		assertParse(6, 123, "  ~t123", 0, -1, CHARSFORMAT_SKIPWHITESPACE) ' 2 spaces + tab + 3 digits = pos 6
	End Method

	' -------------------------
	' Sign handling
	' -------------------------
	Method testLeadingPlus() { test }
		assertFail("+123")
		assertParse(4, 123, "+123", 0, -1, CHARSFORMAT_ALLOWLEADINGPLUS | CHARSFORMAT_GENERAL)

		assertFail("+")      ' sign only
		assertFail("-")      ' sign only
		assertParse(4, -123, "-123") ' minus should normally work
	End Method

	' -------------------------
	' endPos windowing
	' -------------------------
	Method testEndPosWindow() { test }
		assertParse(3, 123, "12345", 0, 3) ' only "123"
		assertParse(1, 1, "12", 0, 1)

		assertFail("123", 0, 0) ' no room
		assertFail("123", 2, 1) ' endPos < startPos
		assertFail("123", 99, -1) ' startPos beyond length
	End Method

	' -------------------------
	' Base parsing
	' -------------------------
	Method testBases() { test }
		assertParse(4, 11, "1011", 0, -1, CHARSFORMAT_GENERAL, 2)
		assertParse(2, 15, "17",   0, -1, CHARSFORMAT_GENERAL, 8)
		assertParse(6, 11255809, "abc001", 0, -1, CHARSFORMAT_GENERAL, 16)

		' invalid digit stops parse but succeeds if at least one digit
		assertParse(2, 12, "12x",  0, -1, CHARSFORMAT_GENERAL, 10)
		assertParse(2, 2,  "102",  0, -1, CHARSFORMAT_GENERAL, 2)

		' no digits => fail
		assertFail("x12", 0, -1, CHARSFORMAT_GENERAL, 10)
	End Method

	' -------------------------
	' Overflow / underflow
	' -------------------------
	Method testOverflow() { test }
		assertFail("999999999999999999999999999999")
		assertFail("-999999999999999999999999999999")
	End Method

	' -------------------------
	' Fixed / Scientific / Fortran
	' -------------------------
	Method testFixedAndScientific() { test }

		' If ToIntEx accepts float syntax only when integral:
		assertParse(1, 1, "1.0", 0, -1, CHARSFORMAT_FIXED)
		assertParse(1, 1, "1.2", 0, -1, CHARSFORMAT_FIXED)

		assertParse(1, 1, "1e3", 0, -1, CHARSFORMAT_SCIENTIFIC)
		assertParse(1, 1, "1e-1", 0, -1, CHARSFORMAT_SCIENTIFIC)

		' Fortran-style exponent (D)
		assertParse(1, 1, "1D3", 0, -1, CHARSFORMAT_FORTRAN)
	End Method

	' -------------------------
	' JSON format
	' -------------------------
	Method testJsonFormat() { test }
		' JSON disallows leading whitespace
		assertFail(" 1", 0, -1, CHARSFORMAT_JSON)

		' JSON disallows leading plus
		assertFail("+1", 0, -1, CHARSFORMAT_JSON)

		' JSON disallows leading zeros except "0"
		assertParse(1, 0, "0", 0, -1, CHARSFORMAT_JSON)
	End Method

End Type

Type TStringToUIntExTest Extends TTest

	' Helper: expect success
	Method assertParse(expectedPos:Int, expectedVal:UInt, s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:UInt = 987654321:UInt ' sentinel
		Local p:Int = s.ToUIntEx(v, startPos, endPos, format, base)
		assertEquals(expectedPos, p)
		assertEquals(expectedVal, v)
	End Method

	' Helper: expect failure; assert val unchanged
	Method assertFail(s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:UInt = 42:UInt
		Local p:Int = s.ToUIntEx(v, startPos, endPos, format, base)
		assertEquals(0, p)
		assertEquals(42:UInt, v)
	End Method

	' -------------------------
	' Basic parsing + offsets
	' -------------------------
	Method testBasicSuccess() { test }
		assertParse(3, 123:UInt, "123")
		assertParse(2, 12:UInt, "12abc") ' partial parse
		assertParse(5, 123:UInt, "xx123yy", 2) ' startPos
	End Method

	Method testEmptyAndGarbage() { test }
		assertFail("")
		assertFail(" ")
		assertFail("~t~n")
		assertFail("abc")
		assertFail(" abc ")
	End Method

	' -------------------------
	' Whitespace handling
	' -------------------------
	Method testSkipWhitespace() { test }
		assertFail("  ~t123") ' no flag
		assertParse(6, 123:UInt, "  ~t123", 0, -1, CHARSFORMAT_SKIPWHITESPACE)
	End Method

	' -------------------------
	' Sign handling (unsigned-specific)
	' -------------------------
	Method testLeadingPlusAndMinus() { test }
		' plus only if allowed
		assertFail("+123")
		assertParse(4, 123:UInt, "+123", 0, -1, CHARSFORMAT_ALLOWLEADINGPLUS | CHARSFORMAT_GENERAL)

		' minus should always fail for UInt
		assertFail("-0")
		assertFail("-1")
		assertFail("-123")

		' sign only
		assertFail("+")
		assertFail("-")
	End Method

	' -------------------------
	' endPos windowing
	' -------------------------
	Method testEndPosWindow() { test }
		assertParse(3, 123:UInt, "12345", 0, 3)
		assertParse(1, 1:UInt, "12", 0, 1)

		assertFail("123", 0, 0)
		assertFail("123", 2, 1)
		assertFail("123", 99, -1)
	End Method

	' -------------------------
	' Base parsing
	' -------------------------
	Method testBases() { test }
		assertParse(4, 11:UInt, "1011", 0, -1, CHARSFORMAT_GENERAL, 2)
		assertParse(2, 15:UInt, "17",   0, -1, CHARSFORMAT_GENERAL, 8)
		assertParse(6, 11255809:UInt, "abc001", 0, -1, CHARSFORMAT_GENERAL, 16)

		' invalid digit stops parse but succeeds if at least one digit
		assertParse(2, 12:UInt, "12x", 0, -1, CHARSFORMAT_GENERAL, 10)
		assertParse(2, 2:UInt,  "102", 0, -1, CHARSFORMAT_GENERAL, 2)

		' no digits => fail
		assertFail("x12", 0, -1, CHARSFORMAT_GENERAL, 10)
	End Method

	' -------------------------
	' Overflow (unsigned)
	' -------------------------
	Method testOverflow() { test }
		' Definitely too big for 32-bit and 64-bit UInt
		assertFail("999999999999999999999999999999")
		assertFail("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 0, -1, CHARSFORMAT_GENERAL, 16)
	End Method

	' -------------------------
	' Fixed / Scientific / Fortran (tokenizer-style behavior)
	' -------------------------
	Method testFixedAndScientific() { test }

		assertParse(1, 1:UInt, "1.0", 0, -1, CHARSFORMAT_FIXED)
		assertParse(1, 1:UInt, "1e3", 0, -1, CHARSFORMAT_SCIENTIFIC)
		assertParse(1, 1:UInt, "1D3", 0, -1, CHARSFORMAT_FORTRAN)

		' No digits at start => fail
		assertFail(".5", 0, -1, CHARSFORMAT_FIXED)
	End Method

	' -------------------------
	' JSON format (basic invariants)
	' -------------------------
	Method testJsonFormat() { test }
		' JSON disallows leading whitespace and leading plus
		assertFail(" 1", 0, -1, CHARSFORMAT_JSON)
		assertFail("+1", 0, -1, CHARSFORMAT_JSON)

		' ' JSON leading zero rule
		assertParse(1, 0:UInt, "0", 0, -1, CHARSFORMAT_JSON)

		' Unsigned: negative must fail regardless
		assertFail("-1", 0, -1, CHARSFORMAT_JSON)
	End Method

End Type

Type TStringToULongExTest Extends TTest

	' Helper: expect success
	Method assertParse(expectedPos:Int, expectedVal:ULong, s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:ULong = 987654321:ULong ' sentinel
		Local p:Int = s.ToULongEx(v, startPos, endPos, format, base)
		assertEquals(expectedPos, p)
		assertEquals(expectedVal, v)
	End Method

	' Helper: expect failure; assert val unchanged
	Method assertFail(s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:ULong = 42:ULong
		Local p:Int = s.ToULongEx(v, startPos, endPos, format, base)
		assertEquals(0, p)
		assertEquals(42:ULong, v)
	End Method

	' -------------------------
	' Basic parsing + offsets
	' -------------------------
	Method testBasicSuccess() { test }
		assertParse(3, 123:ULong, "123")
		assertParse(2, 12:ULong, "12abc") ' partial parse
		assertParse(5, 123:ULong, "xx123yy", 2) ' startPos
	End Method

	Method testEmptyAndGarbage() { test }
		assertFail("")
		assertFail(" ")
		assertFail("~t~n")
		assertFail("abc")
		assertFail(" abc ")
	End Method

	' -------------------------
	' Whitespace handling
	' -------------------------
	Method testSkipWhitespace() { test }
		assertFail("  ~t123") ' no flag
		assertParse(6, 123:ULong, "  ~t123", 0, -1, CHARSFORMAT_SKIPWHITESPACE)
	End Method

	' -------------------------
	' Sign handling (unsigned-specific)
	' -------------------------
	Method testLeadingPlusAndMinus() { test }
		' plus only if allowed
		assertFail("+123")
		assertParse(4, 123:ULong, "+123", 0, -1, CHARSFORMAT_ALLOWLEADINGPLUS | CHARSFORMAT_GENERAL)

		' minus should always fail for UInt
		assertFail("-0")
		assertFail("-1")
		assertFail("-123")

		' sign only
		assertFail("+")
		assertFail("-")
	End Method

	' -------------------------
	' endPos windowing
	' -------------------------
	Method testEndPosWindow() { test }
		assertParse(3, 123:ULong, "12345", 0, 3)
		assertParse(1, 1:ULong, "12", 0, 1)

		assertFail("123", 0, 0)
		assertFail("123", 2, 1)
		assertFail("123", 99, -1)
	End Method

	' -------------------------
	' Base parsing
	' -------------------------
	Method testBases() { test }
		assertParse(4, 11:ULong, "1011", 0, -1, CHARSFORMAT_GENERAL, 2)
		assertParse(2, 15:ULong, "17",   0, -1, CHARSFORMAT_GENERAL, 8)
		assertParse(6, 11255809:ULong, "abc001", 0, -1, CHARSFORMAT_GENERAL, 16)

		' invalid digit stops parse but succeeds if at least one digit
		assertParse(2, 12:ULong, "12x", 0, -1, CHARSFORMAT_GENERAL, 10)
		assertParse(2, 2:ULong,  "102", 0, -1, CHARSFORMAT_GENERAL, 2)

		' no digits => fail
		assertFail("x12", 0, -1, CHARSFORMAT_GENERAL, 10)
	End Method

	' -------------------------
	' Overflow (unsigned)
	' -------------------------
	Method testOverflow() { test }
		' Definitely too big for 32-bit and 64-bit UInt
		assertFail("999999999999999999999999999999")
		assertFail("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 0, -1, CHARSFORMAT_GENERAL, 16)
	End Method

	' -------------------------
	' Fixed / Scientific / Fortran (tokenizer-style behavior)
	' -------------------------
	Method testFixedAndScientific() { test }

		assertParse(1, 1:ULong, "1.0", 0, -1, CHARSFORMAT_FIXED)
		assertParse(1, 1:ULong, "1e3", 0, -1, CHARSFORMAT_SCIENTIFIC)
		assertParse(1, 1:ULong, "1D3", 0, -1, CHARSFORMAT_FORTRAN)

		' No digits at start => fail
		assertFail(".5", 0, -1, CHARSFORMAT_FIXED)
	End Method

	' -------------------------
	' JSON format (basic invariants)
	' -------------------------
	Method testJsonFormat() { test }
		' JSON disallows leading whitespace and leading plus
		assertFail(" 1", 0, -1, CHARSFORMAT_JSON)
		assertFail("+1", 0, -1, CHARSFORMAT_JSON)

		' ' JSON leading zero rule
		assertParse(1, 0:ULong, "0", 0, -1, CHARSFORMAT_JSON)

		' Unsigned: negative must fail regardless
		assertFail("-1", 0, -1, CHARSFORMAT_JSON)
	End Method

End Type

Type TStringToULongIntExTest Extends TTest

	' Helper: expect success
	Method assertParse(expectedPos:Int, expectedVal:ULongInt, s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:ULongInt = 987654321:ULongInt ' sentinel
		Local p:Int = s.ToULongIntEx(v, startPos, endPos, format, base)
		assertEquals(expectedPos, p)
		assertEquals(expectedVal, v)
	End Method

	' Helper: expect failure; assert val unchanged
	Method assertFail(s:String, startPos:Int=0, endPos:Int=-1, format:Int=CHARSFORMAT_GENERAL, base:Int=10)
		Local v:ULongInt = 42:ULongInt
		Local p:Int = s.ToULongIntEx(v, startPos, endPos, format, base)
		assertEquals(0, p)
		assertEquals(42:ULongInt, v)
	End Method

	' -------------------------
	' Basic parsing + offsets
	' -------------------------
	Method testBasicSuccess() { test }
		assertParse(3, 123:ULongInt, "123")
		assertParse(2, 12:ULongInt, "12abc") ' partial parse
		assertParse(5, 123:ULongInt, "xx123yy", 2) ' startPos
	End Method

	Method testEmptyAndGarbage() { test }
		assertFail("")
		assertFail(" ")
		assertFail("~t~n")
		assertFail("abc")
		assertFail(" abc ")
	End Method

	' -------------------------
	' Whitespace handling
	' -------------------------
	Method testSkipWhitespace() { test }
		assertFail("  ~t123") ' no flag
		assertParse(6, 123:ULongInt, "  ~t123", 0, -1, CHARSFORMAT_SKIPWHITESPACE)
	End Method

	' -------------------------
	' Sign handling (unsigned-specific)
	' -------------------------
	Method testLeadingPlusAndMinus() { test }
		' plus only if allowed
		assertFail("+123")
		assertParse(4, 123:ULongInt, "+123", 0, -1, CHARSFORMAT_ALLOWLEADINGPLUS | CHARSFORMAT_GENERAL)

		' minus should always fail for UInt
		assertFail("-0")
		assertFail("-1")
		assertFail("-123")

		' sign only
		assertFail("+")
		assertFail("-")
	End Method

	' -------------------------
	' endPos windowing
	' -------------------------
	Method testEndPosWindow() { test }
		assertParse(3, 123:ULongInt, "12345", 0, 3)
		assertParse(1, 1:ULongInt, "12", 0, 1)

		assertFail("123", 0, 0)
		assertFail("123", 2, 1)
		assertFail("123", 99, -1)
	End Method

	' -------------------------
	' Base parsing
	' -------------------------
	Method testBases() { test }
		assertParse(4, 11:ULongInt, "1011", 0, -1, CHARSFORMAT_GENERAL, 2)
		assertParse(2, 15:ULongInt, "17",   0, -1, CHARSFORMAT_GENERAL, 8)
		assertParse(6, 11255809:ULongInt, "abc001", 0, -1, CHARSFORMAT_GENERAL, 16)

		' invalid digit stops parse but succeeds if at least one digit
		assertParse(2, 12:ULongInt, "12x", 0, -1, CHARSFORMAT_GENERAL, 10)
		assertParse(2, 2:ULongInt,  "102", 0, -1, CHARSFORMAT_GENERAL, 2)

		' no digits => fail
		assertFail("x12", 0, -1, CHARSFORMAT_GENERAL, 10)
	End Method

	' -------------------------
	' Overflow (unsigned)
	' -------------------------
	Method testOverflow() { test }
		' Definitely too big for 32-bit and 64-bit UInt
		assertFail("999999999999999999999999999999")
		assertFail("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 0, -1, CHARSFORMAT_GENERAL, 16)
	End Method

	' -------------------------
	' Fixed / Scientific / Fortran (tokenizer-style behavior)
	' -------------------------
	Method testFixedAndScientific() { test }

		assertParse(1, 1:ULongInt, "1.0", 0, -1, CHARSFORMAT_FIXED)
		assertParse(1, 1:ULongInt, "1e3", 0, -1, CHARSFORMAT_SCIENTIFIC)
		assertParse(1, 1:ULongInt, "1D3", 0, -1, CHARSFORMAT_FORTRAN)

		' No digits at start => fail
		assertFail(".5", 0, -1, CHARSFORMAT_FIXED)
	End Method

	' -------------------------
	' JSON format (basic invariants)
	' -------------------------
	Method testJsonFormat() { test }
		' JSON disallows leading whitespace and leading plus
		assertFail(" 1", 0, -1, CHARSFORMAT_JSON)
		assertFail("+1", 0, -1, CHARSFORMAT_JSON)

		' ' JSON leading zero rule
		assertParse(1, 0:ULongInt, "0", 0, -1, CHARSFORMAT_JSON)

		' Unsigned: negative must fail regardless
		assertFail("-1", 0, -1, CHARSFORMAT_JSON)
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

Type TStringFromBytesAsHexTest Extends TTest

	Method testSimpleHex() { test }
		' Byte array: [0xDE, 0xAD, 0xBE, 0xEF]
		Local data:Byte[] = [$DE, $AD, $BE, $EF]
		Local text:String = String.FromBytesAsHex(data, data.Length)
		assertEquals("DEADBEEF", text)
	End Method

	Method testSimpleHexLower() { test }
		' Byte array: [0xDE, 0xAD, 0xBE, 0xEF]
		Local data:Byte[] = [$DE, $AD, $BE, $EF]
		Local text:String = String.FromBytesAsHex(data, data.Length, False)
		assertEquals("deadbeef", text)
	End Method

	Method testEmptyArray() { test }
		Local data:Byte[] = []
		Local text:String = String.FromBytesAsHex(data, data.Length)
		assertEquals("", text)
	End Method
	
End Type

Type TStringJoinIntsTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Int[] = New Int[0]
		AssertEquals("", ",".Join(a), "Join of empty array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:Int[] = [ 42 ]
		AssertEquals("42", ",".Join(a), "Join of single element should not add separator")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:Int[] = [ 1, 2, 3 ]
		AssertEquals("1,2,3", ",".Join(a), "Basic join with comma separator")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:Int[] = [ 1, 2, 3 ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator")
	End Method

	Method Test_NegativesAndZero() { test }
		Local a:Int[] = [ -1, 0, 2, -300 ]
		AssertEquals("-1,0,2,-300", ",".Join(a), "Join should handle negatives and zero correctly")
	End Method

	Method Test_IntMinMax() { test }
		' BlitzMax Int is 32-bit signed (-2^31..2^31-1)
		Local minVal:Int = $80000000 ' -2147483648
		Local maxVal:Int = $7FFFFFFF '  2147483647

		Local a:Int[] = [ minVal, maxVal ]
		AssertEquals("-2147483648,2147483647", ",".Join(a), "Join should correctly format Int min/max values")
	End Method

	Method Test_DigitLengthCoverage_Sweep() { test }
		' Exercise various digit lengths and sign without iterating the full 32-bit range.
		' Includes boundaries around powers of 10.
		Local a:Int[] = [ ..
			0, 1, 9, 10, 11, ..
			99, 100, 101, ..
			999, 1000, 1001, ..
			9999, 10000, 10001, ..
			99999, 100000, 100001, ..
			999999, 1000000, 1000001, ..
			9999999, 10000000, 10000001, ..
			99999999, 100000000, 100000001, ..
			999999999, 1000000000, 1000000001, ..
			-1, -9, -10, -99, -100, -1000, -1000000 ..
		]

		Local expected:String = ..
			"0|1|9|10|11|" + ..
			"99|100|101|" + ..
			"999|1000|1001|" + ..
			"9999|10000|10001|" + ..
			"99999|100000|100001|" + ..
			"999999|1000000|1000001|" + ..
			"9999999|10000000|10000001|" + ..
			"99999999|100000000|100000001|" + ..
			"999999999|1000000000|1000000001|" + ..
			"-1|-9|-10|-99|-100|-1000|-1000000"

		AssertEquals(expected, "|".Join(a), "Join should handle varied digit lengths and negatives consistently")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Int[] = [ 1, 2, 3 ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator")
	End Method

End Type

Type TStringJoinLongsTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Long[] = New Long[0]
		AssertEquals("", ",".Join(a), "Join of empty Long array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:Long[] = [ 42:Long ]
		AssertEquals("42", ",".Join(a), "Join of single Long element should not add separator")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:Long[] = [ 1:Long, 2:Long, 3:Long ]
		AssertEquals("1,2,3", ",".Join(a), "Basic Long join with comma separator")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:Long[] = [ 1:Long, 2:Long, 3:Long ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (Long)")
	End Method

	Method Test_NegativesAndZero() { test }
		Local a:Long[] = [ -1:Long, 0:Long, 2:Long, -300:Long ]
		AssertEquals("-1,0,2,-300", ",".Join(a), "Join should handle Long negatives and zero correctly")
	End Method

	Method Test_LongMinMax() { test }
		' Long in BlitzMax is 64-bit (-2^63..2^63-1)
		Local minVal:Long = $8000000000000000:Long ' -9223372036854775808
		Local maxVal:Long = $7FFFFFFFFFFFFFFF:Long '  9223372036854775807

		Local a:Long[] = [ minVal, maxVal ]
		AssertEquals("-9223372036854775808,9223372036854775807", ",".Join(a), "Join should correctly format Long min/max values")
	End Method

	Method Test_DigitLengthCoverage_Sweep() { test }
		' Exercise various digit lengths (1..19 digits for positive) plus sign.
		' Includes boundaries around powers of 10 and some > 32-bit values.
		Local a:Long[] = [ ..
			0:Long, 1:Long, 9:Long, 10:Long, 11:Long, ..
			99:Long, 100:Long, 101:Long, ..
			999:Long, 1000:Long, 1001:Long, ..
			9999:Long, 10000:Long, 10001:Long, ..
			99999:Long, 100000:Long, 100001:Long, ..
			999999:Long, 1000000:Long, 1000001:Long, ..
			9999999:Long, 10000000:Long, 10000001:Long, ..
			99999999:Long, 100000000:Long, 100000001:Long, ..
			999999999:Long, 1000000000:Long, 1000000001:Long, ..
			9999999999:Long, 10000000000:Long, 10000000001:Long, ..
			99999999999:Long, 100000000000:Long, 100000000001:Long, ..
			999999999999:Long, 1000000000000:Long, 1000000000001:Long, ..
			9999999999999:Long, 10000000000000:Long, 10000000000001:Long, ..
			99999999999999:Long, 100000000000000:Long, 100000000000001:Long, ..
			999999999999999:Long, 1000000000000000:Long, 1000000000000001:Long, ..
			9999999999999999:Long, 10000000000000000:Long, 10000000000000001:Long, ..
			99999999999999999:Long, 100000000000000000:Long, 100000000000000001:Long, ..
			999999999999999999:Long, 1000000000000000000:Long, 1000000000000000001:Long, ..
			-1:Long, -9:Long, -10:Long, -99:Long, -100:Long, -1000:Long, -1000000:Long, -10000000000:Long ..
		]

		Local expected:String = ..
			"0|1|9|10|11|" + ..
			"99|100|101|" + ..
			"999|1000|1001|" + ..
			"9999|10000|10001|" + ..
			"99999|100000|100001|" + ..
			"999999|1000000|1000001|" + ..
			"9999999|10000000|10000001|" + ..
			"99999999|100000000|100000001|" + ..
			"999999999|1000000000|1000000001|" + ..
			"9999999999|10000000000|10000000001|" + ..
			"99999999999|100000000000|100000000001|" + ..
			"999999999999|1000000000000|1000000000001|" + ..
			"9999999999999|10000000000000|10000000000001|" + ..
			"99999999999999|100000000000000|100000000000001|" + ..
			"999999999999999|1000000000000000|1000000000000001|" + ..
			"9999999999999999|10000000000000000|10000000000000001|" + ..
			"99999999999999999|100000000000000000|100000000000000001|" + ..
			"999999999999999999|1000000000000000000|1000000000000000001|" + ..
			"-1|-9|-10|-99|-100|-1000|-1000000|-10000000000"

		AssertEquals(expected, "|".Join(a), "Join should handle varied Long digit lengths and negatives consistently")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Long[] = [ 1:Long, 2:Long, 3:Long ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Long)")
	End Method

End Type

Type TStringJoinBytesTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Byte[] = New Byte[0]
		AssertEquals("", ",".Join(a), "Join of empty Byte array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:Byte[] = [ 42:Byte ]
		AssertEquals("42", ",".Join(a), "Join of single Byte element should not add separator")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:Byte[] = [ 1:Byte, 2:Byte, 3:Byte ]
		AssertEquals("1,2,3", ",".Join(a), "Basic Byte join with comma separator")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:Byte[] = [ 1:Byte, 2:Byte, 3:Byte ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (Byte)")
	End Method

	Method Test_ByteMinMaxAndUnsigned() { test }
		' Byte is unsigned 8-bit (0..255)
		Local a:Byte[] = [ 0:Byte, 1:Byte, 9:Byte, 10:Byte, 99:Byte, 100:Byte, 254:Byte, 255:Byte ]
		AssertEquals("0,1,9,10,99,100,254,255", ",".Join(a), "Join should format full unsigned Byte range correctly")
	End Method

	Method Test_DigitLengthCoverage_Sweep() { test }
		Local a:Byte[] = [ ..
			0:Byte, 1:Byte, 9:Byte, 10:Byte, 11:Byte, ..
			99:Byte, 100:Byte, 101:Byte, ..
			249:Byte, 250:Byte, 254:Byte, 255:Byte ..
		]

		Local expected:String = "0|1|9|10|11|99|100|101|249|250|254|255"
		AssertEquals(expected, "|".Join(a), "Join should handle varied Byte digit lengths consistently")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Byte[] = [ 1:Byte, 2:Byte, 3:Byte ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Byte)")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		' Ensure we never get a negative sign for unsigned bytes.
		Local a:Byte[] = [ 0:Byte, 128:Byte, 200:Byte, 255:Byte ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned Byte join output should not contain '-'")
	End Method

End Type

Type TStringJoinShortsTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Short[] = New Short[0]
		AssertEquals("", ",".Join(a), "Join of empty Short array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:Short[] = [ 42:Short ]
		AssertEquals("42", ",".Join(a), "Join of single Short element should not add separator")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:Short[] = [ 1:Short, 2:Short, 3:Short ]
		AssertEquals("1,2,3", ",".Join(a), "Basic Short join with comma separator")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:Short[] = [ 1:Short, 2:Short, 3:Short ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (Short)")
	End Method

	Method Test_ShortMinMaxAndUnsigned() { test }
		' Short is unsigned 16-bit (0..65535)
		Local a:Short[] = [ ..
			0:Short, 1:Short, 9:Short, 10:Short, 99:Short, 100:Short, ..
			999:Short, 1000:Short, 9999:Short, 10000:Short, ..
			32767:Short, 32768:Short, 65534:Short, 65535:Short ..
		]
		AssertEquals("0,1,9,10,99,100,999,1000,9999,10000,32767,32768,65534,65535", ",".Join(a), ..
			"Join should format full unsigned Short range boundaries correctly")
	End Method

	Method Test_DigitLengthCoverage_Sweep() { test }
		Local a:Short[] = [ ..
			0:Short, 1:Short, 9:Short, 10:Short, 11:Short, ..
			99:Short, 100:Short, 101:Short, ..
			999:Short, 1000:Short, 1001:Short, ..
			9999:Short, 10000:Short, 10001:Short, ..
			65534:Short, 65535:Short ..
		]

		Local expected:String = ..
			"0|1|9|10|11|" + ..
			"99|100|101|" + ..
			"999|1000|1001|" + ..
			"9999|10000|10001|" + ..
			"65534|65535"

		AssertEquals(expected, "|".Join(a), "Join should handle varied Short digit lengths consistently")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Short[] = [ 1:Short, 2:Short, 3:Short ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Short)")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		' Ensure we never get a negative sign for unsigned shorts.
		Local a:Short[] = [ 0:Short, 32768:Short, 50000:Short, 65535:Short ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned Short join output should not contain '-'")
	End Method

End Type

Type TStringJoinUIntsTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:UInt[] = New UInt[0]
		AssertEquals("", ",".Join(a), "Join of empty UInt array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:UInt[] = [ 42:UInt ]
		AssertEquals("42", ",".Join(a), "Join of single UInt element should not add separator")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:UInt[] = [ 1:UInt, 2:UInt, 3:UInt ]
		AssertEquals("1,2,3", ",".Join(a), "Basic UInt join with comma separator")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:UInt[] = [ 1:UInt, 2:UInt, 3:UInt ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (UInt)")
	End Method

	Method Test_UIntRangeEdges() { test }
		' UInt is unsigned 32-bit (0..4294967295)
		Local a:UInt[] = [ ..
			0:UInt, 1:UInt, 9:UInt, 10:UInt, 99:UInt, 100:UInt, ..
			2147483647:UInt, ..
			2147483648:UInt, ..
			4000000000:UInt, ..
			4294967294:UInt, 4294967295:UInt ..
		]

		Local expected:String = "0,1,9,10,99,100,2147483647,2147483648,4000000000,4294967294,4294967295"
		AssertEquals(expected, ",".Join(a), "Join should format full UInt range boundaries correctly")
	End Method

	Method Test_DigitLengthCoverage_Sweep() { test }
		Local a:UInt[] = [ ..
			0:UInt, 1:UInt, 9:UInt, 10:UInt, 11:UInt, ..
			99:UInt, 100:UInt, 101:UInt, ..
			999:UInt, 1000:UInt, 1001:UInt, ..
			9999:UInt, 10000:UInt, 10001:UInt, ..
			99999:UInt, 100000:UInt, 100001:UInt, ..
			999999:UInt, 1000000:UInt, 1000001:UInt, ..
			9999999:UInt, 10000000:UInt, 10000001:UInt, ..
			99999999:UInt, 100000000:UInt, 100000001:UInt, ..
			999999999:UInt, 1000000000:UInt, 1000000001:UInt, ..
			4294967295:UInt ..
		]

		Local expected:String = ..
			"0|1|9|10|11|" + ..
			"99|100|101|" + ..
			"999|1000|1001|" + ..
			"9999|10000|10001|" + ..
			"99999|100000|100001|" + ..
			"999999|1000000|1000001|" + ..
			"9999999|10000000|10000001|" + ..
			"99999999|100000000|100000001|" + ..
			"999999999|1000000000|1000000001|" + ..
			"4294967295"

		AssertEquals(expected, "|".Join(a), "Join should handle varied UInt digit lengths consistently")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:UInt[] = [ 1:UInt, 2:UInt, 3:UInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (UInt)")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local a:UInt[] = [ 0:UInt, 2147483648:UInt, 4000000000:UInt, 4294967295:UInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned UInt join output should not contain '-'")
	End Method

End Type

Type TStringJoinULongsTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:ULong[] = New ULong[0]
		AssertEquals("", ",".Join(a), "Join of empty ULong array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:ULong[] = [ 42:ULong ]
		AssertEquals("42", ",".Join(a), "Join of single ULong element should not add separator")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:ULong[] = [ 1:ULong, 2:ULong, 3:ULong ]
		AssertEquals("1,2,3", ",".Join(a), "Basic ULong join with comma separator")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:ULong[] = [ 1:ULong, 2:ULong, 3:ULong ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (ULong)")
	End Method

	Method Test_ULongRangeEdges() { test }
		' ULong is unsigned 64-bit (0..18446744073709551615)
		Local a:ULong[] = [ ..
			0:ULong, ..
			1:ULong, ..
			9:ULong, ..
			10:ULong, ..
			99:ULong, ..
			100:ULong, ..
			4294967295:ULong, ..
			4294967296:ULong, ..
			9223372036854775807:ULong, ..
			9223372036854775808:ULong, ..
			18446744073709551614:ULong, ..
			18446744073709551615:ULong ..
		]

		Local expected:String = ..
			"0,1,9,10,99,100," + ..
			"4294967295,4294967296," + ..
			"9223372036854775807,9223372036854775808," + ..
			"18446744073709551614,18446744073709551615"

		AssertEquals(expected, ",".Join(a), "Join should format full ULong range boundaries correctly")
	End Method

	Method Test_DigitLengthCoverage_Sweep() { test }
		' Exercise digit-length boundaries up to 20 digits
		Local a:ULong[] = [ ..
			0:ULong, 1:ULong, 9:ULong, 10:ULong, 11:ULong, ..
			99:ULong, 100:ULong, 101:ULong, ..
			999:ULong, 1000:ULong, 1001:ULong, ..
			9999:ULong, 10000:ULong, 10001:ULong, ..
			99999:ULong, 100000:ULong, 100001:ULong, ..
			999999:ULong, 1000000:ULong, 1000001:ULong, ..
			9999999:ULong, 10000000:ULong, 10000001:ULong, ..
			99999999:ULong, 100000000:ULong, 100000001:ULong, ..
			999999999:ULong, 1000000000:ULong, 1000000001:ULong, ..
			9999999999:ULong, 10000000000:ULong, 10000000001:ULong, ..
			99999999999:ULong, 100000000000:ULong, 100000000001:ULong, ..
			999999999999:ULong, 1000000000000:ULong, 1000000000001:ULong, ..
			9999999999999:ULong, 10000000000000:ULong, 10000000000001:ULong, ..
			99999999999999:ULong, 100000000000000:ULong, 100000000000001:ULong, ..
			999999999999999:ULong, 1000000000000000:ULong, 1000000000000001:ULong, ..
			9999999999999999:ULong, 10000000000000000:ULong, 10000000000000001:ULong, ..
			99999999999999999:ULong, 100000000000000000:ULong, 100000000000000001:ULong, ..
			999999999999999999:ULong, 1000000000000000000:ULong, 1000000000000000001:ULong, ..
			18446744073709551615:ULong ..
		]

		Local expected:String = ..
			"0|1|9|10|11|" + ..
			"99|100|101|" + ..
			"999|1000|1001|" + ..
			"9999|10000|10001|" + ..
			"99999|100000|100001|" + ..
			"999999|1000000|1000001|" + ..
			"9999999|10000000|10000001|" + ..
			"99999999|100000000|100000001|" + ..
			"999999999|1000000000|1000000001|" + ..
			"9999999999|10000000000|10000000001|" + ..
			"99999999999|100000000000|100000000001|" + ..
			"999999999999|1000000000000|1000000000001|" + ..
			"9999999999999|10000000000000|10000000000001|" + ..
			"99999999999999|100000000000000|100000000000001|" + ..
			"999999999999999|1000000000000000|1000000000000001|" + ..
			"9999999999999999|10000000000000000|10000000000000001|" + ..
			"99999999999999999|100000000000000000|100000000000000001|" + ..
			"999999999999999999|1000000000000000000|1000000000000000001|" + ..
			"18446744073709551615"

		AssertEquals(expected, "|".Join(a), "Join should handle varied ULong digit lengths consistently")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:ULong[] = [ 1:ULong, 2:ULong, 3:ULong ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (ULong)")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		' Ensure we never get a negative sign for unsigned longs.
		Local a:ULong[] = [ 0:ULong, 9223372036854775808:ULong, 18446744073709551615:ULong ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned ULong join output should not contain '-'")
	End Method

End Type

?ptr32

Type TStringJoinSizeTs32Test Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Size_T[] = New Size_T[0]
		AssertEquals("", ",".Join(a), "Join of empty Size_T array should be empty string (ptr32)")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:Size_T[] = [ 42:Size_T ]
		AssertEquals("42", ",".Join(a), "Join of single Size_T element should not add separator (ptr32)")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:Size_T[] = [ 1:Size_T, 2:Size_T, 3:Size_T ]
		AssertEquals("1,2,3", ",".Join(a), "Basic Size_T join with comma separator (ptr32)")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:Size_T[] = [ 1:Size_T, 2:Size_T, 3:Size_T ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (Size_T ptr32)")
	End Method

	Method Test_SizeTRangeEdges_32bit() { test }
		' Size_T is unsigned 32-bit on ptr32
		Local a:Size_T[] = [ ..
			0:Size_T, 1:Size_T, 9:Size_T, 10:Size_T, 99:Size_T, 100:Size_T, ..
			2147483647:Size_T, ..
			2147483648:Size_T, ..
			4000000000:Size_T, ..
			4294967294:Size_T, 4294967295:Size_T ..
		]

		Local expected:String = "0,1,9,10,99,100,2147483647,2147483648,4000000000,4294967294,4294967295"
		AssertEquals(expected, ",".Join(a), "Join should format Size_T 32-bit range boundaries correctly")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local a:Size_T[] = [ 0:Size_T, 2147483648:Size_T, 4294967295:Size_T ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned Size_T join output should not contain '-' (ptr32)")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Size_T[] = [ 1:Size_T, 2:Size_T, 3:Size_T ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Size_T ptr32)")
	End Method

End Type

?ptr64

Type TStringJoinSizeTs64Test Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Size_T[] = New Size_T[0]
		AssertEquals("", ",".Join(a), "Join of empty Size_T array should be empty string (ptr64)")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:Size_T[] = [ 42:Size_T ]
		AssertEquals("42", ",".Join(a), "Join of single Size_T element should not add separator (ptr64)")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:Size_T[] = [ 1:Size_T, 2:Size_T, 3:Size_T ]
		AssertEquals("1,2,3", ",".Join(a), "Basic Size_T join with comma separator (ptr64)")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:Size_T[] = [ 1:Size_T, 2:Size_T, 3:Size_T ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (Size_T ptr64)")
	End Method

	Method Test_SizeTRangeEdges_64bit() { test }
		' Size_T is unsigned 64-bit on ptr64
		Local a:Size_T[] = [ ..
			0:Size_T, 1:Size_T, 9:Size_T, 10:Size_T, 99:Size_T, 100:Size_T, ..
			4294967295:Size_T, ..
			4294967296:Size_T, ..
			9223372036854775807:Size_T, ..
			9223372036854775808:Size_T, ..
			18446744073709551614:Size_T, ..
			18446744073709551615:Size_T ..
		]

		Local expected:String = ..
			"0,1,9,10,99,100," + ..
			"4294967295,4294967296," + ..
			"9223372036854775807,9223372036854775808," + ..
			"18446744073709551614,18446744073709551615"

		AssertEquals(expected, ",".Join(a), "Join should format Size_T 64-bit range boundaries correctly")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local a:Size_T[] = [ 0:Size_T, 9223372036854775808:Size_T, 18446744073709551615:Size_T ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned Size_T join output should not contain '-' (ptr64)")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Size_T[] = [ 1:Size_T, 2:Size_T, 3:Size_T ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Size_T ptr64)")
	End Method

End Type

?

?longint4

Type TStringJoinLongInts32Test Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:LongInt[] = New LongInt[0]
		AssertEquals("", ",".Join(a), "Join of empty LongInt array should be empty string (longint4)")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:LongInt[] = [ 42:LongInt ]
		AssertEquals("42", ",".Join(a), "Join of single LongInt element should not add separator (longint4)")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:LongInt[] = [ 1:LongInt, 2:LongInt, 3:LongInt ]
		AssertEquals("1,2,3", ",".Join(a), "Basic LongInt join with comma separator (longint4)")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:LongInt[] = [ 1:LongInt, 2:LongInt, 3:LongInt ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (LongInt longint4)")
	End Method

	Method Test_NegativesAndZero() { test }
		Local a:LongInt[] = [ -1:LongInt, 0:LongInt, 2:LongInt, -300:LongInt ]
		AssertEquals("-1,0,2,-300", ",".Join(a), "Join should handle LongInt negatives and zero correctly (longint4)")
	End Method

	Method Test_LongIntMinMax_32bit() { test }
		' longint4 => LongInt is 32-bit signed
		Local minVal:LongInt = $80000000:LongInt ' -2147483648
		Local maxVal:LongInt = $7FFFFFFF:LongInt '  2147483647

		Local a:LongInt[] = [ minVal, maxVal ]
		AssertEquals("-2147483648,2147483647", ",".Join(a), "Join should correctly format LongInt min/max (32-bit)")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:LongInt[] = [ 1:LongInt, 2:LongInt, 3:LongInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (LongInt longint4)")
	End Method

End Type

?longint8

?ulongint4

Type TStringJoinULongInts32Test Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:ULongInt[] = New ULongInt[0]
		AssertEquals("", ",".Join(a), "Join of empty ULongInt array should be empty string (ulongint4)")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:ULongInt[] = [ 42:ULongInt ]
		AssertEquals("42", ",".Join(a), "Join of single ULongInt element should not add separator (ulongint4)")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:ULongInt[] = [ 1:ULongInt, 2:ULongInt, 3:ULongInt ]
		AssertEquals("1,2,3", ",".Join(a), "Basic ULongInt join with comma separator (ulongint4)")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:ULongInt[] = [ 1:ULongInt, 2:ULongInt, 3:ULongInt ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (ULongInt ulongint4)")
	End Method

	Method Test_ULongIntRangeEdges_32bit() { test }
		' ulongint4 => ULongInt is unsigned 32-bit (0..4294967295)
		Local a:ULongInt[] = [ _
			0:ULongInt, 1:ULongInt, 9:ULongInt, 10:ULongInt, 99:ULongInt, 100:ULongInt, _
			2147483647:ULongInt, _
			2147483648:ULongInt, _
			4000000000:ULongInt, _
			4294967294:ULongInt, 4294967295:ULongInt _
		]

		Local expected:String = "0,1,9,10,99,100,2147483647,2147483648,4000000000,4294967294,4294967295"
		AssertEquals(expected, ",".Join(a), "Join should format ULongInt 32-bit range boundaries correctly")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local a:ULongInt[] = [ 0:ULongInt, 2147483648:ULongInt, 4294967295:ULongInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned ULongInt join output should not contain '-' (ulongint4)")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:ULongInt[] = [ 1:ULongInt, 2:ULongInt, 3:ULongInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (ULongInt ulongint4)")
	End Method

End Type

?ulongint8

Type TStringJoinULongInts64Test Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:ULongInt[] = New ULongInt[0]
		AssertEquals("", ",".Join(a), "Join of empty ULongInt array should be empty string (ulongint8)")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:ULongInt[] = [ 42:ULongInt ]
		AssertEquals("42", ",".Join(a), "Join of single ULongInt element should not add separator (ulongint8)")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:ULongInt[] = [ 1:ULongInt, 2:ULongInt, 3:ULongInt ]
		AssertEquals("1,2,3", ",".Join(a), "Basic ULongInt join with comma separator (ulongint8)")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:ULongInt[] = [ 1:ULongInt, 2:ULongInt, 3:ULongInt ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (ULongInt ulongint8)")
	End Method

	Method Test_ULongIntRangeEdges_64bit() { test }
		' ulongint8 => ULongInt is unsigned 64-bit (0..18446744073709551615)
		Local a:ULongInt[] = [ ..
			0:ULongInt, 1:ULongInt, 9:ULongInt, 10:ULongInt, 99:ULongInt, 100:ULongInt, ..
			4294967295:ULongInt, ..
			4294967296:ULongInt, ..
			9223372036854775807:ULongInt, ..
			9223372036854775808:ULongInt, ..
			18446744073709551614:ULongInt, ..
			18446744073709551615:ULongInt ..
		]

		Local expected:String = ..
			"0,1,9,10,99,100," + ..
			"4294967295,4294967296," + ..
			"9223372036854775807,9223372036854775808," + ..
			"18446744073709551614,18446744073709551615"

		AssertEquals(expected, ",".Join(a), "Join should format ULongInt 64-bit range boundaries correctly")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local a:ULongInt[] = [ 0:ULongInt, 9223372036854775808:ULongInt, 18446744073709551615:ULongInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.Contains("-"), "Unsigned ULongInt join output should not contain '-' (ulongint8)")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:ULongInt[] = [ 1:ULongInt, 2:ULongInt, 3:ULongInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (ULongInt ulongint8)")
	End Method

End Type

?

Type TStringJoinLongInts64Test Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:LongInt[] = New LongInt[0]
		AssertEquals("", ",".Join(a), "Join of empty LongInt array should be empty string (longint8)")
	End Method

	Method Test_SingleElement_NoSeparator() { test }
		Local a:LongInt[] = [ 42:LongInt ]
		AssertEquals("42", ",".Join(a), "Join of single LongInt element should not add separator (longint8)")
	End Method

	Method Test_MultipleElements_Commas() { test }
		Local a:LongInt[] = [ 1:LongInt, 2:LongInt, 3:LongInt ]
		AssertEquals("1,2,3", ",".Join(a), "Basic LongInt join with comma separator (longint8)")
	End Method

	Method Test_CustomSeparator() { test }
		Local a:LongInt[] = [ 1:LongInt, 2:LongInt, 3:LongInt ]
		AssertEquals("1::2::3", "::".Join(a), "Join should use the current string as separator (LongInt longint8)")
	End Method

	Method Test_NegativesAndZero() { test }
		Local a:LongInt[] = [ -1:LongInt, 0:LongInt, 2:LongInt, -300:LongInt ]
		AssertEquals("-1,0,2,-300", ",".Join(a), "Join should handle LongInt negatives and zero correctly (longint8)")
	End Method

	Method Test_LongIntMinMax_64bit() { test }
		' longint8 => LongInt is 64-bit signed
		Local minVal:LongInt = $8000000000000000:LongInt ' -9223372036854775808
		Local maxVal:LongInt = $7FFFFFFFFFFFFFFF:LongInt '  9223372036854775807

		Local a:LongInt[] = [ minVal, maxVal ]
		AssertEquals("-9223372036854775808,9223372036854775807", ",".Join(a), "Join should correctly format LongInt min/max (64-bit)")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:LongInt[] = [ 1:LongInt, 2:LongInt, 3:LongInt ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (LongInt longint8)")
	End Method

End Type

?

Type TStringJoinFloatsTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Float[] = New Float[0]
		AssertEquals("", ",".Join(a), "Join of empty Float array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator_Default() { test }
		Local a:Float[] = [ 42.0:Float ]
		AssertEquals("4.2E1", ",".Join(a), "Join of single Float element should not add separator (default)")
	End Method

	Method Test_MultipleElements_Commas_Default() { test }
		Local a:Float[] = [ 1.0:Float, 2.0:Float, 3.5:Float ]
		AssertEquals("1E0,2E0,3.5E0", ",".Join(a), "Basic Float join with comma separator (default)")
	End Method

	Method Test_CustomSeparator_Default() { test }
		Local a:Float[] = [ 1.0:Float, 2.0:Float, 3.5:Float ]
		AssertEquals("1E0::2E0::3.5E0", "::".Join(a), "Join should use the current string as separator (Float default)")
	End Method

	Method Test_DefaultFormatting_MatchesExpected() { test }

		Local a:Float[] = [ ..
			0.0:Float, ..
			-0.0:Float, ..
			1.0:Float, ..
			1.5:Float, ..
			3.1415927:Float, ..
			100000.0:Float, ..
			1e-6:Float, ..
			1e20:Float ..
		]

		Local expected:String = "0E0|-0E0|1E0|1.5E0|3.1415927E0|1E5|1E-6|1E20"

		AssertEquals(expected, "|".Join(a), "Float Join default formatting should match expected output")
	End Method

	Method Test_FixedFormatting_9dp() { test }

		Local a:Float[] = [ ..
			0.0:Float, ..
			-0.0:Float, ..
			1.0:Float, ..
			1.5:Float, ..
			3.1415927:Float, ..
			100000.0:Float, ..
			0.000001:Float ..
		]

		Local expected:String = ..
			"0.000000000|-0.000000000|1.000000000|1.500000000|3.141592741|100000.000000000|0.000001000"

		AssertEquals(expected, "|".Join(a, 1), "Float Join fixed formatting should produce 9 decimal places")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Float[] = [ 1.0:Float, 2.0:Float, 3.0:Float ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Float)")
	End Method

	Method Test_NaNAndInfinity() { test }

		Local nanVal:Float = 0.0:Float / 0.0:Float
		Local posInf:Float = 1.0:Float / 0.0:Float
		Local negInf:Float = -1.0:Float / 0.0:Float

		Local a:Float[] = [ nanVal, posInf, negInf ]
		Local s:String = ",".Join(a)

		Local expected:String = "NaN,Infinity,-Infinity"
		AssertEquals(expected, s, "Join should represent NaN and Infinity as expected (Float)")
	End Method

End Type

Type TStringJoinDoublesTest Extends TTest

	Method Test_EmptyArray_ReturnsEmptyString() { test }
		Local a:Double[] = New Double[0]
		AssertEquals("", ",".Join(a), "Join of empty Double array should be empty string")
	End Method

	Method Test_SingleElement_NoSeparator_Default() { test }
		Local a:Double[] = [ 42.0:Double ]
		AssertEquals("4.2E1", ",".Join(a), "Join of single Double element should not add separator (default)")
	End Method

	Method Test_MultipleElements_Commas_Default() { test }
		Local a:Double[] = [ 1.0:Double, 2.0:Double, 3.5:Double ]
		AssertEquals("1E0,2E0,3.5E0", ",".Join(a), "Basic Double join with comma separator (default)")
	End Method

	Method Test_CustomSeparator_Default() { test }
		Local a:Double[] = [ 1.0:Double, 2.0:Double, 3.5:Double ]
		AssertEquals("1E0::2E0::3.5E0", "::".Join(a), "Join should use the current string as separator (Double default)")
	End Method

	Method Test_DefaultFormatting_MatchesExpected() { test }

		Local a:Double[] = [ ..
			0.0:Double, ..
			-0.0:Double, ..
			1.0:Double, ..
			1.5:Double, ..
			3.141592653589793:Double, ..
			100000.0:Double, ..
			1e-6:Double, ..
			1e20:Double ..
		]

		Local expected:String = "0E0|-0E0|1E0|1.5E0|3.141592653589793E0|1E5|1E-6|1E20"

		AssertEquals(expected, "|".Join(a), "Double Join default formatting should match expected output")
	End Method

	Method Test_FixedFormatting_17dp() { test }

		Local a:Double[] = [ ..
			0.0:Double, ..
			-0.0:Double, ..
			1.0:Double, ..
			1.5:Double, ..
			3.141592653589793:Double, ..
			100000.0:Double, ..
			0.000001:Double ..
		]

		Local expected:String = ..
			"0.00000000000000000|-0.00000000000000000|1.00000000000000000|1.50000000000000000|" + ..
			"3.14159265358979312|100000.00000000000000000|0.00000100000000000"

		AssertEquals(expected, "|".Join(a, 1), "Double Join fixed formatting should produce 17 decimal places")
	End Method

	Method Test_NoExtraTrailingSeparator() { test }
		Local a:Double[] = [ 1.0:Double, 2.0:Double, 3.0:Double ]
		Local s:String = ",".Join(a)
		AssertFalse(s.EndsWith(","), "Join should not add trailing separator (Double)")
	End Method

	Method Test_NaNAndInfinity() { test }

		Local nanVal:Double = 0.0:Double / 0.0:Double
		Local posInf:Double = 1.0:Double / 0.0:Double
		Local negInf:Double = -1.0:Double / 0.0:Double

		Local a:Double[] = [ nanVal, posInf, negInf ]
		Local s:String = ",".Join(a)

		Local expected:String = "NaN,Infinity,-Infinity"
		AssertEquals(expected, s, "Join should represent NaN and Infinity as expected (Double)")
	End Method

End Type

Type TStringFromIntTest Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromInt(0), "String.FromInt(0) should be '0'")
	End Method

	Method Test_Positive() { test }
		AssertEquals("42", String.FromInt(42), "String.FromInt(42) should be '42'")
	End Method

	Method Test_Negative() { test }
		AssertEquals("-42", String.FromInt(-42), "String.FromInt(-42) should be '-42'")
	End Method

	Method Test_IntMinMax() { test }
		Local minVal:Int = $80000000 ' -2147483648
		Local maxVal:Int = $7FFFFFFF '  2147483647

		AssertEquals("-2147483648", String.FromInt(minVal), "String.FromInt(Int Min) should match")
		AssertEquals("2147483647", String.FromInt(maxVal), "String.FromInt(Int Max) should match")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		' Boundaries around powers of 10 + sign
		Local vals:Int[] = [ ..
			0, 1, 9, 10, 11, ..
			99, 100, 101, ..
			999, 1000, 1001, ..
			9999, 10000, 10001, ..
			99999, 100000, 100001, ..
			999999, 1000000, 1000001, ..
			9999999, 10000000, 10000001, ..
			99999999, 100000000, 100000001, ..
			999999999, 1000000000, 1000000001, ..
			-1, -9, -10, -99, -100, -1000, -1000000 ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:Int = vals[i]
			Local s:String = String.FromInt(v)

			' basic sanity: must not be empty
			AssertTrue(s.Length > 0, "String.FromInt produced empty string for " + v)

			' negative values must start with '-'
			If v < 0 Then
				AssertTrue(s.StartsWith("-"), "Negative value should start with '-' for " + v)
			Else
				AssertFalse(s.StartsWith("-"), "Non-negative value should not start with '-' for " + v)
			End If

			' round-trip check via Int parsing
			AssertEquals(v, Int(s), "String.FromInt round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringFromLongTest Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromLong(0:Long), "String.FromLong(0) should be '0'")
	End Method

	Method Test_Positive() { test }
		AssertEquals("42", String.FromLong(42:Long), "String.FromLong(42) should be '42'")
	End Method

	Method Test_Negative() { test }
		AssertEquals("-42", String.FromLong(-42:Long), "String.FromLong(-42) should be '-42'")
	End Method

	Method Test_LongMinMax() { test }
		' Long in BlitzMax is 64-bit signed
		Local minVal:Long = $8000000000000000:Long ' -9223372036854775808
		Local maxVal:Long = $7FFFFFFFFFFFFFFF:Long '  9223372036854775807

		AssertEquals("-9223372036854775808", String.FromLong(minVal), "String.FromLong(Long Min) should match")
		AssertEquals("9223372036854775807", String.FromLong(maxVal), "String.FromLong(Long Max) should match")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		' Boundaries around powers of 10 + sign, including values > 32-bit
		Local vals:Long[] = [ ..
			0:Long, 1:Long, 9:Long, 10:Long, 11:Long, ..
			99:Long, 100:Long, 101:Long, ..
			999:Long, 1000:Long, 1001:Long, ..
			9999:Long, 10000:Long, 10001:Long, ..
			99999:Long, 100000:Long, 100001:Long, ..
			999999:Long, 1000000:Long, 1000001:Long, ..
			999999999:Long, 1000000000:Long, 1000000001:Long, ..
			9999999999:Long, 10000000000:Long, 10000000001:Long, ..
			999999999999999999:Long, 1000000000000000000:Long, 1000000000000000001:Long, ..
			-1:Long, -9:Long, -10:Long, -99:Long, -100:Long, -1000:Long, -1000000:Long, -10000000000:Long ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:Long = vals[i]
			Local s:String = String.FromLong(v)

			AssertTrue(s.Length > 0, "String.FromLong produced empty string for " + v)

			If v < 0 Then
				AssertTrue(s.StartsWith("-"), "Negative value should start with '-' for " + v)
			Else
				AssertFalse(s.StartsWith("-"), "Non-negative value should not start with '-' for " + v)
			End If

			' round-trip check via Long parsing
			AssertEquals(v, Long(s), "String.FromLong round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringFromULongTest Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromULong(0:ULong), "String.FromULong(0) should be '0'")
	End Method

	Method Test_PositiveSmall() { test }
		AssertEquals("42", String.FromULong(42:ULong), "String.FromULong(42) should be '42'")
	End Method

	Method Test_ULongMax() { test }
		Local maxVal:ULong = $FFFFFFFFFFFFFFFF:ULong ' 18446744073709551615
		AssertEquals("18446744073709551615", String.FromULong(maxVal), "String.FromULong(ULong Max) should match")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		' Boundaries around powers of 10 and values beyond 32-bit and signed 64-bit
		Local vals:ULong[] = [ ..
			0:ULong, 1:ULong, 9:ULong, 10:ULong, 11:ULong, ..
			99:ULong, 100:ULong, 101:ULong, ..
			999:ULong, 1000:ULong, 1001:ULong, ..
			9999:ULong, 10000:ULong, 10001:ULong, ..
			99999:ULong, 100000:ULong, 100001:ULong, ..
			999999:ULong, 1000000:ULong, 1000001:ULong, ..
			9999999:ULong, 10000000:ULong, 10000001:ULong, ..
			99999999:ULong, 100000000:ULong, 100000001:ULong, ..
			999999999:ULong, 1000000000:ULong, 1000000001:ULong, ..
			9999999999:ULong, 10000000000:ULong, 10000000001:ULong, ..
			999999999999999999:ULong, 1000000000000000000:ULong, 1000000000000000001:ULong, ..
			9223372036854775807:ULong, ..
			9223372036854775808:ULong, ..
			18446744073709551614:ULong, 18446744073709551615:ULong ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:ULong = vals[i]
			Local s:String = String.FromULong(v)

			AssertTrue(s.Length > 0, "String.FromULong produced empty string for " + v)

			' unsigned: must not start with '-'
			AssertFalse(s.StartsWith("-"), "Unsigned value should not start with '-' for " + v)

			' round-trip check via ULong parsing
			AssertEquals(v, ULong(s), "String.FromULong round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringFromUIntTest Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromUInt(0:UInt), "String.FromUInt(0) should be '0'")
	End Method

	Method Test_PositiveSmall() { test }
		AssertEquals("42", String.FromUInt(42:UInt), "String.FromUInt(42) should be '42'")
	End Method

	Method Test_UIntMax() { test }
		Local maxVal:UInt = $FFFFFFFF:UInt ' 4294967295
		AssertEquals("4294967295", String.FromUInt(maxVal), "String.FromUInt(UInt Max) should match")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		' Boundaries around powers of 10, and values above signed 32-bit max
		Local vals:UInt[] = [ ..
			0:UInt, 1:UInt, 9:UInt, 10:UInt, 11:UInt, ..
			99:UInt, 100:UInt, 101:UInt, ..
			999:UInt, 1000:UInt, 1001:UInt, ..
			9999:UInt, 10000:UInt, 10001:UInt, ..
			99999:UInt, 100000:UInt, 100001:UInt, ..
			999999:UInt, 1000000:UInt, 1000001:UInt, ..
			9999999:UInt, 10000000:UInt, 10000001:UInt, ..
			99999999:UInt, 100000000:UInt, 100000001:UInt, ..
			999999999:UInt, 1000000000:UInt, 1000000001:UInt, ..
			2147483647:UInt, ..
			2147483648:UInt, ..
			4000000000:UInt, ..
			4294967294:UInt, 4294967295:UInt ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:UInt = vals[i]
			Local s:String = String.FromUInt(v)

			AssertTrue(s.Length > 0, "String.FromUInt produced empty string for " + v)

			' unsigned: must not start with '-'
			AssertFalse(s.StartsWith("-"), "Unsigned value should not start with '-' for " + v)

			' round-trip check via UInt parsing
			AssertEquals(v, UInt(s), "String.FromUInt round-trip should match for " + v)
		Next
	End Method

End Type

?ptr32

Type TStringFromSizeT32Test Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromSizeT(0:Size_T), "String.FromSizeT(0) should be '0' (ptr32)")
	End Method

	Method Test_PositiveSmall() { test }
		AssertEquals("42", String.FromSizeT(42:Size_T), "String.FromSizeT(42) should be '42' (ptr32)")
	End Method

	Method Test_SizeTMax_32bit() { test }
		Local maxVal:Size_T = $FFFFFFFF:Size_T ' 4294967295
		AssertEquals("4294967295", String.FromSizeT(maxVal), "String.FromSizeT(Size_T Max) should match (ptr32)")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:Size_T[] = [ ..
			0:Size_T, 1:Size_T, 9:Size_T, 10:Size_T, 11:Size_T, ..
			99:Size_T, 100:Size_T, 101:Size_T, ..
			999:Size_T, 1000:Size_T, 1001:Size_T, ..
			9999:Size_T, 10000:Size_T, 10001:Size_T, ..
			99999:Size_T, 100000:Size_T, 100001:Size_T, ..
			999999:Size_T, 1000000:Size_T, 1000001:Size_T, ..
			2147483647:Size_T, ..
			2147483648:Size_T, ..
			4000000000:Size_T, ..
			4294967294:Size_T, 4294967295:Size_T ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:Size_T = vals[i]
			Local s:String = String.FromSizeT(v)

			AssertTrue(s.Length > 0, "String.FromSizeT produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned Size_T should not start with '-' for " + v)

			AssertEquals(v, Size_T(s), "String.FromSizeT round-trip should match for " + v)
		Next
	End Method

End Type

?ptr64

Type TStringFromSizeT64Test Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromSizeT(0:Size_T), "String.FromSizeT(0) should be '0' (ptr64)")
	End Method

	Method Test_PositiveSmall() { test }
		AssertEquals("42", String.FromSizeT(42:Size_T), "String.FromSizeT(42) should be '42' (ptr64)")
	End Method

	Method Test_SizeTMax_64bit() { test }
		' Local maxVal:Size_T = $FFFFFFFFFFFFFFFF:Size_T ' 18446744073709551615
		' AssertEquals("18446744073709551615", String.FromSizeT(maxVal), "String.FromSizeT(Size_T Max) should match (ptr64)")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:Size_T[] = [ ..
			0:Size_T, 1:Size_T, 9:Size_T, 10:Size_T, 11:Size_T, ..
			99:Size_T, 100:Size_T, 101:Size_T, ..
			999:Size_T, 1000:Size_T, 1001:Size_T, ..
			9999:Size_T, 10000:Size_T, 10001:Size_T, ..
			99999:Size_T, 100000:Size_T, 100001:Size_T, ..
			999999:Size_T, 1000000:Size_T, 1000001:Size_T, ..
			999999999:Size_T, 1000000000:Size_T, 1000000001:Size_T, ..
			9999999999:Size_T, 10000000000:Size_T, 10000000001:Size_T, ..
			9223372036854775807:Size_T, ..
			9223372036854775808:Size_T, ..
			18446744073709551614:Size_T, 18446744073709551615:Size_T ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:Size_T = vals[i]
			Local s:String = String.FromSizeT(v)

			AssertTrue(s.Length > 0, "String.FromSizeT produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned Size_T should not start with '-' for " + v)

			AssertEquals(v, Size_T(s), "String.FromSizeT round-trip should match for " + v)
		Next
	End Method

End Type

?

?longint4

Type TStringFromLongInt32Test Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromLongInt(0:LongInt), "String.FromLongInt(0) should be '0' (longint4)")
	End Method

	Method Test_Positive() { test }
		AssertEquals("42", String.FromLongInt(42:LongInt), "String.FromLongInt(42) should be '42' (longint4)")
	End Method

	Method Test_Negative() { test }
		AssertEquals("-42", String.FromLongInt(-42:LongInt), "String.FromLongInt(-42) should be '-42' (longint4)")
	End Method

	Method Test_LongIntMinMax_32bit() { test }
		Local minVal:LongInt = $80000000:LongInt
		Local maxVal:LongInt = $7FFFFFFF:LongInt

		AssertEquals("-2147483648", String.FromLongInt(minVal), "String.FromLongInt(LongInt Min) should match (32-bit)")
		AssertEquals("2147483647", String.FromLongInt(maxVal), "String.FromLongInt(LongInt Max) should match (32-bit)")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:LongInt[] = [ ..
			0:LongInt, 1:LongInt, 9:LongInt, 10:LongInt, 11:LongInt, ..
			99:LongInt, 100:LongInt, 101:LongInt, ..
			999:LongInt, 1000:LongInt, 1001:LongInt, ..
			9999:LongInt, 10000:LongInt, 10001:LongInt, ..
			99999:LongInt, 100000:LongInt, 100001:LongInt, ..
			999999:LongInt, 1000000:LongInt, 1000001:LongInt, ..
			-1:LongInt, -9:LongInt, -10:LongInt, -99:LongInt, -100:LongInt, -1000:LongInt, -1000000:LongInt ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:LongInt = vals[i]
			Local s:String = String.FromLongInt(v)

			AssertTrue(s.Length > 0, "String.FromLongInt produced empty string for " + v)
			If v < 0 Then
				AssertTrue(s.StartsWith("-"), "Negative value should start with '-' for " + v)
			Else
				AssertFalse(s.StartsWith("-"), "Non-negative value should not start with '-' for " + v)
			End If

			AssertEquals(v, LongInt(s), "String.FromLongInt round-trip should match for " + v)
		Next
	End Method

End Type

?longint8

Type TStringFromLongInt64Test Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromLongInt(0:LongInt), "String.FromLongInt(0) should be '0' (longint8)")
	End Method

	Method Test_Positive() { test }
		AssertEquals("42", String.FromLongInt(42:LongInt), "String.FromLongInt(42) should be '42' (longint8)")
	End Method

	Method Test_Negative() { test }
		AssertEquals("-42", String.FromLongInt(-42:LongInt), "String.FromLongInt(-42) should be '-42' (longint8)")
	End Method

	Method Test_LongIntMinMax_64bit() { test }
		Local minVal:LongInt = $8000000000000000:LongInt
		Local maxVal:LongInt = $7FFFFFFFFFFFFFFF:LongInt

		AssertEquals("-9223372036854775808", String.FromLongInt(minVal), "String.FromLongInt(LongInt Min) should match (64-bit)")
		AssertEquals("9223372036854775807", String.FromLongInt(maxVal), "String.FromLongInt(LongInt Max) should match (64-bit)")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:LongInt[] = [ ..
			0:LongInt, 1:LongInt, 9:LongInt, 10:LongInt, 11:LongInt, ..
			99:LongInt, 100:LongInt, 101:LongInt, ..
			999:LongInt, 1000:LongInt, 1001:LongInt, ..
			9999:LongInt, 10000:LongInt, 10001:LongInt, ..
			99999:LongInt, 100000:LongInt, 100001:LongInt, ..
			999999:LongInt, 1000000:LongInt, 1000001:LongInt, ..
			9999999999:LongInt, 10000000000:LongInt, 10000000001:LongInt, ..
			999999999999999999:LongInt, 1000000000000000000:LongInt, 1000000000000000001:LongInt, ..
			-1:LongInt, -9:LongInt, -10:LongInt, -99:LongInt, -100:LongInt, -1000:LongInt, -1000000:LongInt, -10000000000:LongInt ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:LongInt = vals[i]
			Local s:String = String.FromLongInt(v)

			AssertTrue(s.Length > 0, "String.FromLongInt produced empty string for " + v)
			If v < 0 Then
				AssertTrue(s.StartsWith("-"), "Negative value should start with '-' for " + v)
			Else
				AssertFalse(s.StartsWith("-"), "Non-negative value should not start with '-' for " + v)
			End If

			AssertEquals(v, LongInt(s), "String.FromLongInt round-trip should match for " + v)
		Next
	End Method

End Type

?

?ulongint4

Type TStringFromULongInt32Test Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromULongInt(0:ULongInt), "String.FromULongInt(0) should be '0' (ulongint4)")
	End Method

	Method Test_PositiveSmall() { test }
		AssertEquals("42", String.FromULongInt(42:ULongInt), "String.FromULongInt(42) should be '42' (ulongint4)")
	End Method

	Method Test_ULongIntMax_32bit() { test }
		Local maxVal:ULongInt = $FFFFFFFF:ULongInt
		AssertEquals("4294967295", String.FromULongInt(maxVal), "String.FromULongInt(ULongInt Max) should match (32-bit)")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:ULongInt[] = [ ..
			0:ULongInt, 1:ULongInt, 9:ULongInt, 10:ULongInt, 11:ULongInt, ..
			99:ULongInt, 100:ULongInt, 101:ULongInt, ..
			999:ULongInt, 1000:ULongInt, 1001:ULongInt, ..
			9999:ULongInt, 10000:ULongInt, 10001:ULongInt, ..
			99999:ULongInt, 100000:ULongInt, 100001:ULongInt, ..
			2147483647:ULongInt, ..
			2147483648:ULongInt, ..
			4000000000:ULongInt, ..
			4294967294:ULongInt, 4294967295:ULongInt ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:ULongInt = vals[i]
			Local s:String = String.FromULongInt(v)

			AssertTrue(s.Length > 0, "String.FromULongInt produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned ULongInt should not start with '-' for " + v)

			AssertEquals(v, ULongInt(s), "String.FromULongInt round-trip should match for " + v)
		Next
	End Method

End Type

?ulongint8

Type TStringFromULongInt64Test Extends TTest

	Method Test_Zero() { test }
		AssertEquals("0", String.FromULongInt(0:ULongInt), "String.FromULongInt(0) should be '0' (ulongint8)")
	End Method

	Method Test_PositiveSmall() { test }
		AssertEquals("42", String.FromULongInt(42:ULongInt), "String.FromULongInt(42) should be '42' (ulongint8)")
	End Method

	Method Test_ULongIntMax_64bit() { test }
		Local maxVal:ULongInt = $FFFFFFFFFFFFFFFF:ULongInt
		AssertEquals("18446744073709551615", String.FromULongInt(maxVal), "String.FromULongInt(ULongInt Max) should match (64-bit)")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:ULongInt[] = [ ..
			0:ULongInt, 1:ULongInt, 9:ULongInt, 10:ULongInt, 11:ULongInt, ..
			99:ULongInt, 100:ULongInt, 101:ULongInt, ..
			999:ULongInt, 1000:ULongInt, 1001:ULongInt, ..
			9999:ULongInt, 10000:ULongInt, 10001:ULongInt, ..
			99999:ULongInt, 100000:ULongInt, 100001:ULongInt, ..
			4294967295:ULongInt, ..
			4294967296:ULongInt, ..
			9223372036854775807:ULongInt, ..
			9223372036854775808:ULongInt, ..
			18446744073709551614:ULongInt, 18446744073709551615:ULongInt ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:ULongInt = vals[i]
			Local s:String = String.FromULongInt(v)

			AssertTrue(s.Length > 0, "String.FromULongInt produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned ULongInt should not start with '-' for " + v)

			AssertEquals(v, ULongInt(s), "String.FromULongInt round-trip should match for " + v)
		Next
	End Method

End Type

?

Type TStringCompareCaseTest Extends TTest

	' Helper: normalize compare to -1, 0, 1 for easier assertions
	Method Sign:Int(x:Int)
		If x < 0 Then Return -1
		If x > 0 Then Return  1
		Return 0
	End Method

	' ---------- Basic sanity: empty & identical ----------
	Method testEmptyAndIdentical() { test }
		assertEquals(0, "".Compare("", True),   "Empty vs empty, sensitive")
		assertEquals(0, "".Compare("", False), "Empty vs empty, insensitive")

		assertEquals(0, "abc".Compare("abc", True),   "Identical ASCII, sensitive")
		assertEquals(0, "abc".Compare("abc", False), "Identical ASCII, insensitive")
	End Method

	' ---------- ASCII: equality & ordering ----------
	Method testAsciiEqualityAndOrdering() { test }
		' Equality under CI (case-insensitive)
		assertEquals(0, "abc".Compare("ABC", False), "ASCII equals under CI")
		assertEquals(0, "FoObAr".Compare("foobar", False), "Mixed case equals under CI")

		' Ordering under CS (case-sensitive) mirrors ordinal
		assertEquals(-1, Sign("A".Compare("B", True)), "CS ordering A<B")
		assertEquals( 1, Sign("B".Compare("A", True)), "CS ordering B>A")

		' Ordering under CI should compare folded units: "a" < "b"
		assertEquals(-1, Sign("A".Compare("b", False)), "CI ordering a<b")
		assertEquals( 1, Sign("C".Compare("b", False)), "CI ordering c>b")

		' Prefix behavior: shorter wins when common prefix matches
		assertEquals(-1, Sign("foo".Compare("foobar", False)), "CI prefix shorter<longer")
		assertEquals( 1, Sign("foobar".Compare("foo", False)), "CI prefix longer>shorter")
	End Method

	' ---------- Digits & punctuation unaffected ----------
	Method testNonLetters() { test }
		assertEquals(0, "123-456".Compare("123-456", False), "Digits/punct equal")
		assertFalse("123-456".Compare("123_456", False) = 0, "Dash vs underscore differ")
	End Method

	' ---------- Latin-1 & extended Latin ----------
	Method testLatinExtended() { test }
		' É vs é should be equal under CI
		Local upper:String = "CAFÉ"       ' U+00C9
		Local lower:String = "café"       ' U+00E9
		assertEquals(0, upper.Compare(lower, False), "CAFÉ vs café equal under CI")

		' Composed vs decomposed: é (U+00E9) vs e + ́ (U+0065 U+0301)
		' Without normalization, these should NOT compare equal.
		Local composed:String = "café"                     ' ... U+00E9
		Local decomposed:String = "cafe" + Chr($0301)      ' ... U+0301 combining acute
		assertFalse(composed.Compare(decomposed, False) = 0, ..
			"No normalization: composed ≠ decomposed under CI")
	End Method

	' ---------- German sharp s / eszett ----------
	Method testGermanEszett() { test }
		' Simple case folding does NOT equate "ß" to "ss".
		assertFalse("straße".Compare("strasse", False) = 0, ..
			"Simple CI: ß ≠ ss (full case folding would be required)")
		' But “ß” vs “ẞ” (U+1E9E) should be equal under CI.
		assertEquals(0, "fuß".Compare("FUẞ", False), "ß vs ẞ equals under CI")
	End Method

	' ---------- Greek sigma (regular vs final) ----------
	Method testGreekSigma() { test }
		' Expect Σ/σ/ς to compare equal under CI (simple case folding maps ς→σ).
		assertEquals(0, "ΣΕΛΑΣ".Compare("σελας", False), "Greek uppercase vs lowercase")
		assertEquals(0, "ὈΔΥΣΣΕΎΣ".Compare("ὀδυσσεύς", False), "Includes final sigma ς vs σ")
		' Also check a minimal ς vs σ equivalence
		assertEquals(0, "ς".Compare("σ", False), "Final sigma equals sigma under CI")
	End Method

	' ---------- Cyrillic ----------
	Method testCyrillic() { test }
		assertEquals(0, "ПрИвЕт".Compare("привет", False), "Cyrillic equals under CI")
		assertFalse("Привет".Compare("Привед", False) = 0, "Different Cyrillic letters differ")
	End Method

	' ---------- Turkish dotted/dotless I (locale-insensitive) ----------
	Method testTurkishI() { test }
		' In default, locale-neutral simple folding:
		' "I" (U+0049) lowercases to "i" (U+0069), while "ı" (U+0131) stays dotless.
		assertFalse("I".Compare("ı", False) = 0, "Turkish I vs dotless ı not equal under default CI")
		assertEquals(0, "İNAN".Compare("inan", False), "Dotted İ (U+0130) vs 'i' under CI if table lowers U+0130→i")
	End Method

	' ---------- BMP edges & stability ----------
	Method testUnicodeMisc() { test }
		' Characters without case remain identical
		assertEquals(0, "π≈3.14".Compare("π≈3.14", False), "Symbols unaffected")

		' Different code points remain ordered deterministically under CI
		assertEquals(-1, Sign("Δ".Compare("Ω", False)), "Greek Delta < Omega under CI")

		' Emojis / surrogate pairs: treated as opaque code units (no folding). Should compare as-is.
		Local smile:String = "~q😀~q"	' If your source supports it; otherwise comment this out.
		assertEquals(0, smile.Compare(smile, False), "Emoji compares equal to itself (CI)")
		assertEquals(0, smile.Compare(smile, True),   "Emoji compares equal to itself (CS)")
	End Method

	' ---------- Symmetry & antisymmetry properties ----------
	Method testCompareProperties() { test }
		Local a:String = "Alpha"
		Local b:String = "beta"

		Local cs_ab:Int = a.Compare(b, True)
		Local cs_ba:Int = b.Compare(a, True)
		assertEquals(-Sign(cs_ba), Sign(cs_ab), "CS antisymmetry: sign(a,b) = -sign(b,a)")

		Local ci_ab:Int = a.Compare(b, False)
		Local ci_ba:Int = b.Compare(a, False)
		assertEquals(-Sign(ci_ba), Sign(ci_ab), "CI antisymmetry: sign(a,b) = -sign(b,a)")

		' Consistency with equals (CI)
		assertEquals(0, "FOO".Compare("foo", False), "Consistency: CI equal")
		assertFalse("FOO".Compare("bar", False) = 0, "Consistency: CI not equal")
	End Method

	' ---------- Long strings hot path (ASCII fast path coverage) ----------
	Method testLongAsciiPerformancePattern() { test }
		' Not a perf test per se, but hits the ASCII fast path heavily.
		Local s1:String = "TheQuickBrownFoxJumpsOverTheLazyDog"
		Local s2:String = "thequickbrownfoxjumpsoverthelazydog"
		assertEquals(0, s1.Compare(s2, False), "Pangram equals under CI")
		' Verify ordering changes with a terminal char
		assertEquals(1, Sign((s1 + "z").Compare(s2 + "y", False)), "Ordering with suffixes under CI")
	End Method

	Method testSimpleFoldOverrides() { test }
		assertEquals(0, "ΟΣ".Compare("ος", False), "Sigma family equal under CI")
		assertEquals(0, "Σ".Compare("ς", False), "Σ vs ς equal under CI")
		assertEquals(0, "FUẞ".Compare("fuß", False), "ẞ -> ß simple fold")
		assertEquals(0, "ſ".Compare("s", False), "long s ſ -> s")
		assertEquals(0, "µ".Compare("μ", False), "micro sign µ -> μ")
		assertEquals(0, "Ω".Compare("ω", False), "ohm sign Ω -> ω")
		assertEquals(0, "K".Compare("k", False), "kelvin sign K -> k")
		assertEquals(0, "Å".Compare("å", False), "angstrom sign Å -> å")
		assertEquals(0, "ι".Compare("ι", False), "1FBE -> ι")
	End Method
End Type

' testing enum DefaultComparator_HashCode stability and correctness

Enum EByte:Byte
    B0
    B1
End Enum

Enum EShort:Short
    S0
    S1
End Enum

' Default underlying type: Int
Enum EInt
    I0
    I1
End Enum

Enum EUInt:UInt
    U0
    U1
End Enum

Enum ELong:Long
    L0
    L1
End Enum

Enum EULong:ULong
    UL0
    UL1
End Enum

Enum ELongInt:LongInt
    LI0
    LI1
End Enum

Enum EULongInt:ULongInt
    ULI0
    ULI1
End Enum

Enum ESizeT:Size_T
    SZ0
    SZ1
End Enum

' Bit flags enum (default underlying Int)
Enum EBits Flags
    First
    Second
    Third
End Enum

Type TEnumHashCodeTests Extends TTest

    ' --------------------------------------------------------------
    ' Byte
    ' --------------------------------------------------------------
    Method Test_EnumByte_Hash_StableAndMatchesOrdinal() { test }
        For Local v:EByte = EachIn EByte.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "EByte hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "EByte hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumByte_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(EByte.B0)
        Local h1:UInt = DefaultComparator_HashCode(EByte.B1)
        AssertTrue(h0 <> h1, "Different EByte values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' Short
    ' --------------------------------------------------------------
    Method Test_EnumShort_Hash_StableAndMatchesOrdinal() { test }
        For Local v:EShort = EachIn EShort.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "EShort hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "EShort hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumShort_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(EShort.S0)
        Local h1:UInt = DefaultComparator_HashCode(EShort.S1)
        AssertTrue(h0 <> h1, "Different EShort values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' Int (default)
    ' --------------------------------------------------------------
    Method Test_EnumInt_Hash_StableAndMatchesOrdinal() { test }
        For Local v:EInt = EachIn EInt.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "EInt hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "EInt hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumInt_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(EInt.I0)
        Local h1:UInt = DefaultComparator_HashCode(EInt.I1)
        AssertTrue(h0 <> h1, "Different EInt values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' UInt
    ' --------------------------------------------------------------
    Method Test_EnumUInt_Hash_StableAndMatchesOrdinal() { test }
        For Local v:EUInt = EachIn EUInt.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "EUInt hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "EUInt hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumUInt_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(EUInt.U0)
        Local h1:UInt = DefaultComparator_HashCode(EUInt.U1)
        AssertTrue(h0 <> h1, "Different EUInt values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' Long
    ' --------------------------------------------------------------
    Method Test_EnumLong_Hash_StableAndMatchesOrdinal() { test }
        For Local v:ELong = EachIn ELong.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "ELong hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "ELong hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumLong_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(ELong.L0)
        Local h1:UInt = DefaultComparator_HashCode(ELong.L1)
        AssertTrue(h0 <> h1, "Different ELong values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' ULong
    ' --------------------------------------------------------------
    Method Test_EnumULong_Hash_StableAndMatchesOrdinal() { test }
        For Local v:EULong = EachIn EULong.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "EULong hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "EULong hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumULong_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(EULong.UL0)
        Local h1:UInt = DefaultComparator_HashCode(EULong.UL1)
        AssertTrue(h0 <> h1, "Different EULong values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' LongInt
    ' --------------------------------------------------------------
    Method Test_EnumLongInt_Hash_StableAndMatchesOrdinal() { test }
        For Local v:ELongInt = EachIn ELongInt.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "ELongInt hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "ELongInt hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumLongInt_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(ELongInt.LI0)
        Local h1:UInt = DefaultComparator_HashCode(ELongInt.LI1)
        AssertTrue(h0 <> h1, "Different ELongInt values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' ULongInt
    ' --------------------------------------------------------------
    Method Test_EnumULongInt_Hash_StableAndMatchesOrdinal() { test }
        For Local v:EULongInt = EachIn EULongInt.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "EULongInt hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "EULongInt hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumULongInt_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(EULongInt.ULI0)
        Local h1:UInt = DefaultComparator_HashCode(EULongInt.ULI1)
        AssertTrue(h0 <> h1, "Different EULongInt values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' Size_T
    ' --------------------------------------------------------------
    Method Test_EnumSizeT_Hash_StableAndMatchesOrdinal() { test }
        For Local v:ESizeT = EachIn ESizeT.Values()
            Local h1:UInt = DefaultComparator_HashCode(v)
            Local h2:UInt = DefaultComparator_HashCode(v)
            AssertEquals(h1, h2, "ESizeT hash must be stable for value " + v.ToString())

            Local ordHash:UInt = DefaultComparator_HashCode(v.Ordinal())
            AssertEquals(ordHash, h1, "ESizeT hash must match hash of Ordinal() for " + v.ToString())
        Next
    End Method

    Method Test_EnumSizeT_DifferentValuesDifferentHashes() { test }
        Local h0:UInt = DefaultComparator_HashCode(ESizeT.SZ0)
        Local h1:UInt = DefaultComparator_HashCode(ESizeT.SZ1)
        AssertTrue(h0 <> h1, "Different ESizeT values should normally have different hashes")
    End Method


    ' --------------------------------------------------------------
    ' Flags enum (uses default Int)
    ' --------------------------------------------------------------
    Method Test_FlagsEnum_Hash_StableAndMatchesOrdinal() { test }
        ' Single flag
        Local single:EBits = EBits.Second
        Local sh1:UInt = DefaultComparator_HashCode(single)
        Local sh2:UInt = DefaultComparator_HashCode(single)
        AssertEquals(sh1, sh2, "EBits single flag hash must be stable")

        Local singleOrdHash:UInt = DefaultComparator_HashCode(single.Ordinal())
        AssertEquals(singleOrdHash, sh1, "EBits single flag hash must match Ordinal() hash")

        ' Combination
        Local combo:EBits = EBits.First | EBits.Third
        Local ch1:UInt = DefaultComparator_HashCode(combo)
        Local ch2:UInt = DefaultComparator_HashCode(combo)
        AssertEquals(ch1, ch2, "EBits combined flags hash must be stable")

        Local comboOrdHash:UInt = DefaultComparator_HashCode(combo.Ordinal())
        AssertEquals(comboOrdHash, ch1, "EBits combined flags hash must match Ordinal() hash")
    End Method

    Method Test_FlagsEnum_DifferentCombinationsDifferentHashes() { test }
        Local first:EBits    = EBits.First
        Local combo:EBits    = EBits.First | EBits.Third

        Local firstHash:UInt = DefaultComparator_HashCode(first)
        Local comboHash:UInt = DefaultComparator_HashCode(combo)

        AssertTrue(firstHash <> comboHash, "Different EBits flag combinations should normally have different hashes")
    End Method

End Type

Type TUsingCloseableTests Extends TTest

	Method Setup() { before }
		TCloseLog.Reset()
	End Method

	Method TearDown() { after }
		' no-op
	End Method

	' --- Basic close behavior ---

	Method UsingClosesOnNormalExit_Single() { test }
		Using
			Local a:TCloseableBase = New TCloseableBase("A")
		Do
			TCloseLog.Add("body")
		End Using

		AssertEquals("body|close:A", TCloseLog.log, "Expected Close to run after body on normal exit.")
	End Method

	Method UsingClosesOnReturn_Single() { test }
		Using
			Local a:TCloseableBase = New TCloseableBase("A")
		Do
			TCloseLog.Add("body")
			Return
		End Using

		' If Using desugars to Try/Finally, close should still run.
		AssertEquals("body|close:A", TCloseLog.log, "Expected Close to run even when returning from Using block.")
	End Method

	Method UsingClosesMultipleInReverseOrder() { test }
		Using
			Local a:TCloseableBase = New TCloseableBase("A")
			Local b:TCloseableBase = New TCloseableBase("B")
			Local c:TCloseableBase = New TCloseableBase("C")
		Do
			TCloseLog.Add("body")
		End Using

		AssertEquals("body|close:C|close:B|close:A", TCloseLog.log, "Expected Close in reverse declaration order.")
	End Method

	Method UsingClosesMultipleOnReturnInReverseOrder() { test }
		Using
			Local a:TCloseableBase = New TCloseableBase("A")
			Local b:TCloseableBase = New TCloseableBase("B")
		Do
			TCloseLog.Add("body")
			Return
		End Using

		AssertEquals("body|close:B|close:A", TCloseLog.log, "Expected Close in reverse order even on Return.")
	End Method

	' --- Close exceptions swallowed ---

	Method CloseExceptionIsSwallowed_Single() { test }
		Using
			Local a:TCloseableBase = New TCloseableBase("A", True)
		Do
			TCloseLog.Add("body")
		End Using

		' If Close throws but is swallowed, test completes and log contains close.
		AssertEquals("body|close:A", TCloseLog.log, "Expected Close exception swallowed and Close still logged.")
	End Method

	Method CloseExceptionsDoNotStopOtherCloses() { test }
		Using
			Local a:TCloseableBase = New TCloseableBase("A", True)
			Local b:TCloseableBase = New TCloseableBase("B", True)
			Local c:TCloseableBase = New TCloseableBase("C", False)
		Do
			TCloseLog.Add("body")
		End Using

		' All closes should have been attempted in reverse order, regardless of exceptions.
		AssertEquals("body|close:C|close:B|close:A", TCloseLog.log, "Expected all Close calls attempted even when some throw.")
	End Method

	Method BodyExceptionPropagates_CloseExceptionsSwallowed() { test }
		Local caught:Int = False

		Try
			Using
				Local a:TCloseableBase = New TCloseableBase("A", True)
				Local b:TCloseableBase = New TCloseableBase("B", True)
			Do
				TCloseLog.Add("body")
				Throw "BodyBoom"
			End Using
		Catch e:Object
			caught = True
			TCloseLog.Add("caught")
		End Try

		AssertTrue(caught, "Expected body exception to propagate out of Using (and be catchable).")
		AssertEquals("body|close:B|close:A|caught", TCloseLog.log, "Expected closes attempted, close exceptions swallowed, body exception preserved.")
	End Method

	' --- Throwing from body / try integration ---

	Method UsingClosesOnBodyThrow_MultipleReverseOrder() { test }
		Local caught:Int = False

		Try
			ThrowInsideUsing("X:", False, False)
		Catch e:Object
			caught = True
			TCloseLog.Add("caught:X")
		End Try

		AssertTrue(caught, "Expected exception thrown in body to be caught outside.")
		AssertEquals("body:X:|close:X:B|close:X:A|caught:X", TCloseLog.log, "Expected close in reverse order after body throw.")
	End Method

	Method UsingInsideTryCatch_BodyThrows_ClosesBeforeCatch() { test }
		UsingInsideTryCatch("T1:", True)

		' Expect: body then closes then catch marker.
		AssertEquals("body:T1:|close:T1:B|close:T1:A|caught:T1:", TCloseLog.log, "Expected Using closes run before outer Catch executes.")
	End Method

	Method TryCatchInsideUsing_InnerThrowHandled_StillCloses() { test }
		TryCatchInsideUsing("T2:", True)

		AssertEquals("body:T2:|innercatch:T2:|close:T2:B|close:T2:A", TCloseLog.log, "Expected inner exception handled, then closes run.")
	End Method

	Method TryCatchInsideUsing_NoInnerThrow_StillCloses() { test }
		TryCatchInsideUsing("T3:", False)

		AssertEquals("body:T3:|innertry:ok:T3:|close:T3:B|close:T3:A", TCloseLog.log, "Expected normal inner try path, then closes run.")
	End Method

	' --- Nested Using ---

	Method NestedUsing_ClosesInnerBeforeOuter() { test }
		NestedUsing("N1:", False, False)

		AssertEquals("body:outer:N1:|body:inner:N1:|close:N1:Inner|close:N1:Outer", TCloseLog.log, "Expected inner Close before outer Close.")
	End Method

	Method NestedUsing_InnerCloseThrows_OuterStillCloses() { test }
		NestedUsing("N2:", False, True)

		AssertEquals("body:outer:N2:|body:inner:N2:|close:N2:Inner|close:N2:Outer", TCloseLog.log, "Expected inner Close exception swallowed; outer still closes.")
	End Method

	Method NestedUsing_OuterCloseThrows_DoesNotAffectInnerClose() { test }
		NestedUsing("N3:", True, False)

		AssertEquals("body:outer:N3:|body:inner:N3:|close:N3:Inner|close:N3:Outer", TCloseLog.log, "Expected inner closes first; outer Close exception swallowed.")
	End Method

	Method NestedUsing_BodyReturn_StillClosesAll() { test }
		Using
			Local outer:TCloseableBase = New TCloseableBase("Outer")
		Do
			TCloseLog.Add("body:outer")
			Using
				Local inner:TCloseableBase = New TCloseableBase("Inner")
			Do
				TCloseLog.Add("body:inner")
				Return
			End Using
			' unreachable
		End Using

		AssertEquals("body:outer|body:inner|close:Inner|close:Outer", TCloseLog.log, "Expected Return inside inner Using still closes inner+outer.")
	End Method

	' --- Using in Finally ---

	Method UsingInFinally_NoThrowInTry() { test }
		UsingInFinally("F1:", False)

		AssertEquals("try:F1:|finallybody:F1:|close:F1:B|close:F1:A", TCloseLog.log, "Expected Using inside Finally runs and closes normally.")
	End Method

	Method UsingInFinally_TryThrows_FinallyRunsAndCloses() { test }
		Local caught:Int = False

		Try
			UsingInFinally("F2:", True)
		Catch e:Object
			caught = True
			TCloseLog.Add("caught:F2")
		End Try

		AssertTrue(caught, "Expected outer try to catch exception thrown before Finally.")
		AssertEquals("try:F2:|finallybody:F2:|close:F2:B|close:F2:A|caught:F2", TCloseLog.log, "Expected Finally runs Using+closes even when Try throws.")
	End Method

	' --- Functions/methods integration ---

	Method UsingInsideFunction_Returns_ClosesAll() { test }
		ReturnInsideUsing("R1:", False, False)
		AssertEquals("body:R1:|close:R1:B|close:R1:A", TCloseLog.log, "Expected closes on return inside function helper.")
	End Method

	Method UsingInsideFunction_Returns_CloseThrows_Swallowed() { test }
		ReturnInsideUsing("R2:", True, True)
		AssertEquals("body:R2:|close:R2:B|close:R2:A", TCloseLog.log, "Expected close exceptions swallowed on return path.")
	End Method

	Method UsingInsideFunction_BodyThrows_CloseThrows_BodyPropagates() { test }
		Local caught:Int = False
		Try
			ThrowInsideUsing("E1:", True, True)
		Catch e:Object
			caught = True
			TCloseLog.Add("caught:E1")
		End Try

		AssertTrue(caught, "Expected body exception from helper to propagate.")
		AssertEquals("body:E1:|close:E1:B|close:E1:A|caught:E1", TCloseLog.log, "Expected close exceptions swallowed, body exception preserved.")
	End Method

	' --- Null resource edge case: ensure no close attempt on null ---
	Method Using_NullResource_NoCloseAttempt() { test }
		Using
			Local a:TCloseableBase = Null
		Do
			TCloseLog.Add("body")
		End Using

		AssertEquals("body", TCloseLog.log, "Expected no close attempt when resource is Null.")
	End Method

End Type

Type TCloseLog
	Global log:String

	Function Reset()
		log = ""
	End Function

	Function Add(msg:String)
		If log <> "" Then log :+ "|"
		log :+ msg
	End Function
End Type

Type TCloseableBase Implements ICloseable
	Field name:String
	Field throwOnClose:Int

	Method New(name:String, throwOnClose:Int = False)
		Self.name = name
		Self.throwOnClose = throwOnClose
	End Method

	Method Close()
		TCloseLog.Add("close:" + name)
		If throwOnClose Then Throw "Close failed: " + name
	End Method
End Type

Type TCloseableWithBodyThrow
	' Not closeable; used to model body exceptions only
	Field name:String
	Method New(name:String)
		Self.name = name
	End Method
End Type

' Helper: throws in body after optionally doing something
Function ThrowInBody(msg:String)
	Throw msg
End Function

' Helper: returns from inside using
Function ReturnInsideUsing(logPrefix:String, aThrowOnClose:Int = False, bThrowOnClose:Int = False)
	Using
		Local a:TCloseableBase = New TCloseableBase(logPrefix + "A", aThrowOnClose)
		Local b:TCloseableBase = New TCloseableBase(logPrefix + "B", bThrowOnClose)
	Do
		TCloseLog.Add("body:" + logPrefix)
		Return
	End Using
End Function

' Helper: body throws, closes still run; caller catches
Function ThrowInsideUsing(logPrefix:String, aThrowOnClose:Int = False, bThrowOnClose:Int = False)
	Using
		Local a:TCloseableBase = New TCloseableBase(logPrefix + "A", aThrowOnClose)
		Local b:TCloseableBase = New TCloseableBase(logPrefix + "B", bThrowOnClose)
	Do
		TCloseLog.Add("body:" + logPrefix)
		Throw "Body failed: " + logPrefix
	End Using
End Function

' Helper: nested Using
Function NestedUsing(logPrefix:String, outerThrowOnClose:Int = False, innerThrowOnClose:Int = False)
	Using
		Local outer:TCloseableBase = New TCloseableBase(logPrefix + "Outer", outerThrowOnClose)
	Do
		TCloseLog.Add("body:outer:" + logPrefix)
		Using
			Local inner:TCloseableBase = New TCloseableBase(logPrefix + "Inner", innerThrowOnClose)
		Do
			TCloseLog.Add("body:inner:" + logPrefix)
		End Using
	End Using
End Function

' Helper: Using inside Try/Catch
Function UsingInsideTryCatch(logPrefix:String, throwInUsingBody:Int)
	Try
		Using
			Local a:TCloseableBase = New TCloseableBase(logPrefix + "A")
			Local b:TCloseableBase = New TCloseableBase(logPrefix + "B")
		Do
			TCloseLog.Add("body:" + logPrefix)
			If throwInUsingBody Then Throw "Body failed: " + logPrefix
		End Using
	Catch e:Object
		TCloseLog.Add("caught:" + logPrefix)
	End Try
End Function

' Helper: Try/Catch inside Using body
Function TryCatchInsideUsing(logPrefix:String, throwInsideTry:Int)
	Using
		Local a:TCloseableBase = New TCloseableBase(logPrefix + "A")
		Local b:TCloseableBase = New TCloseableBase(logPrefix + "B")
	Do
		TCloseLog.Add("body:" + logPrefix)
		Try
			If throwInsideTry Then Throw "Inner try failed: " + logPrefix
			TCloseLog.Add("innertry:ok:" + logPrefix)
		Catch e:Object
			TCloseLog.Add("innercatch:" + logPrefix)
		End Try
	End Using
End Function

' Helper: Using in Finally
Function UsingInFinally(logPrefix:String, throwInTry:Int)
	Try
		TCloseLog.Add("try:" + logPrefix)
		If throwInTry Then Throw "Try failed: " + logPrefix
	Finally
		Using
			Local a:TCloseableBase = New TCloseableBase(logPrefix + "A")
			Local b:TCloseableBase = New TCloseableBase(logPrefix + "B")
		Do
			TCloseLog.Add("finallybody:" + logPrefix)
		End Using
	End Try
End Function
