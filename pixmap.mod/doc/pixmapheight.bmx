SuperStrict

Graphics 640,480

Local pix:TPixmap = LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")

If pix = Null Then
	RuntimeError ("Error Loading Image")
End If

Repeat
	Cls
	
	' Display Information
	DrawText "Image Width:"+PixmapWidth(pix)+"  Image Height:"+PixmapHeight(pix),0,0 

	DrawPixmap pix,100,100
	Flip
Until KeyHit(key_escape) Or AppTerminate()
