SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' copy the list elements into another one
Local list2:TList = list.Copy()

' enumerate all the strings in the first list
For Local a:String = EachIn list
	Print a
Next

' enumerate all the strings in the second list
For Local a:String = EachIn list2
	Print a
Next

' outputs:
' one
' two
' three
' one
' two
' three
