SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' create another object list containing the elements in reversed order
Local list2:TObjectList = list.Reversed()

' enumerate all the strings in the first list
For Local a:String = EachIn list
	Print a
Next

' enumerate all the strings in the second list
For Local a:String = EachIn list2
	Print a
Next

' outputs:
' one
' two
' three
' three
' two
' one