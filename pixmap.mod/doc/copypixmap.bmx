SuperStrict

Graphics 640 , 480

Local pix:TPixmap=LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")
If pix = Null Then
	RuntimeError ("Error Loading Image")
End If


Local newPix:TPixmap=CopyPixmap(pix)

Repeat
	Cls
	DrawPixmap pix, 50, 50
	DrawPixmap newPix, MouseX(), MouseY()
	Flip
Until KeyHit(key_escape) Or AppTerminate()
