SuperStrict

Framework brl.collections
Import brl.standardio

Local data1:Int[] = [3, 4, 5, 6, 8, 9]
Local data2:Int[] = [1, 2, 3, 4]
Local data3:Int[] = [10, 11]

Local a:TSet<Int> = New TSet<Int>(data1)
Local b:TSet<Int> = New TSet<Int>(data2)
Local c:TSet<Int> = New TSet<Int>(data3)

Print "Set A"
For Local num:Int = EachIn a
	Print num
Next

Print "~nSet B"
For Local num:Int = EachIn b
	Print num
Next

Print "~nSet C"
For Local num:Int = EachIn c
	Print num
Next

Print "~nA.Union(B)"
a.Union(b)

Print "~nSet A"
For Local num:Int = EachIn a
	Print num
Next

Print "~nA.Union(C)"
a.Union(c)

Print "~nSet A"
For Local num:Int = EachIn a
	Print num
Next
