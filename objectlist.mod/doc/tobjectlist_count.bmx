SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList


' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' print amount of elements in the list
Print list.Count()

' outputs:
' 3