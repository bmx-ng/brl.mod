SuperStrict

Framework brl.standardio
Import brl.stringbuilder
Import BRL.MaxUnit

New TTestSuite.run()

Type TStringBuilderTest Extends TTest

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
		Local s:String = "@825B"
		sb.Append(s)
	
		Local b1:Byte Ptr = s.ToUTF8String()
		Local b2:Byte Ptr = sb.ToUTF8String()
		
		assertNotNull(b2)
		assertEquals(strlen_(b1), strlen_(b2))
		
		For Local i:Int = 0 Until strlen_(b1)
			assertEquals(b1[0], b2[0])
		Next
		
		MemFree(b1)
		MemFree(b2)
	End Method

	Method testEmptyToUTF8String() { test }
	
		assertNull(sb.ToUTF8String())
		
	End Method

	Method testToWString() { test }
		Local s:String = "@825B"
		sb.Append(s)
	
		Local s1:Short Ptr = s.ToWString()
		Local s2:Short Ptr = sb.ToWString()
		
		assertNotNull(s2)
		
		For Local i:Int = 0 Until 6
			assertEquals(s1[0], s2[0])
		Next
		
		MemFree(s1)
		MemFree(s2)
	End Method

	Method testEmptyToWString() { test }
	
		assertNull(sb.ToWString())
		
	End Method

End Type
