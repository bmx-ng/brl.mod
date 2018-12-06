SuperStrict

SetGraphicsDriver GLMax2DDriver()
Graphics 800,600

While Not KeyHit(KEY_ESCAPE)
	Cls
	If AppSuspended() = True
		DrawText "Application Suspended!",10,10
	Else
		DrawText "Application Running...",10,10
	EndIf
	Flip
Wend
