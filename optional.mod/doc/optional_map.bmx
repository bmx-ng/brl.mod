SuperStrict

Framework BRL.StandardIO
Import BRL.Optional

Local score:Optional<Int> = Optional<Int>.FromValue(21)
Local doubleValue:Closure<Int(value:Int)> = Function:Int(value:Int)
	Return value * 2
End Function
Local doubled:Optional<Int> = score.Map<Int>(doubleValue)

Print doubled.ValueOr(0) ' 42

Local missing:Optional<Int> = Optional<Int>.Undefined()
Print missing.Map<Int>(doubleValue).IsUndefined() ' True
