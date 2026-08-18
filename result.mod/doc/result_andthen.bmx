SuperStrict

Framework BRL.StandardIO
Import BRL.Result

Function Reciprocal:Result<Float, String>(value:Int)
	If value = 0 Then Return Result<Float, String>.Err("division by zero")
	Return Result<Float, String>.Ok(1.0 / Float(value))
End Function

Local answer:Result<Float, String> = Result<Int, String>.Ok(4).AndThen<Float>(Reciprocal)
Print answer.ValueOr(0.0) ' 0.25

Local failed:Result<Float, String> = Result<Int, String>.Ok(0).AndThen<Float>(Reciprocal)
Print failed.ErrorOr("") ' division by zero
