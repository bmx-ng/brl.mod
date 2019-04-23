SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "short")
ListAddLast(list, "longer")
ListAddLast(list, "the longest")


' DEFAULT SORT
' sort them (in this case this leads to an alphabetic sort)
' second parameter sets sort to ascending or not
SortList(list, True)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' longer
' short
' the longest


' CUSTOM SORT
' define a custom compare function
Function MyCompare:int( o1:Object, o2:Object )
	if len(string(o1)) < len(string(o2))
		return -1 ' o1 before o2
	elseif len(string(o1)) > len(string(o2))
		return 1 ' o1 after o2
	else
		return 0 ' equal
	endif
End Function

' sort them with a custom compare function
SortList(list, True, MyCompare)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' short
' longer
' the longest
