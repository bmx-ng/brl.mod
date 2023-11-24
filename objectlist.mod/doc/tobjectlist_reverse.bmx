SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' reverse the list
list.Reverse()

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' three
' two
' one
