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

	Method testToUTF8StringBuffer() { test }
		Local s:String = "1234567890"
		Local buf:Byte Ptr = StackAlloc(50)

		Local length:size_t = 10
		s.ToUTF8StringBuffer(buf, length)

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

