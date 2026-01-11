Rem
EndMethod marks the end of a BlitzMax Method declaration.
End Rem

SuperStrict

Framework BRL.StandardIO


Type TPoint
	Field x:Int,y:Int

	Method ToString:String()
		Return x+","+y
	End Method
End Type

Local p:TPoint = New TPoint
Print p.ToString()
