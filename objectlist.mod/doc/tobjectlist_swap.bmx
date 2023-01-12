SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")


' create a second object list
Local list2:TObjectList = New TObjectList
list2.AddLast("four")
list2.AddLast("five")
list2.AddLast("six")


' swap the lists
list.Swap(list2)

' enumerate all the strings in the first list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' four
' five
' six
