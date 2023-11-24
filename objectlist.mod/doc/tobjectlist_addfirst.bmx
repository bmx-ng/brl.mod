SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the begin of the list
list.AddFirst("one")
list.AddFirst("two")
list.AddFirst("three")

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' three
' two
' one
