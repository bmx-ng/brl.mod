' StopChannel example

SuperStrict

Local sound:TSound = LoadSound("shoot.wav",True)
Local channel:TChannel = PlaySound(sound)

Input "Press return key to stop sound"

StopChannel channel

Input "Press return key to quit"
