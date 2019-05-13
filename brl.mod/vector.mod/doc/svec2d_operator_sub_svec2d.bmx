SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(12, 2)
Local b:SVec2D = New SVec2D(4, 5)

Local c:SVec2D = a - b

Print c.ToString() ' 8, -3
