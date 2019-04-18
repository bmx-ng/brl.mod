SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(0, 0)
Local b:SVec2D = New SVec2D(10, 5)

Local v:SVec2D = New SVec2D(11, -2)


Local c:SVec2D = v.Clamp(a, b)

Print c.ToString() ' 10, 0
