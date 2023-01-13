SuperStrict

Framework SDL.SDLRenderMax2D
'Framework brl.glmax2d
import brl.polygon
Import BRL.StandardIO

Local poly:Float[] = [100, 100, 200, 100, 200, 200, 100, 200]

Local indices:Int[] = TriangulatePoly(poly)

Print "count = " + indices.length

For Local i:Int = 0 Until indices.length
	Print indices[i]
next
Graphics 800, 600, 0

SetHandle( 150, 150 )
SetOrigin( 200, 200 )

Local angle:Float = 0
While Not keydown(KEY_ESCAPE)
	
		Cls

		DrawPoly(poly, indices)

		SetRotation( angle )
		angle :+ 0.5

		Flip
Wend
