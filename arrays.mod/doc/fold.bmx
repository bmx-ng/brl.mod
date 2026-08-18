SuperStrict

Framework BRL.StandardIO
Import BRL.Arrays

Function Add:Int(total:Int, value:Int)
	Return total + value
End Function

Local total:Int = Fold<Int, Int>([1, 2, 3, 4], 0, Add)
Print total ' 10
