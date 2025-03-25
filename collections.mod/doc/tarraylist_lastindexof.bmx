SuperStrict

Framework brl.collections
Import brl.standardio

Local cities:TArrayList<String> = New TArrayList<String>

cities.Add("Shanghai")
cities.Add("Beijing")
cities.Add("Guangzhou")
cities.Add("Shenzhen")
cities.Add("Tianjin")
cities.Add("Shanghai")
cities.Add("Wuhan")

For Local city:String = EachIn cities
	Print city
Next

Print "~nLastIndexOf(~qShanghai~q) : " + cities.LastIndexOf("Shanghai")
Print "~nLastIndexOf(~qShanghai~q, 3) : " + cities.LastIndexOf("Shanghai", 3)
Print "~nLastIndexOf(~qShanghai~q, 4, 4) : " + cities.LastIndexOf("Shanghai", 4, 4)
