SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' create an array out of the list elements
Local objects:Object[] = list.ToArray() 

' enumerate all the strings in the array
For Local a:String = EachIn objects
	Print a
Next

' outputs:
' one
' two
' three
