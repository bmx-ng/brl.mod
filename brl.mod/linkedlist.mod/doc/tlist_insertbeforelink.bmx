SuperStrict

Framework Brl.LinkedList
Import Brl.StandardIO

' create a list to hold some objects
Local list:TList = New TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' find the link we want to insert something before or after, here for "two"
Local link:TLink = list.FindLink("two")

'insert a new element before the link
list.InsertBeforeLink("before two", link)

'insert a new element after the link
list.InsertAfterLink("after two", link)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' one
' before two
' two
' after two
' three
