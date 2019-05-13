' createimage.bmx

' creates a 256x1 image with a black to blue color gradient

SuperStrict

Const ALPHABITS:Int=$ff000000

Graphics 640,480,0

Local image:TImage = CreateImage(256,1)
Local map:TPixmap = LockImage(image)
For Local i:Int = 0 To 255
	WritePixel(map,i,0,ALPHABITS|i)
Next
UnlockImage(image)

DrawImageRect image,0,0,640,480
DrawText "Blue Color Gradient",0,0

Flip

WaitKey