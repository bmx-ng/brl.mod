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

Type TSetTest Extends TTest

	' ---------- Basics ----------
	Method TestEmpty() { test }
		Local s:TSet<String> = New TSet<String>
		AssertEquals(0, s.Count(), "Empty Count = 0")
		AssertTrue(s.IsEmpty(), "IsEmpty on empty set")
		AssertTrue(Not s.Contains("x"), "Contains on empty returns False")
		AssertTrue(Not s.Remove("x"), "Remove on empty returns False")

		' TryGetValue should return False and leave var unchanged
		Local out:String = "unchanged"
		AssertTrue(Not s.TryGetValue("x", out), "TryGetValue missing returns False")
		AssertEquals("unchanged", out, "TryGetValue leaves out var unchanged")
		
		' Iteration should be empty
		Local seen:Int = 0
		For Local e:String = EachIn s
			seen :+ 1
		Next
		AssertEquals(0, seen, "No iteration items on empty set")
	End Method

	Method TestAddContainsNoDuplicates() { test }
		Local s:TSet<String> = New TSet<String>
		AssertTrue(s.Add("b"), "Add first time returns True")
		AssertTrue(s.Add("a"), "Add second distinct returns True")
		AssertTrue(s.Add("c"), "Add third distinct returns True")
		AssertEquals(3, s.Count(), "Count after adds")
		AssertTrue(s.Contains("a") And s.Contains("b") And s.Contains("c"), "Contains after adds")
		AssertTrue(Not s.Add("b"), "Add duplicate returns False")
		AssertEquals(3, s.Count(), "No duplicate growth")
	End Method

	' ---------- Removal ----------
	Method TestRemoveVariants() { test }
		Local s:TSet<String> = New TSet<String>
		' Build a small shape that tends to exercise leaf/one-child/two-children
		For Local k:String = EachIn ["b","a","d","c","e"]
			s.Add(k)
		Next
		AssertEquals(5, s.Count(), "Precondition Count=5")

		' Remove leaf (likely "a")
		AssertTrue(s.Remove("a"), "Remove leaf returns True")
		AssertTrue(Not s.Contains("a"), "Leaf removed")
		AssertEquals(4, s.Count(), "Count after leaf removal")

		' Remove node with one child (likely "d")
		AssertTrue(s.Remove("d"), "Remove one-child returns True")
		AssertTrue(Not s.Contains("d"), "One-child removed")
		AssertEquals(3, s.Count(), "Count after one-child removal")

		' Remove node with two children (likely "b")
		AssertTrue(s.Remove("b"), "Remove two-children returns True")
		AssertTrue(Not s.Contains("b"), "Two-children removed")
		AssertEquals(2, s.Count(), "Count after two-children removal")

		' Remaining should be sorted ascending: c, e
		Local expect:String[] = ["c","e"]
		Local i:Int = 0
		For Local e:String = EachIn s
			AssertEquals(expect[i], e, "In-order after removals")
			i :+ 1
		Next
	End Method

	' ---------- Order / iteration ----------
	Method TestIterationOrderSorted() { test }
		Local s:TSet<String> = New TSet<String>
		For Local k:String = EachIn ["j","a","m","b","l","i","z","x","c","k"]
			s.Add(k)
		Next
		Local prev:String = Null
		For Local e:String = EachIn s
			If prev <> Null Then
				AssertTrue(prev <= e, "Monotonic non-decreasing iteration order")
			End If
			prev = e
		Next
		AssertEquals(10, s.Count(), "Count after bulk adds (no dups)")
	End Method

	' ---------- TryGetValue ----------
	Method TestTryGetValue() { test }
		Local s:TSet<String> = New TSet<String>
		For Local k:String = EachIn ["a","b","c"]
			s.Add(k)
		Next

		Local out:String = ""
		AssertTrue(s.TryGetValue("b", out), "TryGetValue existing returns True")
		AssertEquals("b", out, "TryGetValue returns equal stored value")

		out = "keep"
		AssertTrue(Not s.TryGetValue("z", out), "TryGetValue missing returns False")
		AssertEquals("keep", out, "TryGetValue leaves var unchanged for missing")
	End Method

	' ---------- Views ----------
	Method TestViewBetweenAndMutability() { test }
		Local s:TSet<String> = New TSet<String>
		For Local k:String = EachIn ["a","b","c","d","e","f"]
			s.Add(k)
		Next

		Local sub:TSet<String> = s.ViewBetween("b","d") ' expect b,c,d
		' Read via view
		Local seen:String[] = []
		For Local e:String = EachIn sub
			seen :+ [e]
		Next
		AssertEquals(3, seen.Length, "Subset size b..d inclusive is 3")
		AssertEquals("b", seen[0], "Subset[0]=b")
		AssertEquals("c", seen[1], "Subset[1]=c")
		AssertEquals("d", seen[2], "Subset[2]=d")

		' Mutate through view: remove "c"
		AssertTrue(sub.Remove("c"), "Remove via view")
		AssertTrue(Not s.Contains("c"), "Underlying set reflects view removal")

		' Removing outside the view via the view should fail or be no-op.
		' We only require: removing "a" from s should still work, and view should remain consistent.
		AssertTrue(s.Remove("a"), "Remove outside of view via main set")
		AssertTrue(Not s.Contains("a"), "Main set no longer has 'a'")
		AssertTrue(Not sub.Contains("a"), "View does not contain 'a'")
	End Method

	' ---------- Set algebra ----------
	Method TestUnionIntersectionSymmetricDifference() { test }
		Local a:TSet<Int> = New TSet<Int>
		Local b:TSet<Int> = New TSet<Int>
		For Local i:Int = 1 To 5
			a.Add(i)            ' {1,2,3,4,5}
		Next
		For Local j:Int = 4 To 8
			b.Add(j)            ' {4,5,6,7,8}
		Next

		' Intersection (in-place on a): now {4,5}
		Local a1:TSet<Int> = New TSet<Int>
		For Local i:Int = 1 To 5; a1.Add(i); Next
		a1.Intersection(b)
		AssertEquals(2, a1.Count(), "Intersection count")
		AssertTrue(a1.Contains(4) And a1.Contains(5), "Intersection elements")

		' UnionOf (in-place on a): {1..8}
		Local a2:TSet<Int> = New TSet<Int>
		For Local i:Int = 1 To 5; a2.Add(i); Next
		a2.UnionOf(b)
		AssertEquals(8, a2.Count(), "Union count {1..8}")
		For Local k:Int = 1 To 8
			AssertTrue(a2.Contains(k), "Union contains " + k)
		Next

		' SymmetricDifference (in-place on a): {1,2,3,6,7,8}
		Local a3:TSet<Int> = New TSet<Int>
		For Local i:Int = 1 To 5; a3.Add(i); Next
		a3.SymmetricDifference(b)
		Local expect:Int[] = [1,2,3,6,7,8]
		AssertEquals(expect.Length, a3.Count(), "SymDiff count")
		For Local v:Int = EachIn expect
			AssertTrue(a3.Contains(v), "SymDiff contains " + v)
		Next
		AssertTrue(Not a3.Contains(4) And Not a3.Contains(5), "SymDiff excludes intersection")
	End Method

	' ---------- Subset/superset (including proper) ----------
	Method TestSubsetSupersetProper() { test }
		Local a:TSet<Int> = New TSet<Int>
		Local b:TSet<Int> = New TSet<Int>
		For Local i:Int = 1 To 3; a.Add(i); Next           ' {1,2,3}
		For Local i:Int = 1 To 5; b.Add(i); Next           ' {1,2,3,4,5}

		AssertTrue(a.IsSubsetOf(b), "a ⊆ b")
		AssertTrue(Not a.IsSupersetOf(b), "a ⊇ b false")
		AssertTrue(b.IsSupersetOf(a), "b ⊇ a")
		AssertTrue(Not b.IsSubsetOf(a), "b ⊆ a false")

		AssertTrue(a.IsProperSubsetOf(b), "a ⊂ b proper")
		AssertTrue(Not b.IsProperSubsetOf(a), "b ⊄ a")
		AssertTrue(b.IsProperSupersetOf(a), "b ⊃ a proper")
		AssertTrue(Not a.IsProperSupersetOf(b), "a ⊅ b")

		' Empty set edge cases
		Local e:TSet<Int> = New TSet<Int>
		AssertTrue(e.IsSubsetOf(a), "∅ ⊆ a")
		AssertTrue(e.IsProperSubsetOf(a), "∅ ⊂ a (a non-empty)")
		AssertTrue(a.IsSupersetOf(e), "a ⊇ ∅")
		AssertTrue(a.IsProperSupersetOf(e), "a ⊃ ∅ (a non-empty)")
		' ∅ proper superset of ∅ is false; plain superset is true
		Local e2:TSet<Int> = New TSet<Int>
		AssertTrue(e.IsSupersetOf(e2), "∅ ⊇ ∅")
		AssertTrue(Not e.IsProperSupersetOf(e2), "∅ ⊃ ∅ is false")
		AssertTrue(e.IsSubsetOf(e2), "∅ ⊆ ∅")
		AssertTrue(Not e.IsProperSubsetOf(e2), "∅ ⊂ ∅ is false")
	End Method

	' ---------- Overlaps ----------
	Method TestOverlaps() { test }
		Local a:TSet<String> = New TSet<String>
		Local b:TSet<String> = New TSet<String>
		For Local k:String = EachIn ["a","b","c"]; a.Add(k); Next
		For Local k:String = EachIn ["x","y","z"]; b.Add(k); Next
		AssertTrue(Not a.Overlaps(b), "No overlap")
		b.Add("b")
		AssertTrue(a.Overlaps(b), "Overlap on 'b'")
	End Method

	' ---------- Complement ----------
	Method TestComplement() { test }
		Local a:TSet<Int> = New TSet<Int>
		Local b:TSet<Int> = New TSet<Int>
		For Local i:Int = 1 To 6; a.Add(i); Next       ' {1..6}
		For Local j:Int = 2 To 4; b.Add(j); Next       ' {2,3,4}
		a.Complement(b)                                 ' remove {2,3,4}
		AssertEquals(3, a.Count(), "Complement removed 3 elements")
		For Local v:Int = EachIn [1,5,6]
			AssertTrue(a.Contains(v), "Complement kept " + v)
		Next
		For Local v2:Int = EachIn [2,3,4]
			AssertTrue(Not a.Contains(v2), "Complement removed " + v2)
		Next
	End Method

	' ---------- Constructors ----------
	Method TestConstructorsArrayAndIterable() { test }
		Local arr:String[] = ["a","b","c","b","a"]
		Local s1:TSet<String> = New TSet<String>(arr)    ' from array (dedup)
		AssertEquals(3, s1.Count(), "Array ctor dedup count 3")

		' iterable ctor: use another set
		Local s2:TSet<String> = New TSet<String>(s1, Null)
		AssertEquals(3, s2.Count(), "Iterable ctor copied 3")
		For Local k:String = EachIn ["a","b","c"]
			AssertTrue(s2.Contains(k), "Iterable ctor contains " + k)
		Next
	End Method

	' ---------- ToArray ----------
	Method TestToArray() { test }
		Local s:TSet<Int> = New TSet<Int>
		For Local i:Int = 5 To 1 Step -1
			s.Add(i)
		Next
		Local a:Int[] = s.ToArray()
		AssertEquals(s.Count(), a.Length, "ToArray length matches Count")
		' Should be in-order ascending
		For Local i:Int = 0 Until a.Length - 1
			AssertTrue(a[i] <= a[i+1], "ToArray preserves sorted order")
		Next
	End Method

	' ---------- Custom comparator ----------
	Method TestCustomComparatorReverseOrder() { test }
		Local cmp:TReverseStringComparator = New TReverseStringComparator
		Local s:TSet<String> = New TSet<String>(cmp)
		For Local k:String = EachIn ["a","b","c"]
			s.Add(k)
		Next
		Local expect:String[] = ["c","b","a"]
		Local i:Int = 0
		For Local e:String = EachIn s
			AssertEquals(expect[i], e, "Reverse comparator iteration order")
			i :+ 1
		Next
	End Method

	' ---------- Fuzz / stability ----------
	Method TestFuzzInsertRemoveAndOrder() { test }
		Local s:TSet<Int> = New TSet<Int>
		Local seed:Int = 24681357
		For Local i:Int = 1 Until 200
			seed = (seed * 1103515245 + 12345) & $7fffffff
			Local k:Int = seed Mod 300
			s.Add(k) ' Add ignores dups
		Next
		' Order check
		Local first:Int = True
		Local prev:Int = 0
		For Local e:Int = EachIn s
			If Not first Then AssertTrue(prev <= e, "In-order after fuzz inserts")
			prev = e
			first = False
		Next

		' Remove a pattern of keys and re-check
		For Local k:Int = 0 To 150 Step 7
			s.Remove(k)
			AssertTrue(Not s.Contains(k), "Removed key " + k)
		Next

		Local prev2:Int = -2147483648
		For Local e2:Int = EachIn s
			AssertTrue(prev2 <= e2, "In-order after fuzz removals")
			prev2 = e2
		Next
	End Method

End Type
