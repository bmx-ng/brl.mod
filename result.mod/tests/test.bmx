SuperStrict

Framework BRL.MaxUnit
Import BRL.Result

New TTestSuite.Run()

Type TResultMarker
	Field value:Int
End Type

Interface IResultMarker
	Method Read:Int()
End Interface

Type TResultInterfaceMarker Implements IResultMarker
	Field value:Int
	Method Read:Int()
		Return value
	End Method
End Type

Struct SResultPoint
	Field x:Int
	Field y:Int
End Struct

Type TResultMapperException Extends TBlitzException
End Type

Function DoubleResultValue:Int(value:Int)
	Return value * 2
End Function

Function ResultErrorLength:Int(error:String)
	Return error.Length
End Function

Function ContinueResult:Result<Long, String>(value:Int)
	If value < 0 Then Return Result<Long, String>.Err("negative")
	Return Result<Long, String>.Ok(Long(value) + 1)
End Function

Function RecoverResult:Result<Int, Long>(error:String)
	Return Result<Int, Long>.Ok(error.Length)
End Function

Function FoldResultOk:String(value:Int)
	Return "ok:" + value
End Function

Function FoldResultError:String(error:String)
	Return "err:" + error
End Function

Type TResultTest Extends TTest

	Method DefaultIsUninitialized() { test }
		Local result:Result<Int, String>
		AssertEquals(Int(EResultState.Uninitialized), Int(result.State()))
		AssertFalse(result.IsInitialized())
		AssertTrue(result.IsUninitialized())
		AssertFalse(result.IsOk())
		AssertFalse(result.IsErr())
	End Method

	Method OkAndErrPreserveDefaultValues() { test }
		Local ok:Result<Int, String> = Result<Int, String>.Ok(0)
		Local err:Result<Int, String> = Result<Int, String>.Err("")
		AssertTrue(ok.IsInitialized())
		AssertTrue(ok.IsOk())
		AssertFalse(ok.IsErr())
		AssertEquals(0, ok.Value())
		AssertEquals("fallback", ok.ErrorOr("fallback"))
		AssertTrue(err.IsInitialized())
		AssertTrue(err.IsErr())
		AssertFalse(err.IsOk())
		AssertEquals("", err.Error())
		AssertEquals(7, err.ValueOr(7))
	End Method

	Method ScalarStringArrayObjectInterfaceAndStructValues() { test }
		Local longValue:Result<Long, String> = Result<Long, String>.Ok(922337203685477580:Long)
		AssertEquals(922337203685477580:Long, longValue.Value())

		Local text:Result<String, Int> = Result<String, Int>.Ok("value")
		AssertEquals("value", text.Value())

		Local source:Int[] = [1, 2, 3]
		Local arrayValue:Result<Int[], String> = Result<Int[], String>.Ok(source)
		source[1] = 20
		AssertEquals(20, arrayValue.Value()[1])

		Local marker:TResultMarker = New TResultMarker
		marker.value = 42
		Local objectValue:Result<TResultMarker, String> = Result<TResultMarker, String>.Ok(marker)
		AssertSame(marker, objectValue.Value())

		Local interfaceMarker:TResultInterfaceMarker = New TResultInterfaceMarker
		interfaceMarker.value = 17
		Local interfaceValue:Result<IResultMarker, String> = Result<IResultMarker, String>.Ok(interfaceMarker)
		AssertEquals(17, interfaceValue.Value().Read())

		Local point:SResultPoint
		point.x = 8
		point.y = -3
		Local structValue:Result<SResultPoint, String> = Result<SResultPoint, String>.Ok(point)
		AssertEquals(8, structValue.Value().x)
		AssertEquals(-3, structValue.Value().y)
	End Method

	Method ManagedNullRemainsAnExplicitPayload() { test }
		Local marker:TResultMarker
		Local ok:Result<TResultMarker, String> = Result<TResultMarker, String>.Ok(marker)
		Local err:Result<Int, TResultMarker> = Result<Int, TResultMarker>.Err(marker)
		AssertTrue(ok.IsOk())
		AssertNull(ok.Value())
		AssertTrue(err.IsErr())
		AssertNull(err.Error())
	End Method

	Method NestedAndCallableValuesRemainTyped() { test }
		Local inner:Result<Int, String> = Result<Int, String>.Err("inner")
		Local outer:Result<Result<Int, String>, Long> = Result<Result<Int, String>, Long>.Ok(inner)
		AssertTrue(outer.Value().IsErr())
		AssertEquals("inner", outer.Value().Error())

		Local offset:Int = 2
		Local callable:Closure<Int()> = Function:Int()
			Return 40 + offset
		End Function
		Local callableResult:Result<Closure<Int()>, String> = Result<Closure<Int()>, String>.Ok(callable)
		AssertEquals(42, callableResult.Value()())
	End Method

	Method StructCopiesAreIndependent() { test }
		Local original:Result<Int, String> = Result<Int, String>.Ok(3)
		Local copy:Result<Int, String> = original
		original = Result<Int, String>.Err("changed")
		AssertEquals(3, copy.Value())
		AssertEquals("changed", original.Error())
	End Method

	Method WrongBranchAccessThrowsSpecificExceptions() { test }
		Local valueCaught:TResultValueException
		Try
			Result<Int, String>.Err("bad").Value()
		Catch exception:TResultValueException
			valueCaught = exception
		End Try
		AssertNotNull(valueCaught)
		AssertEquals("Result does not contain an Ok value", valueCaught.ToString())

		Local errorCaught:TResultErrorException
		Try
			Result<Int, String>.Ok(1).Error()
		Catch exception:TResultErrorException
			errorCaught = exception
		End Try
		AssertNotNull(errorCaught)
		AssertEquals("Result does not contain an Err value", errorCaught.ToString())
	End Method

	Method UninitializedOperationsThrowStateException() { test }
		Local result:Result<Int, String>
		AssertStateException(Function:Object()
			result.Value()
		End Function)
		AssertStateException(Function:Object()
			result.Error()
		End Function)
		AssertStateException(Function:Object()
			result.ValueOr(1)
		End Function)
		AssertStateException(Function:Object()
			result.ErrorOr("fallback")
		End Function)

		Local mapper:Closure<String(value:Int)> = Function:String(value:Int)
			Return String(value)
		End Function
		AssertStateException(Function:Object()
			result.Map<String>(mapper)
		End Function)

		Local errorMapper:Closure<Int(error:String)> = Function:Int(error:String)
			Return error.Length
		End Function
		AssertStateException(Function:Object()
			result.MapError<Int>(errorMapper)
		End Function)

		Local continuation:Closure<Result<Long, String>(value:Int)> = Function:Result<Long, String>(value:Int)
			Return Result<Long, String>.Ok(value)
		End Function
		AssertStateException(Function:Object()
			result.AndThen<Long>(continuation)
		End Function)

		Local recovery:Closure<Result<Int, Long>(error:String)> = Function:Result<Int, Long>(error:String)
			Return Result<Int, Long>.Err(error.Length)
		End Function
		AssertStateException(Function:Object()
			result.OrElse<Long>(recovery)
		End Function)

		Local okHandler:Closure<String(value:Int)> = Function:String(value:Int)
			Return "ok"
		End Function
		Local errorHandler:Closure<String(error:String)> = Function:String(error:String)
			Return "err"
		End Function
		AssertStateException(Function:Object()
			result.Fold<String>(okHandler, errorHandler)
		End Function)
	End Method

	Method TryAccessLeavesOutputUnchangedOnFailure() { test }
		Local ok:Result<Int, String> = Result<Int, String>.Ok(42)
		Local err:Result<Int, String> = Result<Int, String>.Err("bad")
		Local uninitialized:Result<Int, String>
		Local value:Int = 7
		Local error:String = "original"
		AssertTrue(ok.TryValue(value))
		AssertEquals(42, value)
		AssertFalse(err.TryValue(value))
		AssertEquals(42, value)
		AssertFalse(uninitialized.TryValue(value))
		AssertEquals(42, value)
		AssertTrue(err.TryError(error))
		AssertEquals("bad", error)
		AssertFalse(ok.TryError(error))
		AssertEquals("bad", error)
		AssertFalse(uninitialized.TryError(error))
		AssertEquals("bad", error)
	End Method

	Method MapAndMapErrorAreLazyAndExact() { test }
		Local valueCalls:Int
		Local errorCalls:Int
		Local valueOffset:Int = 1
		Local errorOffset:Int = 2
		Local mapValue:Closure<Int(value:Int)> = Function:Int(value:Int)
			valueCalls :+ 1
			Return value + valueOffset
		End Function
		Local mapError:Closure<Int(error:String)> = Function:Int(error:String)
			errorCalls :+ 1
			Return error.Length + errorOffset
		End Function

		Local ok:Result<Int, String> = Result<Int, String>.Ok(41)
		Local err:Result<Int, String> = Result<Int, String>.Err("bad")
		AssertEquals(42, ok.Map<Int>(mapValue).Value())
		AssertEquals("bad", err.Map<Int>(mapValue).Error())
		AssertEquals(41, ok.MapError<Int>(mapError).Value())
		AssertEquals(5, err.MapError<Int>(mapError).Error())
		AssertEquals(1, valueCalls)
		AssertEquals(1, errorCalls)
	End Method

	Method NonCapturingMapOverloadsRemainThinAndTyped() { test }
		AssertEquals(42, Result<Int, String>.Ok(21).Map<Int>(DoubleResultValue).Value())
		AssertEquals(3, Result<Int, String>.Err("bad").MapError<Int>(ResultErrorLength).Error())
	End Method

	Method AndThenAndOrElseShortCircuitExactly() { test }
		Local continueCalls:Int
		Local recoverCalls:Int
		Local continue:Closure<Result<Long, String>(value:Int)> = Function:Result<Long, String>(value:Int)
			continueCalls :+ 1
			Return Result<Long, String>.Ok(Long(value) + 1)
		End Function
		Local recover:Closure<Result<Int, Long>(error:String)> = Function:Result<Int, Long>(error:String)
			recoverCalls :+ 1
			Return Result<Int, Long>.Ok(error.Length)
		End Function

		Local ok:Result<Int, String> = Result<Int, String>.Ok(41)
		Local err:Result<Int, String> = Result<Int, String>.Err("bad")
		AssertEquals(42:Long, ok.AndThen<Long>(continue).Value())
		AssertEquals("bad", err.AndThen<Long>(continue).Error())
		AssertEquals(41, ok.OrElse<Long>(recover).Value())
		AssertEquals(3, err.OrElse<Long>(recover).Value())
		AssertEquals(1, continueCalls)
		AssertEquals(1, recoverCalls)
	End Method

	Method NonCapturingAndThenOrElseAndFoldRemainTyped() { test }
		AssertEquals(42:Long, Result<Int, String>.Ok(41).AndThen<Long>(ContinueResult).Value())
		AssertEquals(3, Result<Int, String>.Err("bad").OrElse<Long>(RecoverResult).Value())
		AssertEquals("ok:7", Result<Int, String>.Ok(7).Fold<String>(FoldResultOk, FoldResultError))
		AssertEquals("err:no", Result<Int, String>.Err("no").Fold<String>(FoldResultOk, FoldResultError))
	End Method

	Method FoldInvokesExactlyOneCapturingHandler() { test }
		Local okCalls:Int
		Local errorCalls:Int
		Local onOk:Closure<String(value:Int)> = Function:String(value:Int)
			okCalls :+ 1
			Return "value:" + value
		End Function
		Local onError:Closure<String(error:String)> = Function:String(error:String)
			errorCalls :+ 1
			Return "error:" + error
		End Function
		AssertEquals("value:4", Result<Int, String>.Ok(4).Fold<String>(onOk, onError))
		AssertEquals("error:x", Result<Int, String>.Err("x").Fold<String>(onOk, onError))
		AssertEquals(1, okCalls)
		AssertEquals(1, errorCalls)
	End Method

	Method MapperExceptionsPropagateUnchanged() { test }
		Local expected:TResultMapperException = New TResultMapperException
		Local mapper:Closure<Int(value:Int)> = Function:Int(value:Int)
			Throw expected
		End Function
		Local caught:TResultMapperException
		Try
			Result<Int, String>.Ok(1).Map<Int>(mapper)
		Catch exception:TResultMapperException
			caught = exception
		End Try
		AssertSame(expected, caught)
	End Method

	Method AssertStateException(action:Closure<Object()>)
		Local caught:TResultStateException
		Try
			action()
		Catch exception:TResultStateException
			caught = exception
		End Try
		AssertNotNull(caught)
		AssertEquals("Result is uninitialized", caught.ToString())
	End Method
End Type
