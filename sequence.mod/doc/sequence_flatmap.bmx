SuperStrict

Framework BRL.StandardIO
Import BRL.Sequence

Function Digits:Sequence<Int>(value:Int)
	Local result:Int[] = New Int[String(value).Length]
	For Local index:Int = 0 Until result.Length
		result[index] = String(value)[index] - Asc("0")
	Next
	Return Sequence<Int>.FromArray(result)
End Function

Local digits:Int[] = Sequence<Int>.FromArray([12, 305]). ..
	FlatMap<Int>(Digits). ..
	ToArray()

For Local digit:Int = EachIn digits
	Print digit
Next
