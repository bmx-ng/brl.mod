SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' find the element at the given index and cast it (back) to a string
' cast is needed as the function returns "object" rather than "string"
Local value:String = String(list.ValueAtIndex(1))

Print value 

' outputs:
' two
