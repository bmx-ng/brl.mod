SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")


' create a second list
Local list2:TList = CreateList()
ListAddLast(list2, "four")
ListAddLast(list2, "five")
ListAddLast(list2, "six")


' swap the lists
SwapLists(list, list2)

' enumerate all the strings in the first list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' four
' five
' six
