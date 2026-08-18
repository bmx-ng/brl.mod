SuperStrict

Framework BRL.MaxUnit
Import BRL.Optional

New TTestSuite.Run()

Type TOptionalMarker
	Field value:Int
End Type

Interface IOptionalMarker
End Interface

Type TOptionalInterfaceMarker Implements IOptionalMarker
End Type

Struct SOptionalPoint
	Field x:Int
	Field y:Int
End Struct

Enum EOptionalNumber:Int
	Zero
	One
	Two
End Enum

Function WrapOptional<T>:Optional<T>(value:T)
	Return Optional<T>.FromValue(value)
End Function

Type TOptionalTest Extends TTest

	Method DefaultIsUndefined() { test }
		Local value:Optional<Int>
		AssertEquals(Int(EOptionalState.Undefined), Int(value.State()), "Default state")
		AssertTrue(value.IsUndefined(), "Default Optional should be undefined")
		AssertFalse(value.IsDefined(), "Default Optional should not be defined")
		AssertFalse(value.IsNull(), "Default Optional should not be explicitly null")
		AssertFalse(value.HasValue(), "Default Optional should not contain a value")
	End Method

	Method UndefinedFactoryCreatesUndefinedState() { test }
		Local value:Optional<String> = Optional<String>.Undefined()
		AssertEquals(Int(EOptionalState.Undefined), Int(value.State()), "Undefined factory state")
		AssertTrue(value.IsUndefined())
		AssertFalse(value.IsDefined())
		AssertFalse(value.IsNull())
		AssertFalse(value.HasValue())
	End Method

	Method NullFactoryCreatesDistinctDefinedState() { test }
		Local value:Optional<String> = Optional<String>.NullValue()
		AssertEquals(Int(EOptionalState.NullValue), Int(value.State()), "Null factory state")
		AssertFalse(value.IsUndefined())
		AssertTrue(value.IsDefined(), "Explicit null is a defined state")
		AssertTrue(value.IsNull())
		AssertFalse(value.HasValue())
	End Method

	Method FromValuePreservesZeroAndEmptyValues() { test }
		Local zero:Optional<Int> = Optional<Int>.FromValue(0)
		Local empty:Optional<String> = Optional<String>.FromValue("")
		AssertTrue(zero.HasValue(), "Zero remains a present value")
		AssertEquals(0, zero.Value())
		AssertTrue(empty.HasValue(), "Empty String remains a present value")
		AssertEquals("", empty.Value())
		AssertFalse(empty.IsNull(), "An explicitly present empty String is not the null state")
	End Method

	Method ValueReturnsScalarAndEnumValues() { test }
		Local number:Optional<Long> = Optional<Long>.FromValue(922337203685477580:Long)
		Local enumeration:Optional<EOptionalNumber> = Optional<EOptionalNumber>.FromValue(EOptionalNumber.Two)
		AssertEquals(922337203685477580:Long, number.Value())
		AssertEquals(Int(EOptionalNumber.Two), Int(enumeration.Value()))
	End Method

	Method ValuePreservesStructValues() { test }
		Local point:SOptionalPoint
		point.x = 12
		point.y = -7
		Local value:Optional<SOptionalPoint> = Optional<SOptionalPoint>.FromValue(point)
		AssertTrue(value.HasValue())
		AssertEquals(12, value.Value().x)
		AssertEquals(-7, value.Value().y)
	End Method

	Method ValuePreservesManagedIdentity() { test }
		Local marker:TOptionalMarker = New TOptionalMarker
		marker.value = 42
		Local value:Optional<TOptionalMarker> = Optional<TOptionalMarker>.FromValue(marker)
		AssertSame(marker, value.Value(), "Object identity should be preserved")
		marker.value = 99
		AssertEquals(99, value.Value().value, "Optional retains the same managed object")
	End Method

	Method ValuePreservesArrayReference() { test }
		Local source:Int[] = [1, 2, 3]
		Local value:Optional<Int[]> = Optional<Int[]>.FromValue(source)
		AssertEquals(3, value.Value().Length)
		source[1] = 20
		AssertEquals(20, value.Value()[1], "Optional retains the managed Array value")
	End Method

	Method NestedOptionalRetainsInnerState() { test }
		Local inner:Optional<Int> = Optional<Int>.FromValue(37)
		Local outer:Optional<Optional<Int>> = Optional<Optional<Int>>.FromValue(inner)
		AssertTrue(outer.HasValue())
		AssertTrue(outer.Value().HasValue())
		AssertEquals(37, outer.Value().Value())

		Local nestedNull:Optional<Optional<String>> = Optional<Optional<String>>.FromValue(Optional<String>.NullValue())
		AssertTrue(nestedNull.HasValue(), "Outer Optional contains an inner Optional")
		AssertTrue(nestedNull.Value().IsNull(), "Inner null state is retained")
	End Method

	Method GenericFactoryWorksForClosedTypes() { test }
		Local integer:Optional<Int> = WrapOptional<Int>(17)
		Local text:Optional<String> = WrapOptional<String>("generic")
		AssertEquals(17, integer.Value())
		AssertEquals("generic", text.Value())
	End Method

	Method ClosureValuesRemainCallable() { test }
		Local base:Int = 40
		Local functionValue:Closure<Int()> = Function:Int()
			Return base + 2
		End Function
		Local callable:Optional<Closure<Int()>> = Optional<Closure<Int()>>.FromValue(functionValue)
		AssertTrue(callable.HasValue())
		AssertEquals(42, callable.Value()())
	End Method

	Method ValueOrUsesValueOnlyForPresentState() { test }
		Local present:Optional<Int> = Optional<Int>.FromValue(0)
		Local undefined:Optional<Int>
		Local nullValue:Optional<Int> = Optional<Int>.NullValue()
		AssertEquals(0, present.ValueOr(7), "A present zero must not be replaced")
		AssertEquals(7, undefined.ValueOr(7), "Undefined uses fallback")
		AssertEquals(7, nullValue.ValueOr(7), "Explicit null uses fallback")
	End Method

	Method TryGetReturnsPresentValue() { test }
		Local value:Optional<String> = Optional<String>.FromValue("found")
		Local result:String
		AssertTrue(value.TryGet(result))
		AssertEquals("found", result)
	End Method

	Method TryGetResetsScalarOnFailure() { test }
		Local undefined:Optional<Int>
		Local result:Int = 123
		AssertFalse(undefined.TryGet(result))
		AssertEquals(0, result, "Failed TryGet resets a scalar to its default")
	End Method

	Method TryGetResetsManagedValuesOnFailure() { test }
		Local nullText:Optional<String> = Optional<String>.NullValue()
		Local text:String = "stale"
		AssertFalse(nullText.TryGet(text))
		AssertEquals("", text, "Failed String TryGet preserves the empty sentinel")

		Local undefinedArray:Optional<Int[]>
		Local array:Int[] = [1, 2]
		AssertFalse(undefinedArray.TryGet(array))
		AssertEquals(0, array.Length, "Failed Array TryGet preserves the empty Array sentinel")

		Local undefinedObject:Optional<TOptionalMarker>
		Local marker:TOptionalMarker = New TOptionalMarker
		AssertFalse(undefinedObject.TryGet(marker))
		AssertNull(marker, "Failed object TryGet resets to BlitzMax Null")

		Local undefinedInterface:Optional<IOptionalMarker>
		Local interfaceValue:IOptionalMarker = New TOptionalInterfaceMarker
		AssertFalse(undefinedInterface.TryGet(interfaceValue))
		AssertTrue(interfaceValue = Null, "Failed Interface TryGet resets to BlitzMax Null")
	End Method

	Method ValueThrowsForUndefined() { test }
		Local value:Optional<Int>
		Local caught:TOptionalValueException
		Try
			value.Value()
			Fail("Undefined Value() should throw")
		Catch exception:TOptionalValueException
			caught = exception
		End Try
		AssertNotNull(caught)
		AssertEquals("Optional does not contain a value", caught.ToString())
	End Method

	Method ValueThrowsForExplicitNull() { test }
		Local value:Optional<String> = Optional<String>.NullValue()
		Local threw:Int
		Try
			value.Value()
		Catch exception:TOptionalValueException
			threw = True
		End Try
		AssertTrue(threw, "Explicit null Value() should throw")
	End Method

	Method StructCopiesRetainIndependentScalarValues() { test }
		Local original:Optional<Int> = Optional<Int>.FromValue(3)
		Local copy:Optional<Int> = original
		original = Optional<Int>.FromValue(9)
		AssertEquals(3, copy.Value(), "Optional is copied as a value")
		AssertEquals(9, original.Value())
	End Method

	Method MapTransformsValuesAndCapturesState() { test }
		Local offset:Int = 5
		Local calls:Int
		Local mapper:Closure<String(value:Int)> = Function:String(value:Int)
			calls :+ 1
			Return String(value + offset)
		End Function
		Local result:Optional<String> = Optional<Int>.FromValue(37).Map<String>(mapper)
		AssertEquals("42", result.Value())
		AssertEquals(1, calls)
	End Method

	Method MapPropagatesBothAbsenceStatesLazily() { test }
		Local calls:Int
		Local mapper:Closure<String(value:Int)> = Function:String(value:Int)
			calls :+ 1
			Return String(value)
		End Function
		Local undefined:Optional<Int>
		Local nullValue:Optional<Int> = Optional<Int>.NullValue()
		AssertTrue(undefined.Map<String>(mapper).IsUndefined())
		AssertTrue(nullValue.Map<String>(mapper).IsNull())
		AssertEquals(0, calls)
	End Method

	Method MapSupportsArrayObjectAndStructResults() { test }
		Local arrayMapper:Closure<Int[](value:Int)> = Function:Int[](value:Int)
			Return [value, value + 1]
		End Function
		Local objectMapper:Closure<TOptionalMarker(value:Int)> = Function:TOptionalMarker(value:Int)
			Local marker:TOptionalMarker = New TOptionalMarker
			marker.value = value
			Return marker
		End Function
		Local structMapper:Closure<SOptionalPoint(value:Int)> = Function:SOptionalPoint(value:Int)
			Local point:SOptionalPoint
			point.x = value
			point.y = -value
			Return point
		End Function

		Local arrayValue:Optional<Int[]> = Optional<Int>.FromValue(4).Map<Int[]>(arrayMapper)
		Local objectValue:Optional<TOptionalMarker> = Optional<Int>.FromValue(8).Map<TOptionalMarker>(objectMapper)
		Local structValue:Optional<SOptionalPoint> = Optional<Int>.FromValue(6).Map<SOptionalPoint>(structMapper)
		AssertEquals(2, arrayValue.Value().Length)
		AssertEquals(5, arrayValue.Value()[1])
		AssertEquals(8, objectValue.Value().value)
		AssertEquals(6, structValue.Value().x)
		AssertEquals(-6, structValue.Value().y)
	End Method

	Method FlatMapReturnsMapperStateAndPreservesExistingAbsence() { test }
		Local calls:Int
		Local toNull:Closure<Optional<String>(value:Int)> = Function:Optional<String>(value:Int)
			calls :+ 1
			Return Optional<String>.NullValue()
		End Function
		Local present:Optional<String> = Optional<Int>.FromValue(1).FlatMap<String>(toNull)
		Local undefined:Optional<Int>
		Local absent:Optional<String> = undefined.FlatMap<String>(toNull)
		Local existingNull:Optional<String> = Optional<Int>.NullValue().FlatMap<String>(toNull)
		AssertTrue(present.IsNull(), "FlatMap retains the mapper's exact state")
		AssertTrue(absent.IsUndefined())
		AssertTrue(existingNull.IsNull())
		AssertEquals(1, calls)
	End Method

	Method FlatMapSupportsNestedOptionals() { test }
		Local mapper:Closure<Optional<Optional<Int>>(value:Int)> = Function:Optional<Optional<Int>>(value:Int)
			Return Optional<Optional<Int>>.FromValue(Optional<Int>.FromValue(value + 1))
		End Function
		Local result:Optional<Optional<Int>> = Optional<Int>.FromValue(9).FlatMap<Optional<Int>>(mapper)
		AssertEquals(10, result.Value().Value())
	End Method

	Method FilterRetainsMatchesAndRejectsToUndefined() { test }
		Local calls:Int
		Local even:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ 1
			Return value Mod 2 = 0
		End Function
		AssertEquals(4, Optional<Int>.FromValue(4).Filter(even).Value())
		AssertTrue(Optional<Int>.FromValue(3).Filter(even).IsUndefined())
		AssertTrue(Optional<Int>.NullValue().Filter(even).IsNull())
		Local undefined:Optional<Int>
		AssertTrue(undefined.Filter(even).IsUndefined())
		AssertEquals(2, calls)
	End Method

	Method IfPresentInvokesOnlyForValue() { test }
		Local total:Int
		Local action:Closure<(value:Int)> = Function(value:Int)
			total :+ value
		End Function
		Optional<Int>.FromValue(7).IfPresent(action)
		Optional<Int>.NullValue().IfPresent(action)
		Local undefined:Optional<Int>
		undefined.IfPresent(action)
		AssertEquals(7, total)
	End Method

	Method ValueOrElseIsLazyForPresentAndUsedForEitherAbsence() { test }
		Local calls:Int
		Local factory:Closure<Int()> = Function:Int()
			calls :+ 1
			Return 99
		End Function
		AssertEquals(5, Optional<Int>.FromValue(5).ValueOrElse(factory))
		AssertEquals(0, calls)
		AssertEquals(99, Optional<Int>.NullValue().ValueOrElse(factory))
		Local undefined:Optional<Int>
		AssertEquals(99, undefined.ValueOrElse(factory))
		AssertEquals(2, calls)
	End Method

	Method StateSpecificRecoveryIsLazyAndExact() { test }
		Local calls:Int
		Local recover:Closure<Optional<Int>()> = Function:Optional<Int>()
			calls :+ 1
			Return Optional<Int>.FromValue(42)
		End Function
		Local undefined:Optional<Int>
		Local nullValue:Optional<Int> = Optional<Int>.NullValue()
		Local present:Optional<Int> = Optional<Int>.FromValue(7)
		AssertEquals(42, undefined.OrIfUndefined(recover).Value())
		AssertTrue(nullValue.OrIfUndefined(recover).IsNull())
		AssertEquals(42, nullValue.OrIfNull(recover).Value())
		AssertTrue(undefined.OrIfNull(recover).IsUndefined())
		AssertEquals(42, undefined.OrIfEmpty(recover).Value())
		AssertEquals(42, nullValue.OrIfEmpty(recover).Value())
		AssertEquals(7, present.OrIfEmpty(recover).Value())
		AssertEquals(4, calls)
	End Method

	Method MatchExhaustivelySelectsOneHandler() { test }
		Local valueCalls:Int
		Local nullCalls:Int
		Local undefinedCalls:Int
		Local onValue:Closure<String(value:Int)> = Function:String(value:Int)
			valueCalls :+ 1
			Return "value:" + value
		End Function
		Local onNull:Closure<String()> = Function:String()
			nullCalls :+ 1
			Return "null"
		End Function
		Local onUndefined:Closure<String()> = Function:String()
			undefinedCalls :+ 1
			Return "undefined"
		End Function
		Local undefined:Optional<Int>
		AssertEquals("value:3", Optional<Int>.FromValue(3).Match<String>(onValue, onNull, onUndefined))
		AssertEquals("null", Optional<Int>.NullValue().Match<String>(onValue, onNull, onUndefined))
		AssertEquals("undefined", undefined.Match<String>(onValue, onNull, onUndefined))
		AssertEquals(1, valueCalls)
		AssertEquals(1, nullCalls)
		AssertEquals(1, undefinedCalls)
	End Method

	Method VisitExhaustivelySelectsOneSideEffectingHandler() { test }
		Local visited:String
		Local onValue:Closure<(value:Int)> = Function(value:Int)
			visited :+ "value:" + value + ";"
		End Function
		Local onNull:Closure<()> = Function()
			visited :+ "null;"
		End Function
		Local onUndefined:Closure<()> = Function()
			visited :+ "undefined;"
		End Function
		Local undefined:Optional<Int>
		Optional<Int>.FromValue(4).Visit(onValue, onNull, onUndefined)
		Optional<Int>.NullValue().Visit(onValue, onNull, onUndefined)
		undefined.Visit(onValue, onNull, onUndefined)
		AssertEquals("value:4;null;undefined;", visited)
	End Method

	Method ClosureExceptionsPropagate() { test }
		Local mapper:Closure<Int(value:Int)> = Function:Int(value:Int)
			Throw "map failure"
		End Function
		Local caught:String
		Try
			Optional<Int>.FromValue(1).Map<Int>(mapper)
		Catch message:String
			caught = message
		End Try
		AssertEquals("map failure", caught)

		Local visitValue:Closure<(value:Int)> = Function(value:Int)
			Throw "visit failure"
		End Function
		Local visitNull:Closure<()> = Function()
		End Function
		Local visitUndefined:Closure<()> = Function()
		End Function
		Try
			Optional<Int>.FromValue(1).Visit(visitValue, visitNull, visitUndefined)
		Catch message:String
			caught = message
		End Try
		AssertEquals("visit failure", caught)
	End Method

	Method MissingClosuresAreSafeWhenTheirStateIsNotSelected() { test }
		Local missingMapper:Closure<String(value:Int)>
		Local missingFactory:Closure<Optional<Int>()>
		Local undefined:Optional<Int>
		AssertTrue(undefined.Map<String>(missingMapper).IsUndefined())
		AssertEquals(2, Optional<Int>.FromValue(2).OrIfEmpty(missingFactory).Value())
	End Method

	Method MissingSelectedClosuresThrowNormalNullFunctionException() { test }
		Local failures:Int
		Local missingMapper:Closure<String(value:Int)>
		Local missingFlatMapper:Closure<Optional<String>(value:Int)>
		Local missingPredicate:Closure<Int(value:Int)>
		Local missingAction:Closure<(value:Int)>
		Local missingValueFactory:Closure<Int()>
		Local missingOptionalFactory:Closure<Optional<Int>()>
		Local missingNullHandler:Closure<String()>
		Local missingVisitNullHandler:Closure<()>
		Local valueHandler:Closure<String(value:Int)> = Function:String(value:Int)
			Return String(value)
		End Function
		Local undefinedHandler:Closure<String()> = Function:String()
			Return "undefined"
		End Function

		Try
			Optional<Int>.FromValue(1).Map<String>(missingMapper)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Try
			Optional<Int>.FromValue(1).FlatMap<String>(missingFlatMapper)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Try
			Optional<Int>.FromValue(1).Filter(missingPredicate)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Try
			Optional<Int>.FromValue(1).IfPresent(missingAction)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Try
			Optional<Int>.Undefined().ValueOrElse(missingValueFactory)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Try
			Optional<Int>.Undefined().OrIfUndefined(missingOptionalFactory)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Try
			Optional<Int>.NullValue().Match<String>(valueHandler, missingNullHandler, undefinedHandler)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		Local visitValueHandler:Closure<(value:Int)> = Function(value:Int)
		End Function
		Local visitUndefinedHandler:Closure<()> = Function()
		End Function
		Try
			Optional<Int>.NullValue().Visit(visitValueHandler, missingVisitNullHandler, visitUndefinedHandler)
		Catch exception:TNullFunctionException
			failures :+ 1
		End Try
		AssertEquals(8, failures, "Every selected missing Closure follows normal Closure call failure semantics")
	End Method
End Type
