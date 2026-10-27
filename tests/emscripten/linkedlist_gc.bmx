SuperStrict
Framework BRL.LinkedList
Import BRL.StandardIO

Type TBox
	Field value:Int
End Type

For Local j:Int = 0 Until 100
	Local list:TList = New TList
	For Local i:Int = 0 Until 100
		Local box:TBox = New TBox
		box.value = i
		list.AddLast(box)
	Next
	GCCollect()
	If list.Count() <> 100 Then Throw "list was lost"
Next
Print "linkedlist gc ok"
