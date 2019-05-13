SuperStrict

Framework brl.standardio
Import brl.map

Local map:TStringMap = New TStringMap

map["one"] = "Hello" ' insert value using index operator
map["two"] = "World"

For Local s:String = EachIn map.Keys()
	Print s + " = " + String(map.ValueForKey(s))
Next
