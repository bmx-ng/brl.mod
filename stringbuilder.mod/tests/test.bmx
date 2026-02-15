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

Type TStringBuilderSplitIntsTest Extends TTest

	' Helper: assert Int[] equals expected (Length + each element)
	Method AssertIntArrayEquals(expected:Int[], actual:Int[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(expected[i], actual[i], message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:Int[] = sb.SplitInts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty Int[]")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Int[] = sb.SplitInts("")
		AssertIntArrayEquals([123], a, "Empty separator should parse whole builder as one entry")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:Int[] = sb.SplitInts("")
		AssertIntArrayEquals([123], a, "Empty separator should allow trailing whitespace (builder)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:Int[] = sb.SplitInts("")
		AssertIntArrayEquals([0], a, "Empty separator should reject trailing junk and return 0 (builder)")
	End Method

	Method Test_BasicCommaSeparated() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,3")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([1,2,3], a, "Basic comma split (builder)")
	End Method

	Method Test_CustomSeparator() { test }
		Local sb:TStringBuilder = New TStringBuilder("1::2::3")
		Local a:Int[] = sb.SplitInts("::")
		AssertIntArrayEquals([1,2,3], a, "Custom separator split (builder)")
	End Method

	Method Test_LeadingSeparator_GivesLeadingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,2")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([0,1,2], a, "Leading separator should produce leading empty token => 0 (builder)")
	End Method

	Method Test_TrailingSeparator_GivesTrailingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([1,2,0], a, "Trailing separator should produce trailing empty token => 0 (builder)")
	End Method

	Method Test_ConsecutiveSeparators_GiveZeroTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,,3")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([1,0,3], a, "Consecutive separators should produce empty token => 0 (builder)")
	End Method

	Method Test_AllEmptyTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder(",,")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([0,0,0], a, "Two separators should produce three empty tokens => 0,0,0 (builder)")
	End Method

	Method Test_SeparatorNotFound_ParsesWholeStringAsSingleEntry() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([123], a, "Separator not found should produce a single entry (builder)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([1,2,3], a, "Whitespace around numbers should be allowed (builder)")
	End Method

	Method Test_SignHandling() { test }
		Local sb:TStringBuilder = New TStringBuilder("-1,+2,0,-300")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([-1,2,0,-300], a, "Signed parsing should handle - and + (builder)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([0,0,0,0], a, "Whitespace between sign and digits should produce 0 (builder)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([0,456,0,0], a, "Tokens with trailing non-whitespace junk should become 0 (builder)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FF,%1010,$0,%0")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([255,10,0,0], a, "Hex and binary prefixes should parse correctly (builder)")
	End Method

	Method Test_BasePrefixes_WithTrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFG,%10102,$1Z,%10 2")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([0,0,0,0], a, "Trailing junk after base-prefixed numbers should be rejected (builder)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([0,0,0,0,0,0], a, "Tokens with no digits should return 0 (builder)")
	End Method

	Method Test_IntMinMax() { test }
		Local minVal:Int = $80000000 ' -2147483648
		Local maxVal:Int = $7FFFFFFF '  2147483647

		Local sb:TStringBuilder = New TStringBuilder("-2147483648,2147483647")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([minVal, maxVal], a, "Should parse Int min/max exactly (builder)")
	End Method

	Method Test_IntOverflow_ClampsOrZero() { test }
		Local minVal:Int = $80000000 ' -2147483648
		Local maxVal:Int = $7FFFFFFF '  2147483647

		Local sb:TStringBuilder = New TStringBuilder("2147483648,-2147483649,999999999999999999999")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([maxVal, minVal, 0], a, "Overflow should clamp to Int min/max when within Long range, else 0 (builder)")
	End Method

	Method Test_MultiCharSeparator_Edges() { test }
		Local sb:TStringBuilder = New TStringBuilder("::1::::3::")
		Local a:Int[] = sb.SplitInts("::")
		AssertIntArrayEquals([0,1,0,3,0], a, "Multi-char separator should handle leading/trailing/consecutive correctly (builder)")
	End Method

	Method Test_NewlineAndTabWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("~t123~n,~r~n-45~t,  6")
		Local a:Int[] = sb.SplitInts(",")
		AssertIntArrayEquals([123,-45,6], a, "Various whitespace characters should be allowed (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:Int[] = sb.SplitInts("aa")
		AssertIntArrayEquals([0,0,0], a, "Non-overlapping separator matching should be used (builder)")
	End Method

	Method Test_MatchesStringSplitInts_Output() { test }
		' Sanity: builder and string should produce identical results for the same content/separator
		Local content:String = "  $FF, -1, 2147483648, 12x, , %1010  "
		Local sep:String = ","

		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:Int[] = sb.SplitInts(sep)
		Local a2:Int[] = content.SplitInts(sep)

		AssertIntArrayEquals(a2, a1, "Builder.SplitInts should match String.SplitInts for identical input")
	End Method

End Type

Type TStringBuilderSplitBytesTest Extends TTest

	' Helper: assert Byte[] equals expected (Length + each element)
	Method AssertByteArrayEquals(expected:Byte[], actual:Byte[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(Int(expected[i]), Int(actual[i]), message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:Byte[] = sb.SplitBytes(",")
		AssertEquals(0, a.Length, "Empty builder should return empty Byte[]")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Byte[] = sb.SplitBytes("")
		AssertByteArrayEquals([Byte(123)], a, "Empty separator should parse whole builder as one entry")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:Byte[] = sb.SplitBytes("")
		AssertByteArrayEquals([Byte(123)], a, "Empty separator should allow trailing whitespace (builder)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:Byte[] = sb.SplitBytes("")
		AssertByteArrayEquals([Byte(0)], a, "Empty separator should reject trailing junk and return 0 (builder)")
	End Method

	Method Test_BasicCommaSeparated() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,3")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(1),Byte(2),Byte(3)], a, "Basic comma split (builder)")
	End Method

	Method Test_CustomSeparator() { test }
		Local sb:TStringBuilder = New TStringBuilder("1::2::3")
		Local a:Byte[] = sb.SplitBytes("::")
		AssertByteArrayEquals([Byte(1),Byte(2),Byte(3)], a, "Custom separator split (builder)")
	End Method

	Method Test_LeadingSeparator_GivesLeadingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,2")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(1),Byte(2)], a, "Leading separator should produce leading empty token => 0 (builder)")
	End Method

	Method Test_TrailingSeparator_GivesTrailingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(1),Byte(2),Byte(0)], a, "Trailing separator should produce trailing empty token => 0 (builder)")
	End Method

	Method Test_ConsecutiveSeparators_GiveZeroTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,,3")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(1),Byte(0),Byte(3)], a, "Consecutive separators should produce empty token => 0 (builder)")
	End Method

	Method Test_AllEmptyTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder(",,")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(0),Byte(0)], a, "Two separators should produce three empty tokens => 0,0,0 (builder)")
	End Method

	Method Test_SeparatorNotFound_ParsesWholeStringAsSingleEntry() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(123)], a, "Separator not found should produce a single entry (builder)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(1),Byte(2),Byte(3)], a, "Whitespace around numbers should be allowed (builder)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(0),Byte(0),Byte(0)], a, "Whitespace between sign and digits should produce 0 (builder)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 4, 7 8, 10-")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(4),Byte(0),Byte(0)], a, "Tokens with trailing non-whitespace junk should become 0 (builder)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FF,%1010,$0,%0")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(255),Byte(10),Byte(0),Byte(0)], a, "Hex/binary prefixes should parse correctly (builder)")
	End Method

	Method Test_BasePrefixes_WithTrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFG,%10102,$1Z,%10 2")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(0),Byte(0),Byte(0)], a, "Trailing junk after base-prefixed numbers should be rejected (builder)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(0),Byte(0),Byte(0),Byte(0),Byte(0)], a, "Tokens with no digits should return 0 (builder)")
	End Method

	Method Test_RangeEdges_Byte() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,254,255")
		Local a:Byte[] = sb.SplitBytes(",")
		AssertByteArrayEquals([Byte(0),Byte(1),Byte(9),Byte(10),Byte(99),Byte(100),Byte(254),Byte(255)], a, "Should parse Byte range edges correctly (builder)")
	End Method

	Method Test_OutOfRange_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("256,-1,999999999999999999999")
		Local a:Byte[] = sb.SplitBytes(",")

		AssertByteArrayEquals([Byte(0),Byte(0),Byte(0)], a, "Out-of-range handling should return 0 for Byte (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:Byte[] = sb.SplitBytes("aa")
		AssertByteArrayEquals([Byte(0),Byte(0),Byte(0)], a, "Non-overlapping separator matching should be used (builder)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:Byte[] = [ Byte(0), Byte(1), Byte(2), Byte(10), Byte(100), Byte(254), Byte(255) ]
		Local joined:String = ",".Join(vals)
		Local parsed:Byte[] = New TStringBuilder(joined).SplitBytes(",")
		AssertByteArrayEquals(vals, parsed, "Join(Byte[]) then Builder.SplitBytes should round-trip for clean tokens")
	End Method

	Method Test_MatchesStringSplitBytes_Output() { test }
		' Sanity: builder and string should produce identical results for the same content/separator
		Local content:String = "  $FF, 1, 256, 12x, , %1010  "
		Local sep:String = ","

		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:Byte[] = sb.SplitBytes(sep)
		Local a2:Byte[] = content.SplitBytes(sep)

		AssertByteArrayEquals(a2, a1, "Builder.SplitBytes should match String.SplitBytes for identical input")
	End Method

End Type

Type TStringBuilderSplitShortsTest Extends TTest

	' Helper: assert Short[] equals expected (Length + each element)
	Method AssertShortArrayEquals(expected:Short[], actual:Short[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(Int(expected[i]), Int(actual[i]), message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:Short[] = sb.SplitShorts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty Short[]")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("1234")
		Local a:Short[] = sb.SplitShorts("")
		AssertShortArrayEquals([Short(1234)], a, "Empty separator should parse whole builder as one entry")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("1234   ")
		Local a:Short[] = sb.SplitShorts("")
		AssertShortArrayEquals([Short(1234)], a, "Empty separator should allow trailing whitespace (builder)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("1234x")
		Local a:Short[] = sb.SplitShorts("")
		AssertShortArrayEquals([Short(0)], a, "Empty separator should reject trailing junk and return 0 (builder)")
	End Method

	Method Test_BasicCommaSeparated() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,3")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(1),Short(2),Short(3)], a, "Basic comma split (builder)")
	End Method

	Method Test_CustomSeparator() { test }
		Local sb:TStringBuilder = New TStringBuilder("1::2::3")
		Local a:Short[] = sb.SplitShorts("::")
		AssertShortArrayEquals([Short(1),Short(2),Short(3)], a, "Custom separator split (builder)")
	End Method

	Method Test_LeadingSeparator_GivesLeadingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,2")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(0),Short(1),Short(2)], a, "Leading separator should produce leading empty token => 0 (builder)")
	End Method

	Method Test_TrailingSeparator_GivesTrailingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(1),Short(2),Short(0)], a, "Trailing separator should produce trailing empty token => 0 (builder)")
	End Method

	Method Test_ConsecutiveSeparators_GiveZeroTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,,3")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(1),Short(0),Short(3)], a, "Consecutive separators should produce empty token => 0 (builder)")
	End Method

	Method Test_AllEmptyTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder(",,")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(0),Short(0),Short(0)], a, "Two separators should produce three empty tokens => 0,0,0 (builder)")
	End Method

	Method Test_SeparatorNotFound_ParsesWholeStringAsSingleEntry() { test }
		Local sb:TStringBuilder = New TStringBuilder("1234")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(1234)], a, "Separator not found should produce a single entry (builder)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(1),Short(2),Short(3)], a, "Whitespace around numbers should be allowed (builder)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(0),Short(0),Short(0),Short(0)], a, "Whitespace between sign and digits should produce 0 (builder)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("1234x, 456, 78 9, 10-")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(0),Short(456),Short(0),Short(0)], a, "Tokens with trailing non-whitespace junk should become 0 (builder)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFF,%1010,$0,%0")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(65535),Short(10),Short(0),Short(0)], a, "Hex/binary prefixes should parse correctly (builder)")
	End Method

	Method Test_BasePrefixes_WithTrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFG,%10102,$1Z,%10 2")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(0),Short(0),Short(0),Short(0)], a, "Trailing junk after base-prefixed numbers should be rejected (builder)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([Short(0),Short(0),Short(0),Short(0),Short(0),Short(0)], a, "Tokens with no digits should return 0 (builder)")
	End Method

	Method Test_RangeEdges_Short() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,32767,32768,65534,65535")
		Local a:Short[] = sb.SplitShorts(",")
		AssertShortArrayEquals([ ..
			Short(0),Short(1),Short(9),Short(10),Short(99),Short(100), ..
			Short(32767),Short(32768),Short(65534),Short(65535) ..
		], a, "Should parse Short range edges correctly (builder)")
	End Method

	Method Test_OutOfRange_ReturnsZero() { test }
		' Unsigned narrow parsers return 0 for out-of-range and for bbStrToULong overflow.
		Local sb:TStringBuilder = New TStringBuilder("65536,-1,999999999999999999999")
		Local a:Short[] = sb.SplitShorts(",")

		AssertShortArrayEquals([Short(0),Short(0),Short(0)], a, "Out-of-range handling should return 0 for Short (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:Short[] = sb.SplitShorts("aa")
		AssertShortArrayEquals([Short(0),Short(0),Short(0)], a, "Non-overlapping separator matching should be used (builder)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:Short[] = [ Short(0), Short(1), Short(2), Short(10), Short(1000), Short(32768), Short(65535) ]
		Local joined:String = ",".Join(vals)
		Local parsed:Short[] = New TStringBuilder(joined).SplitShorts(",")
		AssertShortArrayEquals(vals, parsed, "Join(Short[]) then Builder.SplitShorts should round-trip for clean tokens")
	End Method

	Method Test_MatchesStringSplitShorts_Output() { test }
		' Sanity: builder and string should produce identical results for the same content/separator
		Local content:String = "  $FFFF, 1, 65536, 12x, , %1010  "
		Local sep:String = ","

		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:Short[] = sb.SplitShorts(sep)
		Local a2:Short[] = content.SplitShorts(sep)

		AssertShortArrayEquals(a2, a1, "Builder.SplitShorts should match String.SplitShorts for identical input")
	End Method

End Type

Type TStringBuilderSplitUIntsTest Extends TTest

	' Helper: assert UInt[] equals expected (Length + each element)
	Method AssertUIntArrayEquals(expected:UInt[], actual:UInt[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(ULong(expected[i]), ULong(actual[i]), message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:UInt[] = sb.SplitUInts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty UInt[]")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:UInt[] = sb.SplitUInts("")
		AssertUIntArrayEquals([123:UInt], a, "Empty separator should parse whole builder as one entry")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:UInt[] = sb.SplitUInts("")
		AssertUIntArrayEquals([123:UInt], a, "Empty separator should allow trailing whitespace (builder)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:UInt[] = sb.SplitUInts("")
		AssertUIntArrayEquals([0:UInt], a, "Empty separator should reject trailing junk and return 0 (builder)")
	End Method

	Method Test_BasicCommaSeparated() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,3")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([1:UInt,2:UInt,3:UInt], a, "Basic comma split (builder)")
	End Method

	Method Test_CustomSeparator() { test }
		Local sb:TStringBuilder = New TStringBuilder("1::2::3")
		Local a:UInt[] = sb.SplitUInts("::")
		AssertUIntArrayEquals([1:UInt,2:UInt,3:UInt], a, "Custom separator split (builder)")
	End Method

	Method Test_LeadingSeparator_GivesLeadingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,2")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([0:UInt,1:UInt,2:UInt], a, "Leading separator should produce leading empty token => 0 (builder)")
	End Method

	Method Test_TrailingSeparator_GivesTrailingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([1:UInt,2:UInt,0:UInt], a, "Trailing separator should produce trailing empty token => 0 (builder)")
	End Method

	Method Test_ConsecutiveSeparators_GiveZeroTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,,3")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([1:UInt,0:UInt,3:UInt], a, "Consecutive separators should produce empty token => 0 (builder)")
	End Method

	Method Test_AllEmptyTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder(",,")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([0:UInt,0:UInt,0:UInt], a, "Two separators should produce three empty tokens => 0,0,0 (builder)")
	End Method

	Method Test_SeparatorNotFound_ParsesWholeStringAsSingleEntry() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([123:UInt], a, "Separator not found should produce a single entry (builder)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([1:UInt,2:UInt,3:UInt], a, "Whitespace around numbers should be allowed (builder)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([0:UInt,0:UInt,0:UInt,0:UInt], a, "Whitespace between sign and digits should produce 0 (builder)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([0:UInt,456:UInt,0:UInt,0:UInt], a, "Tokens with trailing non-whitespace junk should become 0 (builder)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFF,%1010,$0,%0")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([$FFFFFFFF:UInt,10:UInt,0:UInt,0:UInt], a, "Hex/binary prefixes should parse correctly (builder)")
	End Method

	Method Test_BasePrefixes_WithTrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFFG,%10102,$1Z,%10 2")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([0:UInt,0:UInt,0:UInt,0:UInt], a, "Trailing junk after base-prefixed numbers should be rejected (builder)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([0:UInt,0:UInt,0:UInt,0:UInt,0:UInt,0:UInt], a, "Tokens with no digits should return 0 (builder)")
	End Method

	Method Test_RangeEdges_UInt() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,2147483647,2147483648,4000000000,4294967294,4294967295")
		Local a:UInt[] = sb.SplitUInts(",")
		AssertUIntArrayEquals([ ..
			0:UInt,1:UInt,9:UInt,10:UInt,99:UInt,100:UInt, ..
			2147483647:UInt,2147483648:UInt,4000000000:UInt,4294967294:UInt,4294967295:UInt ..
		], a, "Should parse UInt range edges correctly (builder)")
	End Method

	Method Test_OutOfRange_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("4294967296,-1,999999999999999999999")
		Local a:UInt[] = sb.SplitUInts(",")

		AssertUIntArrayEquals([0:UInt,0:UInt,0:UInt], a, "Out-of-range handling should return 0 for UInt (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:UInt[] = sb.SplitUInts("aa")
		AssertUIntArrayEquals([0:UInt,0:UInt,0:UInt], a, "Non-overlapping separator matching should be used (builder)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:UInt[] = [ 0:UInt, 1:UInt, 2:UInt, 10:UInt, 100:UInt, 2147483648:UInt, 4294967295:UInt ]
		Local joined:String = ",".Join(vals)
		Local parsed:UInt[] = New TStringBuilder(joined).SplitUInts(",")
		AssertUIntArrayEquals(vals, parsed, "Join(UInt[]) then Builder.SplitUInts should round-trip for clean tokens")
	End Method

	Method Test_MatchesStringSplitUInts_Output() { test }
		' Sanity: builder and string should produce identical results for the same content/separator
		Local content:String = "  $FFFFFFFF, 1, 4294967296, 12x, , %1010  "
		Local sep:String = ","

		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:UInt[] = sb.SplitUInts(sep)
		Local a2:UInt[] = content.SplitUInts(sep)

		AssertUIntArrayEquals(a2, a1, "Builder.SplitUInts should match String.SplitUInts for identical input")
	End Method

End Type

Type TStringBuilderSplitLongsTest Extends TTest

	' Helper: assert Long[] equals expected (Length + each element)
	Method AssertLongArrayEquals(expected:Long[], actual:Long[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(expected[i], actual[i], message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:Long[] = sb.SplitLongs(",")
		AssertEquals(0, a.Length, "Empty builder should return empty Long[]")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Long[] = sb.SplitLongs("")
		AssertLongArrayEquals([123:Long], a, "Empty separator should parse whole builder as one entry")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:Long[] = sb.SplitLongs("")
		AssertLongArrayEquals([123:Long], a, "Empty separator should allow trailing whitespace (builder)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:Long[] = sb.SplitLongs("")
		AssertLongArrayEquals([0:Long], a, "Empty separator should reject trailing junk and return 0 (builder)")
	End Method

	Method Test_BasicCommaSeparated() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,3")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([1:Long,2:Long,3:Long], a, "Basic comma split (builder)")
	End Method

	Method Test_CustomSeparator() { test }
		Local sb:TStringBuilder = New TStringBuilder("1::2::3")
		Local a:Long[] = sb.SplitLongs("::")
		AssertLongArrayEquals([1:Long,2:Long,3:Long], a, "Custom separator split (builder)")
	End Method

	Method Test_LeadingSeparator_GivesLeadingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,2")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([0:Long,1:Long,2:Long], a, "Leading separator should produce leading empty token => 0 (builder)")
	End Method

	Method Test_TrailingSeparator_GivesTrailingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([1:Long,2:Long,0:Long], a, "Trailing separator should produce trailing empty token => 0 (builder)")
	End Method

	Method Test_ConsecutiveSeparators_GiveZeroTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,,3")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([1:Long,0:Long,3:Long], a, "Consecutive separators should produce empty token => 0 (builder)")
	End Method

	Method Test_AllEmptyTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder(",,")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([0:Long,0:Long,0:Long], a, "Two separators should produce three empty tokens => 0,0,0 (builder)")
	End Method

	Method Test_SeparatorNotFound_ParsesWholeStringAsSingleEntry() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([123:Long], a, "Separator not found should produce a single entry (builder)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([1:Long,2:Long,3:Long], a, "Whitespace around numbers should be allowed (builder)")
	End Method

	Method Test_SignHandling() { test }
		Local sb:TStringBuilder = New TStringBuilder("-1,+2,0,-300")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([-1:Long,2:Long,0:Long,-300:Long], a, "Signed parsing should handle - and + (builder)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([0:Long,0:Long,0:Long,0:Long], a, "Whitespace between sign and digits should produce 0 (builder)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([0:Long,456:Long,0:Long,0:Long], a, "Tokens with trailing non-whitespace junk should become 0 (builder)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$7FFFFFFFFFFFFFFF,%1010,$0,%0")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([$7FFFFFFFFFFFFFFF:Long,10:Long,0:Long,0:Long], a, "Hex/binary prefixes should parse correctly (builder)")
	End Method

	Method Test_BasePrefixes_WithTrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFG,%10102,$1Z,%10 2")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([0:Long,0:Long,0:Long,0:Long], a, "Trailing junk after base-prefixed numbers should be rejected (builder)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([0:Long,0:Long,0:Long,0:Long,0:Long,0:Long], a, "Tokens with no digits should return 0 (builder)")
	End Method

	Method Test_LongMinMax() { test }
		Local minVal:Long = $8000000000000000:Long ' -9223372036854775808
		Local maxVal:Long = $7FFFFFFFFFFFFFFF:Long '  9223372036854775807

		Local sb:TStringBuilder = New TStringBuilder("-9223372036854775808,9223372036854775807")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([minVal,maxVal], a, "Should parse Long min/max exactly (builder)")
	End Method

	Method Test_LongOverflow_Clamps() { test }
		Local minVal:Long = $8000000000000000:Long
		Local maxVal:Long = $7FFFFFFFFFFFFFFF:Long

		Local sb:TStringBuilder = New TStringBuilder("9223372036854775808,-9223372036854775809,999999999999999999999999999999")
		Local a:Long[] = sb.SplitLongs(",")

		AssertLongArrayEquals([maxVal,minVal,maxVal], a, "Overflow should clamp for Long (builder)")
	End Method

	Method Test_MultiCharSeparator_Edges() { test }
		Local sb:TStringBuilder = New TStringBuilder("::1::::3::")
		Local a:Long[] = sb.SplitLongs("::")
		AssertLongArrayEquals([0:Long,1:Long,0:Long,3:Long,0:Long], a, "Multi-char separator should handle edges (builder)")
	End Method

	Method Test_NewlineAndTabWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("~t123~n,~r~n-45~t,  6")
		Local a:Long[] = sb.SplitLongs(",")
		AssertLongArrayEquals([123:Long,-45:Long,6:Long], a, "Various whitespace characters should be allowed (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:Long[] = sb.SplitLongs("aa")
		AssertLongArrayEquals([0:Long,0:Long,0:Long], a, "Non-overlapping separator matching should be used (builder)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:Long[] = [ ..
			-1:Long, 0:Long, 1:Long, 2:Long, 10:Long, 100:Long, ..
			$7FFFFFFFFFFFFFFF:Long, $8000000000000000:Long ..
		]
		Local joined:String = ",".Join(vals)
		Local parsed:Long[] = New TStringBuilder(joined).SplitLongs(",")
		AssertLongArrayEquals(vals, parsed, "Join(Long[]) then Builder.SplitLongs should round-trip for clean tokens")
	End Method

	Method Test_MatchesStringSplitLongs_Output() { test }
		' Sanity: builder and string should produce identical results for the same content/separator
		Local content:String = "  $7FFFFFFFFFFFFFFF, -1, 9223372036854775808, 12x, , %1010  "
		Local sep:String = ","

		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:Long[] = sb.SplitLongs(sep)
		Local a2:Long[] = content.SplitLongs(sep)

		AssertLongArrayEquals(a2, a1, "Builder.SplitLongs should match String.SplitLongs for identical input")
	End Method

End Type

Type TStringBuilderSplitULongsTest Extends TTest

	' Helper: assert ULong[] equals expected (Length + each element)
	Method AssertULongArrayEquals(expected:ULong[], actual:ULong[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(expected[i], actual[i], message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:ULong[] = sb.SplitULongs(",")
		AssertEquals(0, a.Length, "Empty builder should return empty ULong[]")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:ULong[] = sb.SplitULongs("")
		AssertULongArrayEquals([123:ULong], a, "Empty separator should parse whole builder as one entry")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:ULong[] = sb.SplitULongs("")
		AssertULongArrayEquals([123:ULong], a, "Empty separator should allow trailing whitespace (builder)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:ULong[] = sb.SplitULongs("")
		AssertULongArrayEquals([0:ULong], a, "Empty separator should reject trailing junk and return 0 (builder)")
	End Method

	Method Test_BasicCommaSeparated() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,3")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([1:ULong,2:ULong,3:ULong], a, "Basic comma split (builder)")
	End Method

	Method Test_CustomSeparator() { test }
		Local sb:TStringBuilder = New TStringBuilder("1::2::3")
		Local a:ULong[] = sb.SplitULongs("::")
		AssertULongArrayEquals([1:ULong,2:ULong,3:ULong], a, "Custom separator split (builder)")
	End Method

	Method Test_LeadingSeparator_GivesLeadingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,2")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([0:ULong,1:ULong,2:ULong], a, "Leading separator should produce leading empty token => 0 (builder)")
	End Method

	Method Test_TrailingSeparator_GivesTrailingZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,2,")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([1:ULong,2:ULong,0:ULong], a, "Trailing separator should produce trailing empty token => 0 (builder)")
	End Method

	Method Test_ConsecutiveSeparators_GiveZeroTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder("1,,3")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([1:ULong,0:ULong,3:ULong], a, "Consecutive separators should produce empty token => 0 (builder)")
	End Method

	Method Test_AllEmptyTokens() { test }
		Local sb:TStringBuilder = New TStringBuilder(",,")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([0:ULong,0:ULong,0:ULong], a, "Two separators should produce three empty tokens => 0,0,0 (builder)")
	End Method

	Method Test_SeparatorNotFound_ParsesWholeStringAsSingleEntry() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([123:ULong], a, "Separator not found should produce a single entry (builder)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([1:ULong,2:ULong,3:ULong], a, "Whitespace around numbers should be allowed (builder)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([0:ULong,0:ULong,0:ULong,0:ULong], a, "Whitespace between sign and digits should produce 0 (builder)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([0:ULong,456:ULong,0:ULong,0:ULong], a, "Tokens with trailing non-whitespace junk should become 0 (builder)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFFFFFFFFFF,%1010,$0,%0")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([$FFFFFFFFFFFFFFFF:ULong,10:ULong,0:ULong,0:ULong], a, "Hex/binary prefixes should parse correctly (builder)")
	End Method

	Method Test_BasePrefixes_WithTrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFG,%10102,$1Z,%10 2")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([0:ULong,0:ULong,0:ULong,0:ULong], a, "Trailing junk after base-prefixed numbers should be rejected (builder)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([0:ULong,0:ULong,0:ULong,0:ULong,0:ULong,0:ULong], a, "Tokens with no digits should return 0 (builder)")
	End Method

	Method Test_RangeEdges_ULong() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,4294967295,4294967296,9223372036854775807,9223372036854775808,18446744073709551614,18446744073709551615")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([ ..
			0:ULong,1:ULong,9:ULong,10:ULong,99:ULong,100:ULong, ..
			4294967295:ULong,4294967296:ULong, ..
			9223372036854775807:ULong,9223372036854775808:ULong, ..
			18446744073709551614:ULong,18446744073709551615:ULong ..
		], a, "Should parse ULong range edges correctly (builder)")
	End Method

	Method Test_ULongOverflow_ClampsToMax() { test }
		Local maxVal:ULong = $FFFFFFFFFFFFFFFF:ULong

		Local sb:TStringBuilder = New TStringBuilder("18446744073709551616,999999999999999999999999999999999")
		Local a:ULong[] = sb.SplitULongs(",")

		AssertULongArrayEquals([maxVal, maxVal], a, "Overflow should clamp to ULong max (builder)")
	End Method

	Method Test_NegativeWrap_Behaviour() { test }
		Local sb:TStringBuilder = New TStringBuilder("-1,-0")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([$FFFFFFFFFFFFFFFF:ULong,0:ULong], a, "Negative values should wrap for ULong per bbStrToULong semantics (builder)")
	End Method

	Method Test_MultiCharSeparator_Edges() { test }
		Local sb:TStringBuilder = New TStringBuilder("::1::::3::")
		Local a:ULong[] = sb.SplitULongs("::")
		AssertULongArrayEquals([0:ULong,1:ULong,0:ULong,3:ULong,0:ULong], a, "Multi-char separator should handle edges (builder)")
	End Method

	Method Test_NewlineAndTabWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("~t123~n,~r~n45~t,  6")
		Local a:ULong[] = sb.SplitULongs(",")
		AssertULongArrayEquals([123:ULong,45:ULong,6:ULong], a, "Various whitespace characters should be allowed (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:ULong[] = sb.SplitULongs("aa")
		AssertULongArrayEquals([0:ULong,0:ULong,0:ULong], a, "Non-overlapping separator matching should be used (builder)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:ULong[] = [ ..
			0:ULong, 1:ULong, 2:ULong, 10:ULong, 100:ULong, ..
			4294967296:ULong, 9223372036854775808:ULong, $FFFFFFFFFFFFFFFF:ULong ..
		]
		Local joined:String = ",".Join(vals)
		Local parsed:ULong[] = New TStringBuilder(joined).SplitULongs(",")
		AssertULongArrayEquals(vals, parsed, "Join(ULong[]) then Builder.SplitULongs should round-trip for clean tokens")
	End Method

	Method Test_MatchesStringSplitULongs_Output() { test }
		' Sanity: builder and string should produce identical results for the same content/separator
		Local content:String = "  $FFFFFFFFFFFFFFFF, 1, 18446744073709551616, 12x, , %1010  "
		Local sep:String = ","

		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:ULong[] = sb.SplitULongs(sep)
		Local a2:ULong[] = content.SplitULongs(sep)

		AssertULongArrayEquals(a2, a1, "Builder.SplitULongs should match String.SplitULongs for identical input")
	End Method

End Type

?ptr32

Type TStringBuilderSplitSizeTs32Test Extends TTest

	Method AssertSizeTArrayEquals(expected:Size_T[], actual:Size_T[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(ULong(expected[i]), ULong(actual[i]), message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertEquals(0, a.Length, "Empty builder should return empty Size_T[] (ptr32)")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Size_T[] = sb.SplitSizeTs("")
		AssertSizeTArrayEquals([123:Size_T], a, "Empty separator parses whole builder (ptr32)")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:Size_T[] = sb.SplitSizeTs("")
		AssertSizeTArrayEquals([123:Size_T], a, "Trailing whitespace allowed (ptr32)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:Size_T[] = sb.SplitSizeTs("")
		AssertSizeTArrayEquals([0:Size_T], a, "Trailing junk rejected (ptr32)")
	End Method

	Method Test_Separators_LeadingTrailingConsecutive() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,,3,")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,1:Size_T,0:Size_T,3:Size_T,0:Size_T], a, "Empty tokens become 0 (ptr32)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([1:Size_T,2:Size_T,3:Size_T], a, "Whitespace allowed (ptr32)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,0:Size_T], a, "Whitespace between sign and digits rejected (ptr32)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,456:Size_T,0:Size_T,0:Size_T], a, "Trailing junk rejected (ptr32)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFF,%1010,$0,%0")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([$FFFFFFFF:Size_T,10:Size_T,0:Size_T,0:Size_T], a, "Hex/binary prefixes parse (ptr32)")
	End Method

	Method Test_RangeEdges_SizeT32() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,2147483647,2147483648,4000000000,4294967294,4294967295")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([ ..
			0:Size_T,1:Size_T,9:Size_T,10:Size_T,99:Size_T,100:Size_T, ..
			2147483647:Size_T,2147483648:Size_T,4000000000:Size_T,4294967294:Size_T,4294967295:Size_T ..
		], a, "Size_T 32-bit range edges parse (ptr32)")
	End Method

	Method Test_OutOfRange_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("4294967296,-1,999999999999999999999")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,0:Size_T,0:Size_T], a, "Out-of-range should return 0 for Size_T (ptr32)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:Size_T[] = sb.SplitSizeTs("aa")
		AssertSizeTArrayEquals([0:Size_T,0:Size_T,0:Size_T], a, "Non-overlapping separator matching (ptr32)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:Size_T[] = [ 0:Size_T, 1:Size_T, 2:Size_T, 10:Size_T, 100:Size_T, 2147483648:Size_T, 4294967295:Size_T ]
		Local joined:String = ",".Join(vals)
		Local parsed:Size_T[] = New TStringBuilder(joined).SplitSizeTs(",")
		AssertSizeTArrayEquals(vals, parsed, "Join(Size_T[]) then Builder.SplitSizeTs round-trip (ptr32)")
	End Method

	Method Test_MatchesStringSplitSizeTs_Output() { test }
		Local content:String = "  $FFFFFFFF, 1, 4294967296, 12x, , %1010  "
		Local sep:String = ","
		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:Size_T[] = sb.SplitSizeTs(sep)
		Local a2:Size_T[] = content.SplitSizeTs(sep)
		AssertSizeTArrayEquals(a2, a1, "Builder.SplitSizeTs should match String.SplitSizeTs (ptr32)")
	End Method

End Type

?ptr64

Type TStringBuilderSplitSizeTs64Test Extends TTest

	Method AssertSizeTArrayEquals(expected:Size_T[], actual:Size_T[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(ULong(expected[i]), ULong(actual[i]), message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertEquals(0, a.Length, "Empty builder should return empty Size_T[] (ptr64)")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:Size_T[] = sb.SplitSizeTs("")
		AssertSizeTArrayEquals([123:Size_T], a, "Empty separator parses whole builder (ptr64)")
	End Method

	Method Test_Separators_LeadingTrailingConsecutive() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,,3,")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,1:Size_T,0:Size_T,3:Size_T,0:Size_T], a, "Empty tokens become 0 (ptr64)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([1:Size_T,2:Size_T,3:Size_T], a, "Whitespace allowed (ptr64)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,456:Size_T,0:Size_T,0:Size_T], a, "Trailing junk rejected (ptr64)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFFFFFFFFFF,%1010,$0,%0")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([$FFFFFFFFFFFFFFFF:Size_T,10:Size_T,0:Size_T,0:Size_T], a, "Hex/binary prefixes parse (ptr64)")
	End Method

	Method Test_RangeEdges_SizeT64() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,4294967295,4294967296,9223372036854775807,9223372036854775808,18446744073709551614,18446744073709551615")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([ ..
			0:Size_T,1:Size_T,9:Size_T,10:Size_T,99:Size_T,100:Size_T, ..
			4294967295:Size_T,4294967296:Size_T, ..
			9223372036854775807:Size_T,9223372036854775808:Size_T, ..
			18446744073709551614:Size_T,18446744073709551615:Size_T ..
		], a, "Size_T 64-bit range edges parse (ptr64)")
	End Method

	Method Test_SizeTOverflow_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("18446744073709551616,999999999999999999999999999999999")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([0:Size_T,0:Size_T], a, "Overflow should return 0 for Size_T (ptr64)")
	End Method

	Method Test_NegativeWrap_AllowedOnPtr64() { test }
		' On ptr64, SIZE_MAX == 0xFFFFFFFFFFFFFFFF, so -1 wraps to SIZE_MAX and is accepted.
		Local sb:TStringBuilder = New TStringBuilder("-1,-0")
		Local a:Size_T[] = sb.SplitSizeTs(",")
		AssertSizeTArrayEquals([$FFFFFFFFFFFFFFFF:Size_T,0:Size_T], a, "Negative wrap yields SIZE_MAX for -1 on ptr64")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:Size_T[] = sb.SplitSizeTs("aa")
		AssertSizeTArrayEquals([0:Size_T,0:Size_T,0:Size_T], a, "Non-overlapping separator matching (ptr64)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:Size_T[] = [ 0:Size_T, 1:Size_T, 2:Size_T, 10:Size_T, 100:Size_T, 4294967296:Size_T, 9223372036854775808:Size_T ]
		Local joined:String = ",".Join(vals)
		Local parsed:Size_T[] = New TStringBuilder(joined).SplitSizeTs(",")
		AssertSizeTArrayEquals(vals, parsed, "Join(Size_T[]) then Builder.SplitSizeTs round-trip (ptr64)")
	End Method

	Method Test_MatchesStringSplitSizeTs_Output() { test }
		Local content:String = "  $FFFFFFFFFFFFFFFF, 1, 18446744073709551616, 12x, , %1010  "
		Local sep:String = ","
		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:Size_T[] = sb.SplitSizeTs(sep)
		Local a2:Size_T[] = content.SplitSizeTs(sep)
		AssertSizeTArrayEquals(a2, a1, "Builder.SplitSizeTs should match String.SplitSizeTs (ptr64)")
	End Method

End Type

?

?longint4

Type TStringBuilderSplitLongInts32Test Extends TTest

	Method AssertLongIntArrayEquals(expected:LongInt[], actual:LongInt[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(expected[i], actual[i], message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty LongInt[] (longint4)")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:LongInt[] = sb.SplitLongInts("")
		AssertLongIntArrayEquals([123:LongInt], a, "Empty separator parses whole builder (longint4)")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:LongInt[] = sb.SplitLongInts("")
		AssertLongIntArrayEquals([123:LongInt], a, "Trailing whitespace allowed (longint4)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:LongInt[] = sb.SplitLongInts("")
		AssertLongIntArrayEquals([0:LongInt], a, "Trailing junk rejected (longint4)")
	End Method

	Method Test_Separators_LeadingTrailingConsecutive() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,,3,")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,1:LongInt,0:LongInt,3:LongInt,0:LongInt], a, "Empty tokens become 0 (longint4)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([1:LongInt,2:LongInt,3:LongInt], a, "Whitespace allowed (longint4)")
	End Method

	Method Test_SignHandling() { test }
		Local sb:TStringBuilder = New TStringBuilder("-1,+2,0,-300")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([-1:LongInt,2:LongInt,0:LongInt,-300:LongInt], a, "Signed parsing works (longint4)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt,0:LongInt], a, "Whitespace between sign and digits rejected (longint4)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,456:LongInt,0:LongInt,0:LongInt], a, "Trailing junk rejected (longint4)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$7FFFFFFF,%1010,$0,%0")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([$7FFFFFFF:LongInt,10:LongInt,0:LongInt,0:LongInt], a, "Hex/binary prefixes parse (longint4)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt,0:LongInt,0:LongInt,0:LongInt], a, "No digits => 0 (longint4)")
	End Method

	Method Test_RangeEdges_LongInt32() { test }
		Local minVal:LongInt = $80000000:LongInt
		Local maxVal:LongInt = $7FFFFFFF:LongInt
		Local sb:TStringBuilder = New TStringBuilder("-2147483648,-1,0,1,2147483647")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([minVal,-1:LongInt,0:LongInt,1:LongInt,maxVal], a, "LongInt 32-bit range edges parse (builder longint4)")
	End Method

	Method Test_OutOfRange_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("2147483648,-2147483649,999999999999999999999")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt], a, "Out-of-range/overflow should return 0 for LongInt (builder longint4)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:LongInt[] = sb.SplitLongInts("aa")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt], a, "Non-overlapping separator matching (builder longint4)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:LongInt[] = [ $80000000:LongInt, -1:LongInt, 0:LongInt, 1:LongInt, 42:LongInt, $7FFFFFFF:LongInt ]
		Local joined:String = ",".Join(vals)
		Local parsed:LongInt[] = New TStringBuilder(joined).SplitLongInts(",")
		AssertLongIntArrayEquals(vals, parsed, "Join(LongInt[]) then Builder.SplitLongInts round-trip (longint4)")
	End Method

	Method Test_MatchesStringSplitLongInts_Output() { test }
		Local content:String = "  $7FFFFFFF, -1, 2147483648, 12x, , %1010  "
		Local sep:String = ","
		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:LongInt[] = sb.SplitLongInts(sep)
		Local a2:LongInt[] = content.SplitLongInts(sep)
		AssertLongIntArrayEquals(a2, a1, "Builder.SplitLongInts should match String.SplitLongInts (longint4)")
	End Method

End Type

?longint8

Type TStringBuilderSplitLongInts64Test Extends TTest

	Method AssertLongIntArrayEquals(expected:LongInt[], actual:LongInt[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(expected[i], actual[i], message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty LongInt[] (longint8)")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:LongInt[] = sb.SplitLongInts("")
		AssertLongIntArrayEquals([123:LongInt], a, "Empty separator parses whole builder (longint8)")
	End Method

	Method Test_Separators_LeadingTrailingConsecutive() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,,3,")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,1:LongInt,0:LongInt,3:LongInt,0:LongInt], a, "Empty tokens become 0 (longint8)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([1:LongInt,2:LongInt,3:LongInt], a, "Whitespace allowed (longint8)")
	End Method

	Method Test_SignHandling() { test }
		Local sb:TStringBuilder = New TStringBuilder("-1,+2,0,-300")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([-1:LongInt,2:LongInt,0:LongInt,-300:LongInt], a, "Signed parsing works (longint8)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2,-~t3,+~n4")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt,0:LongInt], a, "Whitespace between sign and digits rejected (longint8)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,456:LongInt,0:LongInt,0:LongInt], a, "Trailing junk rejected (longint8)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$7FFFFFFFFFFFFFFF,%1010,$0,%0")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([$7FFFFFFFFFFFFFFF:LongInt,10:LongInt,0:LongInt,0:LongInt], a, "Hex/binary prefixes parse (longint8)")
	End Method

	Method Test_LongIntMinMax_64bit() { test }
		Local minVal:LongInt = $8000000000000000:LongInt
		Local maxVal:LongInt = $7FFFFFFFFFFFFFFF:LongInt
		Local sb:TStringBuilder = New TStringBuilder("-9223372036854775808,9223372036854775807")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([minVal,maxVal], a, "LongInt 64-bit min/max parse (builder longint8)")
	End Method

	Method Test_Overflow_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("9223372036854775808,-9223372036854775809,999999999999999999999999999999")
		Local a:LongInt[] = sb.SplitLongInts(",")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt], a, "Overflow/underflow should return 0 for LongInt (builder longint8)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:LongInt[] = sb.SplitLongInts("aa")
		AssertLongIntArrayEquals([0:LongInt,0:LongInt,0:LongInt], a, "Non-overlapping separator matching (builder longint8)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:LongInt[] = [ ..
			$8000000000000000:LongInt, -1:LongInt, 0:LongInt, 1:LongInt, 42:LongInt, $7FFFFFFFFFFFFFFF:LongInt ..
		]
		Local joined:String = ",".Join(vals)
		Local parsed:LongInt[] = New TStringBuilder(joined).SplitLongInts(",")
		AssertLongIntArrayEquals(vals, parsed, "Join(LongInt[]) then Builder.SplitLongInts round-trip (longint8)")
	End Method

	Method Test_MatchesStringSplitLongInts_Output() { test }
		Local content:String = "  $7FFFFFFFFFFFFFFF, -1, 9223372036854775808, 12x, , %1010  "
		Local sep:String = ","
		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:LongInt[] = sb.SplitLongInts(sep)
		Local a2:LongInt[] = content.SplitLongInts(sep)
		AssertLongIntArrayEquals(a2, a1, "Builder.SplitLongInts should match String.SplitLongInts (longint8)")
	End Method

End Type

?

?ulongint4

Type TStringBuilderSplitULongInts32Test Extends TTest

	Method AssertULongIntArrayEquals(expected:ULongInt[], actual:ULongInt[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(ULong(expected[i]), ULong(actual[i]), message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty ULongInt[] (ulongint4)")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:ULongInt[] = sb.SplitULongInts("")
		AssertULongIntArrayEquals([123:ULongInt], a, "Empty separator parses whole builder (ulongint4)")
	End Method

	Method Test_EmptySeparator_TrailingWhitespaceAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("123   ")
		Local a:ULongInt[] = sb.SplitULongInts("")
		AssertULongIntArrayEquals([123:ULongInt], a, "Trailing whitespace allowed (ulongint4)")
	End Method

	Method Test_EmptySeparator_TrailingJunkRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x")
		Local a:ULongInt[] = sb.SplitULongInts("")
		AssertULongIntArrayEquals([0:ULongInt], a, "Trailing junk rejected (ulongint4)")
	End Method

	Method Test_Separators_LeadingTrailingConsecutive() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,,3,")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,1:ULongInt,0:ULongInt,3:ULongInt,0:ULongInt], a, "Empty tokens become 0 (ulongint4)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([1:ULongInt,2:ULongInt,3:ULongInt], a, "Whitespace allowed (ulongint4)")
	End Method

	Method Test_WhitespaceBetweenSignAndDigits_IsRejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("- 1,+ 2")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,0:ULongInt], a, "Whitespace between sign and digits rejected (ulongint4)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,456:ULongInt,0:ULongInt,0:ULongInt], a, "Trailing junk rejected (ulongint4)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFF,%1010,$0,%0")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([$FFFFFFFF:ULongInt,10:ULongInt,0:ULongInt,0:ULongInt], a, "Hex/binary prefixes parse (ulongint4)")
	End Method

	Method Test_NoDigits_TokensReturnZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("abc,  , +, -, $, %")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,0:ULongInt,0:ULongInt,0:ULongInt,0:ULongInt,0:ULongInt], a, "No digits => 0 (ulongint4)")
	End Method

	Method Test_RangeEdges_ULongInt32() { test }
		Local sb:TStringBuilder = New TStringBuilder("0,1,9,10,99,100,2147483647,2147483648,4294967294,4294967295")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([ ..
			0:ULongInt,1:ULongInt,9:ULongInt,10:ULongInt,99:ULongInt,100:ULongInt, ..
			2147483647:ULongInt,2147483648:ULongInt,4294967294:ULongInt,4294967295:ULongInt ..
		], a, "ULongInt 32-bit range edges parse (builder ulongint4)")
	End Method

	Method Test_OutOfRange_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("4294967296,-1,999999999999999999999")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,0:ULongInt,0:ULongInt], a, "Out-of-range/overflow should return 0 for ULongInt (builder ulongint4)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:ULongInt[] = sb.SplitULongInts("aa")
		AssertULongIntArrayEquals([0:ULongInt,0:ULongInt,0:ULongInt], a, "Non-overlapping separator matching (builder ulongint4)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:ULongInt[] = [ 0:ULongInt, 1:ULongInt, 2:ULongInt, 10:ULongInt, 100:ULongInt, 2147483648:ULongInt, $FFFFFFFF:ULongInt ]
		Local joined:String = ",".Join(vals)
		Local parsed:ULongInt[] = New TStringBuilder(joined).SplitULongInts(",")
		AssertULongIntArrayEquals(vals, parsed, "Join(ULongInt[]) then Builder.SplitULongInts round-trip (ulongint4)")
	End Method

	Method Test_MatchesStringSplitULongInts_Output() { test }
		Local content:String = "  $FFFFFFFF, 1, 4294967296, 12x, , %1010  "
		Local sep:String = ","
		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:ULongInt[] = sb.SplitULongInts(sep)
		Local a2:ULongInt[] = content.SplitULongInts(sep)
		AssertULongIntArrayEquals(a2, a1, "Builder.SplitULongInts should match String.SplitULongInts (ulongint4)")
	End Method

End Type

?ulongint8

Type TStringBuilderSplitULongInts64Test Extends TTest

	Method AssertULongIntArrayEquals(expected:ULongInt[], actual:ULongInt[], message:String)
		AssertEquals(expected.Length, actual.Length, message + " (length)")
		For Local i:Int = 0 Until expected.Length
			AssertEquals(expected[i], actual[i], message + " (index " + i + ")")
		Next
	End Method

	Method Test_EmptyBuilder_ReturnsEmptyArray() { test }
		Local sb:TStringBuilder = New TStringBuilder
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertEquals(0, a.Length, "Empty builder should return empty ULongInt[] (ulongint8)")
	End Method

	Method Test_EmptySeparator_ParsesWholeString() { test }
		Local sb:TStringBuilder = New TStringBuilder("123")
		Local a:ULongInt[] = sb.SplitULongInts("")
		AssertULongIntArrayEquals([123:ULongInt], a, "Empty separator parses whole builder (ulongint8)")
	End Method

	Method Test_Separators_LeadingTrailingConsecutive() { test }
		Local sb:TStringBuilder = New TStringBuilder(",1,,3,")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,1:ULongInt,0:ULongInt,3:ULongInt,0:ULongInt], a, "Empty tokens become 0 (ulongint8)")
	End Method

	Method Test_WhitespaceAroundNumbers_IsAllowed() { test }
		Local sb:TStringBuilder = New TStringBuilder("  1 ,  2  ,   3   ")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([1:ULongInt,2:ULongInt,3:ULongInt], a, "Whitespace allowed (ulongint8)")
	End Method

	Method Test_TrailingJunk_Rejected() { test }
		Local sb:TStringBuilder = New TStringBuilder("123x, 456, 78 9, 10-")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,456:ULongInt,0:ULongInt,0:ULongInt], a, "Trailing junk rejected (ulongint8)")
	End Method

	Method Test_EmbeddedHexAndBinary() { test }
		Local sb:TStringBuilder = New TStringBuilder("$FFFFFFFFFFFFFFFF,%1010,$0,%0")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([$FFFFFFFFFFFFFFFF:ULongInt,10:ULongInt,0:ULongInt,0:ULongInt], a, "Hex/binary prefixes parse (ulongint8)")
	End Method

	Method Test_ULongIntMax_64bit() { test }
		Local maxVal:ULongInt = $FFFFFFFFFFFFFFFF:ULongInt
		Local sb:TStringBuilder = New TStringBuilder("18446744073709551615")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([maxVal], a, "ULongInt max parses (builder ulongint8)")
	End Method

	Method Test_Overflow_ReturnsZero() { test }
		Local sb:TStringBuilder = New TStringBuilder("18446744073709551616,999999999999999999999999999999999")
		Local a:ULongInt[] = sb.SplitULongInts(",")
		AssertULongIntArrayEquals([0:ULongInt,0:ULongInt], a, "Overflow should return 0 for ULongInt (builder ulongint8)")
	End Method

	Method Test_NegativeWrap_AllowedOnULongInt64() { test }
		Local maxVal:ULongInt = $FFFFFFFFFFFFFFFF:ULongInt

		Local sb:TStringBuilder = New TStringBuilder("-1,-0")
		Local a:ULongInt[] = sb.SplitULongInts(",")

		AssertULongIntArrayEquals([maxVal,0:ULongInt], a, "Negative wrap yields max for -1 on 64-bit ULongInt (builder)")
	End Method

	Method Test_OverlappingSeparator_NonOverlappingMatches() { test }
		Local sb:TStringBuilder = New TStringBuilder("aaaa")
		Local a:ULongInt[] = sb.SplitULongInts("aa")
		AssertULongIntArrayEquals([0:ULongInt,0:ULongInt,0:ULongInt], a, "Non-overlapping separator matching (builder ulongint8)")
	End Method

	Method Test_PredictableRoundTrip_Simple() { test }
		Local vals:ULongInt[] = [ 0:ULongInt, 1:ULongInt, 2:ULongInt, 10:ULongInt, 100:ULongInt, 4294967296:ULongInt, $FFFFFFFFFFFFFFFF:ULongInt ]
		Local joined:String = ",".Join(vals)
		Local parsed:ULongInt[] = New TStringBuilder(joined).SplitULongInts(",")
		AssertULongIntArrayEquals(vals, parsed, "Join(ULongInt[]) then Builder.SplitULongInts round-trip (ulongint8)")
	End Method

	Method Test_MatchesStringSplitULongInts_Output() { test }
		Local content:String = "  $FFFFFFFFFFFFFFFF, 1, 18446744073709551616, 12x, , %1010  "
		Local sep:String = ","
		Local sb:TStringBuilder = New TStringBuilder(content)
		Local a1:ULongInt[] = sb.SplitULongInts(sep)
		Local a2:ULongInt[] = content.SplitULongInts(sep)
		AssertULongIntArrayEquals(a2, a1, "Builder.SplitULongInts should match String.SplitULongInts (ulongint8)")
	End Method

End Type

?
