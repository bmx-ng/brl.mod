SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(12, 8)
Local b:SVec2D = New SVec2D(10, 16)


Local c:SVec2D = a.Max(b)

Print c.ToString() ' 12, 16
