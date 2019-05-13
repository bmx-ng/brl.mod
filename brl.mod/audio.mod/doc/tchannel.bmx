'TChannel controls the pipe thru which the sound plays
SuperStrict

Graphics 640 , 480

Local noise:TSound = TSound.Load(blitzmaxpath()+"\samples\hitoro\sounds\gameover.ogg",0)
Local channel:TChannel = PlaySound(noise)

Repeat
	Cls
	DrawText "Press P to play sound", 10, 10
	If channel.Playing() Then
		DrawText "You should hear something...",10,30
	End If
	If KeyHit(KEY_P) Then
		Channel=PlaySound(Noise)
	End If
	Flip
Until AppTerminate() Or KeyHit(KEY_ESCAPE)
