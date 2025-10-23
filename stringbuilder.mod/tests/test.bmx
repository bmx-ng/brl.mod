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
