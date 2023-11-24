SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' create an array out of the list elements
Local objects:Object[] = ListToArray(list) 

' enumerate all the strings in the array
For Local a:String = EachIn objects
	Print a
Next

' outputs:
' one
' two
' three
