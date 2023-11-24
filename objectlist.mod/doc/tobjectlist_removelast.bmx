SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the begin of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' remove the last element of the list
list.RemoveLast()

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' one
' two
