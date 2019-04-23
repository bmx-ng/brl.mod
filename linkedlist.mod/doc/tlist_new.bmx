SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the list
list.Addlast("one")
list.Addlast("two")
list.Addlast("three")

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next
