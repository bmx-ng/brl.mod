SuperStrict

Framework brl.standardio
Import brl.jconv
Import BRL.MaxUnit

New TTestSuite.run()

Type TJConvTest Extends TTest

	Field jconv:TJConv
	
	Method setup() { before }
		jconv = New TJConvBuilder.WithEmptyArrays().Build()
	End Method

End Type

Type TArrayTest Extends TJConvTest

	Const EMPTY_ARRAY:String = "[]"
	Const EMPTY_OBJECT:String = "{}"
	Const STRING_ARRAY:String = "[~qOne~q, ~qTwo~q, ~qThree~q]"
	Const INT_ARRAY:String = "[1, 2, 3, 4, 5]"

	Method testEmptyObject() { test }
		Local obj:Object
		
		assertEquals(EMPTY_OBJECT, jconv.ToJson(obj))
	End Method

	Method testEmptyArray() { test }
		Local array:Object[]
		
		array = Object[](jconv.FromJson(EMPTY_ARRAY, array))
		
		assertEquals(0, array.length)

		assertEquals(EMPTY_ARRAY, jconv.ToJson(array))
	End Method

	Method testEmptyArrayWithoutEmpties() { test }
		Local array:Object[]
		
		array = Object[](jconv.FromJson(EMPTY_ARRAY, array))
		
		assertEquals(0, array.length)

		assertEquals(EMPTY_ARRAY, New TJConvBuilder.Build().ToJson(array))
	End Method

	Method testStringsArray() { test }
		Local array:String[1]
		
		array = String[](jconv.FromJson(STRING_ARRAY, array))
		
		assertEquals(3, array.length)
		
		assertEquals(STRING_ARRAY, jconv.ToJson(array))
	End Method

	Method testStringsName() { test }		
		Local array:String[] = String[](jconv.FromJson(STRING_ARRAY, "String[]"))
		
		assertEquals(3, array.length)
		
		assertEquals(STRING_ARRAY, jconv.ToJson(array))
	End Method

	Method testIntsArray() { test }
		Local array:Int[1]
		
		array = Int[](jconv.FromJson(INT_ARRAY, array))
		
		assertEquals(5, array.length)
		
		assertEquals(INT_ARRAY, jconv.ToJson(array))
	End Method

	Method testIntsName() { test }
		Local array:Int[] = Int[](jconv.FromJson(INT_ARRAY, "Int[]"))
		
		assertEquals(5, array.length)
		
		assertEquals(INT_ARRAY, jconv.ToJson(array))
	End Method

	Method testData() { test }
		Local stream:TStream = ReadStream("data.json")
		
		Local array:TData[] = TData[](jconv.FromJson(stream, "TData[]"))
		
		stream.Close()
		
		assertNotNull(array)
		assertEquals(5, array.length)
		assertEquals("194.75.65.15", array[4].ip_address)
		
		assertNotNull(array[1].locations)
		assertNull(array[2].locations)
		assertEquals(3, array[1].locations.length)
		assertEquals(50.4575108:Double, array[1].locations[1].lat)
	End Method
	
End Type

Type TData
	Field id:Long
	Field first_name:String
	Field last_name:String
	Field email:String
	Field gender:String
	Field ip_address:String
	Field language:String
	Field locations:TLocation[]
End Type

Type TLocation
	Field lat:Double
	Field lng:Double
End Type

