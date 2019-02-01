SuperStrict

Framework brl.standardio
Import brl.map

Local map:TPtrMap = New TPtrMap

map[Byte Ptr(1)] = "Hello" ' insert value using index operator
map[Byte Ptr(2)] = "World"

For Local k:TPtrKey = EachIn map.Keys()
	Print Int(k.value) + " = " + String(map.ValueForKey(k.value))
Next
