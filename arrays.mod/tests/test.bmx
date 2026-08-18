SuperStrict

Framework BRL.MaxUnit
Import BRL.Arrays
Import BRL.Functions
Import BRL.Result
Import BRL.Sequence

New TTestSuite.Run()

Global ArrayVisitTotal:Int

Type TArrayMarker
	Field value:Int
End Type

Interface IArrayMarker
	Method Read:Int()
End Interface

Type TArrayInterfaceMarker Implements IArrayMarker
	Field value:Int
	Method Read:Int()
		Return value
	End Method
End Type

Struct SArrayPoint
	Field x:Int
	Field y:Int
End Struct

Type TArrayAlgorithmException Extends TBlitzException
End Type

Function ArrayEven:Int(value:Int)
	Return (value & 1) = 0
End Function

Function ArrayPositive:Int(value:Int)
	Return value > 0
End Function

Function ArrayDouble:Int(value:Int)
	Return value * 2
End Function

Function ArrayAdd:Int(total:Int, value:Int)
	Return total + value
End Function

Function ArrayStringLength:Int(value:String)
	Return value.Length
End Function

Function ArrayVisit(value:Int)
	ArrayVisitTotal :+ value
End Function

Function ArrayPointShift:SArrayPoint(value:SArrayPoint)
	value.x :+ 1
	value.y :+ 2
	Return value
End Function

Type TArraysTest Extends TTest

	Method MapIsEagerOrderedAndIndependent() { test }
		Local calls:Int
		Local offset:Int = 10
		Local source:Int[] = [1, 2, 3]
		Local mapper:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value + offset
		End Function
		Local mapped:Int[] = Map<Int, Int>(source, mapper)
		AssertEquals(3, calls)
		AssertEquals(11, mapped[0])
		AssertEquals(13, mapped[2])
		source[0] = 99
		AssertEquals(11, mapped[0])
	End Method

	Method MapSupportsThinFunctionsAndValueCategories() { test }
		Local lengths:Int[] = Map<String, Int>(["a", "abcd"], ArrayStringLength)
		AssertEquals(1, lengths[0])
		AssertEquals(4, lengths[1])

		Local point:SArrayPoint
		point.x = 3
		point.y = 4
		Local shifted:SArrayPoint[] = Map<SArrayPoint, SArrayPoint>([point], ArrayPointShift)
		AssertEquals(4, shifted[0].x)
		AssertEquals(6, shifted[0].y)

		Local nested:Int[][] = [[1, 2], [3]]
		Local nestedIdentity:Closure<Int[](value:Int[])> = Function:Int[](value:Int[])
			Return value
		End Function
		Local sameNested:Int[][] = Map<Int[], Int[]>(nested, nestedIdentity)
		AssertSame(nested[0], sameNested[0])
	End Method

	Method FilterInvokesOnceAndAlwaysCopies() { test }
		Local calls:Int
		Local source:Int[] = [1, 2, 3, 4]
		Local predicate:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value >= 2
		End Function
		Local selected:Int[] = Filter<Int>(source, predicate)
		AssertEquals(4, calls)
		AssertEquals(3, selected.Length)
		AssertEquals(2, selected[0])
		source[1] = 99
		AssertEquals(2, selected[0])

		Local copied:Int[] = Filter<Int>(source, ArrayPositive)
		AssertEquals(source.Length, copied.Length)
		copied[0] = 77
		AssertEquals(1, source[0])
	End Method

	Method EmptySingleAndMultipleArrays() { test }
		Local empty:Int[] = New Int[0]
		AssertEquals(0, Map<Int, Int>(empty, ArrayDouble).Length)
		AssertEquals(0, Filter<Int>(empty, ArrayEven).Length)
		AssertEquals(7, Fold<Int, Int>(empty, 7, ArrayAdd))
		AssertFalse(Any<Int>(empty))
		AssertTrue(All<Int>(empty, ArrayPositive))
		AssertFalse(FirstOrNone<Int>(empty).IsDefined())
		AssertFalse(LastOrNone<Int>(empty).IsDefined())

		AssertEquals(2, Map<Int, Int>([1], ArrayDouble)[0])
		AssertEquals(6, Fold<Int, Int>([1, 2, 3], 0, ArrayAdd))
		AssertEquals(1, LastOrNone<Int>([1]).Value())
		AssertEquals(3, LastOrNone<Int>([1, 2, 3]).Value())
	End Method

	Method CountAnyAllAndFirstTerminatePrecisely() { test }
		Local values:Int[] = [1, 2, 3, 4]
		Local calls:Int
		Local countPredicate:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return ArrayEven(value)
		End Function
		AssertEquals(2, Count<Int>(values, countPredicate))
		AssertEquals(4, calls)

		calls = 0
		Local anyPredicate:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value = 2
		End Function
		AssertTrue(Any<Int>(values, anyPredicate))
		AssertEquals(2, calls)

		calls = 0
		Local allPredicate:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value < 3
		End Function
		AssertFalse(All<Int>(values, allPredicate))
		AssertEquals(3, calls)

		calls = 0
		Local firstPredicate:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value > 2
		End Function
		Local first:Optional<Int> = FirstOrNone<Int>(values, firstPredicate)
		AssertEquals(3, first.Value())
		AssertEquals(3, calls)
	End Method

	Method ThinPredicateTerminalsWork() { test }
		Local values:Int[] = [1, 2, 3, 4]
		AssertEquals(2, Count<Int>(values, ArrayEven))
		AssertTrue(Any<Int>(values, ArrayEven))
		AssertFalse(All<Int>(values, ArrayEven))
		AssertEquals(2, FirstOrNone<Int>(values, ArrayEven).Value())
	End Method

	Method FoldAndForEachCaptureState() { test }
		Local factor:Int = 2
		Local folder:Closure<Int(total:Int, value:Int)> = Function:Int(total:Int, value:Int)
			Return total + value * factor
		End Function
		Local folded:Int = Fold<Int, Int>([1, 2, 3], 0, folder)
		AssertEquals(12, folded)

		Local visited:String
		Local visitor:Closure<(value:Int)> = Function(value:Int)
			visited :+ value
		End Function
		ForEach<Int>([1, 2, 3], visitor)
		AssertEquals("123", visited)

		ArrayVisitTotal = 0
		ForEach<Int>([1, 2, 3], ArrayVisit)
		AssertEquals(6, ArrayVisitTotal)
	End Method

	Method ObjectInterfaceAndNullValuesArePreserved() { test }
		Local marker:TArrayMarker = New TArrayMarker
		marker.value = 7
		Local objects:TArrayMarker[] = [marker, Null]
		Local identity:Closure<TArrayMarker(value:TArrayMarker)> = Function:TArrayMarker(value:TArrayMarker)
			Return value
		End Function
		Local copied:TArrayMarker[] = Map<TArrayMarker, TArrayMarker>(objects, identity)
		AssertSame(marker, copied[0])
		AssertNull(copied[1])
		Local missing:TArrayMarker
		Local nullValue:Optional<TArrayMarker> = FirstOrNone<TArrayMarker>([missing])
		AssertTrue(nullValue.IsDefined())
		AssertNull(nullValue.Value())
		Local lastNull:Optional<TArrayMarker> = LastOrNone<TArrayMarker>([marker, missing])
		AssertTrue(lastNull.IsDefined())
		AssertNull(lastNull.Value())

		Local concrete:TArrayInterfaceMarker = New TArrayInterfaceMarker
		concrete.value = 9
		Local abstract:IArrayMarker = concrete
		Local interfacePredicate:Closure<Int(value:IArrayMarker)> = Function:Int(value:IArrayMarker)
			Return value.Read() = 9
		End Function
		Local interfaces:IArrayMarker[] = Filter<IArrayMarker>([abstract], interfacePredicate)
		AssertEquals(9, interfaces[0].Read())
	End Method

	Method NestedGenericValuesCrossOperations() { test }
		Local values:Result<Int, String>[] = [Result<Int, String>.Ok(42), Result<Int, String>.Err("bad")]
		Local accept:Closure<Int(value:Result<Int, String>)> = Function:Int(value:Result<Int, String>)
			Return True
		End Function
		Local copied:Result<Int, String>[] = Filter<Result<Int, String>>(values, accept)
		AssertEquals(2, copied.Length)
		AssertEquals(42, copied[0].Value())
		AssertEquals("bad", copied[1].Error())
	End Method

	Method IntegratesWithFunctionsResultAndSequence() { test }
		Local eager:Int[] = Map<Int, Int>([1, 2, 3], Identity<Int>)
		AssertEquals(3, eager.Length)
		AssertEquals(6, Sequence<Int>.FromArray(eager).Fold<Int>(0, ArrayAdd))

		Local okMapper:Closure<Result<Int, String>(value:Int)> = Function:Result<Int, String>(value:Int)
			Return Result<Int, String>.Ok(value)
		End Function
		Local results:Result<Int, String>[] = Map<Int, Result<Int, String>>([42], okMapper)
		AssertEquals(42, results[0].Value())
	End Method

	Method ExceptionsPropagateUnchanged() { test }
		Local expected:TArrayAlgorithmException = New TArrayAlgorithmException
		Local caught:TArrayAlgorithmException
		Local fail:Closure<Int(value:Int)> = Function:Int(value:Int)
			Throw expected
		End Function
		Try
			Map<Int, Int>([1], fail)
		Catch exception:TArrayAlgorithmException
			caught = exception
		End Try
		AssertSame(expected, caught)
	End Method
End Type
