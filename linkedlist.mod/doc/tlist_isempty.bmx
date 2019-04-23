SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' check if the list contains some elements
If list.IsEmpty()
	print "list is empty"
Else
	print "list contains elements"
EndIf


' outputs:
' list contains elements