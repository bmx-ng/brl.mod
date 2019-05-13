SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = New TList

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