'
' Run in debug mode
'
SuperStrict

Graphics 640,480
Local a:Int

Repeat
	a = Rnd(20)
Until KeyDown(KEY_ESCAPE)
DebugStop
