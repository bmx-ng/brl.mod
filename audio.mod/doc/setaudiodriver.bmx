SuperStrict

Repeat
	Print "Select Audio Driver:"
	Print "1) FreeAudio"
	Print "2) OpenAL"
	Print "3) DirectSound"

	Local n:Int
	Select Input( ">" )
		Case 1
			n = SetDriver( "FreeAudio" )
		Case 2
			n = SetDriver( "OpenAL" )
		Case 3
			n = SetDriver( "DirectSound" )
	End Select
	If n Exit
Forever

Function SetDriver:Int(d:String)
	If AudioDriverExists(d) Then
		Return SetAudioDriver(d)
	Else
		RuntimeError "Cannot set " + d
	EndIf
End Function
