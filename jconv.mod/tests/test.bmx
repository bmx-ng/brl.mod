SuperStrict

Framework brl.standardio
Import brl.jconv
Import BRL.MaxUnit

New TTestSuite.run()

Type TJConvTest Extends TTest

	Field jconv:TJConv
	
	Method setup() { before }
		jconv = New TJConvBuilder.WithEmptyArrays().WithBoxing().Build()
	End Method

End Type

Type TArrayTest Extends TJConvTest

	Const EMPTY_ARRAY:String = "[]"
	Const EMPTY_OBJECT:String = "{}"
	Const STRING_ARRAY:String = "[~qOne~q, ~qTwo~q, ~qThree~q]"
	Const INT_ARRAY:String = "[1, 2, 3, 4, 5]"
	Const JSON_TYPES:String = "{~qfByte~q: 1, ~qfShort~q: 2, ~qfInt~q: 3, ~qfUInt~q: 4, ~qfLong~q: 5, ~qfULong~q: 6, ~qfSizeT~q: 7, ~qfFloat~q: 8.0, ~qfDouble~q: 9.0, ~qfString~q: ~q10~q, ~qfObject~q: {~qx~q: 1, ~qy~q: 2, ~qz~q: 3}}"
	Const JSON_TYPES_SER:String = "{~qfByte~q: 1, ~qfShort~q: 2, ~qfInt~q: 3, ~qfUInt~q: 4, ~qfLong~q: 5, ~qfULong~q: 6, ~qfSizeT~q: 7, ~qfFloat~q: 8.0, ~qfDouble~q: 9.0, ~qfString~q: ~q10~q, ~qfObject~q: {~qz~q: 3, ~qy~q: 2, ~qx~q: 1}}"
	Const JSON_CONTAINER:String = "{~qbox~q: ~q10,10,100,150~q}"
	Const JSON_SER_NAME:String = "{~qname~q: ~qone~q, ~qname1~q: ~qtwo~q, ~qc~q: ~qthree~q}"
	Const JSON_ALT_SER_NAME:String = "{~qa~q: ~qone~q, ~qname3~q: ~qtwo~q, ~qc~q: ~qthree~q}"
	Const JSON_WITH_BOOL_ON:String = "{~qonOff~q: true}"
	Const JSON_WITH_BOOL_OFF:String = "{~qonOff~q: false}"
	Const JSON_BOX_BOOL_ON:String = "{~qb1~q: true}"
	Const JSON_BOX_BOOL_OFF:String = "{~qb1~q: false}"
	Const JSON_BOX_BYTE:String = "{~qb2~q: 42}"
	Const JSON_BOX_SHORT:String = "{~qb3~q: 84}"
	Const JSON_BOX_INT:String = "{~qb4~q: -99}"
	Const JSON_BOX_UINT:String = "{~qb5~q: 6600}"
	Const JSON_BOX_LONG:String = "{~qb6~q: 54321}"
	Const JSON_BOX_ULONG:String = "{~qb7~q: 96}"
	Const JSON_BOX_SIZE_T:String = "{~qb8~q: 100}"
	Const JSON_BOX_FLOAT:String = "{~qb9~q: 7.5}"
	Const JSON_BOX_DOUBLE:String = "{~qb10~q: 68.418}"
	Const JSON_PREC:String = "{~qp1~q: 5.352, ~qp2~q: 65.698}"
	Const JSON_SER_NAME_COMPACT:String = "{~qname~q:~qone~q,~qname1~q:~qtwo~q,~qc~q:~qthree~q}"
	Const JSON_SER_NAME_PRETTY:String = "{~n  ~qname~q: ~qone~q,~n  ~qname1~q: ~qtwo~q,~n  ~qc~q: ~qthree~q~n}"
	Const JSON_TRANS_NO_B:String = "{~qa~q: ~qone~q, ~qc~q: ~qthree~q}"
	Const JSON_TRANS:String = "{~qa~q: ~qone~q, ~qb~q: ~qtwo~q, ~qc~q: ~qthree~q}"
	Const JSON_IGNORE_SER:String = "{~qa~q: ~qone~q, ~qc~q: ~qthree~q}"
	Const JSON_IGNORE:String = "{~qa~q: ~qone~q, ~qb~q: ~qtwo~q, ~qc~q: ~qthree~q, ~qd~q: ~qfour~q}"

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
	
	Method testFieldTypes() { test }
		Local types:TTypes = New TTypes
		
		assertEquals(JSON_TYPES, jconv.ToJson(types)) 
	End Method

	Method testObjectSerializer() { test }
		jconv = New TJConvBuilder.RegisterSerializer("TEmbedded", New TEmbeddedSerializer).Build()

		Local types:TTypes = New TTypes
		assertEquals(JSON_TYPES_SER, jconv.ToJson(types)) 
	End Method
	
	Method testCustomSerializer() { test }
		Local serializer:TBoxSerializer = New TBoxSerializer
		jconv = New TJConvBuilder.RegisterSerializer("TBox", serializer).Build()

		Local container:TContainer = New TContainer(New TBox(10, 10, 100, 150))

		assertEquals(JSON_CONTAINER, jconv.ToJson(container))

		Local c2:TContainer = TContainer(jconv.FromJson(JSON_CONTAINER, "TContainer"))
		
		assertNotNull(c2)
		assertNotNull(c2.box)
		assertEquals(10, c2.box.x)
		assertEquals(10, c2.box.y)
		assertEquals(100, c2.box.w)
		assertEquals(150, c2.box.h)
	End Method

	Method testFieldNameSerialize() { test }
		Local name1:TSName = New TSName
		name1.a = "one"
		name1.b = "two"
		name1.c = "three"
		
		assertEquals(JSON_SER_NAME, jconv.ToJson(name1))

		Local name2:TSName = TSName(jconv.FromJson(JSON_SER_NAME, "TSName"))
		assertNotNull(name2)
		assertEquals(name1.a, name2.a)
		assertEquals(name1.b, name2.b)
		assertEquals(name1.c, name2.c)

		Local name3:TSName = TSName(jconv.FromJson(JSON_ALT_SER_NAME, "TSName"))
		assertNotNull(name3)
		assertEquals(name1.a, name3.a)
		assertEquals(name1.b, name3.b)
		assertEquals(name1.c, name3.c)
	End Method

	Method testWithBool() { test }
		Local obj:TWithBool = TWithBool(jconv.FromJson(JSON_WITH_BOOL_ON, "TWithBool"))
		
		assertNotNull(obj)
		assertEquals(True, obj.onOff)

		obj = TWithBool(jconv.FromJson(JSON_WITH_BOOL_OFF, "TWithBool"))
		
		assertNotNull(obj)
		assertEquals(False, obj.onOff)
	End Method

	Method testBoxing() { test }
		Local boxed:TBoxed = New TBoxed
		
		assertEquals(EMPTY_OBJECT, jconv.ToJson(boxed))
		
		boxed.b1 = New TBool(True)
		assertEquals(JSON_BOX_BOOL_ON, jconv.ToJson(boxed))
		boxed.b1.value = False
		assertEquals(JSON_BOX_BOOL_OFF, jconv.ToJson(boxed))
		boxed.b1 = Null

		boxed.b2 = New TByte(42)
		assertEquals(JSON_BOX_BYTE, jconv.ToJson(boxed))
		boxed.b2 = Null

		boxed.b3 = New TShort(84)
		assertEquals(JSON_BOX_SHORT, jconv.ToJson(boxed))
		boxed.b3 = Null

		boxed.b4 = New TInt(-99)
		assertEquals(JSON_BOX_INT, jconv.ToJson(boxed))
		boxed.b4 = Null

		boxed.b5 = New TUInt(6600)
		assertEquals(JSON_BOX_UINT, jconv.ToJson(boxed))
		boxed.b5 = Null

		boxed.b6 = New TLong(54321)
		assertEquals(JSON_BOX_LONG, jconv.ToJson(boxed))
		boxed.b6 = Null

		boxed.b7 = New TULong(96)
		assertEquals(JSON_BOX_ULONG, jconv.ToJson(boxed))
		boxed.b7 = Null

		boxed.b8 = New TSize_T(100)
		assertEquals(JSON_BOX_SIZE_T, jconv.ToJson(boxed))
		boxed.b8 = Null

		boxed.b9 = New TFloat(7.5)
		assertEquals(JSON_BOX_FLOAT, jconv.ToJson(boxed), 0.01)
		boxed.b9 = Null

		boxed.b10 = New TDouble(68.484)
		Local s:String = jconv.ToJson(boxed)
		Local dboxed:TBoxed = TBoxed(jconv.FromJson(s, "TBoxed"))
		assertNotNull(dboxed.b10)
		assertEquals(68.484, dboxed.b10.value, 0.1)
		boxed.b10 = Null
		
	End Method
	
	Method testUnboxing() { test }
		Local boxed:TBoxed = TBoxed(jconv.FromJson(EMPTY_OBJECT, "TBoxed"))
		
		assertNull(boxed.b1)
		assertNull(boxed.b2)
		assertNull(boxed.b3)
		assertNull(boxed.b4)
		assertNull(boxed.b5)
		assertNull(boxed.b6)
		assertNull(boxed.b7)
		assertNull(boxed.b8)
		assertNull(boxed.b9)
		assertNull(boxed.b10)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_BOOL_ON, "TBoxed"))
		
		assertNotNull(boxed.b1)
		assertEquals(True, boxed.b1.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_BOOL_OFF, "TBoxed"))
		
		assertNotNull(boxed.b1)
		assertEquals(False, boxed.b1.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_BYTE, "TBoxed"))

		assertNotNull(boxed.b2)
		assertEquals(42, boxed.b2.value)
		
		boxed = TBoxed(jconv.FromJson(JSON_BOX_SHORT, "TBoxed"))

		assertNotNull(boxed.b3)
		assertEquals(84, boxed.b3.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_INT, "TBoxed"))

		assertNotNull(boxed.b4)
		assertEquals(-99, boxed.b4.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_UINT, "TBoxed"))

		assertNotNull(boxed.b5)
		assertEquals(6600, boxed.b5.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_LONG, "TBoxed"))

		assertNotNull(boxed.b6)
		assertEquals(54321, boxed.b6.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_ULONG, "TBoxed"))

		assertNotNull(boxed.b7)
		assertEquals(96, boxed.b7.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_SIZE_T, "TBoxed"))

		assertNotNull(boxed.b8)
		assertEquals(100, boxed.b8.value)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_FLOAT, "TBoxed"))

		assertNotNull(boxed.b9)
		assertEquals(7.5, boxed.b9.value, 0.1)

		boxed = TBoxed(jconv.FromJson(JSON_BOX_DOUBLE, "TBoxed"))
		assertNotNull(boxed.b10)
		assertEquals(68.484, boxed.b10.value, 0.1)
		
	End Method

	Method testPrecision() { test }

		Local prec:TPrec = New TPrec(5.3521, 65.6982902)

		jconv = New TJConvBuilder.WithPrecision(3).Build()
		
		assertEquals(JSON_PREC, jconv.ToJson(prec))

	End Method

	Method testCompact() { test }

		jconv = New TJConvBuilder.WithCompact().Build()

		Local name1:TSName = New TSName
		name1.a = "one"
		name1.b = "two"
		name1.c = "three"
		
		assertEquals(JSON_SER_NAME_COMPACT, jconv.ToJson(name1))
		
	End Method

	Method testIndent() { test }

		jconv = New TJConvBuilder.WithIndent(2).Build()

		Local name1:TSName = New TSName
		name1.a = "one"
		name1.b = "two"
		name1.c = "three"
		
		assertEquals(JSON_SER_NAME_PRETTY, jconv.ToJson(name1))
		
	End Method

	Method testDepth() { test }
	
		Local deep:TDeep = New TDeep
		deep.inner = New TInner
		deep.inner.deepest = New TDeepest
		deep.inner.deepest.option1 = New TBool(True)
				
	End Method

	Method testTransient() { test }
		
		Local trans:TTransient = New TTransient
		trans.a = "one"
		trans.b = "two"
		trans.c = "three"
		
		assertEquals(JSON_TRANS_NO_B, jconv.ToJson(trans))
		
		trans = TTransient(jconv.FromJson(JSON_TRANS, "TTransient"))
		assertEquals("one", trans.a)
		assertNull(trans.b)
		assertEquals("three", trans.c)
	End Method

	Method testIgnored() { test }
		
		Local ignored:TIgnored = New TIgnored
		ignored.a = "one"
		ignored.b = "two"
		ignored.c = "three"
		ignored.d = "four"
		
		assertEquals(JSON_IGNORE_SER, jconv.ToJson(ignored))
		
		ignored = TIgnored(jconv.FromJson(JSON_IGNORE, "TIgnored"))
		assertEquals("one", ignored.a)
		assertEquals("two", ignored.b)
		assertNull(ignored.c)
		assertNull(ignored.d)
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

Type TTypes

	Field fByte:Byte = 1
	Field fShort:Short = 2
	Field fInt:Int = 3
	Field fUInt:UInt = 4
	Field fLong:Long = 5
	Field fULong:ULong = 6
	Field fSizeT:Size_T = 7
	Field fFloat:Float = 8
	Field fDouble:Double = 9
	Field fString:String = "10"
	
	Field fObject:TEmbedded = New TEmbedded(1, 2, 3)
End Type

Type TEmbedded

	Field x:Int
	Field y:Int
	Field z:Int
	
	Method New(x:Int, y:Int, z:Int)
		Self.x = x
		Self.y = y
		Self.z = z
	End Method

End Type

Type TEmbeddedSerializer Extends TJConvSerializer

	Method Serialize:TJSON(source:Object, sourceType:String)
		Local embedded:TEmbedded = TEmbedded(source)
		
		Local json:TJSONObject = New TJSONObject.Create()
		
		json.Set("z", embedded.z)
		json.Set("y", embedded.y)
		json.Set("x", embedded.x)
		
		Return json
	End Method

End Type

Type TContainer
	Field box:TBox
	
	Method New(box:TBox)
		Self.box = box
	End Method
End Type

Type TBox

	Field x:Int
	Field y:Int
	Field w:Int
	Field h:Int

	Method New(x:Int, y:Int, w:Int, h:Int)
		Self.x = x
		Self.y = y
		Self.w = w
		Self.h = h
	End Method

End Type

Type TBoxSerializer Extends TJConvSerializer

	Method Serialize:TJSON(source:Object, sourceType:String)
		Local box:TBox = TBox(source)

		Local json:TJSONString = New TJSONString.Create(box.x + "," + box.y + "," + box.w + "," + box.h)
				
		Return json
	End Method

	Method Deserialize:Object(json:TJSON, typeId:TTypeId, obj:Object)

		If TJSONString(json) Then
			If Not obj Then
				obj = New TBox
			End If
			Local box:TBox = TBox(obj)
			
			Local parts:String[] = TJSONString(json).Value().Split(",")
			box.x = parts[0].ToInt()
			box.y = parts[1].ToInt()
			box.w = parts[2].ToInt()
			box.h = parts[3].ToInt()
		End If

		Return obj
	End Method
	
End Type

Type TSName

	Field a:String { serializedName="name" }
	Field b:String { serializedName="name1" alternateName="name2,name3" }
	Field c:String

End Type

Type TWithBool

	Field onOff:Int

End Type

Type TBoxed

	Field b1:TBool
	Field b2:TByte
	Field b3:TShort
	Field b4:TInt
	Field b5:TUInt
	Field b6:TLong
	Field b7:TULong
	Field b8:TSize_T
	Field b9:TFloat
	Field b10:TDouble

End Type


Type TPrec

	Field p1:Float
	Field p2:Double

	Method New(p1:Float, p2:Double)
		Self.p1 = p1
		Self.p2 = p2
	End Method
	
End Type

Type TDeep

	Field inner:TInner

End Type

Type TInner

	Field deepest:TDeepest

End Type

Type TDeepest

	Field option1:TBool

End Type

Type TTransient
	Field a:String
	Field b:String { transient }
	Field c:String
End Type

Type TIgnored
	Field a:String
	Field b:String { noSerialize }
	Field c:String { noDeserialize }
	Field d:String { noSerialize noDeserialize }
End Type
