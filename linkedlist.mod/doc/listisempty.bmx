SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' check if the list contains some elements
If ListIsEmpty(list)
	print "list is empty"
Else
	print "list contains elements"
EndIf


' outputs:
' list contains elements