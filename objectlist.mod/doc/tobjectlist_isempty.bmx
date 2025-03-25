SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an object list to hold some objects
Local list:TObjectList = New TObjectList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' check if the list contains some elements
If list.IsEmpty() Then
	Print "list is empty"
Else
	Print "list contains elements"
EndIf


' outputs:
' list contains elements