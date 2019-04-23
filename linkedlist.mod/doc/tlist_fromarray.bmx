SuperStrict

' create an array holding some objects
Local objects:object[] = ["one", "two", "three"]

' create a linked list out of the elements
local list:TList = TList.FromArray(objects) 

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' one
' two
' three
