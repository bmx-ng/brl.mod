SuperStrict

Framework brl.collections
Import brl.standardio

Local data1:Int[] = [3, 4, 5, 6, 7, 8]
Local data2:Int[] = [1, 2, 3, 4, 5]

Local a:TSet<Int> = New TSet<Int>(data1)
Local b:TSet<Int> = New TSet<Int>(data2)

Print "Set A"
For Local num:Int = EachIn a
	Print num
Next

Print "~nSet B"
For Local num:Int = EachIn b
	Print num
Next

Print "~nA.SymmetricDifference(B)"
a.SymmetricDifference(b)

Print "~nSet A"
For Local num:Int = EachIn a
	Print num
Next
