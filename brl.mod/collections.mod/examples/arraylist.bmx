SuperStrict

Framework brl.standardio
Import brl.collections

Local countries:String[] = LoadText("countries.txt").Split("~n")

Local list:IList<String> = New TArrayList<String>

' load the list

list.AddAll(countries)

Print "Sizes : " + countries.length + " (array) = " + list.Size() + " (arraylist)"

Print "Iceland is at position " + list.IndexOf("Iceland")

Print "Has 'Borisland' ?   = " + list.Contains("Borisland")
Print "Has 'New Zealand' ? = " + list.Contains("New Zealand")
