SuperStrict

Graphics 640,480
Local player:TPixmap=LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")

If player = Null Then
	RuntimeError ("Error Loading Image")
End If

Repeat
	Cls
	DrawPixmap Player,10,10
	Flip
Until KeyHit(key_escape) Or AppTerminate()
