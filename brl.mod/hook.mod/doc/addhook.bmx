SuperStrict

'This function will be automagically called every Flip
Function MyHook:Object( id:Int,data:Object,context:Object )
	Global count:Int
	
	count:+1
	If count Mod 10=0 Then
		Print "Flips="+count
	End If
	
End Function

'Add our hook to the system
AddHook FlipHook,MyHook

'Some simple graphics
Graphics 640,480,0

While Not KeyHit( KEY_ESCAPE )

	Cls
	DrawText MouseX()+","+MouseY(),0,0
	Flip

Wend



