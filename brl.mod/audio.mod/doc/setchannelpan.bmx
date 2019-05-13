' setchannelpan.bmx

SuperStrict

Graphics 640, 480

Local channel:TChannel = AllocChannel ()
Local sound:TSound = LoadSound ("shoot.wav") ' Use a short sample...

Repeat
	If MouseHit(1) Then
		PlaySound sound,channel
	End If
	
	Local pan# = MouseX () / (GraphicsWidth () / 2.0) - 1
	Local vol# = 1 - MouseY () / 480.0
	SetChannelPan channel, pan
	SetChannelVolume channel, vol*2

	Cls
	DrawText "Click to play...", 240, 200
	DrawText "Pan   : " + pan, 240, 220
	DrawText "Volume: " + vol, 240, 240

	Flip
Until KeyHit (KEY_ESCAPE)

End
