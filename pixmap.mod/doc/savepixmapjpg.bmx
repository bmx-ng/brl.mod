SuperStrict

Graphics 640,480

Local pix:TPixmap = LoadPixmap(blitzmaxpath()+"\samples\hitoro\gfx\boing.png")

If pix = Null Then
	RuntimeError ("Error Loading Image")
End If

Repeat
	Cls
	DrawText "Press S to save Image to Disk",10,10
	
	' Save pixmap
	If KeyHit(KEY_S)
		'Prompt the user for a path to save to
		Local path:String = RequestFile("Save As","PNG:png;JPG:jpg",True)
		
		' Save the TPixmap into a file according to its format
		Select ExtractExt(path)
			Case "png"
				SavePixmapPNG(pix, path)
			Case "jpg"
				SavePixmapJPeg(pix, path)
		End Select					
   End If

	DrawPixmap pix,100,100
	Flip
Until KeyHit(key_escape) Or AppTerminate()
