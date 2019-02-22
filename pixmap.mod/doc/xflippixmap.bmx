SuperStrict

Graphics 640,480

Local pix:TPixmap=LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")

If pix = Null Then
	RuntimeError ("Error Loading Image")
End If

Repeat
	Cls
	DrawText "Press Key X or Y to change Orientation" , 10 , 10
	
	' Change pixmap orientation
	If KeyHit(KEY_X) Then
		pix = XFlipPixmap(pix)
	End If
	
	If KeyHit(KEY_Y) Then
		pix = YFlipPixmap(pix)
	End If
	
	DrawPixmap pix,50,50
	Flip
Until KeyHit(key_escape) Or AppTerminate()
