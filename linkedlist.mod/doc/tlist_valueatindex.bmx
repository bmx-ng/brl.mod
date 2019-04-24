SuperStrict

' create a list to hold some objects
Local list:TList = New TList

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
