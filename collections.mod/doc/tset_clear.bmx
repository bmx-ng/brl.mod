SuperStrict

Framework brl.collections
Import brl.standardio

Local data1:Int[] = [1, 2, 3, 4, 5, 6]

Local set:TSet<Int> = New TSet<Int>(data1)

Print "Set : " + set.Count() + " elements"
For Local num:Int = EachIn set
	Print num
Next

Print "~nset.Clear()"
set.Clear()

Print "~nSet : " + set.Count() + " elements"
For Local num:Int = EachIn set
	Print num
Next
