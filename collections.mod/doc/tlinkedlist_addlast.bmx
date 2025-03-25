SuperStrict

Framework brl.collections
Import brl.standardio

Local cities:TLinkedList<String> = New TLinkedList<String>

cities.AddLast("Shanghai")
cities.AddLast("Beijing")
cities.AddLast("Guangzhou")
cities.AddLast("Shenzhen")
cities.AddLast("Tianjin")
cities.AddLast("Shanghai")
cities.AddLast("Wuhan")

For Local city:String = EachIn cities
	Print city
Next

Print "Count = " + cities.Count()
