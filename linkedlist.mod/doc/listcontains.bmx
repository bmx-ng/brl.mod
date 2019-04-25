SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' check if the list contains some elements
If ListContains(list, "four") Then
	Print "four"
EndIf

If ListContains(list, "three") Then
	Print "three"
EndIf

' outputs:
' three