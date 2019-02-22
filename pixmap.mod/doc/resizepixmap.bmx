SuperStrict

Graphics 640 , 480

Local pix:TPixmap=LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")

If pix = Null Then
	RuntimeError ("Error Loading Image")
End If

'Reduce Image by 50%
Local newPix:TPixmap=ResizePixmap(pix, Int(PixmapWidth(pix)*.5), Int(PixmapHeight(pix)*.5))

Repeat
	Cls
	DrawPixmap pix, 50, 50
	DrawPixmap newPix, MouseX() , MouseY()
	Flip
Until KeyHit(key_escape) Or AppTerminate()
