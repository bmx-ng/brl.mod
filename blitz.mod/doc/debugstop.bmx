'
' Run in debug mode
'
SuperStrict

Framework BRL.StandardIO


Graphics 640,480
Local a:Int

Repeat
	a = Rnd(20)
Until KeyDown(KEY_ESCAPE)
DebugStop
