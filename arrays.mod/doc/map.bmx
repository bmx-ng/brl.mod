SuperStrict

Framework BRL.StandardIO
Import BRL.Arrays

Function Square:Int(value:Int)
	Return value * value
End Function

Local squares:Int[] = Map<Int, Int>([1, 2, 3, 4], Square)

For Local value:Int = EachIn squares
	Print value
Next
