SuperStrict

Graphics 640,480

Local x:Int = 100
Local sync:Int = 0

While Not (KeyHit(KEY_ESCAPE) Or AppTerminate())
	Cls 
	DrawText "Sync=" + Sync , x , 100
	x :+ 1 
	If x > 300 Then
		x = 100
		sync :+ 1
		If sync >1 Then
			sync=-1
		End If
  End If
  Flip sync
Wend
