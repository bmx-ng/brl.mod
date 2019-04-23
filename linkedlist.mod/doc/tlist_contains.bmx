SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' check if the list contains some elements
If list.Contains("four")
	print "four"
EndIf

If list.Contains("three")
	print "three"
EndIf


' outputs:
' three