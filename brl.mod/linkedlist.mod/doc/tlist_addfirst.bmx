SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = New TList

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
