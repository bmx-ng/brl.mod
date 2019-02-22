SuperStrict

Framework brl.standardio
Import brl.map

Local map:TIntMap = New TIntMap

map[1] = "Hello" ' insert value using index operator
map[2] = "World"

For Local k:TIntKey = EachIn map.Keys()
	Print k.value + " = " + String(map.ValueForKey(k.value))
Next
