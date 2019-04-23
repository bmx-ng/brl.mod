SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' check if the list contains some elements
If ListContains(list, "four")
	print "four"
EndIf

If ListContains(list, "three")
	print "three"
EndIf


' outputs:
' three