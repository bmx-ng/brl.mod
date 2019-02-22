SuperStrict

Graphics 640 , 480

Local pix:TPixmap=LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")
'converts Pixmap to Image
'note alpha transparency
Local image:TImage=LoadImage(pix)

Repeat
	Cls
	DrawPixmap pix, 50, 50
	DrawImage image, MouseX(), MouseY()
	Flip
Until KeyHit(key_escape) Or AppTerminate()
