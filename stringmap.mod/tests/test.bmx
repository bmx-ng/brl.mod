SuperStrict

Framework Brl.Standardio
Import Brl.StringMap
Import Brl.MaxUnit

New TTestSuite.run()

Type TStringMapTest Extends TTest

	' Simple value types for typed Values() filtering tests
	Type TFruit
		Field name:String
		Method New(n:String)
			name = n
		End Method
		Method ToString:String()
			Return "TFruit(" + name + ")"
		End Method
	End Type

	Type TVeg
		Field name:String
		Method New(n:String)
			name = n
		End Method
		Method ToString:String()
			Return "TVeg(" + name + ")"
		End Method
	End Type

	' Helpers
	Method AsSet:String[](arr:String[])  ' returns unique set sorted for stable comparison
		Local m:TStringMap = New TStringMap()
		For Local s:String = EachIn arr
			m.Insert(s, Null)
		Next
		Local out:String[]; Local i:Int
		For Local s:String = EachIn m.Keys()
			out = out[..i+1]; out[i] = s; i :+ 1
		Next
		out.Sort(True) ' ascending
		Return out
	End Method

	Method AssertStringSetEquals(expected:String[], actual:String[], msg:String)
		expected = AsSet(expected)
		actual = AsSet(actual)
		assertEquals(expected.Length, actual.Length, msg + " (size)")
		For Local i:Int = 0 Until expected.Length
			assertEquals(expected[i], actual[i], msg + " (elt " + i + ")")
		Next
	End Method

	' ---------- Construction & emptiness ----------
	Method testConstructorsAndEmpty() { test }
		Local m:TStringMap = New TStringMap() ' default CS
		assertTrue(m.IsEmpty(), "New() should be empty")

		Local ci:TStringMap = New TStringMap(False) ' CI map
		assertTrue(ci.IsEmpty(), "New(False) should be empty")

		m.Insert("a", "1")
		assertFalse(m.IsEmpty(), "IsEmpty false after insert")
		m.Clear()
		assertTrue(m.IsEmpty(), "IsEmpty true after Clear")
	End Method

	' ---------- Insert / Contains / ValueForKey / Operator[] ----------
	Method testInsertAndLookupCS() { test }
		Local m:TStringMap = New TStringMap() ' Case-sensitive
		m.Insert("Foo", "A")
		m.Insert("Bar", "B")

		assertTrue(m.Contains("Foo"), "Contains should find exact key")
		assertFalse(m.Contains("foo"), "CS: different case not found")

		assertEquals("A", String(m.ValueForKey("Foo")), "ValueForKey exact hit")

		Local out:Object
		assertEquals(True, m.ValueForKey("Bar", out), "ValueForKey(out) returns True on hit")
		assertEquals("B", String(out), "ValueForKey(out) populates value")
		assertEquals(False, m.ValueForKey("baz", out), "ValueForKey(out) returns False on miss")
		assertEquals(Null, m["baz"], "Operator[] returns Null on miss (assumed)")

		' Overwrite same key (same case)
		m.Insert("Foo", "A2")
		assertEquals("A2", String(m["Foo"]), "Insert overwrites existing value (same case)")
	End Method

	Method testInsertAndLookupCI() { test }
		Local m:TStringMap = New TStringMap(False) ' Case-insensitive
		m.Insert("Foo", "A")
		m.Insert("BAR", "B")

		assertTrue(m.Contains("foo"), "CI: Contains is case-insensitive")
		assertTrue(m.Contains("bar"), "CI: Contains is case-insensitive (2)")

		assertEquals("A", String(m["FOO"]), "CI: Operator[] retrieves regardless of case")
		assertEquals("B", String(m.ValueForKey("bar")), "CI: ValueForKey retrieves regardless of case")

		' Overwrite using different case
		m.Insert("fOO", "A3")
		assertEquals("A3", String(m["foo"]), "CI: Insert with different case overwrites same logical key")

		' Minimal Unicode sanity under CI
		m.Insert("CAFÉ", "X")
		assertEquals("X", String(m["café"]), "CI: Unicode simple fold works (CAFÉ ~~ café)")
	End Method

	' ---------- Remove ----------
	Method testRemove() { test }
		Local m:TStringMap = New TStringMap(False) ' CI for convenience
		m.Insert("Key1", "v1")
		m.Insert("Key2", "v2")

		assertEquals(True, m.Remove("key1"), "CI: Remove returns True for existing key")
		assertFalse(m.Contains("Key1"), "Removed key is gone")
		assertEquals(False, m.Remove("missing"), "Remove on non-existent returns False")

		' Removing with different case in CS map
		Local cs:TStringMap = New TStringMap()
		cs.Insert("Foo", "A")
		assertEquals(False, cs.Remove("foo"), "CS: Remove with different case should fail")
		assertTrue(cs.Contains("Foo"), "CS: Original key still present")
	End Method

	' ---------- Keys() & Values() enumeration ----------
	Method testEnumerationKeysValues() { test }
		Local m:TStringMap = New TStringMap()
		m.Insert("Alpha", "1")
		m.Insert("beta", "2")
		m.Insert("Gamma", "3")

		' Gather keys/values via enumerators (order is unspecified)
		Local keys:String[]; Local i:Int
		For Local k:String = EachIn m.Keys()
			keys = keys[..i+1]; keys[i] = k; i :+ 1
		Next
		AssertStringSetEquals(["Alpha","beta","Gamma"], keys, "Keys() enumerates all keys once")

		Local vals:String[]; Local j:Int
		For Local v:Object = EachIn m.Values()
			vals = vals[..j+1]; vals[j] = String(v); j :+ 1
		Next
		AssertStringSetEquals(["1","2","3"], vals, "Values() enumerates all values once")
	End Method

	' ---------- Typed Values() filtering ----------
	Method testTypedValuesFiltering() { test }
		Local m:TStringMap = New TStringMap()
		m.Insert("apple", New TFruit("apple"))
		m.Insert("carrot", New TVeg("carrot"))
		m.Insert("banana", New TFruit("banana"))

		' Only TFruit values should be yielded when enumerating as TFruit
		Local fruits:String[]; Local i:Int
		For Local f:TFruit = EachIn m.Values()
			fruits = fruits[..i+1]; fruits[i] = f.name; i :+ 1
		Next
		AssertStringSetEquals(["apple","banana"], fruits, "Typed Values() yields only matching type")

		' And only TVeg for TVeg enumeration
		Local vegs:String[]; Local j:Int
		For Local v:TVeg = EachIn m.Values()
			vegs = vegs[..j+1]; vegs[j] = v.name; j :+ 1
		Next
		AssertStringSetEquals(["carrot"], vegs, "Typed Values() yields only TVeg")
	End Method

	' ---------- ObjectEnumerator() yields TStringKeyValue ----------
	Method testObjectEnumeratorPairs() { test }
		Local m:TStringMap = New TStringMap(False)
		m.Insert("x", "1")
		m.Insert("y", "2")

		Local seenKeys:String[]; Local seenVals:String[]
		Local i:Int; Local j:Int

		For Local kv:TStringKeyValue = EachIn m
			seenKeys = seenKeys[..i+1]; seenKeys[i] = kv.Key(); i :+ 1
			seenVals = seenVals[..j+1]; seenVals[j] = String(kv.Value()); j :+ 1
		Next

		AssertStringSetEquals(["x","y"], seenKeys, "ObjectEnumerator keys")
		AssertStringSetEquals(["1","2"], seenVals, "ObjectEnumerator values")
	End Method

	' ---------- Operator[] and []= sugar ----------
	Method testIndexers() { test }
		Local m:TStringMap = New TStringMap()
		m["Foo"] = "A"
		assertEquals(True, m.Contains("Foo"), "[]= inserts key")
		assertEquals("A", String(m["Foo"]), "[] retrieves value")

		m["Foo"] = "B"
		assertEquals("B", String(m["Foo"]), "[]= overwrites existing value")

		' CI map: index with mixed case
		Local ci:TStringMap = New TStringMap(False)
		ci["Bar"] = "X"
		assertEquals("X", String(ci["bar"]), "CI [] lookups are case-insensitive")
	End Method

	' ---------- Copy semantics ----------
	Method testCopyIndependence() { test }
		Local m:TStringMap = New TStringMap(False)
		Local shared:Object = New TFruit("shared")
		m.Insert("A", shared)
		m.Insert("B", "Bval")

		Local copy:TStringMap = m.Copy()

		' Same content now
		assertTrue(copy.Contains("a"), "Copy contains key A (CI)")
		assertEquals("Bval", String(copy["b"]), "Copy contains key B value")

		' Shallow copy of values (same object reference)
		'assertTrue(Object(copy["a"]) Is shared, "Copy holds same object reference (shallow)")

		' Independence of maps: mutate copy, original unaffected
		copy.Insert("C", "Cval")
		copy.Remove("B")
		assertFalse(m.Contains("c"), "Original unaffected by additions to copy")
		assertTrue(m.Contains("b"), "Original unaffected by removals from copy")

		' Mutate original, copy unaffected
		m["D"] = "Dval"
		assertFalse(copy.Contains("d"), "Copy unaffected by mutations to original")
	End Method

	' ---------- Clear & iteration on empty ----------
	Method testClearAndEmptyEnumerations() { test }
		Local m:TStringMap = New TStringMap()
		m.Insert("x", "1")
		m.Clear()
		assertTrue(m.IsEmpty(), "IsEmpty after Clear")

		Local count:Int = 0
		For Local k:String = EachIn m.Keys()
			count :+ 1
		Next
		assertEquals(0, count, "Keys() over empty yields 0")

		count = 0
		For Local v:Object = EachIn m.Values()
			count :+ 1
		Next
		assertEquals(0, count, "Values() over empty yields 0")

		count = 0
		For Local kv:TStringKeyValue = EachIn m
			count :+ 1
		Next
		assertEquals(0, count, "ObjectEnumerator() over empty yields 0")
	End Method

End Type
