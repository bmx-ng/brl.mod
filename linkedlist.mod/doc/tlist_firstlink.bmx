SuperStrict

' create a list to hold some objects
Local list:TList = New TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' find first link 
Local link:TLink = list.FirstLink()

' remove the element from the list by utilizing the link
list.RemoveLink(link)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' two
' three
