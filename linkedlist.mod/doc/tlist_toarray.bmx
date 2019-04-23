SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' create an array out of the list elements
local objects:object[] = list.ToArray() 

' enumerate all the strings in the array
For Local a:String = EachIn objects
	Print a
Next

' outputs:
' one
' two
' three
