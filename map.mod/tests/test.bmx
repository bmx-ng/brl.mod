SuperStrict

Framework brl.standardio
Import brl.map
Import BRL.MaxUnit

New TTestSuite.run()

Type TIntMapTest Extends TTest

	Method test() { test }

		Local map:TIntMap = New TIntMap

		Local count:Int

		For Local key:TIntKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "initial empty count")

		map.Insert(1, "One")
		map.Insert(-1, "Two")
		map.Insert($7fffffff, "Three")

		count = 0

		For Local key:TIntKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(3, count, "count after inserts")

		AssertNotNull(map.ValueForKey($7fffffff))
		AssertNotNull(map.ValueForKey(-1))
		AssertNull(map.ValueForKey(0))
		AssertNull(map.ValueForKey(2))

		AssertTrue(map.Remove($7fffffff), "key removed")
		AssertFalse(map.Remove($7fffffff), "key not found")

		count = 0

		map.Clear()
		map.Clear()

		For Local key:TIntKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after clear")

		map.Insert(4, "Four")

		count = 0

		For Local key:TIntKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(1, count, "count after insert")

		AssertTrue(map.Remove(4))

		count = 0

		For Local key:TIntKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after last remove")

	End Method


End Type

Type TStringMapTest Extends TTest

	Method test() { test }

		Local map:TStringMap = New TStringMap

		Local count:Int

		For Local key:TIntKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "initial empty count")

		map.Insert("one", "One")
		map.Insert("two", "Two")
		map.Insert("three", "Three")

		count = 0

		For Local key:String = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(3, count, "count after inserts")

		AssertNotNull(map.ValueForKey("one"))
		AssertNotNull(map.ValueForKey("three"))
		AssertNull(map.ValueForKey("six"))
		AssertNull(map.ValueForKey("123"))

		AssertTrue(map.Remove("two"), "key removed")
		AssertFalse(map.Remove("two"), "key not found")

		count = 0

		map.Clear()
		map.Clear()

		For Local key:String = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after clear")

		map.Insert("four", "Four")

		count = 0

		For Local key:String = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(1, count, "count after insert")

		AssertTrue(map.Remove("four"))

		count = 0

		For Local key:String = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after last remove")

	End Method

End Type

Type TPtrMapTest Extends TTest

	Method test() { test }

		Local map:TPtrMap = New TPtrMap

		Local count:Int

		For Local key:TPtrKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "initial empty count")

		map.Insert(Byte Ptr(12345), "One")
		map.Insert(Byte Ptr(2222), "Two")
		map.Insert(Byte Ptr(100), "Three")

		count = 0

		For Local key:TPtrKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(3, count, "count after inserts")

		AssertNotNull(map.ValueForKey(Byte Ptr(12345)))
		AssertNotNull(map.ValueForKey(Byte Ptr(100)))
		AssertNull(map.ValueForKey(Byte Ptr(42)))
		AssertNull(map.ValueForKey(Byte Ptr(900000)))

		AssertTrue(map.Remove(Byte Ptr(2222)), "key removed")
		AssertFalse(map.Remove(Byte Ptr(2222)), "key not found")

		count = 0

		map.Clear()
		map.Clear()

		For Local key:TPtrKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after clear")

		map.Insert(Byte Ptr(440000), "Four")

		count = 0

		For Local key:TPtrKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(1, count, "count after insert")

		AssertTrue(map.Remove(Byte Ptr(440000)))

		count = 0

		For Local key:TPtrKey = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after last remove")

	End Method


End Type

Type TObj
	Field value:Int
	Method New(value:Int)
		Self.value = value
	End Method

	Method Compare:Int(other:Object)
		Local obj:TObj = TObj(other)
		If Not obj Then
			Return -1
		End If
		If value < obj.value Then
			Return -1
		Else if value > obj.value Then
			Return 1
		End If
		Return 0
	End Method
End Type

Type TObjectMapTest Extends TTest

	Method test() { test }

		Local map:TObjectMap = New TObjectMap

		Local count:Int

		For Local key:Object = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "initial empty count")

		Local obj1:TObj = New TObj(1)
		Local obj2:TObj = New TObj(2)
		Local s3:String = "three"
		Local obj4:TObj = New TObj(4)
		Local obj1a:TObj = New TObj(1)

		Local obj11:TObj = New TObj(11)
		Local obj12:TObj = New TObj(12)

		map.Insert(obj1, "One")
		map.Insert(obj2, "Two")
		map.Insert(s3, "Three") ' mixed objects/Strings

		count = 0

		For Local key:Object = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(3, count, "count after inserts")

		AssertNotNull(map.ValueForKey(obj1))
		AssertNotNull(map.ValueForKey(obj1a)) ' different obj same compare
		AssertNotNull(map.ValueForKey("three"))
		AssertNull(map.ValueForKey(obj11))
		AssertNull(map.ValueForKey(obj12))

		AssertTrue(map.Remove(obj2), "key removed")
		AssertFalse(map.Remove(obj2), "key not found")

		count = 0

		map.Clear()

		For Local key:Object = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after clear")

		map.Clear() ' multiple cleans are ok

		map.Insert(obj4, "Four")

		count = 0

		For Local key:Object = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(1, count, "count after insert")

		AssertTrue(map.Remove(obj4))

		count = 0

		For Local key:Object = Eachin map.Keys()
			count :+ 1
		Next

		AssertEquals(0, count, "count after last remove")

	End Method

End Type
