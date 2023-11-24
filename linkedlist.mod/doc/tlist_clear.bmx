SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = New TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' print amount of elements in the list
Print list.Count()

' clear the list and remove all elements
list.Clear()

' print amount of elements in the list
Print list.Count()

' outputs:
' 3
' 0