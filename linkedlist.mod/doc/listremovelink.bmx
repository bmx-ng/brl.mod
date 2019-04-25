SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the begin of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' find the TLink instance of the element/object "two" 
Local link:TLink = ListFindLink(list, "two")

' remove the element from the list by utilizing the link
ListRemoveLink(list, link)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' one
' three
