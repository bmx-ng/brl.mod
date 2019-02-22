' channelplaying.bmx

SuperStrict

Local sound:TSound = LoadSound ("shoot.wav")

Input "Hit return to begin channelplaying test, use ctrl-C to exit"

Local channel:TChannel = PlaySound (sound)
While True
	Print "ChannelPlaying(channel)="+ChannelPlaying(channel)
Wend
