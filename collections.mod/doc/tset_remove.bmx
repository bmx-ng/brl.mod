SuperStrict

Framework brl.collections
Import brl.standardio

Local data1:Int[] = [1, 2, 3, 4, 5, 6, 7, 8, 9]

Local set:TSet<Int> = New TSet<Int>(data1)

Print "Set:"
For Local num:Int = EachIn set
	Print num
Next

Print "~nset.Remove(4) : 1"
Print set.Remove(4)

Print "~nset.Remove(4) : 0"
Print set.Remove(4)

Print "~nSet:"
For Local num:Int = EachIn set
	Print num
Next
