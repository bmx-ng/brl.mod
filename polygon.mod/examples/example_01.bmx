SuperStrict

Framework BRL.StandardIO
Import BRL.Polygon


Local points:SVec2I[] = [new SVec2I(1, 1), new SVec2I(10, 1), new SVec2I(10, 10), new SVec2I(1, 10)]

Local indices:Int[] = TriangulatePoly(points)

Print indices.length

For Local i:Int = 0 Until indices.length
	Print indices[i]
next
