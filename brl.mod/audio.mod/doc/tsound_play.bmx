' Play method example
SuperStrict

Graphics 640, 480

Local noise:TSound = TSound.Load(blitzmaxpath()+"\samples\hitoro\sounds\gameover.ogg",0)

Repeat
	DrawText "Press P to play sound",10,10
	
	If KeyHit(KEY_P) Then
		noise.Play
	End If
	
	Flip
Until AppTerminate() Or KeyHit(KEY_ESCAPE)
