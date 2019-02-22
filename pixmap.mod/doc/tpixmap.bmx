SuperStrict

'Prompt the user for an image file
Local path:String = RequestFile("Select an Image File","Image Files:png,jpg,bmp")

Local pix:TPixmap

'Load the file into a TPixmap according to its format
Select ExtractExt(path)
	Case "png"
		pix = LoadPixmapPNG(path)
	Case "jpg"
		pix = LoadPixmapJPeg(path)
	Default
		pix = LoadPixmap(path)
EndSelect

'Ensure the file loaded
If Not pix Then
	Notify "The File Could Not Load. The Program Will Now End."
	End
End If

'Setup the window
Graphics 600,600,0,60,2
Repeat
	Cls
	DrawPixmap Image , 20 , 20
	Flip
Until KeyDown(KEY_ESCAPE) Or AppTerminate()
