SuperStrict

' create a list to hold some objects
Local list:TList = New TList

' add some string objects to the begin of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")

' remove the string "two"
list.Remove("two")

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' one
' three
