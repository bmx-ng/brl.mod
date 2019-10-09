SuperStrict

Framework brl.standardio
Import brl.stringbuilder
Import BRL.MaxUnit

New TTestSuite.run()

Type TStringBuilderTest Extends TTest

	Field unicode:Int[] = [1055, 1088, 1080, 1074, 1077, 1090]
	Field utf8:Byte[] = [208, 159, 209, 128, 208, 184, 208, 178, 208, 181, 209, 130]

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
		assertEquals(utf8.length, strlen_(b2))
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

End Type
