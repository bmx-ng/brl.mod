SuperStrict

Framework BRL.MaxUnit
Import BRL.Sequence
Import Collections.ArrayList
Import Collections.LinkedList
Import Collections.HashSet
Import Collections.Queue
Import Collections.Stack
Import Collections.ImmutableList
Import Collections.HashMap

New TTestSuite.Run()

Type TSequenceMarker
	Field value:Int
End Type

Interface ISequenceMarker
	Method Value:Int()
End Interface

Type TSequenceInterfaceMarker Implements ISequenceMarker
	Field _value:Int

	Method New(value:Int)
		_value = value
	End Method

	Method Value:Int()
		Return _value
	End Method
End Type

Struct SSequencePoint
	Field x:Int
	Field y:Int
End Struct

Type TCountingIterable<T> Implements IIterable<T>
	Field values:T[]
	Field iteratorRequests:Int
	Field moveCalls:Int

	Method New(values:T[])
		Self.values = values
	End Method

	Method GetIterator:IIterator<T>()
		iteratorRequests :+ 1
		Return New TCountingIterator<T>(Self)
	End Method
End Type

Type TCountingIterator<T> Implements IIterator<T>
	Field owner:TCountingIterable<T>
	Field index:Int = -1

	Method New(owner:TCountingIterable<T>)
		Self.owner = owner
	End Method

	Method Current:T()
		Return owner.values[index]
	End Method

	Method MoveNext:Int()
		owner.moveCalls :+ 1
		index :+ 1
		Return index < owner.values.Length
	End Method
End Type

Type TOneShotIterable<T> Implements IIterable<T>
	Field iterator:IIterator<T>
	Field iteratorRequests:Int

	Method New(values:T[])
		Local source:TCountingIterable<T> = New TCountingIterable<T>(values)
		iterator = source.GetIterator()
	End Method

	Method GetIterator:IIterator<T>()
		iteratorRequests :+ 1
		Return iterator
	End Method
End Type

Function Materialize<T>:T[](source:IIterable<T>)
	Return New Sequence<T>(source).ToArray()
End Function

Global fusionEvaluationOrder:String

Function FusionValues:Int[]()
	fusionEvaluationOrder :+ "source,"
	Return [2]
End Function

Function FusionPredicate:Closure<Int(value:Int)>()
	fusionEvaluationOrder :+ "predicate,"
	Return Function:Int(value:Int)
		Return True
	End Function
End Function

Function FusionTakeCount:Int()
	fusionEvaluationOrder :+ "take,"
	Return 1
End Function

Function FusionTakeWhilePredicate:Closure<Int(value:Int)>()
	fusionEvaluationOrder :+ "takeWhile,"
	Return Function:Int(value:Int)
		Return value < 10
	End Function
End Function

Function FusionSkipWhilePredicate:Closure<Int(value:Int)>()
	fusionEvaluationOrder :+ "skipWhile,"
	Return Function:Int(value:Int)
		Return value < 0
	End Function
End Function

Function FusionSeed:Int()
	fusionEvaluationOrder :+ "seed,"
	Return 3
End Function

Function FusionFolder:Closure<Int(total:Int, value:Int)>()
	fusionEvaluationOrder :+ "folder,"
	Return Function:Int(total:Int, value:Int)
		Return total + value
	End Function
End Function

Global thinFunctionVisits:String

Function ThinEven:Int(value:Int)
	Return (value & 1) = 0
End Function

Function ThinTriple:Int(value:Int)
	Return value * 3
End Function

Function ThinAdd:Int(total:Int, value:Int)
	Return total + value
End Function

Function ThinBelowTen:Int(value:Int)
	Return value < 10
End Function

Function ThinVisit(value:Int)
	thinFunctionVisits :+ value + ","
End Function

Function ThinFail:Int(value:Int)
	If value = 2 Then Throw "thin failure"
	Return value
End Function

Function ExpandPair:Sequence<Int>(value:Int)
	Return Sequence<Int>.FromArray([value, value * 10])
End Function

Function LessThanFour:Int(value:Int)
	Return value < 4
End Function

Type TSequenceTest Extends TTest
	Method NonCapturingFunctionOverloadsWorkFusedAndUnfused() { test }
		Local pipeline:Sequence<Int> = Sequence<Int>.FromArray([1, 2, 3, 4]).Filter(ThinEven).Map<Int>(ThinTriple)
		Local values:Int[] = pipeline.ToArray()
		AssertEquals(2, values.Length)
		AssertEquals(6, values[0])
		AssertEquals(12, values[1])
		AssertEquals(18, pipeline.Fold<Int>(0, ThinAdd))
		AssertEquals(1, pipeline.Count(ThinBelowTen))
		AssertTrue(pipeline.Any(ThinBelowTen))
		AssertFalse(pipeline.All(ThinBelowTen))
		AssertEquals(6, pipeline.FirstOrNone(ThinBelowTen).Value())
		AssertEquals(12, pipeline.LastOrNone().Value())

		thinFunctionVisits = ""
		pipeline.ForEach(ThinVisit)
		AssertEquals("6,12,", thinFunctionVisits)

		AssertEquals(18, Sequence<Int>.FromArray([1, 2, 3, 4]).Filter(ThinEven).Map<Int>(ThinTriple).Fold<Int>(0, ThinAdd))
		Local caught:String
		Try
			Sequence<Int>.FromArray([1, 2, 3]).Map<Int>(ThinFail).Count()
		Catch message:String
			caught = message
		End Try
		AssertEquals("thin failure", caught)
	End Method

	Method CompilerFusedDirectArrayPipelinePreservesCounts() { test }
		Local predicateCalls:Int
		Local mapperCalls:Int
		Local folderCalls:Int
		Local even:Closure<Int(value:Int)> = Function:Int(value:Int)
			predicateCalls :+ 1
			Return (value & 1) = 0
		End Function
		Local triple:Closure<Int(value:Int)> = Function:Int(value:Int)
			mapperCalls :+ 1
			Return value * 3
		End Function
		Local add:Closure<Int(total:Int, value:Int)> = Function:Int(total:Int, value:Int)
			folderCalls :+ 1
			Return total + value
		End Function

		Local total:Int = Sequence<Int>.FromArray([1, 2, 3, 4, 5]).Filter(even).Map<Int>(triple).Take(2).Fold<Int>(0, add)
		AssertEquals(18, total)
		AssertEquals(4, predicateCalls, "Take must stop the fused source loop without a probe")
		AssertEquals(2, mapperCalls)
		AssertEquals(2, folderCalls)
	End Method

	Method CompilerFusedTakeSkipAndTerminalsPreserveEarlyExit() { test }
		Local rejectedCalls:Int
		Local reject:Closure<Int(value:Int)> = Function:Int(value:Int)
			rejectedCalls :+ 1
			Return False
		End Function
		AssertEquals(0, Sequence<Int>.FromArray([1, 2, 3, 4]).Take(2).Filter(reject).Count())
		AssertEquals(2, rejectedCalls, "A downstream rejection must not pull beyond an exhausted Take")

		Local zeroCalls:Int
		Local countVisit:Closure<Int(value:Int)> = Function:Int(value:Int)
			zeroCalls :+ 1
			Return True
		End Function
		AssertEquals(0, Sequence<Int>.FromArray([1, 2, 3]).Filter(countVisit).Take(0).Count())
		AssertEquals(0, zeroCalls)
		AssertEquals(0, Sequence<Int>.FromArray([1, 2, 3]).Take(2).Skip(2).Count())

		Local isThree:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value = 3
		End Function
		Local belowFour:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value < 4
		End Function
		AssertTrue(Sequence<Int>.FromArray([1, 2, 3, 4]).Skip(1).Any(isThree))
		AssertFalse(Sequence<Int>.FromArray([1, 2, 4]).All(belowFour))

		Local terminalCalls:Int
		Local terminalEven:Closure<Int(value:Int)> = Function:Int(value:Int)
			terminalCalls :+ 1
			Return (value & 1) = 0
		End Function
		AssertEquals(2, Sequence<Int>.FromArray([1, 2, 3, 4]).Count(terminalEven))
		AssertEquals(4, terminalCalls)
		terminalCalls = 0
		AssertEquals(2, Sequence<Int>.FromArray([1, 2, 3, 4]).FirstOrNone(terminalEven).Value())
		AssertEquals(2, terminalCalls)
		AssertEquals(4, Sequence<Int>.FromArray([1, 2, 3, 4]).Filter(terminalEven).LastOrNone().Value())
	End Method

	Method CompilerFusedTakeWhileAndSkipWhilePreservePrefixState() { test }
		Local takeCalls:Int
		Local belowThree:Closure<Int(value:Int)> = Function:Int(value:Int)
			takeCalls :+ 1
			Return value < 3
		End Function
		AssertEquals(2, Sequence<Int>.FromArray([1, 2, 3, 1]).TakeWhile(belowThree).Count())
		AssertEquals(3, takeCalls, "TakeWhile must test and consume its first rejected value")

		Local mappedCalls:Int
		Local identity:Closure<Int(value:Int)> = Function:Int(value:Int)
			mappedCalls :+ 1
			Return value
		End Function
		AssertEquals(2, Sequence<Int>.FromArray([1, 2, 3, 1]).TakeWhile(belowThree).Map<Int>(identity).Count())
		AssertEquals(2, mappedCalls, "a rejected TakeWhile value must not reach downstream stages")

		Local skipCalls:Int
		Local skipBelowThree:Closure<Int(value:Int)> = Function:Int(value:Int)
			skipCalls :+ 1
			Return value < 3
		End Function
		Local skipped:Int[] = Sequence<Int>.FromArray([1, 2, 3, 1]).SkipWhile(skipBelowThree).ToArray()
		AssertEquals(2, skipped.Length)
		AssertEquals(3, skipped[0])
		AssertEquals(1, skipped[1])
		AssertEquals(3, skipCalls, "SkipWhile must stop invoking its predicate after the first rejection")

		Local upstreamCalls:Int
		Local alwaysTrue:Closure<Int(value:Int)> = Function:Int(value:Int)
			upstreamCalls :+ 1
			Return True
		End Function
		AssertEquals(0, Sequence<Int>.FromArray([1, 2, 3]).Take(2).SkipWhile(alwaysTrue).Count())
		AssertEquals(2, upstreamCalls, "an exhausted upstream Take must stop SkipWhile without another test")

		skipCalls = 0
		AssertEquals(1, Sequence<Int>.FromArray([1, 2, 3, 4]).SkipWhile(skipBelowThree).Take(1).Count())
		AssertEquals(3, skipCalls, "a downstream Take must stop after SkipWhile releases its first value")
	End Method

	Method CompilerFusedFoldRetainsManagedValuesAndExceptions() { test }
		Local join:Closure<String(total:String, value:String)> = Function:String(total:String, value:String)
			Return total + value
		End Function
		AssertEquals("abc", Sequence<String>.FromArray(["a", "b", "c"]).Fold<String>("", join))

		Local fail:Closure<Int(value:Int)> = Function:Int(value:Int)
			If value = 2 Then Throw "fused failure"
			Return value
		End Function
		Local caught:String
		Try
			Sequence<Int>.FromArray([1, 2, 3]).Map<Int>(fail).Count()
		Catch message:String
			caught = message
		End Try
		AssertEquals("fused failure", caught)
	End Method

	Method CompilerFusionPreservesReceiverAndArgumentEvaluationOrder() { test }
		fusionEvaluationOrder = ""
		Local result:Int = Sequence<Int>.FromArray(FusionValues()).Filter(FusionPredicate()).Take(FusionTakeCount()).TakeWhile(FusionTakeWhilePredicate()).SkipWhile(FusionSkipWhilePredicate()).Fold<Int>(FusionSeed(), FusionFolder())
		AssertEquals(5, result)
		AssertEquals("source,predicate,take,takeWhile,skipWhile,seed,folder,", fusionEvaluationOrder)
	End Method

	Method CompilerFusionRetainsMappedStructAndArrayTypes() { test }
		Local makePoint:Closure<SSequencePoint(value:Int)> = Function:SSequencePoint(value:Int)
			Local point:SSequencePoint
			point.x = value
			point.y = -value
			Return point
		End Function
		AssertEquals(2, Sequence<Int>.FromArray([3, 4]).Map<SSequencePoint>(makePoint).Count())
		Local lastPoint:SSequencePoint = Sequence<Int>.FromArray([3, 4]).Map<SSequencePoint>(makePoint).LastOrNone().Value()
		AssertEquals(4, lastPoint.x)
		AssertEquals(-4, lastPoint.y)

		Local wrap:Closure<Int[](value:Int)> = Function:Int[](value:Int)
			Return [value]
		End Function
		AssertEquals(2, Sequence<Int>.FromArray([5, 6]).Map<Int[]>(wrap).Count())
		Local lastArray:Int[] = Sequence<Int>.FromArray([5, 6]).Map<Int[]>(wrap).LastOrNone().Value()
		AssertEquals(6, lastArray[0])
		AssertEquals("right", Sequence<String>.FromArray(["left", "right"]).LastOrNone().Value())
	End Method

	Method ArrayAdapterAndEachInAreTyped() { test }
		Local sequence:Sequence<Int> = Sequence<Int>.FromArray([1, 2, 3])
		Local total:Int
		For Local value:Int = EachIn sequence
			total :+ value
		Next
		AssertEquals(6, total)
	End Method

	Method EmptySingleAndMultipleMaterialize() { test }
		AssertEquals(0, New Sequence<Int>(New Int[0]).ToArray().Length)
		Local single:Int[] = New Sequence<Int>([7]).ToArray()
		AssertEquals(1, single.Length)
		AssertEquals(7, single[0])
		Local multiple:Int[] = New Sequence<Int>([2, 4, 6]).ToArray()
		AssertEquals(3, multiple.Length)
		AssertEquals(2, multiple[0])
		AssertEquals(4, multiple[1])
		AssertEquals(6, multiple[2])
	End Method

	Method MapFilterTakeSkipComposeLazily() { test }
		Local source:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 3, 4, 5])
		Local predicateCalls:Int
		Local mapperCalls:Int
		Local predicate:Closure<Int(value:Int)> = Function:Int(value:Int)
			predicateCalls :+ 1
			Return value Mod 2 = 0
		End Function
		Local mapper:Closure<String(value:Int)> = Function:String(value:Int)
			mapperCalls :+ 1
			Return "v" + value
		End Function

		Local pipeline:Sequence<String> = Sequence<Int>.FromIterable(source).Filter(predicate).Map<String>(mapper).Take(2)
		AssertEquals(0, source.iteratorRequests, "Pipeline construction must not request an iterator")
		AssertEquals(0, predicateCalls)
		AssertEquals(0, mapperCalls)

		Local values:String[] = pipeline.ToArray()
		AssertEquals(2, values.Length)
		AssertEquals("v2", values[0])
		AssertEquals("v4", values[1])
		AssertEquals(1, source.iteratorRequests)
		AssertEquals(4, predicateCalls, "Filter stops after Take has enough values")
		AssertEquals(2, mapperCalls)
		AssertEquals(4, source.moveCalls, "Take must not probe the fifth source value")

		Local skipped:String[] = pipeline.Skip(1).ToArray()
		AssertEquals(1, skipped.Length)
		AssertEquals("v4", skipped[0])
	End Method

	Method FlatMapIsLazyOrderedAndStopsInsideAnInnerSequence() { test }
		Local outer:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 3])
		Local first:TCountingIterable<Int> = New TCountingIterable<Int>([10, 11])
		Local second:TCountingIterable<Int> = New TCountingIterable<Int>([20, 21])
		Local third:TCountingIterable<Int> = New TCountingIterable<Int>([30, 31])
		Local mapperCalls:Int
		Local mapper:Closure<Sequence<Int>(value:Int)> = Function:Sequence<Int>(value:Int)
			mapperCalls :+ 1
			Select value
				Case 1 Return Sequence<Int>.FromIterable(first)
				Case 2 Return Sequence<Int>.FromIterable(second)
				Default Return Sequence<Int>.FromIterable(third)
			End Select
		End Function

		Local pipeline:Sequence<Int> = Sequence<Int>.FromIterable(outer).FlatMap<Int>(mapper).Take(3)
		AssertEquals(0, outer.iteratorRequests)
		AssertEquals(0, mapperCalls)
		Local values:Int[] = pipeline.ToArray()
		AssertEquals(3, values.Length)
		AssertEquals(10, values[0])
		AssertEquals(11, values[1])
		AssertEquals(20, values[2])
		AssertEquals(2, mapperCalls, "FlatMap invokes its mapper once per requested outer value")
		AssertEquals(2, outer.moveCalls, "FlatMap requests only the outer values needed by Take")
		AssertEquals(1, first.iteratorRequests)
		AssertEquals(1, second.iteratorRequests)
		AssertEquals(0, third.iteratorRequests, "Later inner sequences must not be requested after Take terminates")
		AssertEquals(3, first.moveCalls, "An exhausted inner sequence includes its terminating probe")
		AssertEquals(1, second.moveCalls, "Take must not probe beyond its last requested inner value")
	End Method

	Method FlatMapSupportsNonCapturingFunctionsEmptyInnersAndReplay() { test }
		Local values:Int[] = Sequence<Int>.FromArray([1, 2]).FlatMap<Int>(ExpandPair).ToArray()
		AssertEquals(4, values.Length)
		AssertEquals(1, values[0])
		AssertEquals(10, values[1])
		AssertEquals(2, values[2])
		AssertEquals(20, values[3])

		Local mapper:Closure<Sequence<String>(value:Int)> = Function:Sequence<String>(value:Int)
			If value = 2 Then Return New Sequence<String>()
			Return Sequence<String>.FromArray(["v" + value])
		End Function
		Local pipeline:Sequence<String> = Sequence<Int>.FromArray([1, 2, 3]).FlatMap<String>(mapper)
		Local join:Closure<String(total:String, value:String)> = Function:String(total:String, value:String)
			If total Then Return total + "," + value
			Return value
		End Function
		AssertEquals("v1,v3", pipeline.Fold<String>("", join))
		AssertEquals(2, pipeline.Count(), "A replayable FlatMap recipe requests fresh outer and inner iterators")
	End Method

	Method ConcatDefersSecondIteratorAndReplaysBothSources() { test }
		Local first:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2])
		Local second:TCountingIterable<Int> = New TCountingIterable<Int>([3, 4])
		Local combined:Sequence<Int> = Sequence<Int>.FromIterable(first).Concat(Sequence<Int>.FromIterable(second))
		AssertEquals(0, first.iteratorRequests)
		AssertEquals(0, second.iteratorRequests)
		Local iterator:IIterator<Int> = combined.GetIterator()
		AssertEquals(1, first.iteratorRequests)
		AssertEquals(0, second.iteratorRequests)
		AssertTrue(iterator.MoveNext())
		AssertEquals(1, iterator.Current())
		AssertTrue(iterator.MoveNext())
		AssertEquals(2, iterator.Current())
		AssertEquals(0, second.iteratorRequests)
		AssertTrue(iterator.MoveNext())
		AssertEquals(3, iterator.Current())
		AssertEquals(1, second.iteratorRequests)
		AssertEquals(4, combined.Count())
		AssertEquals(2, first.iteratorRequests)
		AssertEquals(2, second.iteratorRequests)
	End Method

	Method TakeWhileAndSkipWhileHavePrefixSemantics() { test }
		Local takeSource:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 4, 3])
		Local takeCalls:Int
		Local belowFour:Closure<Int(value:Int)> = Function:Int(value:Int)
			takeCalls :+ 1
			Return value < 4
		End Function
		Local taken:Int[] = Sequence<Int>.FromIterable(takeSource).TakeWhile(belowFour).ToArray()
		AssertEquals(2, taken.Length)
		AssertEquals(1, taken[0])
		AssertEquals(2, taken[1])
		AssertEquals(3, takeCalls)
		AssertEquals(3, takeSource.moveCalls, "TakeWhile consumes its rejecting value but nothing after it")

		Local skipSource:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 4, 3])
		Local skipCalls:Int
		Local skipBelowFour:Closure<Int(value:Int)> = Function:Int(value:Int)
			skipCalls :+ 1
			Return value < 4
		End Function
		Local skipped:Int[] = Sequence<Int>.FromIterable(skipSource).SkipWhile(skipBelowFour).ToArray()
		AssertEquals(2, skipped.Length)
		AssertEquals(4, skipped[0])
		AssertEquals(3, skipped[1])
		AssertEquals(3, skipCalls, "SkipWhile stops invoking its predicate after the first rejection")
		AssertEquals(4, Sequence<Int>.FromArray([1, 2, 4, 3]).SkipWhile(LessThanFour).FirstOrNone().Value())
		AssertEquals(2, Sequence<Int>.FromArray([1, 2, 4, 3]).TakeWhile(LessThanFour).Count())
	End Method

	Method AppendAndPrependPreserveOrderAndManagedNullValues() { test }
		Local values:Int[] = Sequence<Int>.FromArray([2, 3]).Prepend(1).Append(4).ToArray()
		AssertEquals(4, values.Length)
		For Local index:Int = 0 Until values.Length
			AssertEquals(index + 1, values[index])
		Next
		AssertEquals(9, New Sequence<Int>().Append(9).SingleOrNone().Value())
		AssertEquals(8, New Sequence<Int>().Prepend(8).SingleOrNone().Value())

		Local marker:TSequenceMarker
		Local appended:Optional<TSequenceMarker> = New Sequence<TSequenceMarker>().Append(marker).SingleOrNone()
		AssertTrue(appended.HasValue())
		AssertNull(appended.Value())
	End Method

	Method ElementAtAndSingleStopAsSoonAsTheirAnswerIsKnown() { test }
		Local negative:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2])
		AssertTrue(Sequence<Int>.FromIterable(negative).ElementAtOrNone(-1).IsUndefined())
		AssertEquals(0, negative.iteratorRequests)

		Local found:TCountingIterable<Int> = New TCountingIterable<Int>([4, 5, 6])
		AssertEquals(5, Sequence<Int>.FromIterable(found).ElementAtOrNone(1).Value())
		AssertEquals(2, found.moveCalls)
		Local missing:TCountingIterable<Int> = New TCountingIterable<Int>([4, 5])
		AssertTrue(Sequence<Int>.FromIterable(missing).ElementAtOrNone(3).IsUndefined())
		AssertEquals(3, missing.moveCalls)

		AssertTrue(New Sequence<Int>().SingleOrNone().IsUndefined())
		AssertEquals(7, Sequence<Int>.FromArray([7]).SingleOrNone().Value())
		Local multiple:TCountingIterable<Int> = New TCountingIterable<Int>([7, 8, 9])
		AssertTrue(Sequence<Int>.FromIterable(multiple).SingleOrNone().IsUndefined())
		AssertEquals(2, multiple.moveCalls, "SingleOrNone stops after proving that a second value exists")
	End Method

	Method SecondTierOperatorsPreserveComplexGenericTypes() { test }
		Local expandArray:Closure<Sequence<Int>(value:Int[])> = Function:Sequence<Int>(value:Int[])
			Return Sequence<Int>.FromArray(value)
		End Function
		Local flattened:Int[] = Sequence<Int[]>.FromArray([[1, 2], New Int[0], [3]]).FlatMap<Int>(expandArray).ToArray()
		AssertEquals(3, flattened.Length)
		AssertEquals(3, flattened[2])

		Local first:SSequencePoint
		first.x = 4
		Local second:SSequencePoint
		second.x = 5
		Local points:SSequencePoint[] = Sequence<SSequencePoint>.FromArray([first]).Concat(Sequence<SSequencePoint>.FromArray([second])).ToArray()
		AssertEquals(4, points[0].x)
		AssertEquals(5, points[1].x)

		Local interfaceValue:ISequenceMarker = New TSequenceInterfaceMarker(23)
		AssertEquals(23, New Sequence<ISequenceMarker>().Append(interfaceValue).SingleOrNone().Value().Value())
		Local nested:Optional<Int> = Optional<Int>.FromValue(29)
		AssertEquals(29, New Sequence<Optional<Int>>().Prepend(nested).ElementAtOrNone(0).Value().Value())
	End Method

	Method SecondTierClosureExceptionsPropagateUnchanged() { test }
		Local flattenFailure:Closure<Sequence<Int>(value:Int)> = Function:Sequence<Int>(value:Int)
			If value = 2 Then Throw "flat-map failure"
			Return Sequence<Int>.FromArray([value])
		End Function
		Local caught:String
		Try
			Sequence<Int>.FromArray([1, 2, 3]).FlatMap<Int>(flattenFailure).Count()
		Catch message:String
			caught = message
		End Try
		AssertEquals("flat-map failure", caught)

		Local predicateFailure:Closure<Int(value:Int)> = Function:Int(value:Int)
			If value = 2 Then Throw "prefix failure"
			Return True
		End Function
		caught = ""
		Try
			Sequence<Int>.FromArray([1, 2, 3]).TakeWhile(predicateFailure).Count()
		Catch message:String
			caught = message
		End Try
		AssertEquals("prefix failure", caught)

		caught = ""
		Try
			Sequence<Int>.FromArray([1, 2, 3]).SkipWhile(predicateFailure).Count()
		Catch message:String
			caught = message
		End Try
		AssertEquals("prefix failure", caught)
	End Method

	Method TakeZeroAndNegativeDoNotAdvanceSource() { test }
		Local source:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2])
		AssertEquals(0, New Sequence<Int>(source).Take(0).Count())
		AssertEquals(0, source.moveCalls)
		AssertEquals(0, New Sequence<Int>(source).Take(-5).Count())
		AssertEquals(0, source.moveCalls)
		AssertEquals(2, New Sequence<Int>(source).Skip(-5).Count())
	End Method

	Method FoldCountAndForEachWork() { test }
		Local folder:Closure<Int(accumulator:Int, value:Int)> = Function:Int(accumulator:Int, value:Int)
			Return accumulator + value
		End Function
		Local sequence:Sequence<Int> = New Sequence<Int>([1, 2, 3, 4])
		AssertEquals(20, sequence.Fold<Int>(10, folder))
		AssertEquals(4, sequence.Count())
		Local visited:String
		Local action:Closure<(value:Int)> = Function(value:Int)
			visited :+ value + ","
		End Function
		sequence.ForEach(action)
		AssertEquals("1,2,3,4,", visited)
	End Method

	Method AnyAllAndFirstTerminateEarly() { test }
		Local source:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 3, 4])
		Local calls:Int
		Local isTwo:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value = 2
		End Function
		AssertTrue(New Sequence<Int>(source).Any(isTwo))
		AssertEquals(2, calls)
		AssertEquals(2, source.moveCalls)

		Local allSource:TCountingIterable<Int> = New TCountingIterable<Int>([2, 4, 5, 6])
		Local evenCalls:Int
		Local even:Closure<Int(value:Int)> = Function:Int(value:Int)
			evenCalls :+ 1
			Return value Mod 2 = 0
		End Function
		AssertFalse(New Sequence<Int>(allSource).All(even))
		AssertEquals(3, evenCalls)
		AssertEquals(3, allSource.moveCalls)

		Local firstSource:TCountingIterable<Int> = New TCountingIterable<Int>([9, 10])
		AssertEquals(9, New Sequence<Int>(firstSource).FirstOrNone().Value())
		AssertEquals(1, firstSource.moveCalls)
		AssertTrue(New Sequence<Int>(New Int[0]).FirstOrNone().IsUndefined())
		AssertFalse(New Sequence<Int>(New Int[0]).Any())
		AssertTrue(New Sequence<Int>(New Int[0]).All(even))
	End Method

	Method PredicateCountFirstAndLastHaveExactFallbackTraversal() { test }
		Local countSource:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 3, 4])
		Local countCalls:Int
		Local even:Closure<Int(value:Int)> = Function:Int(value:Int)
			countCalls :+ 1
			Return (value & 1) = 0
		End Function
		AssertEquals(2, New Sequence<Int>(countSource).Count(even))
		AssertEquals(4, countCalls)
		AssertEquals(5, countSource.moveCalls, "Count performs the terminating MoveNext probe")

		Local firstSource:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 3, 4])
		Local firstCalls:Int
		Local aboveTwo:Closure<Int(value:Int)> = Function:Int(value:Int)
			firstCalls :+ 1
			Return value > 2
		End Function
		AssertEquals(3, New Sequence<Int>(firstSource).FirstOrNone(aboveTwo).Value())
		AssertEquals(3, firstCalls)
		AssertEquals(3, firstSource.moveCalls)

		Local lastSource:TCountingIterable<Int> = New TCountingIterable<Int>([1, 2, 3, 4])
		AssertEquals(4, New Sequence<Int>(lastSource).LastOrNone().Value())
		AssertEquals(5, lastSource.moveCalls, "LastOrNone enumerates the complete source")
		AssertTrue(New Sequence<Int>(New Int[0]).LastOrNone().IsUndefined())
	End Method

	Method RepeatedEnumerationRequestsFreshIterators() { test }
		Local source:TCountingIterable<Int> = New TCountingIterable<Int>([3, 4])
		Local sequence:Sequence<Int> = New Sequence<Int>(source)
		AssertEquals(2, sequence.Count())
		AssertEquals(2, sequence.Count())
		AssertEquals(2, source.iteratorRequests)
	End Method

	Method OneShotSourceRemainsOneShotWithoutBuffering() { test }
		Local source:TOneShotIterable<Int> = New TOneShotIterable<Int>([1, 2, 3])
		Local sequence:Sequence<Int> = New Sequence<Int>(source)
		AssertEquals(3, sequence.Count())
		AssertEquals(0, sequence.Count(), "Sequence must not silently replay or buffer a one-shot source")
		AssertEquals(2, source.iteratorRequests)
	End Method

	Method ArrayAndCollectionMutationsAreVisibleLater() { test }
		Local values:Int[] = [1, 2]
		Local arraySequence:Sequence<Int> = New Sequence<Int>(values)
		values[0] = 9
		AssertEquals(9, arraySequence.FirstOrNone().Value())

		Local list:TArrayList<Int> = New TArrayList<Int>([2, 3])
		Local listSequence:Sequence<Int> = New Sequence<Int>(list)
		AssertEquals(2, listSequence.Count())
		list.Add(4)
		AssertEquals(3, listSequence.Count())
	End Method

	Method ToArrayIsAnIndependentMaterializedCopy() { test }
		Local source:Int[] = [1, 2]
		Local copy:Int[] = New Sequence<Int>(source).ToArray()
		source[0] = 7
		copy[1] = 8
		AssertEquals(1, copy[0])
		AssertEquals(2, source[1])
	End Method

	Method CapturedClosuresAndNestedPipelinesWork() { test }
		Local offset:Int = 5
		Local addOffset:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value + offset
		End Function
		Local greaterThan:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value > offset + 2
		End Function
		Local result:Int[] = New Sequence<Int>([1, 2, 3, 4]).Map<Int>(addOffset).Filter(greaterThan).Skip(1).Take(1).ToArray()
		AssertEquals(1, result.Length)
		AssertEquals(9, result[0])
	End Method

	Method ClosureExceptionsPropagateUnchanged() { test }
		Local mapper:Closure<Int(value:Int)> = Function:Int(value:Int)
			If value = 2 Then Throw "map failure"
			Return value
		End Function
		Local caught:String
		Try
			New Sequence<Int>([1, 2, 3]).Map<Int>(mapper).Count()
		Catch message:String
			caught = message
		End Try
		AssertEquals("map failure", caught)
	End Method

	Method ImportantValueCategoriesRetainStrongTyping() { test }
		Local strings:String[] = New Sequence<String>(["a", "bb"]).ToArray()
		AssertEquals("bb", strings[1])

		Local nestedArrays:Int[][] = [[1, 2], [3]]
		Local arrayLengths:Closure<Int(value:Int[])> = Function:Int(value:Int[])
			Return value.Length
		End Function
		Local lengths:Int[] = New Sequence<Int[]>(nestedArrays).Map<Int>(arrayLengths).ToArray()
		AssertEquals(2, lengths[0])
		AssertEquals(1, lengths[1])

		Local marker:TSequenceMarker = New TSequenceMarker
		marker.value = 11
		AssertSame(marker, New Sequence<TSequenceMarker>([marker]).FirstOrNone().Value())

		Local interfaceValue:ISequenceMarker = New TSequenceInterfaceMarker(13)
		AssertEquals(13, New Sequence<ISequenceMarker>([interfaceValue]).FirstOrNone().Value().Value())

		Local point:SSequencePoint
		point.x = 17
		point.y = -4
		Local points:SSequencePoint[] = New Sequence<SSequencePoint>([point]).ToArray()
		AssertEquals(17, points[0].x)
		AssertEquals(-4, points[0].y)

		Local optionals:Optional<Int>[] = [Optional<Int>.FromValue(21), Optional<Int>.Undefined()]
		Local nested:Optional<Int>[] = New Sequence<Optional<Int>>(optionals).ToArray()
		AssertEquals(21, nested[0].Value())
		AssertTrue(nested[1].IsUndefined())
	End Method

	Method PresentNullObjectIsStillASequenceElement() { test }
		Local values:TSequenceMarker[] = New TSequenceMarker[1]
		Local first:Optional<TSequenceMarker> = New Sequence<TSequenceMarker>(values).FirstOrNone()
		AssertTrue(first.HasValue(), "Element presence is separate from its managed Null payload")
		AssertNull(first.Value())
		Local last:Optional<TSequenceMarker> = Sequence<TSequenceMarker>.FromArray(values).LastOrNone()
		AssertTrue(last.HasValue())
		AssertNull(last.Value())
	End Method

	Method GenericHelperPreservesTypeAcrossModuleBoundary() { test }
		Local list:TArrayList<String> = New TArrayList<String>(["left", "right"])
		Local iterable:IIterable<String> = list
		Local values:String[] = Materialize<String>(iterable)
		AssertEquals(2, values.Length)
		AssertEquals("right", values[1])
	End Method

	Method CollectionsAndMapViewsAdaptThroughIIterable() { test }
		Local arrayList:TArrayList<Int> = New TArrayList<Int>([1, 2])
		Local linkedList:TLinkedList<Int> = New TLinkedList<Int>([3, 4])
		Local set:THashSet<Int> = New THashSet<Int>([5, 6])
		Local queue:TQueue<Int> = New TQueue<Int>([7, 8])
		Local stack:TStack<Int> = New TStack<Int>([9, 10])
		Local immutable:TImmutableList<Int> = New TImmutableList<Int>([11, 12])

		AssertEquals(2, New Sequence<Int>(arrayList).Count())
		AssertEquals(2, New Sequence<Int>(linkedList).Count())
		AssertEquals(2, New Sequence<Int>(set).Count())
		AssertEquals(2, New Sequence<Int>(queue).Count())
		AssertEquals(2, New Sequence<Int>(stack).Count())
		AssertEquals(2, New Sequence<Int>(immutable).Count())

		Local map:THashMap<String, Int> = New THashMap<String, Int>
		map.Add("one", 1)
		map.Add("two", 2)
		AssertEquals(2, New Sequence<IMapNode<String, Int>>(map).Count())
		AssertEquals(2, New Sequence<String>(map.Keys()).Count())
		Local isTwo:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value = 2
		End Function
		AssertTrue(New Sequence<Int>(map.Values()).Any(isTwo))
	End Method
End Type
