'Animation on MaxGUI canvas
SuperStrict

Import MaxGUI.Drivers

Local MyWindow:TGadget=CreateWindow("Canvas Example", 200,200,320,240)
Local MyCanvas:TGadget=CreateCanvas(10,10,290,140,MyWindow)
Local timer:TTimer=CreateTimer(60)
Local x:Int=0

Repeat
  WaitEvent()
  Select EventID()
  Case EVENT_WINDOWCLOSE
     End
  Case EVENT_TIMERTICK
     x=x+1
     If x>240 x=0
     RedrawGadget(MyCanvas)
  Case EVENT_GADGETPAINT
    SetGraphics CanvasGraphics (MyCanvas)
    Cls
    DrawRect  x,20,50,80
    Flip
   End Select
Forever
