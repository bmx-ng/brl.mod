SuperStrict

Framework BRL.StandardIO
Import BRL.Sequence

Function IsEven:Int(value:Int)
	Return value Mod 2 = 0
End Function

Function Square:Int(value:Int)
	Return value * value
End Function

Local values:Int[] = Sequence<Int>.FromArray([1, 2, 3, 4, 5, 6]). ..
	Filter(IsEven). ..
	Map<Int>(Square). ..
	ToArray()

For Local value:Int = EachIn values
	Print value
Next
