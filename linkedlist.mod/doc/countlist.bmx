SuperStrict

' create a list to hold some objects
Local list:TList = CreateList()

' add some string objects to the end of the list
ListAddLast(list, "one")
ListAddLast(list, "two")
ListAddLast(list, "three")

' print amount of elements in the list
print CountList(list)

' outputs:
' 3