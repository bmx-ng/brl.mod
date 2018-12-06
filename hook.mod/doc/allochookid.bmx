SuperStrict

Global myHookID:Int=AllocHookId()

' This function will be called everytime RunHook is executed due to the AddHook action below
Function MyHook:Object( id:Int,data:Object,context:Object )
	Global count:Int
	
	count:+1
	If count Mod 10=0 Then
		Print "Flips="+count
	End If
	
End Function

'Add the MyHook function to our hook ID
AddHook myHookID,MyHook

'Some simple graphics
Graphics 640,480,0

While Not KeyHit( KEY_ESCAPE )

   Cls
   DrawText MouseX()+","+MouseY(),0,0
   RunHooks myHookID, Null
   Flip

Wend
