' PauseChannel Example

SuperStrict

Graphics 640 , 480

Local noise:TSound = TSound.Load(blitzmaxpath()+"\samples\hitoro\sounds\gameover.ogg",0)
Local channel:TChannel = PlaySound(noise)
Local elapsed:Int = MilliSecs()

Repeat
	Cls
	DrawText "Press P to play sound" , 10 , 10
	If (MilliSecs() - elapsed) > 500
		PauseChannel(channel) ' pause after 0.5 secs played
	End If
	
	If KeyHit(KEY_P) Then
		channel = PlaySound(noise)
		elapsed = MilliSecs() 
	End If
	Flip
Until AppTerminate() Or KeyHit(KEY_ESCAPE)
