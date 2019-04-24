SuperStrict

' create a list to hold some objects
Local list:TList = New TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")


' request the last element in the list and cast it (back) to a string
' cast is needed as the function returns "object" rather than "string"
Local value:String = String(list.Last())

Print value

' outputs:
' three
