Rem
Load and Play a small example wav file with looping.
End Rem

SuperStrict

Local sound:TSound = LoadSound("shoot.wav",True)
PlaySound sound

Input "Press any key to continue"
