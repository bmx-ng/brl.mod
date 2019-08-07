SuperStrict

Framework brl.standardio
Import brl.jconv

' a serialized object as json
Local txt:String = "{~qposition~q:{~qx~q:100,~qy~q:50},~qspeed~q:{~qx~q:50,~qy~q:75}}"

' create jconv instance
Local jconv:TJConv = New TJConvBuilder.Build()

' deserialize into a TPlayer object
Local player:TPlayer = TPlayer(jconv.FromJson(txt, "TPlayer"))

If player Then
	Print "Position = " + player.position.x + ", " + player.position.y
	Print "Speed    = " + player.speed.x + ", " + player.speed.y
End If

Type TPlayer
	Field position:TVec2
	Field speed:TVec2
End Type

Type TVec2
	Field x:Int
	Field y:Int
End Type
