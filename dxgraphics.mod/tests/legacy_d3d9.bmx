SuperStrict
Framework BRL.D3D9Max2D
Import BRL.StandardIO
Function Check(ok:Int,message:String)
 If Not ok Then Throw message
End Function
Try
 Local canvas:TGraphics=Graphics(320,240,0,0)
 Check(canvas<>Null,"Legacy window creation")
 Local pixmap:TPixmap=CreatePixmap(8,8,PF_RGBA8888)
 pixmap.ClearPixels($ffff0000)
 Local image:TImage=LoadImage(pixmap)
 For Local pass:Int=0 Until 3
  canvas.Resize(400+pass*40,300+pass*30)
  GraphicsPosition(80+pass*10,100+pass*10)
  ' Existing BRL.Max2D refreshes its rendering state when graphics is selected.
  SetGraphics(canvas)
  Local w:Int,h:Int,d:Int,hz:Int,f:Long,x:Int,y:Int
  TMax2DGraphics(canvas)._backendGraphics.GetSettings(w,h,d,hz,f,x,y)
  Check(w=400+pass*40 And h=300+pass*30,"Legacy resized settings")
  Check(x=80+pass*10 And y=100+pass*10,"Legacy position settings")
  SetViewport(0,0,w,h);SetClsColor(0,0,0);Cls
  SetBlend(SOLIDBLEND);SetColor(255,255,255);DrawImage(image,10,10)
  Check((GrabPixmap(11,11,1,1).ReadPixel(0,0)&$ffffff)=$ff0000,"Legacy image renders after resize")
  Flip(0)
 Next
 EndGraphics()
 Print "BRL.D3D9Max2D compatibility tests passed"
Catch error:Object
 EndGraphics()
 Print "FAILED: "+error.ToString()
 EndWithCode(1)
End Try
