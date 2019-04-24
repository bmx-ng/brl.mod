SuperStrict

' create a list to hold some objects
Local list:TList = New TList

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
Function MyCompare:Int( o1:Object, o2:Object )
	If Len(String(o1)) < Len(String(o2)) Then
		Return -1 ' o1 before o2
	ElseIf Len(String(o1)) > Len(String(o2)) Then
		Return 1 ' o1 after o2
	Else
		Return 0 ' equal
	EndIf
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
