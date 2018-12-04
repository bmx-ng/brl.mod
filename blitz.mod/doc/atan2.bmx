Rem
ATan2 returns the Inverse Tangent of two variables
End Rem

SuperStrict

Function Angle:Double(x0:Double,y0:Double,x1:Double,y1:Double)
	Return ATan2(y1-y0,x1-x0)
End Function

Graphics 640,480
While Not KeyHit(KEY_ESCAPE)
	Cls
	Local x:Float = MouseX()
	Local y:Float = MouseY()
	DrawLine 320,240,x,y
	DrawText "Angle="+Angle(320,240,x,y),20,20
	Flip
Wend
