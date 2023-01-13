SuperStrict

Framework Brl.ObjectList
Import Brl.StandardIO

' create an array holding some objects
Local objects:Object[] = ["one", "two", "three"]

' create a object list out of the elements
Local list:TObjectList = TObjectList.FromArray(objects) 

' enumerate all the strings in the list
For Local a:String = EachIn list
	Print a
Next

' outputs:
' one
' two
' three
