SuperStrict

Framework brl.standardio
Import brl.map

Local map:TStringMap = New TStringMap

map.Insert("one", "Hello")
map.Insert("two", "World")

For Local s:String = EachIn map.Keys()
	Print s + " = " + String(map[s]) ' retrieve value using index operator
Next
