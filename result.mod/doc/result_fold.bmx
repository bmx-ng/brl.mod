SuperStrict

Framework BRL.StandardIO
Import BRL.Result

Function ShowValue:String(value:Int)
	Return "value=" + value
End Function

Function ShowError:String(error:String)
	Return "error: " + error
End Function

Local success:Result<Int, String> = Result<Int, String>.Ok(42)
Local failure:Result<Int, String> = Result<Int, String>.Err("not found")

Print success.Fold<String>(ShowValue, ShowError)
Print failure.Fold<String>(ShowValue, ShowError)
