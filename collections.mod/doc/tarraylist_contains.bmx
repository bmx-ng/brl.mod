SuperStrict

Framework brl.collections
Import brl.standardio

Local data:Int[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Local list:TArrayList<Int> = New TArrayList<Int>(data)

For Local i:Int = EachIn list
	Print i
Next

Print "~nContains(0) : " + list.Contains(0)
Print "Contains(5) : " + list.Contains(5)
Print "Contains(15) : " + list.Contains(15)
