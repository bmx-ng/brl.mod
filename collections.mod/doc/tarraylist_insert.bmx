SuperStrict

Framework brl.collections
Import brl.standardio

Local data:String[] = ["two", "three", "five", "six"]

Local list:TArrayList<String> = New TArrayList<String>(data)

Print "Count : " + list.Count()
Print

For Local num:String = EachIn list
	Print num
Next

list.Insert(0, "one")
list.Insert(3, "four")
list.Insert(6, "seven")

Print "~nCount : " + list.Count()
Print

For Local num:String = EachIn list
	Print num
Next
