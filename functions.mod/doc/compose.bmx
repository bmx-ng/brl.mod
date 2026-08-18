SuperStrict

Framework BRL.StandardIO
Import BRL.Functions

Function DoubleValue:Int(value:Int)
	Return value * 2
End Function

Function FormatValue:String(value:Int)
	Return "value=" + value
End Function

Local transform:Closure<String(value:Int)> = Compose<Int, Int, String>(FormatValue, DoubleValue)
Print transform(21) ' value=42
