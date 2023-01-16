SuperStrict

Framework brl.standardio
Import brl.ObjectList
Import BRL.MaxUnit

New TTestSuite.run()

Type TObjectListTest Extends TTest

	Method test() { test }

		Local list:TObjectList = New TObjectList
		'check inserts/counts
		AssertEquals(0, list.Count(), "initial empty count")

		list.AddLast("One")
		list.AddLast("Two")
		list.AddLast("Three")
		AssertEquals(3, list.Count(), "count after addLast")

		list.AddFirst("Zero")
		AssertEquals(4, list.Count(), "count after addFirst")

		'check retrievers
		AssertEquals("Zero", list.ValueAtIndex(0))

rem
		Try
			list.ValueAtIndex(-1)
		Catch e:string
			AssertEquals("Object index must be positive", e, "incorrect error string ValueAtIndex(negativeIndex)")
		End Try
		Try
			list.ValueAtIndex(4)
		Catch e:string
			AssertEquals("List index out of range", e, "incorrect error string ValueAtIndex(outOfRangeIndex)")
		End Try
endrem		
		
		'check removers
		AssertEquals("Zero", list.RemoveFirst(), "RemoveFirst()")
		AssertEquals("Three", list.RemoveLast(), "RemoveLast()")
		'add two "Threes" to check "Remove(value, removeAll)"
		list.AddLast("Three")
		list.AddLast("Three")
		AssertTrue(list.Remove("Three", True), "Remove(value, removeAll=True)")
		AssertEquals(2, list.Count(), "Remove(value, removeAll=True) did not remove all fitting elements")
		
		
		'check swap
		Local otherList:TObjectList = New TObjectList
		list.swap(otherList)
		AssertEquals(0, list.Count(), "Swap() failed swapping content in list")
		AssertEquals(2, otherList.Count(), "Swap() failed swapping content into otherList")
		'swap back
		list.swap(otherList)

		'check copy
		AssertEquals(2, list.Copy().Count(), "Copy() failed to copy content")
		
		'check reversion (content for now: "One", "Two")
		list.Reverse()
		AssertEquals("Two", list.First(), "Reverse() failed")
		'reverse back
		list.Reverse()

		otherList = list.Reversed()
		AssertEquals("Two", otherList.First(), "Reversed() failed")
		
		'check toArray
		Local arr:Object[] = list.ToArray()
		AssertEquals("One", arr[0], "ToArray() failed")
		AssertEquals("Two", arr[1], "ToArray() failed")

		
		'check sort
		list.AddLast("A")
		list.AddLast("Z")
		list.AddLast("B")
		list.AddLast("Y")
		list.AddLast("VeryLong")
		list.AddLast("EvenLonger")
		list.Sort()
		AssertEquals("A", list.ValueAtIndex(0), "Sort() failed")
		AssertEquals("B", list.ValueAtIndex(1), "Sort() failed")
		list.Sort(False)
		AssertEquals("Z", list.ValueAtIndex(0), "Sort(False) failed")
		AssertEquals("Y", list.ValueAtIndex(1), "Sort(False) failed")
		list.Sort(True, CompareFunc)
		AssertEquals("EvenLonger", list.ValueAtIndex(0), "Sort(True, CompareFunc) failed")
		AssertEquals("VeryLong", list.ValueAtIndex(1), "Sort(True, CompareFunc) failed")
	End Method


	Function CompareFunc:Int(o1:object, o2:object)
		'sort by length first (longer = first),
		'else sort by alphabet
		If ObjectIsString(o1) and ObjectIsString(o2)
			Local l:Int = len(String(o2)) - len(String(o1))
			If l <> 0 Return l
		EndIf
		
		If o1 < o2 Then
			Return -1
		Else if o1 > o2 Then
			Return 1
		End If
		Return 0
	End Function
End Type