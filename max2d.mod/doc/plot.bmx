' plot.bmx

' plots a cosine graph
' scrolls along the graph using an incrementing frame variable 

SuperStrict

Graphics 640,480

Local frame:Int
While Not KeyHit(KEY_ESCAPE)
	Cls
	For Local x:Int = 0 To 640
		Local theta:Int = x + frame
		Local y:Int = 240-Cos(theta)*240
		Plot x,y
	Next
	frame=frame+1
	Flip
Wend
