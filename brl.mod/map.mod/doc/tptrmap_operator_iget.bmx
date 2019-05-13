SuperStrict

Framework brl.standardio
Import brl.map

Local map:TPtrMap = New TPtrMap

map.Insert(Byte Ptr(1), "Hello")
map.Insert(Byte Ptr(2), "World")

For Local k:TPtrKey = EachIn map.Keys()
	Print Int(k.value) + " = " + String(map[k.value]) ' retrieve value using index operator
Next
