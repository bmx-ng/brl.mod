'AllocChannel.bmx

SuperStrict

Local timer:TTimer = CreateTimer(20)

Local sound:TSound = LoadSound ("shoot.wav")
Local channel:TChannel = AllocChannel()

For Local i:Int = 1 To 20
	WaitTimer timer
	PlaySound sound,channel
Next
