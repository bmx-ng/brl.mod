SuperStrict

Framework brl.collections
Import brl.standardio

Local data1:Int[] = [1, 2, 3, 4, 5, 6]

Local set:TSet<Int> = New TSet<Int>(data1)

Print "Set:"
For Local num:Int = EachIn set
	Print num
Next

Print "~nset.Contains(5) : " + set.Contains(5)

Print "~nset.Contains(8) : " + set.Remove(8)
