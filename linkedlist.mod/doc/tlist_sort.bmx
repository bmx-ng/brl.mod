SuperStrict

' create a list to hold some objects
Local list:TList = new TList

' add some string objects to the end of the list
list.AddLast("short")
list.AddLast("longer")
list.AddLast("the longest")


' DEFAULT SORT
' sort them (in this case this leads to an alphabetic sort)
' second parameter sets sort to ascending or not
list.Sort(True)

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
list.Sort(True, MyCompare)

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' short
' longer
' the longest
