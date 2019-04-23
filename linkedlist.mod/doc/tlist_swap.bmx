SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the end of the list
list.AddLast("one")
list.AddLast("two")
list.AddLast("three")


' create a second list
Local list2:TList = new TList
list2.AddLast("four")
list2.AddLast("five")
list2.AddLast("six")


' swap the lists
list.Swap(list2)

' enumerate all the strings in the first list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' four
' five
' six
