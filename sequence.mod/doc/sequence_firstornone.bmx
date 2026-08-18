SuperStrict

Framework BRL.StandardIO
Import BRL.Sequence

Function GreaterThanTen:Int(value:Int)
	Return value > 10
End Function

Local first:Optional<Int> = Sequence<Int>.FromArray([3, 8, 13, 21]).FirstOrNone(GreaterThanTen)

Print first.ValueOr(-1) ' 13
