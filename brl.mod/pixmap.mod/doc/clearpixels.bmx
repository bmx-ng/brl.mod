SuperStrict

Graphics 800 , 600

Local mypix:TPixmap = LoadPixmap(BlitzMaxPath()+"/samples/hitoro/gfx/boing.png")
If mypix = Null Then
	RuntimeError ("Error Loading Image")
End If

DrawPixmap mypix, 0, 0

ClearPixels(mypix, $FFFFFF)
 

DrawPixmap mypix, 300, 0

Flip

WaitKey
