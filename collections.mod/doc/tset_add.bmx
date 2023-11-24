SuperStrict

Framework brl.collections
Import brl.standardio

Local cities:TSet<String> = New TSet<String>

AddCity(cities, "Shanghai")
AddCity(cities, "Beijing")
AddCity(cities, "Guangzhou")
AddCity(cities, "Shenzhen")
AddCity(cities, "Tianjin")
AddCity(cities, "Wuhan")

Print "~nCount : " + cities.Count()
Print

For Local city:String = EachIn cities
	Print city
Next

Print
' try to add duplicate
AddCity(cities, "Shanghai")

Print "~nCount : " + cities.Count()

Function AddCity(cities:TSet<String>, city:String)
	If cities.Add(city) Then
		Print "Added " + city
	Else
		Print city + " already exists."
	End If
End Function
