SuperStrict

Framework brl.collections
Import brl.standardio

Local cities:TArrayList<String> = New TArrayList<String>

cities.Add("Shanghai")
cities.Add("Beijing")
cities.Add("Guangzhou")
cities.Add("Shenzhen")
cities.Add("Tianjin")
cities.Add("Wuhan")

Print "Cities (" + cities.Count() + ") :"
For Local city:String = EachIn cities
	Print city
Next

cities.Clear()

Print "~nCities (" + cities.Count() + ") :"
For Local city:String = EachIn cities
	Print city
Next
