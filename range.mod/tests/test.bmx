SuperStrict

Framework BRL.MaxUnit
Import BRL.Range

New TTestSuite.Run()

Global rangeReceiverEvaluations:Int
Global rangeValueEvaluations:Int
Global rangeEndpointEvaluations:Int

Function EvaluatedText:String()
	rangeReceiverEvaluations :+ 1
	Return "abcdef"
End Function

Function EvaluatedRange:Range()
	rangeValueEvaluations :+ 1
	Return Range.FromUntil(1, 4)
End Function

Function EvaluatedEndpoint:Int(value:Int)
	rangeEndpointEvaluations :+ 1
	Return value
End Function

Function SliceValues<T>:T[](values:T[], selected:Range)
	Return values[selected]
End Function

Function SliceLast<T>:T[](values:T[], distance:Int)
	Return values[^distance..]
End Function

Struct SRangeValue
	Field value:Int
End Struct

Type TRangeMarker
End Type

Type TRangeConstructionTest Extends TTest

	Method DefaultRangeIsAll() { test }
		Local value:Range
		AssertTrue(value.Start().IsUndefined())
		AssertTrue(value.EndExclusive().IsUndefined())
		AssertEquals(0, value.ResolveStart(9))
		AssertEquals(9, value.ResolveEndExclusive(9))
	End Method

	Method AllHasTwoOpenBounds() { test }
		Local value:Range = Range.All()
		AssertTrue(value.Start().IsUndefined())
		AssertTrue(value.EndExclusive().IsUndefined())
		AssertEquals(0, value.ResolveStart(17))
		AssertEquals(0, value.ResolveEndExclusive(0))
		AssertEquals(17, value.ResolveEndExclusive(17))
	End Method

	Method UntilHasOpenStart() { test }
		Local value:Range = Range.Until(4)
		AssertTrue(value.Start().IsUndefined())
		AssertTrue(value.EndExclusive().HasValue())
		AssertEquals(4, value.EndExclusive().Value())
		AssertEquals(0, value.ResolveStart(100))
		AssertEquals(4, value.ResolveEndExclusive(100))
	End Method

	Method FromHasOpenEnd() { test }
		Local value:Range = Range.From(3)
		AssertTrue(value.Start().HasValue())
		AssertEquals(3, value.Start().Value())
		AssertTrue(value.EndExclusive().IsUndefined())
		AssertEquals(3, value.ResolveStart(8))
		AssertEquals(8, value.ResolveEndExclusive(8))
	End Method

	Method FromUntilHasTwoExplicitBounds() { test }
		Local value:Range = Range.FromUntil(-2, 12)
		AssertEquals(-2, value.Start().Value())
		AssertEquals(12, value.EndExclusive().Value())
		AssertEquals(-2, value.ResolveStart(5))
		AssertEquals(12, value.ResolveEndExclusive(5))
	End Method

	Method OpenEndpointValueThrowsRangeException() { test }
		Local caught:TRangeEndpointValueException
		Try
			RangeEndpoint.Open().Value()
			Fail("An open RangeEndpoint.Value() should throw")
		Catch exception:TRangeEndpointValueException
			caught = exception
		End Try
		AssertNotNull(caught)
		AssertEquals("Range endpoint is open and does not contain a value", caught.ToString())
	End Method

	Method RangeCopiesAsAValue() { test }
		Local original:Range = Range.FromUntil(1, 3)
		Local copy:Range = original
		original = Range.From(4)
		AssertEquals(1, copy.Start().Value())
		AssertEquals(3, copy.EndExclusive().Value())
		AssertEquals(4, original.Start().Value())
		AssertTrue(original.EndExclusive().IsUndefined())
	End Method

	Method BoundQueriesDescribeEachShape() { test }
		AssertTrue(Range.All().IsAll())
		AssertFalse(Range.All().HasStart())
		AssertFalse(Range.All().HasEnd())
		AssertFalse(Range.All().IsBounded())
		AssertTrue(Range.From(2).HasStart())
		AssertFalse(Range.From(2).HasEnd())
		AssertFalse(Range.Until(2).HasStart())
		AssertTrue(Range.Until(2).HasEnd())
		AssertTrue(Range.FromUntil(1, 2).IsBounded())
		AssertFalse(Range.FromUntil(1, 2).IsAll())
	End Method

	Method SingleCreatesOneElementRange() { test }
		Local value:Range = Range.Single(3)
		AssertEquals(3, value.Start().Value())
		AssertEquals(4, value.EndExclusive().Value())
		AssertEquals("d", "abcdef"[value])
	End Method

	Method FromLengthTreatsNonPositiveLengthAsEmptyAtStart() { test }
		Local positive:Range = Range.FromLength(2, 3)
		Local zero:Range = Range.FromLength(4, 0)
		Local negative:Range = Range.FromLength(4, -3)
		AssertEquals(2, positive.Start().Value())
		AssertEquals(5, positive.EndExclusive().Value())
		AssertEquals(4, zero.EndExclusive().Value())
		AssertEquals(4, negative.EndExclusive().Value())
		AssertEquals("cde", "abcdef"[positive])
		AssertEquals("", "abcdef"[negative])
	End Method

	Method OffsetMovesOnlyDefinedBounds() { test }
		Local all:Range = Range.All().Offset(5)
		Local suffix:Range = Range.From(2).Offset(-1)
		Local prefix:Range = Range.Until(3).Offset(4)
		Local bounded:Range = Range.FromUntil(1, 4).Offset(2)
		AssertTrue(all.IsAll())
		AssertEquals(1, suffix.Start().Value())
		AssertFalse(suffix.HasEnd())
		AssertFalse(prefix.HasStart())
		AssertEquals(7, prefix.EndExclusive().Value())
		AssertEquals(3, bounded.Start().Value())
		AssertEquals(6, bounded.EndExclusive().Value())
	End Method

	Method ResolveFillsOpenBoundsWithoutClamping() { test }
		Local all:ResolvedRange = Range.All().Resolve(6)
		Local outOfBounds:ResolvedRange = Range.FromUntil(-2, 9).Resolve(6)
		AssertEquals(0, all.Start())
		AssertEquals(6, all.EndExclusive())
		AssertEquals(6, all.Length())
		AssertFalse(all.IsEmpty())
		AssertEquals(-2, outOfBounds.Start())
		AssertEquals(9, outOfBounds.EndExclusive())
		AssertEquals(11, outOfBounds.Length())
	End Method

	Method ResolvedReversedRangeRetainsCoordinatesButIsEmpty() { test }
		Local resolved:ResolvedRange = Range.FromUntil(5, 2).Resolve(10)
		AssertEquals(5, resolved.Start())
		AssertEquals(2, resolved.EndExclusive())
		AssertEquals(0, resolved.Length())
		AssertTrue(resolved.IsEmpty())
	End Method

	Method ClampConstrainsCoordinatesAndHandlesNegativeLength() { test }
		Local wide:ResolvedRange = Range.FromUntil(-3, 12).Clamp(8)
		Local above:ResolvedRange = Range.FromUntil(10, 20).Clamp(8)
		Local reversed:ResolvedRange = Range.FromUntil(7, 2).Clamp(8)
		Local negativeLength:ResolvedRange = Range.All().Clamp(-4)
		AssertEquals(0, wide.Start())
		AssertEquals(8, wide.EndExclusive())
		AssertEquals(8, wide.Length())
		AssertEquals(8, above.Start())
		AssertEquals(8, above.EndExclusive())
		AssertTrue(above.IsEmpty())
		AssertEquals(7, reversed.Start())
		AssertEquals(2, reversed.EndExclusive())
		AssertTrue(reversed.IsEmpty())
		AssertEquals(0, negativeLength.Start())
		AssertEquals(0, negativeLength.EndExclusive())
	End Method

	Method ResolvedRangeCopiesAsAValue() { test }
		Local original:ResolvedRange = Range.FromUntil(1, 4).Resolve(10)
		Local copy:ResolvedRange = original
		original = Range.Single(8).Resolve(10)
		AssertEquals(1, copy.Start())
		AssertEquals(4, copy.EndExclusive())
		AssertEquals(8, original.Start())
	End Method

	Method EndpointsExposeOriginAndResolveAgainstLength() { test }
		Local openEndpoint:RangeEndpoint
		Local absolute:RangeEndpoint = RangeEndpoint.FromStart(-2)
		Local relative:RangeEndpoint = RangeEndpoint.FromEnd(2)
		AssertTrue(openEndpoint.IsOpen())
		AssertTrue(openEndpoint.IsUndefined())
		AssertTrue(absolute.IsFromStart())
		AssertEquals(-2, absolute.Value())
		AssertEquals(-2, absolute.Resolve(6, 0))
		AssertTrue(relative.IsFromEnd())
		AssertEquals(2, relative.Value())
		AssertEquals(4, relative.Resolve(6, 0))
		AssertEquals(6, RangeEndpoint.FromEnd(0).Resolve(6, 0))
		AssertEquals(8, RangeEndpoint.FromEnd(-2).Resolve(6, 0), "Negative end distance retains beyond-end padding coordinates")
	End Method

	Method RelativeFactoriesResolveAndSlice() { test }
		Local prefix:Range = Range.UntilFromEnd(2)
		Local suffix:Range = Range.FromEnd(2)
		Local middle:Range = Range.FromEndpoints(RangeEndpoint.FromEnd(5), RangeEndpoint.FromEnd(2))
		AssertTrue(prefix.EndExclusive().IsFromEnd())
		AssertEquals(4, prefix.ResolveEndExclusive(6))
		AssertEquals("abcd", "abcdef"[prefix])
		AssertEquals("ef", "abcdef"[suffix])
		AssertEquals("bcd", "abcdef"[middle])
		Local values:Int[] = [1, 2, 3, 4, 5, 6][middle]
		AssertEquals(3, values.Length)
		AssertEquals(2, values[0])
		AssertEquals(4, values[2])
	End Method

	Method RangeExpressionsConstructEveryEndpointShape() { test }
		Local absolute:Range = 1..4
		Local prefix:Range = ..^2
		Local suffix:Range = (^2..)
		Local all:Range = (..)
		Local relative:Range = ^5..^2
		AssertEquals("bcd", "abcdef"[absolute])
		AssertEquals("abcd", "abcdef"[prefix])
		AssertEquals("ef", "abcdef"[suffix])
		AssertEquals("abcdef", "abcdef"[all])
		AssertEquals("bcd", "abcdef"[relative])
		AssertTrue(prefix.EndExclusive().IsFromEnd())
		AssertTrue(suffix.Start().IsFromEnd())
	End Method

	Method RangeExpressionsKeepPowerUnambiguous() { test }
		Local absolutePower:Range = 1..2^2
		Local relativePower:Range = 1..^(2^1)
		AssertEquals(4, absolutePower.EndExclusive().Value())
		AssertTrue(relativePower.EndExclusive().IsFromEnd())
		AssertEquals(2, relativePower.EndExclusive().Value())
		AssertEquals("bcd", "abcdef"[absolutePower])
		AssertEquals("bcd", "abcdef"[relativePower])
	End Method

	Method RangeExpressionBoundsAreEvaluatedOnce() { test }
		rangeEndpointEvaluations = 0
		Local selected:Range = EvaluatedEndpoint(1)..^EvaluatedEndpoint(2)
		AssertEquals("bcd", "abcdef"[selected])
		AssertEquals(2, rangeEndpointEvaluations)
	End Method

	Method RelativeOffsetMovesResolvedCoordinates() { test }
		Local original:Range = Range.FromEndpoints(RangeEndpoint.FromEnd(5), RangeEndpoint.FromEnd(2))
		Local moved:Range = original.Offset(1)
		AssertEquals(4, moved.Start().Value(), "Moving right reduces a from-end distance")
		AssertEquals(1, moved.EndExclusive().Value())
		Local resolved:ResolvedRange = moved.Resolve(6)
		AssertEquals(2, resolved.Start())
		AssertEquals(5, resolved.EndExclusive())
		AssertEquals("cde", "abcdef"[moved])
	End Method

	Method ResolvedContainsUsesHalfOpenCoordinates() { test }
		Local resolved:ResolvedRange = Range.FromUntil(2, 5).Resolve(10)
		AssertFalse(resolved.Contains(1))
		AssertTrue(resolved.Contains(2))
		AssertTrue(resolved.Contains(4))
		AssertFalse(resolved.Contains(5))
		AssertFalse(New ResolvedRange(5, 2).Contains(3), "Reversed ranges contain no coordinates")
	End Method

	Method CoordinateArithmeticIsCheckedAtIntBoundaries() { test }
		Local failures:Int
		Local minimum:Int = -2147483647 - 1
		Local maximum:Int = 2147483647
		Local message:String

		AssertEquals(maximum, Range.Single(maximum - 1).EndExclusive().Value())
		AssertEquals(maximum, Range.FromLength(maximum - 2, 2).EndExclusive().Value())
		AssertEquals(minimum, Range.From(minimum + 1).Offset(-1).Start().Value())

		Try
			Range.Single(maximum)
		Catch exception:TRangeCoordinateException
			failures :+ 1
			message = exception.ToString()
		End Try
		Try
			Range.FromLength(maximum - 1, 2)
		Catch exception:TRangeCoordinateException
			failures :+ 1
		End Try
		Try
			Range.From(maximum).Offset(1)
		Catch exception:TRangeCoordinateException
			failures :+ 1
		End Try
		Try
			Range.Until(minimum).Offset(-1)
		Catch exception:TRangeCoordinateException
			failures :+ 1
		End Try
		Try
			RangeEndpoint.FromEnd(minimum).Resolve(maximum, 0)
		Catch exception:TRangeCoordinateException
			failures :+ 1
		End Try
		Try
			RangeEndpoint.FromEnd(minimum).Offset(1)
		Catch exception:TRangeCoordinateException
			failures :+ 1
		End Try
		Try
			New ResolvedRange(minimum, maximum).Length()
		Catch exception:TRangeCoordinateException
			failures :+ 1
		End Try

		AssertEquals(7, failures)
		AssertEquals("Range coordinate overflow in Range.Single", message)
		AssertEquals(0, New ResolvedRange(maximum, minimum).Length(), "Reversed width remains empty without overflowing")
	End Method
End Type

Type TStringRangeTest Extends TTest

	Method AllReturnsCompleteString() { test }
		AssertEquals("abcdef", "abcdef"[Range.All()])
		Local defaultRange:Range
		AssertEquals("abcdef", "abcdef"[defaultRange], "Default Range is reusable as All")
	End Method

	Method OpenBoundsSliceString() { test }
		AssertEquals("abc", "abcdef"[Range.Until(3)])
		AssertEquals("def", "abcdef"[Range.From(3)])
		AssertEquals("bcd", "abcdef"[Range.FromUntil(1, 4)])
	End Method

	Method FromEndNotationSlicesStringsDirectly() { test }
		AssertEquals("abcd", "abcdef"[..^2])
		AssertEquals("ef", "abcdef"[^2..])
		AssertEquals("bcd", "abcdef"[^5..^2])
		AssertEquals("bcd", "abcdef"[1..^(2^1)])
	End Method

	Method EmptyAndZeroLengthStringSlices() { test }
		AssertEquals("", ""[Range.All()])
		AssertEquals("", "abcdef"[Range.FromUntil(2, 2)])
		AssertEquals("", "abcdef"[Range.FromUntil(4, 2)], "A reversed range is empty")
		AssertEquals("", "abcdef"[Range.Until(-1)])
	End Method

	Method OutOfBoundsStringSlicesFollowBlitzMaxPadding() { test }
		AssertEquals("  ab", "abcdef"[Range.FromUntil(-2, 2)], "Negative starts pad with spaces")
		AssertEquals("ef  ", "abcdef"[Range.FromUntil(4, 8)], "Ends beyond Length pad with spaces")
		AssertEquals("   ", ""[Range.FromUntil(-1, 2)], "Empty receiver still observes slice width")
	End Method

	Method UnicodeStringUsesNormalStringSliceSemantics() { test }
		AssertEquals("βγδ", "αβγδε"[Range.FromUntil(1, 4)])
	End Method

	Method RangeAndReceiverAreEvaluatedOnce() { test }
		rangeReceiverEvaluations = 0
		rangeValueEvaluations = 0
		AssertEquals("bcd", EvaluatedText()[EvaluatedRange()])
		AssertEquals(1, rangeReceiverEvaluations, "Receiver evaluation count")
		AssertEquals(1, rangeValueEvaluations, "Range evaluation count")
	End Method

	Method OneRangeCanBeReused() { test }
		Local middle:Range = Range.FromUntil(1, 3)
		AssertEquals("bc", "abcd"[middle])
		AssertEquals("23", "1234"[middle])
	End Method
End Type

Type TArrayRangeTest Extends TTest

	Method AllReturnsACompleteArrayCopy() { test }
		Local source:Int[] = [10, 20, 30]
		Local result:Int[] = source[Range.All()]
		AssertEquals(3, result.Length)
		AssertEquals(10, result[0])
		AssertEquals(30, result[2])
		result[0] = 99
		AssertEquals(10, source[0], "Array slicing creates an independent Array")
	End Method

	Method OpenBoundsSliceArrays() { test }
		Local source:Int[] = [10, 20, 30, 40]
		Local prefix:Int[] = source[Range.Until(2)]
		Local suffix:Int[] = source[Range.From(2)]
		Local middle:Int[] = source[Range.FromUntil(1, 3)]
		AssertEquals(2, prefix.Length)
		AssertEquals(10, prefix[0])
		AssertEquals(20, prefix[1])
		AssertEquals(2, suffix.Length)
		AssertEquals(30, suffix[0])
		AssertEquals(40, suffix[1])
		AssertEquals(2, middle.Length)
		AssertEquals(20, middle[0])
		AssertEquals(30, middle[1])
	End Method

	Method EmptyArraySlicesUseEmptySentinel() { test }
		Local source:Int[] = [1, 2, 3]
		Local empty:Int[] = source[Range.FromUntil(2, 2)]
		Local reversed:Int[] = source[Range.FromUntil(3, 1)]
		Local emptySource:Int[]
		Local allEmpty:Int[] = emptySource[Range.All()]
		AssertEquals(0, empty.Length)
		AssertEquals(0, reversed.Length)
		AssertEquals(0, allEmpty.Length)
	End Method

	Method OutOfBoundsScalarArraySlicesAreDefaultFilled() { test }
		Local source:Int[] = [10, 20]
		Local result:Int[] = source[Range.FromUntil(-1, 3)]
		AssertEquals(4, result.Length)
		AssertEquals(0, result[0])
		AssertEquals(10, result[1])
		AssertEquals(20, result[2])
		AssertEquals(0, result[3])
	End Method

	Method OutOfBoundsManagedArraySlicesPreserveSentinels() { test }
		Local strings:String[] = ["a", "b"]
		Local stringResult:String[] = strings[Range.FromUntil(-1, 3)]
		AssertEquals(4, stringResult.Length)
		AssertEquals("", stringResult[0])
		AssertEquals("a", stringResult[1])
		AssertEquals("b", stringResult[2])
		AssertEquals("", stringResult[3])

		Local objects:TRangeMarker[] = [New TRangeMarker]
		Local objectResult:TRangeMarker[] = objects[Range.FromUntil(-1, 2)]
		AssertEquals(3, objectResult.Length)
		AssertNull(objectResult[0])
		AssertSame(objects[0], objectResult[1])
		AssertNull(objectResult[2])
	End Method

	Method StructArraysRetainValuesAndDefaultPadding() { test }
		Local source:SRangeValue[] = New SRangeValue[2]
		source[0].value = 7
		source[1].value = 9
		Local result:SRangeValue[] = source[Range.FromUntil(-1, 3)]
		AssertEquals(4, result.Length)
		AssertEquals(0, result[0].value)
		AssertEquals(7, result[1].value)
		AssertEquals(9, result[2].value)
		AssertEquals(0, result[3].value)
	End Method

	Method GenericFunctionCanApplyRange() { test }
		Local integers:Int[] = SliceValues<Int>([1, 2, 3, 4], Range.FromUntil(1, 3))
		Local strings:String[] = SliceValues<String>(["a", "b", "c"], Range.From(1))
		AssertEquals(2, integers.Length)
		AssertEquals(2, integers[0])
		AssertEquals(3, integers[1])
		AssertEquals(2, strings.Length)
		AssertEquals("b", strings[0])
		AssertEquals("c", strings[1])
	End Method

	Method GenericFunctionCanSliceFromEndDirectly() { test }
		Local integers:Int[] = SliceLast<Int>([1, 2, 3, 4], 2)
		Local strings:String[] = SliceLast<String>(["a", "b", "c"], 1)
		AssertEquals(2, integers.Length)
		AssertEquals(3, integers[0])
		AssertEquals(4, integers[1])
		AssertEquals(1, strings.Length)
		AssertEquals("c", strings[0])
	End Method

	Method FromEndNotationSlicesArraysDirectly() { test }
		Local values:Int[] = [1, 2, 3, 4, 5, 6, 7, 8]
		Local middle:Int[] = values[2..^4]
		Local relative:Int[] = values[^6..^2]
		AssertEquals(2, middle.Length)
		AssertEquals(3, middle[0])
		AssertEquals(4, middle[1])
		AssertEquals(4, relative.Length)
		AssertEquals(3, relative[0])
		AssertEquals(6, relative[3])
	End Method

	Method OneRangeCanSliceDifferentArrayTypes() { test }
		Local selected:Range = Range.FromUntil(1, 3)
		Local integers:Int[] = [1, 2, 3, 4][selected]
		Local strings:String[] = ["a", "b", "c", "d"][selected]
		AssertEquals(2, integers[0])
		AssertEquals(3, integers[1])
		AssertEquals("b", strings[0])
		AssertEquals("c", strings[1])
	End Method
End Type
