SuperStrict

Framework brl.standardio
Import BRL.MaxUnit

New TTestSuite.run()

Type TStringTest Extends TTest

	Field bigUnicode:UInt[] = [$10300, $10301, $10302, $10303, $10304, $10305, 0]
	Field unicode:Int[] = [1055, 1088, 1080, 1074, 1077, 1090]
	Field utf8:Byte[] = [208, 159, 209, 128, 208, 184, 208, 178, 208, 181, 209, 130, 0]
	
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

End Type
