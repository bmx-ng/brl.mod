SuperStrict

Framework brl.standardio
Import brl.maxunit
Import brl.collections


New TTestSuite.run()

Type TQueueTest Extends TTest

	Method TestEnqueueDequeue() { test }
		Local queue:TQueue<Int> = New TQueue<Int>
		
		Local value:Int
		Local count:Int
		For Local i:Int = 0 Until 10
			queue.Enqueue(i)
			assertEquals(value, queue.Peek())
			count :+ 1
			assertEquals(count, queue.size)
		Next
		
		For Local i:Int = 0 Until 10
			assertEquals(count, queue.size)
			assertEquals(value, queue.Peek())
			
			assertEquals(value, queue.Dequeue())
			count :- 1
			value :+ 1

			assertEquals(count, queue.size)
		Next
		
		assertEquals(0, queue.size)
		assertTrue(queue.head = queue.tail)
	
	End Method

	Method TestClear() { test }
		Local queue:TQueue<Int> = New TQueue<Int>

		Local value:Int
		Local count:Int
		For Local i:Int = 0 Until 10
			queue.Enqueue(i)
			count :+ 1
		Next
		
		queue.Clear()
		assertEquals(0, queue.size)
		assertTrue(queue.head = queue.tail)
		
	End Method

End Type

Type TReverseStringComparator Implements IComparator<String>
    Method Compare:Int(a:String, b:String)
        If a = b Then Return 0
        If a > b Then Return -1
        Return 1
    End Method
End Type

Type TTreeMapTest Extends TTest

    Method TestEmpty() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        AssertEquals(0, m.Count(), "Empty map count = 0")
        AssertTrue(m.IsEmpty(), "Empty map IsEmpty()")
        ' iteration should be empty
        Local saw:Int = 0
        For Local n:TMapNode<String,String> = EachIn m
            saw :+ 1
        Next
        AssertEquals(0, saw, "No iteration items on empty map")
        ' ContainsKey/Remove/TryGetValue should be negative
        AssertTrue(Not m.ContainsKey("nope"), "Empty map does not contain key")
        AssertTrue(Not m.Remove("nope"), "Remove missing key returns False")
        Local out:String = "untouched"
        AssertTrue(Not m.TryGetValue("nope", out), "TryGetValue missing returns False")
        AssertEquals("untouched", out, "TryGetValue leaves out var unchanged when missing")
    End Method

    Method TestAddAndCount() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        m.Add("b","bee")
        m.Add("a","aye")
        m.Add("c","see")
        AssertEquals(3, m.Count(), "Count after three adds")
        AssertTrue(m.ContainsKey("a") And m.ContainsKey("b") And m.ContainsKey("c"), "ContainsKey after add")
    End Method

    Method TestAddDuplicateThrows() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        m.Add("x","one")
        Local threw:Int = False
        Try
            m.Add("x","two")
        Catch e:TArgumentException
            threw = True
        End Try
        AssertTrue(threw, "Add duplicate throws TArgumentException")
        ' value should remain the original (since Add should not overwrite)
        AssertEquals("one", m["x"], "Duplicate Add did not overwrite")
    End Method

    Method TestPutOverwriteAndReturnOld() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        Local old:String = m.Put("k","v1")
        AssertTrue(old = Null, "Put on new key returns Null (default)")
        AssertEquals("v1", m["k"], "Put inserted value")
        old = m.Put("k","v2")
        AssertEquals("v1", old, "Put returns old value on overwrite")
        AssertEquals("v2", m["k"], "Put overwrote value")
    End Method

    Method TestContainsValueAndTryGet() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        m.Add("a","1")
        m.Add("b","2")
        m.Add("c","3")
        AssertTrue(m.ContainsValue("2"), "ContainsValue positive")
        AssertTrue(Not m.ContainsValue("9"), "ContainsValue negative")

        Local v:String = "x"
        AssertTrue(m.TryGetValue("b", v), "TryGetValue found")
        AssertEquals("2", v, "TryGetValue output correct")
        v = "unchanged"
        AssertTrue(Not m.TryGetValue("z", v), "TryGetValue missing")
        AssertEquals("unchanged", v, "TryGetValue leaves var unchanged on miss")
    End Method

    Method TestIndexerGetSet() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        m["a"] = "alpha"
        AssertEquals("alpha", m["a"], "Indexer set then get")
        ' get of missing returns Null/default
        Local got:String = m["b"]
        AssertTrue(got = Null, "Indexer get of missing returns Null")
        ' setting existing key updates
        m["a"] = "ALPHA"
        AssertEquals("ALPHA", m["a"], "Indexer update existing")
    End Method

    Method TestRemoveMissingAndLeafOneChildTwoChildren() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        ' missing
        AssertTrue(Not m.Remove("x"), "Remove missing on empty returns False")

        ' build small tree
        m.Add("b","bee")
        m.Add("a","aye")
        m.Add("d","dee")
        m.Add("c","see")
        m.Add("e","eee")

        ' leaf: "a" should be a leaf in this shape
        AssertTrue(m.Remove("a"), "Remove leaf returns True")
        AssertTrue(Not m.ContainsKey("a"), "Leaf key gone")
        AssertEquals(4, m.Count(), "Count after leaf removal")

        ' one child: "d" has left child "c" (with "e" still present), after removing we still have "c","b","e"
        AssertTrue(m.Remove("d"), "Remove node with one child")
        AssertTrue(Not m.ContainsKey("d"), "One-child key gone")
        AssertEquals(3, m.Count(), "Count after one-child removal")

        ' two children: remove "b" (should have children "c" and maybe something to right)
        AssertTrue(m.Remove("b"), "Remove node with two children")
        AssertTrue(Not m.ContainsKey("b"), "Two-children key gone")
        AssertEquals(2, m.Count(), "Count after two-children removal")

        ' remaining should be sorted: "c","e"
        Local prev:String = Null
        For Local n:TMapNode<String,String> = EachIn m
            If prev <> Null Then AssertTrue(prev <= n.key, "In-order after removals")
            prev = n.key
        Next
    End Method

    Method TestIterationOrderSorted() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        Local keys:String[] = ["j","a","m","b","l","i","z","x","c","k"]
        For Local k:String = EachIn keys
            m.Add(k, k.ToUpper())
        Next
        Local prev:String = Null
        For Local n:TMapNode<String,String> = EachIn m
            If prev <> Null Then
                AssertTrue(prev <= n.key, "Keys are yielded in non-decreasing order")
            End If
            prev = n.key
        Next
        AssertEquals(m.Count(), 10, "Count after bulk add")
    End Method

    Method TestKeysAndValuesCollections() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        m.Add("b","2")
        m.Add("a","1")
        m.Add("c","3")

        Local ks:ICollection<String> = m.Keys()
        Local vs:ICollection<String> = m.Values()
        AssertEquals(3, ks.Count(), "Keys.Count")
        AssertEquals(3, vs.Count(), "Values.Count")

        ' Keys should be in-order: a,b,c
        Local expectK:String[] = ["a","b","c"]
        Local i:Int = 0
        For Local k:String = EachIn ks
            AssertEquals(expectK[i], k, "Keys iteration order")
            i :+ 1
        Next

        ' Values should correspond to in-order keys: 1,2,3
        Local expectV:String[] = ["1","2","3"]
        i = 0
        For Local v:String = EachIn vs
            AssertEquals(expectV[i], v, "Values iteration order aligned with keys")
            i :+ 1
        Next
    End Method

    Method TestClear() { test }
        Local m:TTreeMap<String,String> = New TTreeMap<String,String>
        m.Add("a","1"); m.Add("b","2"); m.Add("c","3")
        AssertEquals(3, m.Count(), "Precondition count")
        m.Clear()
        AssertEquals(0, m.Count(), "Count after Clear")
        AssertTrue(m.IsEmpty(), "IsEmpty after Clear")
        AssertTrue(Not m.ContainsKey("a"), "No keys after Clear")
    End Method

    Method TestCustomComparatorReverseOrder() { test }
        Local cmp:TReverseStringComparator = New TReverseStringComparator
        Local m:TTreeMap<String,Int> = New TTreeMap<String,Int>(cmp)
        m.Add("a",1); m.Add("b",2); m.Add("c",3)
        ' iteration should now be c,b,a
        Local expect:String[] = ["c","b","a"]
        Local i:Int = 0
        For Local n:TMapNode<String,Int> = EachIn m
            AssertEquals(expect[i], n.key, "Custom comparator iteration order")
            i :+ 1
        Next
    End Method

    Method TestFuzzInsertRemoveAndOrder() { test }
        Local m:TTreeMap<Int,Int> = New TTreeMap<Int,Int>
        ' Insert a bunch of pseudo-random values with stable seed
        Local seed:Int = 12345
        For Local i:Int = 1 Until 100
            seed = (seed * 1103515245 + 12345) & $7fffffff
            Local k:Int = seed Mod 200
            m.Put(k, k) ' Put to allow duplicates silently update
        Next
        ' Check sorted iteration
        Local first:Int = True
        Local prev:Int = 0
        For Local n:TMapNode<Int,Int> = EachIn m
            If Not first Then AssertTrue(prev <= n.key, "In-order after fuzz inserts")
            prev = n.key
            first = False
        Next

        ' Remove a handful and ensure they are gone, order preserved
        For Local k:Int = 0 To 50 Step 5
            m.Remove(k)
            AssertTrue(Not m.ContainsKey(k), "Key removed in fuzz")
        Next

        Local prev2:Int = -2147483648
        For Local n2:TMapNode<Int,Int> = EachIn m
            AssertTrue(prev2 <= n2.key, "In-order after fuzz removals")
            prev2 = n2.key
        Next
    End Method

End Type
