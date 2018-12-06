'atan2 is a two-argument function that computes the arctangent of y / x 
'given y And x, but with a range of ( - p,p].

SuperStrict

Graphics 640 , 480
Local x:Float
Local y:Float
Repeat
	
	Cls
	x = MouseX()
	y = MouseY()
	DrawLine 320, 240, x, y
	DrawText "Angle to mouse cursor=" + ATan2(y-240,x-320),10,10
	Flip
	
Until KeyDown(KEY_ESCAPE) Or AppTerminate()
