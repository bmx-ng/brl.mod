SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' reverse the list
ReverseList(list)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' three
' two
' one
