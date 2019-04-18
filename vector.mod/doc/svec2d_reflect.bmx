SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(5, 0)
Local b:SVec2D = New SVec2D(0, 10)

Local c:SVec2D = a.Reflect(b)

Print c.ToString() ' -5, 0
