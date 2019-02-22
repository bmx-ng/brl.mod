SuperStrict

Import MaxGUI.Drivers

Local G:TGraphics = Graphics(640,480) 'creates the normal graphic screen first
Local MyWindow:TGadget=CreateWindow("Canvas Example", 200,200,320,240)
Local MyCanvas:TGadget=CreateCanvas(10,10,290,140,MyWindow)

Repeat
	WaitEvent()
	Select EventID()
		Case EVENT_WINDOWCLOSE
			End
		Case EVENT_GADGETPAINT
			SetGraphics CanvasGraphics (MyCanvas)
			SetColor Int(Rnd(255)),Int(Rnd(255)),Int(Rnd(255))
			DrawRect 20 , 20 , 50 , 80
			Flip
			SetGraphics G
			SetColor Int(Rnd(255)),Int(Rnd(255)),Int(Rnd(255))
			DrawOval 100,100,100,100
			Flip
		Case EVENT_MOUSEMOVE
			RedrawGadget(MyCanvas)
	End Select

Until AppTerminate()
