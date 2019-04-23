SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the begin of the list
ListAddFirst(list, "one")
ListAddFirst(list, "two")
ListAddFirst(list, "three")

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' three
' two
' one
