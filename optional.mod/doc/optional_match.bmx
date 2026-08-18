SuperStrict

Framework BRL.StandardIO
Import BRL.Optional

Function Describe:String(value:Optional<Int>)
	Local onValue:Closure<String(number:Int)> = Function:String(number:Int)
		Return "value=" + number
	End Function
	Local onNull:Closure<String()> = Function:String()
		Return "explicitly null"
	End Function
	Local onUndefined:Closure<String()> = Function:String()
		Return "undefined"
	End Function
	Return value.Match<String>(onValue, onNull, onUndefined)
End Function

Print Describe(Optional<Int>.FromValue(7))
Print Describe(Optional<Int>.NullValue())
Print Describe(Optional<Int>.Undefined())
