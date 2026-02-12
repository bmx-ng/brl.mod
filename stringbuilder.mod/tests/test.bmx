SuperStrict

Framework brl.standardio
Import brl.stringbuilder
Import BRL.MaxUnit

New TTestSuite.run()

Type TStringBuilderTest Extends TTest

	Field bigUnicode:UInt[] = [$10300, $10301, $10302, $10303, $10304, $10305, 0]
	Field unicode:Int[] = [1055, 1088, 1080, 1074, 1077, 1090]
	Field utf8:Byte[] = [208, 159, 209, 128, 208, 184, 208, 178, 208, 181, 209, 130, 0]
	Field utf8_hello:Byte[] = [104, 101, 108, 108, 111, 32, 32, 32, 32]
	Field utf8_world:Byte[] = [119, 111, 114, 108, 100, 32, 32, 32, 32]

	Field sb:TStringBuilder
	
	Method setup() { before }
		sb = New TStringBuilder
	End Method

	Method testLeftAlign() { test }
		sb.Append("12345")
		sb.LeftAlign(10)
		assertEquals("12345     ", sb.ToString())
		
		sb.SetLength(0)
		sb.Append("123456789")
		sb.LeftAlign(5)
		assertEquals("12345", sb.ToString())
		
		sb.SetLength(0)
		sb.LeftAlign(10)
		assertEquals("          ", sb.ToString())
	End Method
	
	Method testRightAlign() { test }
		sb.Append("12345")
		sb.RightAlign(10)
		assertEquals("     12345", sb.ToString())

		sb.SetLength(0)
		sb.Append("123456789")
		sb.RightAlign(5)
		assertEquals("56789", sb.ToString())

		sb.SetLength(0)
		sb.RightAlign(10)
		assertEquals("          ", sb.ToString())
	End Method

	Method testToUTF8String() { test }

		Local s:String = "Привет"
		sb.Append(s)
	
		Local b1:Byte Ptr = s.ToUTF8String()
		Local b2:Byte Ptr = sb.ToUTF8String()
		
		assertNotNull(b2)
		assertEquals(utf8.length - 1, strlen_(b2))
		assertEquals(strlen_(b1), strlen_(b2))
		
		For Local i:Int = 0 Until strlen_(b1)
			assertEquals(utf8[i], b2[i])
			assertEquals(b1[i], b2[i])
		Next
		
		MemFree(b1)
		MemFree(b2)
	End Method

	Method testEmptyToUTF8String() { test }
	
		assertNull(sb.ToUTF8String())
		
	End Method

	Method testToWString() { test }
		Local s:String = "Привет"
		sb.Append(s)
	
		Local s1:Short Ptr = s.ToWString()
		Local s2:Short Ptr = sb.ToWString()
		
		assertNotNull(s2)
		
		For Local i:Int = 0 Until 6
			assertEquals(unicode[i], s2[i])
			assertEquals(s1[i], s2[i])
		Next
		
		MemFree(s1)
		MemFree(s2)
	End Method

	Method testEmptyToWString() { test }
	
		assertNull(sb.ToWString())
		
	End Method

	Method testFormat() { test }
		Local txt:String = "Hello World"
		sb.Format("%20s", txt)
		assertEquals("         Hello World", sb.ToString())
		
		sb.SetLength(0)
		
		Local b:Byte = 63
		sb.Format("%04X", b)
		assertEquals("003F", sb.ToString())
		
		sb.SetLength(0)
	End Method

	Method testEquals() { test }
		sb.Append("Hello Equals World")
		Local sb1:TStringBuilder = New TStringBuilder("Hello Equals World")

		assertTrue(sb = sb)
		assertFalse(sb <> sb)
		
		assertTrue(sb = sb1)
		assertFalse(sb <> sb1)

		Local obj:Object = sb1
		assertTrue(sb = obj)
		assertFalse(sb <> obj)
		
		sb1.Append("1")
		
		assertFalse(sb = sb1)
		assertTrue(sb <> sb1)
	End Method

	Method testFromUTF8String() { test }
		Local b:Byte Ptr = utf8

		sb.AppendUTF8String(b)

		assertEquals("Привет", sb.ToString())
	End Method

	Method testFromUTF8Bytes() { test }
		Local b:Byte Ptr = utf8

		sb.AppendUTF8Bytes(b, 12)
		b = utf8_hello
		sb.AppendUTF8Bytes(b, 6)
		b = utf8_world
		sb.AppendUTF8Bytes(b, 5)

		assertEquals("Приветhello world", sb.ToString())
	End Method

	Method testfromUTF32() { test }
		Local b:UInt Ptr = bigUnicode

		sb.AppendUTF32String(b)
		
		Local buf:UInt Ptr = sb.ToString().ToUTF32String()
		For Local i:Int = 0 Until 7
			assertEquals( bigUnicode[i], buf[i] )
		Next
		MemFree(buf)
	End Method

	Method testfromUTF32Bytes() { test }
		Local b:UInt Ptr = bigUnicode

		sb.AppendUTF32Bytes(b, 7)
		
		Local buf:UInt Ptr = sb.ToString().ToUTF32String()
		For Local i:Int = 0 Until 7
			assertEquals( bigUnicode[i], buf[i] )
		Next
		MemFree(buf)
	End Method

	Method testStartsWith() { test }
		sb.Append("Hello World")
		assertTrue( sb.StartsWith("Hello") )
		assertFalse( sb.StartsWith("hello") )
		assertFalse( sb.StartsWith("World") )
		assertTrue( sb.StartsWith("World", 6) )
	End Method

	Method testAppendAsHex() { test }
		Local bytes:Byte[] = [0, 15, 16, 255, 128, 64]

		sb.AppendAsHex( bytes, bytes.Length ) ' default upperCase=True
		assertEquals("000F10FF8040", sb.ToString())

		sb.SetLength(0)

		sb.AppendAsHex( bytes, bytes.Length, True )
		assertEquals("000F10FF8040", sb.ToString())

		sb.SetLength(0)

		sb.AppendAsHex( bytes, bytes.Length, False )
		assertEquals("000f10ff8040", sb.ToString())
	End Method

End Type

Type TSplitBufferTest Extends TTest

	Field sb:TStringBuilder
	
	Method setup() { before }
		sb = New TStringBuilder
	End Method

	Method testSplitBuffer() { test }
		sb.Append("a,b,c,d,e,f,g")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(7, split.Length())
		assertEquals("a", split.Text(0))
		assertEquals("d", split.Text(3))
		assertEquals("g", split.Text(6))
		
	End Method

	Method testSplitBufferEmpty() { test }
		sb.Append("a,b,c,d,e,f,g")

		Local split:TSplitBuffer = sb.Split(" ")

		assertEquals(1, split.Length())
		assertEquals("a,b,c,d,e,f,g", split.Text(0))
		
	End Method

	Method testSplitBufferEmptyString() { test }
		sb.Append("")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1, split.Length())
		assertEquals("", split.Text(0))
		
	End Method

	Method testSplitBufferEmptySeparator() { test }
		sb.Append("a,b,c,d,e,f,g")

		Local split:TSplitBuffer = sb.Split("")

		assertEquals(1, split.Length())
		assertEquals("a,b,c,d,e,f,g", split.Text(0))
		
	End Method

	Method testSplitBufferEmptyFields() { test }
		sb.Append("1,,,3,4,5")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(6, split.Length())
		assertEquals("1", split.Text(0))
		assertEquals("", split.Text(1))
		assertEquals("3", split.Text(3))
		assertEquals("5", split.Text(5))

	End Method

	Method testSplitBufferSplit() { test }
		sb.Append("1,2,3|4,5,6|7,8,9")

		Local split:TSplitBuffer = sb.Split("|")

		assertEquals(3, split.Length())
		assertEquals("1,2,3", split.Text(0))

		Local split2:TSplitBuffer = split.Split(0, ",")

		assertEquals(3, split2.Length())

		assertEquals("1", split2.Text(0))
		assertEquals("2", split2.Text(1))
		assertEquals("3", split2.Text(2))
	End Method

	Method testSplitBufferSplitEmptyFields() { test }
		sb.Append("1,2,3|4,,6|7,8,9")

		Local split:TSplitBuffer = sb.Split("|")

		assertEquals(3, split.Length())
		assertEquals("4,,6", split.Text(1))

		Local split2:TSplitBuffer = split.Split(1, ",")

		assertEquals(3, split2.Length())

		assertEquals("4", split2.Text(0))
		assertEquals("", split2.Text(1))
		assertEquals("6", split2.Text(2))
	End Method

	Method testSplitBufferSplitEmptyFields2() { test }
		sb.Append("1,2,3||7,8,9")

		Local split:TSplitBuffer = sb.Split("|")

		assertEquals(3, split.Length())
		assertEquals("", split.Text(1))

		Local split2:TSplitBuffer = split.Split(1, ",")

		assertEquals(1, split2.Length())
		assertEquals("", split2.Text(0))
	End Method

	Method testSplitBufferEnumeration() { test }
		sb.Append("a,b,c,d,e,f,g")

		Local split:TSplitBuffer = sb.Split(",")

		Local txt:String
		For Local s:String = EachIn split
			txt :+ s
		Next

		assertEquals("abcdefg", txt)
	End Method

	Method testSplitBufferSplitEnumeration() { test }
		sb.Append("1,2,3|4,5,6|7,8,9")

		Local split:TSplitBuffer = sb.Split("|")
		Local split2:TSplitBuffer = split.Split(1, ",")

		Local txt:String
		For Local s:String = EachIn split2
			txt :+ s
		Next

		assertEquals("456", txt)
	End Method

	Method testSplitBufferToInt() { test }
		sb.Append("1,22,333,4444,-55555,666666,777777,8888888,99999999")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1, split.ToInt(0))
		assertEquals(-55555, split.ToInt(4))
		assertEquals(99999999, split.ToInt(8))
	End Method

	Method testSplitBufferToFloat() { test }
		sb.Append("1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,-9.9")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1.1, split.ToFloat(0), 0.0001)
		assertEquals(5.5, split.ToFloat(4), 0.0001)
		assertEquals(-9.9, split.ToFloat(8), 0.0001)
	End Method

	Method testSplitBufferToDouble() { test }
		sb.Append("1.1,2.2,3.3,4.4,-5.5,6.6,7.7,8.8,9.9")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1.1, split.ToDouble(0), 0.0001)
		assertEquals(-5.5, split.ToDouble(4), 0.0001)
		assertEquals(9.9, split.ToDouble(8), 0.0001)
	End Method

	Method testSplitBufferToShort() { test }
		sb.Append("1,2,3,4,5,6,7,8,9")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1, split.ToShort(0))
		assertEquals(5, split.ToShort(4))
		assertEquals(9, split.ToShort(8))
	End Method

	Method testSplitBufferToByte() { test }
		sb.Append("1,2,3,4,5,6,7,8,9")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1, split.ToByte(0))
		assertEquals(5, split.ToByte(4))
		assertEquals(9, split.ToByte(8))
	End Method

	Method testSplitBufferToLong() { test }
		sb.Append("-1,2,3,4,5,6,7,8,9")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(-1, split.ToLong(0))
		assertEquals(5, split.ToLong(4))
		assertEquals(9, split.ToLong(8))
	End Method

	Method testSplitBufferToULong() { test }
		sb.Append("1111,22222,333333,4444444,55555555,666666666,777777777,8888888,99999999999")

		Local split:TSplitBuffer = sb.Split(",")

		assertEquals(1111, split.ToULong(0))
		assertEquals(55555555, split.ToULong(4))
		assertEquals(99999999999:ULong, split.ToULong(8))
	End Method

End Type

Type TStringBuilderAppendIntTest Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0)
		AssertEquals("0", sb.ToString(), "Append(0) should produce '0'")
	End Method

	Method Test_AppendPositive() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42)
		AssertEquals("42", sb.ToString(), "Append(42) should produce '42'")
	End Method

	Method Test_AppendNegative() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(-42)
		AssertEquals("-42", sb.ToString(), "Append(-42) should produce '-42'")
	End Method

	Method Test_AppendMultipleValues() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(1).Append(2).Append(3)
		AssertEquals("123", sb.ToString(), "Multiple Append(int) calls should concatenate values")
	End Method

	Method Test_AppendWithExistingText() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append("Value=")
		sb.Append(100)
		AssertEquals("Value=100", sb.ToString(), "Append(int) should append after existing text")
	End Method

	Method Test_IntMinMax() { test }
		Local sb:TStringBuilder = New TStringBuilder

		Local minVal:Int = $80000000 ' -2147483648
		Local maxVal:Int = $7FFFFFFF '  2147483647

		sb.Append(minVal)
		sb.Append(",")
		sb.Append(maxVal)

		AssertEquals("-2147483648,2147483647", sb.ToString(), "Append(int) should handle Int min/max values")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
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

			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(v)

			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(int) produced empty string for " + v)

			If v < 0 Then
				AssertTrue(s.StartsWith("-"), "Negative value should start with '-' for " + v)
			Else
				AssertFalse(s.StartsWith("-"), "Non-negative value should not start with '-' for " + v)
			End If

			AssertEquals(v, Int(s), "Append(int) round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringBuilderAppendLongTest Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Long)
		AssertEquals("0", sb.ToString(), "Append(Long 0) should produce '0'")
	End Method

	Method Test_AppendPositive() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:Long)
		AssertEquals("42", sb.ToString(), "Append(Long 42) should produce '42'")
	End Method

	Method Test_AppendNegative() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(-42:Long)
		AssertEquals("-42", sb.ToString(), "Append(Long -42) should produce '-42'")
	End Method

	Method Test_AppendMultipleValues() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(1:Long).Append(2:Long).Append(3:Long)
		AssertEquals("123", sb.ToString(), "Multiple Append(Long) calls should concatenate values")
	End Method

	Method Test_AppendWithExistingText() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append("Value=")
		sb.Append(100:Long)
		AssertEquals("Value=100", sb.ToString(), "Append(Long) should append after existing text")
	End Method

	Method Test_LongMinMax() { test }
		Local sb:TStringBuilder = New TStringBuilder

		Local minVal:Long = $8000000000000000:Long ' -9223372036854775808
		Local maxVal:Long = $7FFFFFFFFFFFFFFF:Long '  9223372036854775807

		sb.Append(minVal)
		sb.Append(",")
		sb.Append(maxVal)

		AssertEquals("-9223372036854775808,9223372036854775807", sb.ToString(), "Append(Long) should handle Long min/max values")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
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

			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(v)

			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(Long) produced empty string for " + v)

			If v < 0 Then
				AssertTrue(s.StartsWith("-"), "Negative value should start with '-' for " + v)
			Else
				AssertFalse(s.StartsWith("-"), "Non-negative value should not start with '-' for " + v)
			End If

			AssertEquals(v, Long(s), "Append(Long) round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringBuilderAppendUIntTest Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:UInt)
		AssertEquals("0", sb.ToString(), "Append(UInt 0) should produce '0'")
	End Method

	Method Test_AppendPositive() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:UInt)
		AssertEquals("42", sb.ToString(), "Append(UInt 42) should produce '42'")
	End Method

	Method Test_AppendMultipleValues() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(1:UInt).Append(2:UInt).Append(3:UInt)
		AssertEquals("123", sb.ToString(), "Multiple Append(UInt) calls should concatenate values")
	End Method

	Method Test_AppendWithExistingText() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append("Value=")
		sb.Append(100:UInt)
		AssertEquals("Value=100", sb.ToString(), "Append(UInt) should append after existing text")
	End Method

	Method Test_UIntMax() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local maxVal:UInt = $FFFFFFFF:UInt ' 4294967295

		sb.Append(maxVal)
		AssertEquals("4294967295", sb.ToString(), "Append(UInt) should handle UInt max value")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
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

			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(v)

			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(UInt) produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned value should not start with '-' for " + v)

			AssertEquals(v, UInt(s), "Append(UInt) round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringBuilderAppendULongTest Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:ULong)
		AssertEquals("0", sb.ToString(), "Append(ULong 0) should produce '0'")
	End Method

	Method Test_AppendPositive() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:ULong)
		AssertEquals("42", sb.ToString(), "Append(ULong 42) should produce '42'")
	End Method

	Method Test_AppendMultipleValues() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(1:ULong).Append(2:ULong).Append(3:ULong)
		AssertEquals("123", sb.ToString(), "Multiple Append(ULong) calls should concatenate values")
	End Method

	Method Test_AppendWithExistingText() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append("Value=")
		sb.Append(100:ULong)
		AssertEquals("Value=100", sb.ToString(), "Append(ULong) should append after existing text")
	End Method

	Method Test_ULongMax() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local maxVal:ULong = $FFFFFFFFFFFFFFFF:ULong ' 18446744073709551615

		sb.Append(maxVal)
		AssertEquals("18446744073709551615", sb.ToString(), "Append(ULong) should handle ULong max value")
	End Method

	Method Test_RangeSweep_DigitBoundaries() { test }
		Local vals:ULong[] = [ ..
			0:ULong, 1:ULong, 9:ULong, 10:ULong, 11:ULong, ..
			99:ULong, 100:ULong, 101:ULong, ..
			999:ULong, 1000:ULong, 1001:ULong, ..
			9999:ULong, 10000:ULong, 10001:ULong, ..
			99999:ULong, 100000:ULong, 100001:ULong, ..
			999999:ULong, 1000000:ULong, 1000001:ULong, ..
			999999999:ULong, 1000000000:ULong, 1000000001:ULong, ..
			9999999999:ULong, 10000000000:ULong, 10000000001:ULong, ..
			999999999999999999:ULong, 1000000000000000000:ULong, 1000000000000000001:ULong, ..
			9223372036854775807:ULong, ..
			9223372036854775808:ULong, ..
			18446744073709551614:ULong, 18446744073709551615:ULong ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:ULong = vals[i]

			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(v)

			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(ULong) produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned value should not start with '-' for " + v)

			AssertEquals(v, ULong(s), "Append(ULong) round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringBuilderAppendByteTest Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Byte)
		AssertEquals("0", sb.ToString(), "Append(Byte 0) should produce '0'")
	End Method

	Method Test_AppendPositive() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:Byte)
		AssertEquals("42", sb.ToString(), "Append(Byte 42) should produce '42'")
	End Method

	Method Test_AppendMultipleValues() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(1:Byte).Append(2:Byte).Append(3:Byte)
		AssertEquals("123", sb.ToString(), "Multiple Append(Byte) calls should concatenate values")
	End Method

	Method Test_AppendWithExistingText() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append("Value=")
		sb.Append(100:Byte)
		AssertEquals("Value=100", sb.ToString(), "Append(Byte) should append after existing text")
	End Method

	Method Test_ByteRangeEdges() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Byte).Append(",").Append(255:Byte)
		AssertEquals("0,255", sb.ToString(), "Append(Byte) should handle 0 and 255")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(128:Byte).Append(",").Append(200:Byte).Append(",").Append(255:Byte)
		Local s:String = sb.ToString()
		AssertFalse(s.Contains("-"), "Unsigned Byte append output should not contain '-'")
	End Method

	Method Test_RangeSweep_RoundTrip() { test }
		Local vals:Int[] = [ 0, 1, 9, 10, 11, 99, 100, 101, 249, 250, 254, 255 ]

		For Local i:Int = 0 Until vals.Length
			Local v:Int = vals[i]
			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(Byte(v))
			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(Byte) produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned Byte should not start with '-' for " + v)
			AssertEquals(v, Int(s), "Append(Byte) round-trip should match for " + v)
		Next
	End Method

End Type

Type TStringBuilderAppendShortTest Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Short)
		AssertEquals("0", sb.ToString(), "Append(Short 0) should produce '0'")
	End Method

	Method Test_AppendPositive() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:Short)
		AssertEquals("42", sb.ToString(), "Append(Short 42) should produce '42'")
	End Method

	Method Test_AppendMultipleValues() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(1:Short).Append(2:Short).Append(3:Short)
		AssertEquals("123", sb.ToString(), "Multiple Append(Short) calls should concatenate values")
	End Method

	Method Test_AppendWithExistingText() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append("Value=")
		sb.Append(1000:Short)
		AssertEquals("Value=1000", sb.ToString(), "Append(Short) should append after existing text")
	End Method

	Method Test_ShortRangeEdges() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Short).Append(",").Append(65535:Short)
		AssertEquals("0,65535", sb.ToString(), "Append(Short) should handle 0 and 65535")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(32768:Short).Append(",").Append(50000:Short).Append(",").Append(65535:Short)
		Local s:String = sb.ToString()
		AssertFalse(s.Contains("-"), "Unsigned Short append output should not contain '-'")
	End Method

	Method Test_RangeSweep_RoundTrip() { test }
		Local vals:Int[] = [ 0, 1, 9, 10, 11, 99, 100, 101, 999, 1000, 1001, 9999, 10000, 10001, 32767, 32768, 65534, 65535 ]

		For Local i:Int = 0 Until vals.Length
			Local v:Int = vals[i]
			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(Short(v))
			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(Short) produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned Short should not start with '-' for " + v)
			AssertEquals(v, Int(s), "Append(Short) round-trip should match for " + v)
		Next
	End Method

End Type

?ptr32

Type TStringBuilderAppendSizeT32Test Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Size_T)
		AssertEquals("0", sb.ToString(), "Append(Size_T 0) should produce '0' (ptr32)")
	End Method

	Method Test_AppendPositiveSmall() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:Size_T)
		AssertEquals("42", sb.ToString(), "Append(Size_T 42) should produce '42' (ptr32)")
	End Method

	Method Test_SizeTRangeEdges_32bit() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Size_T).Append(",").Append(4294967295:Size_T)
		AssertEquals("0,4294967295", sb.ToString(), "Append(Size_T) should handle 32-bit max (ptr32)")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(2147483648:Size_T).Append(",").Append(4294967295:Size_T)
		Local s:String = sb.ToString()
		AssertFalse(s.Contains("-"), "Unsigned Size_T append output should not contain '-' (ptr32)")
	End Method

	Method Test_RangeSweep_RoundTrip() { test }
		Local vals:Size_T[] = [ ..
			0:Size_T, 1:Size_T, 9:Size_T, 10:Size_T, 11:Size_T, ..
			99:Size_T, 100:Size_T, 101:Size_T, ..
			999:Size_T, 1000:Size_T, 1001:Size_T, ..
			9999:Size_T, 10000:Size_T, 10001:Size_T, ..
			2147483647:Size_T, 2147483648:Size_T, 4000000000:Size_T, ..
			4294967294:Size_T, 4294967295:Size_T ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:Size_T = vals[i]
			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(v)
			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(Size_T) produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned Size_T should not start with '-' for " + v)
			AssertEquals(v, Size_T(s), "Append(Size_T) round-trip should match for " + v)
		Next
	End Method

End Type

?ptr64

Type TStringBuilderAppendSizeT64Test Extends TTest

	Method Test_AppendZero() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Size_T)
		AssertEquals("0", sb.ToString(), "Append(Size_T 0) should produce '0' (ptr64)")
	End Method

	Method Test_AppendPositiveSmall() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(42:Size_T)
		AssertEquals("42", sb.ToString(), "Append(Size_T 42) should produce '42' (ptr64)")
	End Method

	Method Test_SizeTRangeEdges_64bit() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(0:Size_T).Append(",").Append(18446744073709551615:Size_T)
		AssertEquals("0,18446744073709551615", sb.ToString(), "Append(Size_T) should handle 64-bit max (ptr64)")
	End Method

	Method Test_NoNegativeSignAppears() { test }
		Local sb:TStringBuilder = New TStringBuilder
		sb.Append(9223372036854775808:Size_T).Append(",").Append(18446744073709551615:Size_T)
		Local s:String = sb.ToString()
		AssertFalse(s.Contains("-"), "Unsigned Size_T append output should not contain '-' (ptr64)")
	End Method

	Method Test_RangeSweep_RoundTrip() { test }
		Local vals:Size_T[] = [ ..
			0:Size_T, 1:Size_T, 9:Size_T, 10:Size_T, 11:Size_T, ..
			99:Size_T, 100:Size_T, 101:Size_T, ..
			999:Size_T, 1000:Size_T, 1001:Size_T, ..
			9999:Size_T, 10000:Size_T, 10001:Size_T, ..
			4294967295:Size_T, 4294967296:Size_T, ..
			9223372036854775807:Size_T, 9223372036854775808:Size_T, ..
			18446744073709551614:Size_T, 18446744073709551615:Size_T ..
		]

		For Local i:Int = 0 Until vals.Length
			Local v:Size_T = vals[i]
			Local sb:TStringBuilder = New TStringBuilder
			sb.Append(v)
			Local s:String = sb.ToString()

			AssertTrue(s.Length > 0, "Append(Size_T) produced empty string for " + v)
			AssertFalse(s.StartsWith("-"), "Unsigned Size_T should not start with '-' for " + v)
			AssertEquals(v, Size_T(s), "Append(Size_T) round-trip should match for " + v)
		Next
	End Method

End Type

?
