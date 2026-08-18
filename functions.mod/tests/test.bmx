SuperStrict

Framework BRL.MaxUnit
Import BRL.Functions
Import BRL.Result
Import BRL.Sequence

New TTestSuite.Run()

Type TFunctionsMarker
	Field value:Int
End Type

Interface IFunctionsMarker
	Method Read:Int()
End Interface

Type TFunctionsInterfaceMarker Implements IFunctionsMarker
	Field value:Int
	Method Read:Int()
		Return value
	End Method
End Type

Struct SFunctionsPoint
	Field x:Int
	Field y:Int
End Struct

Type TFunctionsException Extends TBlitzException
End Type

Function DoubleFunction:Int(value:Int)
	Return value * 2
End Function

Function IncrementFunction:Int(value:Int)
	Return value + 1
End Function

Function RenderFunction:String(value:Int)
	Return "value:" + value
End Function

Function StringLengthFunction:Int(value:String)
	Return value.Length
End Function

Type TFunctionsTest Extends TTest

	Method IdentitySupportsRoutineReferencesAndValues() { test }
		Local identityFunction:Int(value:Int) = Identity<Int>
		AssertEquals(42, identityFunction(42))
		AssertEquals("text", Identity<String>("text"))

		Local values:Int[] = [1, 2, 3]
		AssertSame(values, Identity<Int[]>(values))

		Local marker:TFunctionsMarker = New TFunctionsMarker
		marker.value = 7
		AssertSame(marker, Identity<TFunctionsMarker>(marker))
		Local missing:TFunctionsMarker
		AssertNull(Identity<TFunctionsMarker>(missing))

		Local interfaceMarker:TFunctionsInterfaceMarker = New TFunctionsInterfaceMarker
		interfaceMarker.value = 9
		Local abstractMarker:IFunctionsMarker = interfaceMarker
		AssertEquals(9, Identity<IFunctionsMarker>(abstractMarker).Read())

		Local point:SFunctionsPoint
		point.x = 4
		point.y = 5
		Local copied:SFunctionsPoint = Identity<SFunctionsPoint>(point)
		AssertEquals(4, copied.x)
		AssertEquals(5, copied.y)
	End Method

	Method IdentityPreservesNestedAndCallableTypes() { test }
		Local nested:Result<Int, String> = Result<Int, String>.Err("nested")
		AssertEquals("nested", Identity<Result<Int, String>>(nested).Error())

		Local callable:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value * 2
		End Function
		Local same:Closure<Int(value:Int)> = Identity<Closure<Int(value:Int)>>(callable)
		AssertEquals(42, same(21))
	End Method

	Method ConstantCapturesByValue() { test }
		Local answer:Closure<Int(value:String)> = Constant<Int, String>(42)
		AssertEquals(42, answer("ignored"))
		AssertEquals(42, answer("again"))

		Local point:SFunctionsPoint
		point.x = 3
		Local pointFactory:Closure<SFunctionsPoint(value:Int)> = Constant<SFunctionsPoint, Int>(point)
		point.x = 99
		AssertEquals(3, pointFactory(0).x)

		Local marker:TFunctionsMarker = New TFunctionsMarker
		Local markerFactory:Closure<TFunctionsMarker(value:Int)> = Constant<TFunctionsMarker, Int>(marker)
		AssertSame(marker, markerFactory(0))
	End Method

	Method ComposeRunsInnerThenOuterExactlyOnce() { test }
		Local calls:String
		Local offset:Int = 1
		Local inner:Closure<Int(value:Int)> = Function:Int(value:Int)
			calls :+ "i"
			Return value + offset
		End Function
		Local outer:Closure<String(value:Int)> = Function:String(value:Int)
			calls :+ "o"
			Return "value:" + value
		End Function
		Local composed:Closure<String(value:Int)> = Compose<Int, Int, String>(outer, inner)
		AssertEquals("value:42", composed(41))
		AssertEquals("io", calls)
	End Method

	Method ComposeSupportsEveryCallablePairing() { test }
		Local offset:Int = 1
		Local innerClosure:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value + offset
		End Function
		Local prefix:String = "value:"
		Local outerClosure:Closure<String(value:Int)> = Function:String(value:Int)
			Return prefix + value
		End Function

		AssertEquals("value:42", Compose<Int, Int, String>(RenderFunction, IncrementFunction)(41))
		AssertEquals("value:42", Compose<Int, Int, String>(outerClosure, IncrementFunction)(41))
		AssertEquals("value:42", Compose<Int, Int, String>(RenderFunction, innerClosure)(41))
		AssertEquals("value:42", Compose<Int, Int, String>(outerClosure, innerClosure)(41))
	End Method

	Method ComposeSupportsNestedPipelines() { test }
		Local incrementThenDouble:Closure<Int(value:Int)> = Compose<Int, Int, Int>(DoubleFunction, IncrementFunction)
		Local render:Closure<String(value:Int)> = Compose<Int, Int, String>(RenderFunction, incrementThenDouble)
		AssertEquals("value:42", render(20))
	End Method

	Method PipeSupportsClosureAndThinFunctions() { test }
		AssertEquals(42, Pipe<Int, Int>(21, DoubleFunction))

		Local offset:Int = 2
		Local mapper:Closure<Int(value:Int)> = Function:Int(value:Int)
			Return value + offset
		End Function
		AssertEquals(42, Pipe<Int, Int>(40, mapper))
		AssertEquals(3, Pipe<String, Int>("abc", StringLengthFunction))
	End Method

	Method ExceptionsPropagateUnchanged() { test }
		Local expected:TFunctionsException = New TFunctionsException
		Local fail:Closure<Int(value:Int)> = Function:Int(value:Int)
			Throw expected
		End Function
		Local caught:TFunctionsException
		Try
			Pipe<Int, Int>(1, fail)
		Catch exception:TFunctionsException
			caught = exception
		End Try
		AssertSame(expected, caught)

		caught = Null
		Local composed:Closure<String(value:Int)> = Compose<Int, Int, String>(RenderFunction, fail)
		Try
			composed(1)
		Catch exception:TFunctionsException
			caught = exception
		End Try
		AssertSame(expected, caught)
	End Method

	Method IntegratesWithResultAndSequence() { test }
		AssertEquals(42, Result<Int, String>.Ok(42).Map<Int>(Identity<Int>).Value())
		Local values:Int[] = Sequence<Int>.FromArray([1, 2, 3]).Map<Int>(Identity<Int>).ToArray()
		AssertEquals(3, values.Length)
		AssertEquals(2, values[1])
	End Method
End Type
