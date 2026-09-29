SuperStrict
Framework BRL.GLMax2D
Import BRL.StandardIO
Graphics 320, 240
SetClsColor 20, 30, 40
Cls
SetColor 40, 120, 200
DrawRect 10, 10, 100, 100
Local captured:TPixmap = GrabPixmap(20, 20, 1, 1)
If Not captured Then RuntimeError "Legacy Max2D readback failed"
If (ReadPixel(captured, 0, 0) & $FFFFFF) <> $2878C8 Then RuntimeError "Legacy Max2D pixel mismatch"
EndGraphics
Print "Legacy BRL.GLMax2D pixel verified."
