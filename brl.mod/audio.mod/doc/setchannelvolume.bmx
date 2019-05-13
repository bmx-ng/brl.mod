' setchannelvolume.bmx

SuperStrict

Local timer:TTimer = CreateTimer(20)

Local sound:TSound = LoadSound ("shoot.wav")

For Local volume#=.1 To 2 Step .05
	WaitTimer timer
	Local channel:TChannel = CueSound(sound)
	SetChannelVolume channel,volume
	ResumeChannel channel
Next
