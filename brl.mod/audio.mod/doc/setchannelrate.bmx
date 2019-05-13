' setchannelrate.bmx

SuperStrict

Local timer:TTimer = CreateTimer(20)

Local sound:TSound = LoadSound ("shoot.wav",True)
Local channel:TChannel = CueSound(sound)
ResumeChannel channel

For Local rate#=1.0 To 4 Step 0.01
	WaitTimer timer
	SetChannelRate channel,rate
Next
