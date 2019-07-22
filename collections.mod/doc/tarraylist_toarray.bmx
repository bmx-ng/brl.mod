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

Local array:String[] = cities.ToArray()

Print array.length

For Local city:String = EachIn array
	Print city
Next
