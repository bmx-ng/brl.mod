Rem
CueSound example
End Rem

SuperStrict

Local sound:TSound = LoadSound("shoot.wav")
Local channel:TChannel = CueSound(sound)

Input "Press return key to play cued sound"

ResumeChannel channel

Input "Press return key to quit"
