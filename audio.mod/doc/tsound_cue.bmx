'Cue Method

SuperStrict

Graphics 640 , 480

Local sound:TSound = TSound.Load(blitzmaxpath()+"\samples\hitoro\sounds\gameover.ogg",0)
Local channel:TChannel = CueSound(sound)

Repeat
	DrawText "Press A to play sound",10,10
	DrawText "Press C to Cue sound",10,30
	
	If KeyHit(KEY_A) Then
		ResumeChannel channel
	End If
	
	If KeyHit(KEY_C) Then
		channel = sound.Cue()
	End If

	Flip
Until AppTerminate() Or KeyHit(KEY_ESCAPE)
