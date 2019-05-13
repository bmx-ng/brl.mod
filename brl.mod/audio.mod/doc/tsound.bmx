' TSound has three methods Play and Cue and a Load Function
SuperStrict

Graphics 640 , 480

Local Sound:TSound = TSound.Load(blitzmaxpath()+"\samples\hitoro\sounds\gameover.ogg",0)
Local Channel:TChannel = Sound.Cue() ' cue to a channel

Repeat
	DrawText "Press P to play, C to Cue and R to Resume sound",10,10
	
	If KeyHit(KEY_P) Then
		Sound.Play()
	End If
	
	If KeyHit(KEY_C) Then
		Channel=Sound.Cue()
	End If
	
	If KeyHit(KEY_R) Then
		ResumeChannel(Channel)
	End If
	
	Flip
Until AppTerminate() Or KeyHit(KEY_ESCAPE)
