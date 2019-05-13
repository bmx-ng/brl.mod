SuperStrict

Framework brl.standardio
Import brl.vector

Local a:SVec2D = New SVec2D(10, 18)
Local b:SVec2D = New SVec2D(5, 6)

Local c:SVec2D = a / b

Print c.ToString() ' 2, 3
