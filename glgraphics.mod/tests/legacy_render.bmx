SuperStrict
Framework BRL.GLMax2D
Import BRL.StandardIO
Function Check(ok:Int,message:String)
 If Not ok Then Throw message
End Function
Try
 Graphics(320,240,0,0)
 SetBlend(SOLIDBLEND)
 SetClsColor(16,32,64);Cls
 Check((GrabPixmap(20,20,1,1).ReadPixel(0,0)&$ffffff)=$102040,"Clear readback")
 SetColor(0,255,0);DrawRect(10,10,16,16)
 Check((GrabPixmap(15,15,1,1).ReadPixel(0,0)&$ffffff)=$00ff00,"Primitive readback")
 Local pixmap:TPixmap=CreatePixmap(8,8,PF_RGBA8888)
 pixmap.ClearPixels($ffff0000)
 Local image:TImage=LoadImage(pixmap)
 SetColor(255,255,255);DrawImage(image,40,40)
 Check((GrabPixmap(43,43,1,1).ReadPixel(0,0)&$ffffff)=$ff0000,"Image readback")
 SetViewport(60,60,20,20)
 SetColor(0,0,255);DrawRect(50,50,50,50)
 Check((GrabPixmap(65,65,1,1).ReadPixel(0,0)&$ffffff)=$0000ff,"Viewport interior")
 Check((GrabPixmap(55,55,1,1).ReadPixel(0,0)&$ffffff)=$102040,"Viewport exterior")
 SetViewport(0,0,320,240)
 DrawPixmap(pixmap,100,100)
 Local grabbed:TPixmap=GrabPixmap(100,100,8,8)
 Check(grabbed.width=8 And grabbed.height=8,"Logical readback dimensions")
 Check((grabbed.ReadPixel(3,3)&$ffffff)=$ff0000,"DrawPixmap/readback round trip")
 Local target:TRenderImage=CreateRenderImage(16,16,0)
 SetRenderImage(target)
 SetViewport(0,0,16,16)
 SetClsColor(0,255,0);Cls
 Check((GrabPixmap(8,8,1,1).ReadPixel(0,0)&$ffffff)=$00ff00,"Render-image pixel coordinates")
 SetRenderImage(Null)
 SetViewport(0,0,320,240)
 SetColor(255,255,255);DrawImage(target,120,100)
 Check((GrabPixmap(125,105,1,1).ReadPixel(0,0)&$ffffff)=$00ff00,"Backbuffer coordinates after render image")
 Flip(0)
 EndGraphics()
 Print "BRL.GLMax2D legacy rendering passed"
Catch error:Object
 EndGraphics()
 Print "FAILED: "+error.ToString()
 EndWithCode(1)
End Try
