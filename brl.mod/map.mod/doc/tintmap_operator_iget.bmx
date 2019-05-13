SuperStrict

Framework brl.standardio
Import brl.map

Local map:TIntMap = New TIntMap

map.Insert(1, "Hello")
map.Insert(2, "World")

For Local k:TIntKey = EachIn map.Keys()
	Print k.value + " = " + String(map[k.value]) ' retrieve value using index operator
Next
