SuperStrict

Framework BRL.StandardIO
Import BRL.Functions

Function Square:Int(value:Int)
	Return value * value
End Function

Local result:Int = Pipe<Int, Int>(7, Square)
Print result ' 49
