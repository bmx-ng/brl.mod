SuperStrict

Graphics 640,480

Local x:Int,y:Int
Local mx:Int,my:Int

HideMouse
Repeat
	mx=MouseX()
	my=MouseY()
	
	Cls
	' draw grid
	SetColor 90,90,90
	For y=0 Until 480 Step 20
		For x=0 Until 640 Step 20
			Plot x,y
		Next
	Next
	
	'draw mouse mx,my
	SetColor 255,255,255
	DrawRect mx-1,my-1,3,3
	
	' draw ceiled and floored mouse mx,my
	SetColor 255,255,0
	DrawRect Float(Ceil( mx/20.0)*20-1),Float(Ceil(my/20.0)*20-1),3,3
	
	SetColor 0,255,255
	DrawRect Float(Floor(mx/20.0)*20-1),Float(Floor( my/20.0)*20-1),3,3
	
	Flip
	
Until KeyDown(KEY_ESCAPE)
